page 50107 "BDL CVR Employment"
{
    PageType = List;
    ApplicationArea = All;
    SourceTable = "BDL CVR Employment";
    Caption = 'CVR-beskæftigelse';
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field(Year; Rec.Year)
                {
                    ApplicationArea = All;
                    ToolTip = 'Regnskabsår';
                }
                field(Employees; Rec.Employees)
                {
                    ApplicationArea = All;
                    ToolTip = 'Antal ansatte';
                }
                field("Employees Incl. Owners"; Rec."Employees Incl. Owners")
                {
                    ApplicationArea = All;
                    ToolTip = 'Antal ansatte inklusiv ejere';
                }
                field(FTE; Rec.FTE)
                {
                    ApplicationArea = All;
                    ToolTip = 'Antal årsværk';
                }
                field("Interval Employees"; Rec."Interval Employees")
                {
                    ApplicationArea = All;
                    ToolTip = 'Intervalangivelse for ansatte';
                }
            }
        }
    }
}
