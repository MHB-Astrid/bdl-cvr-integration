table 50015 "BDL CVR Participant"
{
    Caption = 'BDL CVR-deltager';
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

        field(20; "Unit Number"; BigInteger)
        {
            Caption = 'Enhedsnummer';
        }

        field(30; "Unit Type"; Text[20])
        {
            Caption = 'Enhedstype';
        }

        field(40; Name; Text[250])
        {
            Caption = 'Navn';
        }

        field(50; Address; Text[250])
        {
            Caption = 'Adresse';
        }

        field(60; "Post Code"; Code[20])
        {
            Caption = 'Postnr.';
        }

        field(70; City; Text[100])
        {
            Caption = 'By';
        }

        field(80; "Fetched DateTime"; DateTime)
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
        key(CVR; "CVR Nr.", "Unit Number")
        {
        }
    }
}
