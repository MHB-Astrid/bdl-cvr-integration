table 50012 "BDL CVR Address History"
{
    Caption = 'BDL CVR-adressehistorik';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Løbenr.';
            AutoIncrement = true;
        }

        field(10; "CVR Nr."; Code[20])
        {
            Caption = 'CVR-nr.';
            TableRelation = "BDL CVR Company"."CVR Nr.";
        }

        field(20; Address; Text[250])
        {
            Caption = 'Adresse';
        }

        field(30; "Post Code"; Code[20])
        {
            Caption = 'Postnr.';
        }

        field(40; City; Text[100])
        {
            Caption = 'By';
        }

        field(50; "Valid From"; Date)
        {
            Caption = 'Gyldig fra';
        }

        field(60; "Valid To"; Date)
        {
            Caption = 'Gyldig til';
        }

        field(70; "Fetched DateTime"; DateTime)
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
