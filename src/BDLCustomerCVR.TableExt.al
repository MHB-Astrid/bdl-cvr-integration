tableextension 50000 "BDL Customer CVR" extends Customer
{
    fields
    {
        field(50000; "CVR Nr."; Code[8])
        {
            Caption = 'CVR-nr.';
            DataClassification = CustomerContent;
        }

        field(50001; "CVR Status"; Enum "BDL CVR Status")
        {
            Caption = 'CVR-status';
            DataClassification = CustomerContent;
            Editable = false;
        }

        field(50002; "CVR Last Synced"; DateTime)
        {
            Caption = 'CVR sidst synkroniseret';
            DataClassification = SystemMetadata;
            Editable = false;
        }
    }
}
