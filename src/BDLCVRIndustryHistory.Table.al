table 50014 "BDL CVR Industry History"
{
    Caption = 'BDL CVR-branchehistorik';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Løbenr.';
            AutoIncrement = true;
        }

        field(10; "CVR Nr."; Code[8])
        {
            Caption = 'CVR-nr.';
            TableRelation = "BDL CVR Company"."CVR Nr.";
        }

        field(20; "Industry Code"; Code[20])
        {
            Caption = 'Branchekode';
        }

        field(30; "Industry Description"; Text[250])
        {
            Caption = 'Branchebeskrivelse';
        }

        field(40; "Valid From"; Date)
        {
            Caption = 'Gyldig fra';
        }

        field(50; "Valid To"; Date)
        {
            Caption = 'Gyldig til';
        }

        field(60; "Fetched DateTime"; DateTime)
        {
            Caption = 'Hentet tidspunkt';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(CVR; "CVR Nr.", "Valid From")
        {
        }
    }
}
