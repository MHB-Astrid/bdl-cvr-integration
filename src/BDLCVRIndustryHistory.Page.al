page 50105 "BDL CVR Industry History"
{
    PageType = List;
    ApplicationArea = All;
    SourceTable = "BDL CVR Industry History";
    Caption = 'CVR-branchehistorik';
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Industry Code"; Rec."Industry Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Branchekode';
                }
                field("Industry Description"; Rec."Industry Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Branchebeskrivelse';
                }
                field("Valid From"; Rec."Valid From")
                {
                    ApplicationArea = All;
                    ToolTip = 'Startdato for denne branche';
                }
                field("Valid To"; Rec."Valid To")
                {
                    ApplicationArea = All;
                    ToolTip = 'Slutdato for denne branche (tom = nuværende)';
                }
            }
        }
    }
}
