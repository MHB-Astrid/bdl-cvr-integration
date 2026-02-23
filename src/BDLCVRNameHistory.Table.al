table 50013 "BDL CVR Name History"
{
    Caption = 'BDL CVR-navnehistorik';
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

        field(20; Name; Text[250])
        {
            Caption = 'Navn';
        }

        field(30; "Name Type"; Option)
        {
            Caption = 'Navnetype';
            OptionMembers = Name,SecondaryName;
            OptionCaption = 'Navn,Binavn';
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
        key(CVR; "CVR Nr.", "Name Type", "Valid From")
        {
        }
    }
}
