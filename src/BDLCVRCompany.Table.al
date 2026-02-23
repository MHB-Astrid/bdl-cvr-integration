table 50011 "BDL CVR Company"
{
    Caption = 'BDL CVR-virksomhed';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "CVR Nr."; Code[8])
        {
            Caption = 'CVR-nr.';
            DataClassification = CustomerContent;
            NotBlank = true;
        }

        field(10; Name; Text[250])
        {
            Caption = 'Navn';
            DataClassification = CustomerContent;
        }

        field(20; Address; Text[250])
        {
            Caption = 'Adresse';
            DataClassification = CustomerContent;
        }

        field(30; "Post Code"; Code[20])
        {
            Caption = 'Postnr.';
            DataClassification = CustomerContent;
        }

        field(40; City; Text[100])
        {
            Caption = 'By';
            DataClassification = CustomerContent;
        }

        field(50; "Municipality Code"; Code[10])
        {
            Caption = 'Kommunekode';
            DataClassification = CustomerContent;
        }

        field(51; "Municipality Name"; Text[100])
        {
            Caption = 'Kommune';
            DataClassification = CustomerContent;
        }

        field(60; "Industry Code"; Code[20])
        {
            Caption = 'Branchekode';
            DataClassification = CustomerContent;
        }

        field(61; "Industry Description"; Text[250])
        {
            Caption = 'Branchebeskrivelse';
            DataClassification = CustomerContent;
        }

        field(70; "Company Form Code"; Code[10])
        {
            Caption = 'Virksomhedsformkode';
            DataClassification = CustomerContent;
        }

        field(71; "Company Form"; Text[100])
        {
            Caption = 'Virksomhedsform';
            DataClassification = CustomerContent;
        }

        field(80; Status; Enum "BDL CVR Status")
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
        }

        field(81; "Founded Date"; Date)
        {
            Caption = 'Stiftelsesdato';
            DataClassification = CustomerContent;
        }

        field(90; "Last Synced"; DateTime)
        {
            Caption = 'Sidst synkroniseret';
            DataClassification = SystemMetadata;
        }

        field(91; "Country Code"; Code[10])
        {
            Caption = 'Landekode';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "CVR Nr.")
        {
            Clustered = true;
        }
        key(Name; Name)
        {
        }
    }
}
