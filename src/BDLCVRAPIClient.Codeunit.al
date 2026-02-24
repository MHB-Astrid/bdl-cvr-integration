codeunit 50200 "BDL CVR API Client"
{
    var
        BaseUrl: Text;
        IsInitialized: Boolean;
        Username: SecretText;
        Password: SecretText;
        MaxRetryAttempts: Integer;

    procedure Initialize()
    var
        UsernameText: Text;
        PasswordText: SecretText;
    begin
        if IsInitialized then
            exit;

        BaseUrl := 'http://distribution.virk.dk/cvr-permanent/virksomhed/_search';
        MaxRetryAttempts := 5;

        if not IsolatedStorage.Contains('CVRApiUsername', DataScope::Company) then
            Error('CVR API credentials er ikke konfigureret.\Brug "Opsæt CVR Credentials" fra Customer Card først.');

        IsolatedStorage.Get('CVRApiUsername', DataScope::Company, UsernameText);
        IsolatedStorage.Get('CVRApiPassword', DataScope::Company, PasswordText);
        Username := UsernameText;
        Password := PasswordText;

        IsInitialized := true;
    end;

    procedure SetCredentials(NewUsername: Text; NewPassword: SecretText)
    begin
        if NewUsername = '' then
            Error('Brugernavn må ikke være tomt.');

        IsolatedStorage.Set('CVRApiUsername', NewUsername, DataScope::Company);
        IsolatedStorage.Set('CVRApiPassword', NewPassword, DataScope::Company);

        IsInitialized := false;
        Message('CVR API credentials gemt.');
    end;

    procedure HasCredentials(): Boolean
    begin
        exit(IsolatedStorage.Contains('CVRApiUsername', DataScope::Company));
    end;

    procedure SearchByCVR(CVRNumber: Code[20]; var ResultJson: JsonObject): Boolean
    var
        RequestBody: Text;
        ResponseText: Text;
        ResponseJson: JsonObject;
        HitsJson: JsonObject;
        HitsArray: JsonArray;
        HitToken: JsonToken;
        SourceToken: JsonToken;
        TotalHits: Integer;
    begin
        Initialize();

        if CVRNumber = '' then
            Error('CVR-nummer må ikke være tomt.');

        if CopyStr(CVRNumber, 1, 2) = 'GD' then
            Error('GD-numre (Grønlands Erhvervsregister) kan ikke slås op direkte.\Brug det 8-cifrede CVR-nummer i stedet.\Nukissiorfiit er f.eks. CVR 18440202, ikke GD100150.');

        RequestBody := StrSubstNo(
            '{"size":1,"query":{"term":{"Vrvirksomhed.cvrNummer":"%1"}}}',
            CVRNumber);

        if not SendRequest(RequestBody, ResponseText) then
            exit(false);

        if not ResponseJson.ReadFrom(ResponseText) then begin
            LogError('Ugyldig JSON-response fra CVR API');
            exit(false);
        end;

        if not GetJsonObject(ResponseJson, 'hits', HitsJson) then begin
            LogError('Manglende hits-objekt i CVR-response');
            exit(false);
        end;

        TotalHits := GetJsonInt(HitsJson, 'total');
        if TotalHits = 0 then begin
            LogError(StrSubstNo('CVR-nummer %1 ikke fundet', CVRNumber));
            exit(false);
        end;

        if not GetJsonArray(HitsJson, 'hits', HitsArray) then
            exit(false);

        HitsArray.Get(0, HitToken);
        if not HitToken.AsObject().Get('_source', SourceToken) then
            exit(false);

        if not SourceToken.AsObject().Get('Vrvirksomhed', HitToken) then
            exit(false);

        ResultJson := HitToken.AsObject();
        exit(true);
    end;

    procedure SearchByName(CompanyName: Text; var ResultArray: JsonArray): Boolean
    var
        RequestBody: Text;
        ResponseText: Text;
        ResponseJson: JsonObject;
        HitsJson: JsonObject;
    begin
        Initialize();

        if CompanyName = '' then
            Error('Virksomhedsnavn må ikke være tomt.');

        RequestBody := StrSubstNo(
            '{"size":10,"query":{"match":{"Vrvirksomhed.virksomhedMetadata.nyesteNavn.navn":{"query":"%1","fuzziness":"AUTO"}}}}',
            CompanyName);

        if not SendRequest(RequestBody, ResponseText) then
            exit(false);

        if not ResponseJson.ReadFrom(ResponseText) then
            exit(false);

        if not GetJsonObject(ResponseJson, 'hits', HitsJson) then
            exit(false);

        if not GetJsonArray(HitsJson, 'hits', ResultArray) then
            exit(false);

        exit(ResultArray.Count() > 0);
    end;

    local procedure SendRequest(RequestBody: Text; var ResponseText: Text): Boolean
    var
        Client: HttpClient;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        Content: HttpContent;
        ContentHeaders: HttpHeaders;
        RequestHeaders: HttpHeaders;
        Attempt: Integer;
        DelayMs: Integer;
        StatusCode: Integer;
    begin
        for Attempt := 1 to MaxRetryAttempts do begin
            Clear(Client);
            Clear(Request);
            Clear(Response);
            Clear(Content);

            Request.Method('POST');
            Request.SetRequestUri(BaseUrl);

            Request.GetHeaders(RequestHeaders);
            RequestHeaders.Add('Authorization', SecretStrSubstNo('Basic %1', GetBase64Credentials()));
            RequestHeaders.Add('Accept', 'application/json');

            Content.WriteFrom(RequestBody);
            Content.GetHeaders(ContentHeaders);
            if ContentHeaders.Contains('Content-Type') then
                ContentHeaders.Remove('Content-Type');
            ContentHeaders.Add('Content-Type', 'application/json');
            Request.Content := Content;

            if TrySendRequest(Client, Request, Response) then begin
                StatusCode := Response.HttpStatusCode();
                if Response.IsSuccessStatusCode() then begin
                    Response.Content().ReadAs(ResponseText);
                    exit(true);
                end;

                if not IsRetryableStatusCode(StatusCode) then begin
                    LogError(StrSubstNo('CVR API fejl: HTTP %1', StatusCode));
                    exit(false);
                end;
            end;

            if Attempt < MaxRetryAttempts then begin
                DelayMs := Power(2, Attempt - 1) * 1000;
                if DelayMs > 16000 then
                    DelayMs := 16000;
                Sleep(DelayMs);
            end;
        end;

        LogError(StrSubstNo('CVR API fejlede efter %1 forsøg', MaxRetryAttempts));
        exit(false);
    end;

    [TryFunction]
    local procedure TrySendRequest(var Client: HttpClient; var Request: HttpRequestMessage; var Response: HttpResponseMessage)
    begin
        if not Client.Send(Request, Response) then
            Error(GetLastErrorText());
    end;

    local procedure GetBase64Credentials(): SecretText
    var
        Base64Convert: Codeunit "Base64 Convert";
        Credentials: SecretText;
    begin
        Credentials := SecretStrSubstNo('%1:%2', Username, Password);
        exit(Base64Convert.ToBase64(Credentials));
    end;

    local procedure IsRetryableStatusCode(StatusCode: Integer): Boolean
    begin
        exit(StatusCode in [429, 500, 502, 503, 504]);
    end;

    local procedure GetJsonObject(ParentObj: JsonObject; PropertyName: Text; var Result: JsonObject): Boolean
    var
        Token: JsonToken;
    begin
        if not ParentObj.Get(PropertyName, Token) then
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
        Result := Token.AsArray();
        exit(true);
    end;

    local procedure GetJsonInt(ParentObj: JsonObject; PropertyName: Text): Integer
    var
        Token: JsonToken;
    begin
        if not ParentObj.Get(PropertyName, Token) then
            exit(0);
        exit(Token.AsValue().AsInteger());
    end;

    local procedure LogError(ErrorMessage: Text)
    begin
        Message('CVR API: %1', ErrorMessage);
    end;
}
