page 50104 "BDL CVR Name History"
{
    PageType = List;
    ApplicationArea = All;
    SourceTable = "BDL CVR Name History";
    Caption = 'CVR-navnehistorik';
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Name Type"; Rec."Name Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Navn eller binavn';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Virksomhedens navn i denne periode';
                }
                field("Valid From"; Rec."Valid From")
                {
                    ApplicationArea = All;
                    ToolTip = 'Startdato for dette navn';
                }
                field("Valid To"; Rec."Valid To")
                {
                    ApplicationArea = All;
                    ToolTip = 'Slutdato for dette navn (tom = nuværende)';
                }
            }
        }
    }
}
