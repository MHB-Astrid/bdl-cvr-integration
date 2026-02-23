page 50106 "BDL CVR Participant"
{
    PageType = List;
    ApplicationArea = All;
    SourceTable = "BDL CVR Participant";
    Caption = 'CVR-deltagere';
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Deltagerens navn';
                }
                field("Unit Type"; Rec."Unit Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Type (PERSON eller VIRKSOMHED)';
                }
                field(Address; Rec.Address)
                {
                    ApplicationArea = All;
                    ToolTip = 'Deltagerens adresse';
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
                field("Unit Number"; Rec."Unit Number")
                {
                    ApplicationArea = All;
                    ToolTip = 'CVR enhedsnummer';
                }
            }
        }
    }
}
