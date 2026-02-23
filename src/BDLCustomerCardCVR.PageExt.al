pageextension 50101 "BDL Customer Card CVR" extends "Customer Card"
{
    layout
    {
        addafter(General)
        {
            group(CVRIntegration)
            {
                Caption = 'CVR Integration';

                field("CVR Nr."; Rec."CVR Nr.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Virksomhedens CVR-nummer fra Erhvervsstyrelsen';
                }
                field("CVR Status"; Rec."CVR Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'CVR-status fra sidste synkronisering';
                }
                field("CVR Last Synced"; Rec."CVR Last Synced")
                {
                    ApplicationArea = All;
                    ToolTip = 'Tidspunkt for sidste CVR-synkronisering';
                }
            }
        }
    }

    actions
    {
        addlast(processing)
        {
            action(FetchCVRData)
            {
                Caption = 'Hent CVR Data';
                ApplicationArea = All;
                Image = RefreshLines;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Hent virksomhedsdata fra CVR-registret baseret på CVR-nr.';

                trigger OnAction()
                var
                    CVRSyncMgt: Codeunit "BDL CVR Sync Mgt";
                begin
                    CVRSyncMgt.FetchAndUpdateCustomer(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(SetupCVRCredentials)
            {
                Caption = 'Opsæt CVR Credentials';
                ApplicationArea = All;
                Image = EncryptionKeys;
                ToolTip = 'Konfigurer brugernavn og adgangskode til CVR API';
                RunObject = page "BDL CVR Setup";
            }
            action(ShowCVRCompany)
            {
                Caption = 'Vis CVR-virksomhed';
                ApplicationArea = All;
                Image = Company;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Åbn CVR-virksomhedskortet med alle registrerede data';

                trigger OnAction()
                var
                    CVRCompany: Record "BDL CVR Company";
                begin
                    if Rec."CVR Nr." = '' then
                        Error('Angiv et CVR-nr. først.');
                    if not CVRCompany.Get(Rec."CVR Nr.") then
                        Error('CVR-virksomhed %1 er ikke hentet endnu. Brug "Hent CVR Data" først.', Rec."CVR Nr.");
                    Page.Run(Page::"BDL CVR Company Card", CVRCompany);
                end;
            }
        }
    }
}
