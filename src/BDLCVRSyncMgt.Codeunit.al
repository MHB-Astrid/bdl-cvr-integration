codeunit 50201 "BDL CVR Sync Mgt"
{
    procedure FetchAndUpdateCustomer(var Customer: Record Customer)
    var
        CVRAPIClient: Codeunit "BDL CVR API Client";
        CVRCompany: Record "BDL CVR Company";
        VrvirksomhedJson: JsonObject;
    begin
        if Customer."CVR Nr." = '' then
            Error('Angiv et CVR-nr. på kunden først.');

        if not CVRAPIClient.SearchByCVR(Customer."CVR Nr.", VrvirksomhedJson) then
            Error('Kunne ikke hente data for CVR-nr. %1. Tjek CVR-nummeret og prøv igen.', Customer."CVR Nr.");

        if not CVRCompany.Get(Customer."CVR Nr.") then begin
            CVRCompany.Init();
            CVRCompany."CVR Nr." := Customer."CVR Nr.";
            ParseCVRResponse(VrvirksomhedJson, CVRCompany, Customer."CVR Nr.");
            CVRCompany."Last Synced" := CurrentDateTime;
            CVRCompany.Insert(true);
        end else begin
            ParseCVRResponse(VrvirksomhedJson, CVRCompany, Customer."CVR Nr.");
            CVRCompany."Last Synced" := CurrentDateTime;
            CVRCompany.Modify(true);
        end;

        Customer.Validate(Name, CVRCompany.Name);
        Customer.Validate(Address, CVRCompany.Address);
        Customer.Validate("Post Code", CVRCompany."Post Code");
        Customer.Validate(City, CVRCompany.City);
        Customer.Validate("CVR Status", CVRCompany.Status);
        Customer."CVR Last Synced" := CurrentDateTime;
        Customer.Modify(true);

        Message('CVR-data hentet for %1 (%2). Status: %3',
            CVRCompany.Name, Customer."CVR Nr.", CVRCompany.Status);
    end;

    local procedure ParseCVRResponse(VrvirksomhedJson: JsonObject; var CVRCompany: Record "BDL CVR Company"; CVRNumber: Code[8])
    var
        MetadataJson: JsonObject;
        AddressJson: JsonObject;
        IndustryJson: JsonObject;
        CompanyFormJson: JsonObject;
        KommuneJson: JsonObject;
        StatusText: Text;
    begin
        CVRCompany."CVR Nr." := CVRNumber;

        // Company name from metadata
        if GetNestedObject(VrvirksomhedJson, 'virksomhedMetadata', MetadataJson) then begin
            CVRCompany.Name := CopyStr(GetNestedText(MetadataJson, 'nyesteNavn', 'navn'), 1, MaxStrLen(CVRCompany.Name));

            // Status
            StatusText := GetJsonText(MetadataJson, 'sammensatStatus');
            CVRCompany.Status := MapStatusToEnum(StatusText);

            // Address
            if GetNestedObject(MetadataJson, 'nyesteBeliggenhedsadresse', AddressJson) then begin
                CVRCompany.Address := CopyStr(BuildAddress(AddressJson), 1, MaxStrLen(CVRCompany.Address));
                CVRCompany."Post Code" := CopyStr(GetJsonText(AddressJson, 'postnummer'), 1, MaxStrLen(CVRCompany."Post Code"));
                CVRCompany.City := CopyStr(GetJsonText(AddressJson, 'postdistrikt'), 1, MaxStrLen(CVRCompany.City));
                CVRCompany."Country Code" := CopyStr(GetJsonText(AddressJson, 'landekode'), 1, MaxStrLen(CVRCompany."Country Code"));

                if GetNestedObject(AddressJson, 'kommune', KommuneJson) then begin
                    CVRCompany."Municipality Code" := CopyStr(GetJsonText(KommuneJson, 'kommuneKode'), 1, MaxStrLen(CVRCompany."Municipality Code"));
                    CVRCompany."Municipality Name" := CopyStr(GetJsonText(KommuneJson, 'kommuneNavn'), 1, MaxStrLen(CVRCompany."Municipality Name"));
                end;
            end;

            // Industry
            if GetNestedObject(MetadataJson, 'nyesteHovedbranche', IndustryJson) then begin
                CVRCompany."Industry Code" := CopyStr(GetJsonText(IndustryJson, 'branchekode'), 1, MaxStrLen(CVRCompany."Industry Code"));
                CVRCompany."Industry Description" := CopyStr(GetJsonText(IndustryJson, 'branchetekst'), 1, MaxStrLen(CVRCompany."Industry Description"));
            end;
        end;

        // Company form
        if GetNestedObject(VrvirksomhedJson, 'virksomhedsform', CompanyFormJson) then begin
            CVRCompany."Company Form Code" := CopyStr(
                GetJsonText(CompanyFormJson, 'virksomhedsformkode'), 1, MaxStrLen(CVRCompany."Company Form Code"));
            CVRCompany."Company Form" := CopyStr(
                GetJsonText(CompanyFormJson, 'kortBeskrivelse'), 1, MaxStrLen(CVRCompany."Company Form"));
        end;

        // Founded date
        CVRCompany."Founded Date" := ParseDate(GetJsonText(VrvirksomhedJson, 'stiftelsesDato'));

        // Sub-table history
        ParseAddressHistory(VrvirksomhedJson, CVRNumber);
        ParseNameHistory(VrvirksomhedJson, CVRNumber);
        ParseIndustryHistory(VrvirksomhedJson, CVRNumber);
        ParseParticipants(VrvirksomhedJson, CVRNumber);
        ParseEmployment(VrvirksomhedJson, CVRNumber);
        ParseStatusHistory(VrvirksomhedJson, CVRNumber);
    end;

    local procedure ParseAddressHistory(VrvirksomhedJson: JsonObject; CVRNumber: Code[8])
    var
        AddressArray: JsonArray;
        AddressToken: JsonToken;
        AddressEntryJson: JsonObject;
        AddressJson: JsonObject;
        PeriodJson: JsonObject;
        AddressHistory: Record "BDL CVR Address History";
        ValidFrom: Date;
        i: Integer;
    begin
        if not GetJsonArray(VrvirksomhedJson, 'beliggenhedsadresse', AddressArray) then
            exit;

        for i := 0 to AddressArray.Count() - 1 do begin
            AddressArray.Get(i, AddressToken);
            AddressEntryJson := AddressToken.AsObject();

            ValidFrom := 0D;
            if GetNestedObject(AddressEntryJson, 'periode', PeriodJson) then
                ValidFrom := ParseDate(GetJsonText(PeriodJson, 'gyldigFra'));

            // Skip duplicates: same CVR + Valid From
            AddressHistory.SetRange("CVR Nr.", CVRNumber);
            AddressHistory.SetRange("Valid From", ValidFrom);
            if not AddressHistory.FindFirst() then begin
                AddressHistory.Init();
                AddressHistory."Entry No." := 0;
                AddressHistory."CVR Nr." := CVRNumber;
                AddressHistory.Address := CopyStr(BuildAddress(AddressEntryJson), 1, MaxStrLen(AddressHistory.Address));
                AddressHistory."Post Code" := CopyStr(GetJsonText(AddressEntryJson, 'postnummer'), 1, MaxStrLen(AddressHistory."Post Code"));
                AddressHistory.City := CopyStr(GetJsonText(AddressEntryJson, 'postdistrikt'), 1, MaxStrLen(AddressHistory.City));
                AddressHistory."Valid From" := ValidFrom;
                if GetNestedObject(AddressEntryJson, 'periode', PeriodJson) then
                    AddressHistory."Valid To" := ParseDate(GetJsonText(PeriodJson, 'gyldigTil'));
                AddressHistory."Fetched DateTime" := CurrentDateTime;
                AddressHistory.Insert(true);
            end;
        end;
    end;

    local procedure ParseNameHistory(VrvirksomhedJson: JsonObject; CVRNumber: Code[8])
    begin
        ParseNameArray(VrvirksomhedJson, 'navne', CVRNumber, 0); // 0 = Name
        ParseNameArray(VrvirksomhedJson, 'binavne', CVRNumber, 1); // 1 = SecondaryName
    end;

    local procedure ParseNameArray(VrvirksomhedJson: JsonObject; ArrayName: Text; CVRNumber: Code[8]; NameType: Option)
    var
        NamesArray: JsonArray;
        NameToken: JsonToken;
        NameJson: JsonObject;
        PeriodJson: JsonObject;
        NameHistory: Record "BDL CVR Name History";
        NameText: Text;
        ValidFrom: Date;
        i: Integer;
    begin
        if not GetJsonArray(VrvirksomhedJson, ArrayName, NamesArray) then
            exit;

        for i := 0 to NamesArray.Count() - 1 do begin
            NamesArray.Get(i, NameToken);
            NameJson := NameToken.AsObject();

            NameText := GetJsonText(NameJson, 'navn');
            if NameText = '' then
                NameText := GetJsonText(NameJson, 'name');

            ValidFrom := 0D;
            if GetNestedObject(NameJson, 'periode', PeriodJson) then
                ValidFrom := ParseDate(GetJsonText(PeriodJson, 'gyldigFra'));

            // Dedup: CVR + Name Type + Valid From
            NameHistory.SetRange("CVR Nr.", CVRNumber);
            NameHistory.SetRange("Name Type", NameType);
            NameHistory.SetRange("Valid From", ValidFrom);
            if not NameHistory.FindFirst() then begin
                NameHistory.Init();
                NameHistory."Entry No." := 0;
                NameHistory."CVR Nr." := CVRNumber;
                NameHistory.Name := CopyStr(NameText, 1, MaxStrLen(NameHistory.Name));
                NameHistory."Name Type" := NameType;
                NameHistory."Valid From" := ValidFrom;
                if GetNestedObject(NameJson, 'periode', PeriodJson) then
                    NameHistory."Valid To" := ParseDate(GetJsonText(PeriodJson, 'gyldigTil'));
                NameHistory."Fetched DateTime" := CurrentDateTime;
                NameHistory.Insert(true);
            end;
        end;
    end;

    local procedure ParseIndustryHistory(VrvirksomhedJson: JsonObject; CVRNumber: Code[8])
    var
        IndustryArray: JsonArray;
        IndustryToken: JsonToken;
        IndustryJson: JsonObject;
        PeriodJson: JsonObject;
        IndustryHistory: Record "BDL CVR Industry History";
        ValidFrom: Date;
        i: Integer;
    begin
        if not GetJsonArray(VrvirksomhedJson, 'hovedbranche', IndustryArray) then
            exit;

        for i := 0 to IndustryArray.Count() - 1 do begin
            IndustryArray.Get(i, IndustryToken);
            IndustryJson := IndustryToken.AsObject();

            ValidFrom := 0D;
            if GetNestedObject(IndustryJson, 'periode', PeriodJson) then
                ValidFrom := ParseDate(GetJsonText(PeriodJson, 'gyldigFra'));

            // Dedup: CVR + Valid From
            IndustryHistory.SetRange("CVR Nr.", CVRNumber);
            IndustryHistory.SetRange("Valid From", ValidFrom);
            if not IndustryHistory.FindFirst() then begin
                IndustryHistory.Init();
                IndustryHistory."Entry No." := 0;
                IndustryHistory."CVR Nr." := CVRNumber;
                IndustryHistory."Industry Code" := CopyStr(GetJsonText(IndustryJson, 'branchekode'), 1, MaxStrLen(IndustryHistory."Industry Code"));
                IndustryHistory."Industry Description" := CopyStr(GetJsonText(IndustryJson, 'branchetekst'), 1, MaxStrLen(IndustryHistory."Industry Description"));
                IndustryHistory."Valid From" := ValidFrom;
                if GetNestedObject(IndustryJson, 'periode', PeriodJson) then
                    IndustryHistory."Valid To" := ParseDate(GetJsonText(PeriodJson, 'gyldigTil'));
                IndustryHistory."Fetched DateTime" := CurrentDateTime;
                IndustryHistory.Insert(true);
            end;
        end;
    end;

    local procedure ParseParticipants(VrvirksomhedJson: JsonObject; CVRNumber: Code[8])
    var
        RelationArray: JsonArray;
        RelationToken: JsonToken;
        RelationJson: JsonObject;
        DeltagerJson: JsonObject;
        NamesArray: JsonArray;
        NameToken: JsonToken;
        AddressArray: JsonArray;
        AddressToken: JsonToken;
        AddressJson: JsonObject;
        Participant: Record "BDL CVR Participant";
        UnitNumber: BigInteger;
        UnitNumberText: Text;
        i: Integer;
    begin
        if not GetJsonArray(VrvirksomhedJson, 'deltagerRelation', RelationArray) then
            exit;

        for i := 0 to RelationArray.Count() - 1 do begin
            RelationArray.Get(i, RelationToken);
            RelationJson := RelationToken.AsObject();

            if not GetNestedObject(RelationJson, 'deltager', DeltagerJson) then
                exit;

            UnitNumberText := GetJsonText(DeltagerJson, 'enhedsNummer');
            if not Evaluate(UnitNumber, UnitNumberText) then
                UnitNumber := 0;

            // Dedup: CVR + Unit Number
            Participant.SetRange("CVR Nr.", CVRNumber);
            Participant.SetRange("Unit Number", UnitNumber);
            if not Participant.FindFirst() then begin
                Participant.Init();
                Participant."Entry No." := 0;
                Participant."CVR Nr." := CVRNumber;
                Participant."Unit Number" := UnitNumber;
                Participant."Unit Type" := CopyStr(GetJsonText(DeltagerJson, 'enhedstype'), 1, MaxStrLen(Participant."Unit Type"));

                // Name from deltager.navne[0].navn
                if GetJsonArray(DeltagerJson, 'navne', NamesArray) then
                    if NamesArray.Count() > 0 then begin
                        NamesArray.Get(0, NameToken);
                        Participant.Name := CopyStr(GetJsonText(NameToken.AsObject(), 'navn'), 1, MaxStrLen(Participant.Name));
                    end;

                // Address from deltager.beliggenhedsadresse[0]
                if GetJsonArray(DeltagerJson, 'beliggenhedsadresse', AddressArray) then
                    if AddressArray.Count() > 0 then begin
                        AddressArray.Get(0, AddressToken);
                        AddressJson := AddressToken.AsObject();
                        Participant.Address := CopyStr(BuildAddress(AddressJson), 1, MaxStrLen(Participant.Address));
                        Participant."Post Code" := CopyStr(GetJsonText(AddressJson, 'postnummer'), 1, MaxStrLen(Participant."Post Code"));
                        Participant.City := CopyStr(GetJsonText(AddressJson, 'postdistrikt'), 1, MaxStrLen(Participant.City));
                    end;

                Participant."Fetched DateTime" := CurrentDateTime;
                Participant.Insert(true);
            end;
        end;
    end;

    local procedure ParseEmployment(VrvirksomhedJson: JsonObject; CVRNumber: Code[8])
    var
        EmpArray: JsonArray;
        EmpToken: JsonToken;
        EmpJson: JsonObject;
        Employment: Record "BDL CVR Employment";
        YearText: Text;
        YearInt: Integer;
        DecimalValue: Decimal;
        IntValue: Integer;
        i: Integer;
    begin
        if not GetJsonArray(VrvirksomhedJson, 'aarsbeskaeftigelse', EmpArray) then
            exit;

        for i := 0 to EmpArray.Count() - 1 do begin
            EmpArray.Get(i, EmpToken);
            EmpJson := EmpToken.AsObject();

            YearText := GetJsonText(EmpJson, 'aar');
            if not Evaluate(YearInt, YearText) then
                YearInt := 0;

            // Dedup: CVR + Year
            Employment.SetRange("CVR Nr.", CVRNumber);
            Employment.SetRange(Year, YearInt);
            if not Employment.FindFirst() then begin
                Employment.Init();
                Employment."Entry No." := 0;
                Employment."CVR Nr." := CVRNumber;
                Employment.Year := YearInt;

                if Evaluate(IntValue, GetJsonText(EmpJson, 'antalAnsatte')) then
                    Employment.Employees := IntValue;
                if Evaluate(IntValue, GetJsonText(EmpJson, 'antalInklusivEjere')) then
                    Employment."Employees Incl. Owners" := IntValue;
                if Evaluate(DecimalValue, GetJsonText(EmpJson, 'antalAarsvaerk')) then
                    Employment.FTE := DecimalValue;

                Employment."Interval Employees" := CopyStr(GetJsonText(EmpJson, 'intervalKodeAntalAnsatte'), 1, MaxStrLen(Employment."Interval Employees"));
                Employment."Interval FTE" := CopyStr(GetJsonText(EmpJson, 'intervalKodeAntalAarsvaerk'), 1, MaxStrLen(Employment."Interval FTE"));
                Employment."Interval Incl. Owners" := CopyStr(GetJsonText(EmpJson, 'intervalKodeAntalInklusivEjere'), 1, MaxStrLen(Employment."Interval Incl. Owners"));

                Employment."Fetched DateTime" := CurrentDateTime;
                Employment.Insert(true);
            end;
        end;
    end;

    local procedure ParseStatusHistory(VrvirksomhedJson: JsonObject; CVRNumber: Code[8])
    var
        StatusArray: JsonArray;
        StatusToken: JsonToken;
        StatusJson: JsonObject;
        PeriodJson: JsonObject;
        StatusHistory: Record "BDL CVR Status History";
        ValidFrom: Date;
        i: Integer;
    begin
        // virksomhedsstatus[]
        if GetJsonArray(VrvirksomhedJson, 'virksomhedsstatus', StatusArray) then
            for i := 0 to StatusArray.Count() - 1 do begin
                StatusArray.Get(i, StatusToken);
                StatusJson := StatusToken.AsObject();

                ValidFrom := 0D;
                if GetNestedObject(StatusJson, 'periode', PeriodJson) then
                    ValidFrom := ParseDate(GetJsonText(PeriodJson, 'gyldigFra'));

                StatusHistory.SetRange("CVR Nr.", CVRNumber);
                StatusHistory.SetRange("Entry Type", StatusHistory."Entry Type"::Status);
                StatusHistory.SetRange("Valid From", ValidFrom);
                if not StatusHistory.FindFirst() then begin
                    StatusHistory.Init();
                    StatusHistory."Entry No." := 0;
                    StatusHistory."CVR Nr." := CVRNumber;
                    StatusHistory."Entry Type" := StatusHistory."Entry Type"::Status;
                    StatusHistory.Status := CopyStr(GetJsonText(StatusJson, 'status'), 1, MaxStrLen(StatusHistory.Status));
                    StatusHistory."Valid From" := ValidFrom;
                    if GetNestedObject(StatusJson, 'periode', PeriodJson) then
                        StatusHistory."Valid To" := ParseDate(GetJsonText(PeriodJson, 'gyldigTil'));
                    StatusHistory."Fetched DateTime" := CurrentDateTime;
                    StatusHistory.Insert(true);
                end;
            end;

        // livsforloeb[]
        if GetJsonArray(VrvirksomhedJson, 'livsforloeb', StatusArray) then
            for i := 0 to StatusArray.Count() - 1 do begin
                StatusArray.Get(i, StatusToken);
                StatusJson := StatusToken.AsObject();

                ValidFrom := 0D;
                if GetNestedObject(StatusJson, 'periode', PeriodJson) then
                    ValidFrom := ParseDate(GetJsonText(PeriodJson, 'gyldigFra'));

                StatusHistory.SetRange("CVR Nr.", CVRNumber);
                StatusHistory.SetRange("Entry Type", StatusHistory."Entry Type"::Lifecycle);
                StatusHistory.SetRange("Valid From", ValidFrom);
                if not StatusHistory.FindFirst() then begin
                    StatusHistory.Init();
                    StatusHistory."Entry No." := 0;
                    StatusHistory."CVR Nr." := CVRNumber;
                    StatusHistory."Entry Type" := StatusHistory."Entry Type"::Lifecycle;
                    StatusHistory.Status := 'AKTIV';
                    StatusHistory."Valid From" := ValidFrom;
                    if GetNestedObject(StatusJson, 'periode', PeriodJson) then
                        StatusHistory."Valid To" := ParseDate(GetJsonText(PeriodJson, 'gyldigTil'));
                    StatusHistory."Fetched DateTime" := CurrentDateTime;
                    StatusHistory.Insert(true);
                end;
            end;
    end;

    local procedure MapStatusToEnum(StatusText: Text): Enum "BDL CVR Status"
    begin
        case UpperCase(StatusText) of
            'NORMAL':
                exit("BDL CVR Status"::Active);
            'OPHØRT', 'OPHOERT':
                exit("BDL CVR Status"::Ceased);
            'KONKURS', 'UNDER KONKURS':
                exit("BDL CVR Status"::UnderBankruptcy);
            'OPLØST', 'OPLOEST':
                exit("BDL CVR Status"::Dissolved);
            else
                exit("BDL CVR Status"::Unknown);
        end;
    end;

    local procedure BuildAddress(AddressJson: JsonObject): Text
    var
        Street: Text;
        HouseNr: Text;
        HouseLetter: Text;
        Floor: Text;
        Door: Text;
        Result: Text;
    begin
        Street := GetJsonText(AddressJson, 'vejnavn');
        HouseNr := GetJsonText(AddressJson, 'husnummerFra');
        HouseLetter := GetJsonText(AddressJson, 'bogstavFra');
        Floor := GetJsonText(AddressJson, 'etage');
        Door := GetJsonText(AddressJson, 'doer');

        Result := Street;
        if HouseNr <> '' then
            Result += ' ' + HouseNr;
        if HouseLetter <> '' then
            Result += HouseLetter;
        if Floor <> '' then
            Result += ', ' + Floor + '.';
        if Door <> '' then
            Result += ' ' + Door;

        exit(Result);
    end;

    local procedure ParseDate(DateText: Text): Date
    var
        Year: Integer;
        Month: Integer;
        Day: Integer;
    begin
        // Expected format: yyyy-MM-dd
        if StrLen(DateText) < 10 then
            exit(0D);

        if not Evaluate(Year, CopyStr(DateText, 1, 4)) then
            exit(0D);
        if not Evaluate(Month, CopyStr(DateText, 6, 2)) then
            exit(0D);
        if not Evaluate(Day, CopyStr(DateText, 9, 2)) then
            exit(0D);

        exit(DMY2Date(Day, Month, Year));
    end;

    local procedure GetJsonText(JsonObj: JsonObject; PropertyName: Text): Text
    var
        Token: JsonToken;
    begin
        if not JsonObj.Get(PropertyName, Token) then
            exit('');
        if Token.IsValue() then
            if not Token.AsValue().IsNull() then
                exit(Token.AsValue().AsText());
        exit('');
    end;

    local procedure GetNestedObject(ParentObj: JsonObject; PropertyName: Text; var Result: JsonObject): Boolean
    var
        Token: JsonToken;
    begin
        if not ParentObj.Get(PropertyName, Token) then
            exit(false);
        if not Token.IsObject() then
            exit(false);
        Result := Token.AsObject();
        exit(true);
    end;

    local procedure GetJsonArray(ParentObj: JsonObject; PropertyName: Text; var Result: JsonArray): Boolean
    var
        Token: JsonToken;
    begin
        if not ParentObj.Get(PropertyName, Token) then
            exit(false);
        if not Token.IsArray() then
            exit(false);
        Result := Token.AsArray();
        exit(true);
    end;

    local procedure GetNestedText(ParentObj: JsonObject; ObjectName: Text; PropertyName: Text): Text
    var
        NestedObj: JsonObject;
    begin
        if not GetNestedObject(ParentObj, ObjectName, NestedObj) then
            exit('');
        exit(GetJsonText(NestedObj, PropertyName));
    end;
}
