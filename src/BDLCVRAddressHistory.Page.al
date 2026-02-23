page 50103 "BDL CVR Address History"
{
    PageType = List;
    ApplicationArea = All;
    SourceTable = "BDL CVR Address History";
    Caption = 'CVR-adressehistorik';
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Valid From"; Rec."Valid From")
                {
                    ApplicationArea = All;
                    ToolTip = 'Startdato for denne adresse';
                }
                field("Valid To"; Rec."Valid To")
                {
                    ApplicationArea = All;
                    ToolTip = 'Slutdato for denne adresse (tom = nuværende)';
                }
                field(Address; Rec.Address)
                {
                    ApplicationArea = All;
                    ToolTip = 'Virksomhedens adresse i denne periode';
                }
                field("Post Code"; Rec."Post Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Postnummer';
                }
                field(City; Rec.City)
                {
                    ApplicationArea = All;
                    ToolTip = 'By';
                }
            }
        }
    }
}
