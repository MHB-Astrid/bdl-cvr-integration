table 50017 "BDL CVR Status History"
{
    Caption = 'BDL CVR-statushistorik';
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

        field(20; "Entry Type"; Option)
        {
            Caption = 'Posttype';
            OptionMembers = Status,Lifecycle;
            OptionCaption = 'Status,Livsforløb';
        }

        field(30; Status; Text[50])
        {
            Caption = 'Status';
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
        key(CVR; "CVR Nr.", "Entry Type", "Valid From")
        {
        }
    }
}
