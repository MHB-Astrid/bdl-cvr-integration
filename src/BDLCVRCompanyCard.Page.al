page 50101 "BDL CVR Company Card"
{
    PageType = Card;
    ApplicationArea = All;
    SourceTable = "BDL CVR Company";
    Caption = 'CVR-virksomhed';
    Editable = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'Generelt';

                field("CVR Nr."; Rec."CVR Nr.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Virksomhedens CVR-nummer';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Virksomhedens registrerede navn';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Virksomhedens aktuelle status';
                }
                field("Company Form"; Rec."Company Form")
                {
                    ApplicationArea = All;
                    ToolTip = 'Virksomhedsform (A/S, ApS, etc.)';
                }
                field("Founded Date"; Rec."Founded Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Dato for virksomhedens stiftelse';
                }
            }
            group(AddressGroup)
            {
                Caption = 'Adresse';

                field(Address; Rec.Address)
                {
                    ApplicationArea = All;
                    ToolTip = 'Virksomhedens adresse';
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
                field("Municipality Name"; Rec."Municipality Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Kommune';
                }
                field("Country Code"; Rec."Country Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Landekode';
                }
            }
            group(IndustryGroup)
            {
                Caption = 'Branche';

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
            }
            group(SyncGroup)
            {
                Caption = 'Synkronisering';

                field("Last Synced"; Rec."Last Synced")
                {
                    ApplicationArea = All;
                    ToolTip = 'Tidspunkt for sidste synkronisering med CVR';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ShowAddressHistory)
            {
                Caption = 'Vis adressehistorik';
                ApplicationArea = All;
                Image = MapSetup;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Vis historiske adresser for denne virksomhed';

                trigger OnAction()
                var
                    AddressHistory: Record "BDL CVR Address History";
                begin
                    AddressHistory.SetRange("CVR Nr.", Rec."CVR Nr.");
                    Page.Run(Page::"BDL CVR Address History", AddressHistory);
                end;
            }
            action(ShowNameHistory)
            {
                Caption = 'Vis navnehistorik';
                ApplicationArea = All;
                Image = Change;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Vis historiske navne og binavne';

                trigger OnAction()
                var
                    NameHistory: Record "BDL CVR Name History";
                begin
                    NameHistory.SetRange("CVR Nr.", Rec."CVR Nr.");
                    Page.Run(Page::"BDL CVR Name History", NameHistory);
                end;
            }
            action(ShowIndustryHistory)
            {
                Caption = 'Vis branchehistorik';
                ApplicationArea = All;
                Image = Industry;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Vis historiske branchekoder';

                trigger OnAction()
                var
                    IndustryHistory: Record "BDL CVR Industry History";
                begin
                    IndustryHistory.SetRange("CVR Nr.", Rec."CVR Nr.");
                    Page.Run(Page::"BDL CVR Industry History", IndustryHistory);
                end;
            }
            action(ShowParticipants)
            {
                Caption = 'Vis deltagere';
                ApplicationArea = All;
                Image = Users;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Vis ejere, direktører og andre deltagere';

                trigger OnAction()
                var
                    Participant: Record "BDL CVR Participant";
                begin
                    Participant.SetRange("CVR Nr.", Rec."CVR Nr.");
                    Page.Run(Page::"BDL CVR Participant", Participant);
                end;
            }
            action(ShowEmployment)
            {
                Caption = 'Vis beskæftigelse';
                ApplicationArea = All;
                Image = Capacity;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Vis årlige beskæftigelsestal';

                trigger OnAction()
                var
                    Employment: Record "BDL CVR Employment";
                begin
                    Employment.SetRange("CVR Nr.", Rec."CVR Nr.");
                    Page.Run(Page::"BDL CVR Employment", Employment);
                end;
            }
            action(ShowStatusHistory)
            {
                Caption = 'Vis statushistorik';
                ApplicationArea = All;
                Image = History;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Vis statusændringer og livsforløb';

                trigger OnAction()
                var
                    StatusHistory: Record "BDL CVR Status History";
                begin
                    StatusHistory.SetRange("CVR Nr.", Rec."CVR Nr.");
                    Page.Run(Page::"BDL CVR Status History", StatusHistory);
                end;
            }
        }
    }
}
