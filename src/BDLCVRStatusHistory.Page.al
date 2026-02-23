page 50108 "BDL CVR Status History"
{
    PageType = List;
    ApplicationArea = All;
    SourceTable = "BDL CVR Status History";
    Caption = 'CVR-statushistorik';
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Entry Type"; Rec."Entry Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Status eller livsforløb';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Statusværdi';
                }
                field("Valid From"; Rec."Valid From")
                {
                    ApplicationArea = All;
                    ToolTip = 'Startdato';
                }
                field("Valid To"; Rec."Valid To")
                {
                    ApplicationArea = All;
                    ToolTip = 'Slutdato (tom = nuværende)';
                }
            }
        }
    }
}
