table 50016 "BDL CVR Employment"
{
    Caption = 'BDL CVR-beskæftigelse';
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

        field(20; Year; Integer)
        {
            Caption = 'År';
        }

        field(30; Employees; Integer)
        {
            Caption = 'Antal ansatte';
        }

        field(40; "Employees Incl. Owners"; Integer)
        {
            Caption = 'Antal inkl. ejere';
        }

        field(50; FTE; Decimal)
        {
            Caption = 'Årsværk';
            DecimalPlaces = 0 : 2;
        }

        field(60; "Interval Employees"; Text[50])
        {
            Caption = 'Interval ansatte';
        }

        field(70; "Interval FTE"; Text[50])
        {
            Caption = 'Interval årsværk';
        }

        field(80; "Interval Incl. Owners"; Text[50])
        {
            Caption = 'Interval inkl. ejere';
        }

        field(90; "Fetched DateTime"; DateTime)
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
        key(CVR; "CVR Nr.", Year)
        {
        }
    }
}
