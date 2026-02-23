page 50102 "BDL CVR Setup"
{
    PageType = StandardDialog;
    Caption = 'CVR API Opsætning';
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(Credentials)
            {
                Caption = 'CVR API Credentials (Erhvervsstyrelsen)';

                field(UsernameField; UsernameValue)
                {
                    ApplicationArea = All;
                    Caption = 'Brugernavn';
                    ToolTip = 'Brugernavn til CVR API fra Erhvervsstyrelsen';
                }
                field(PasswordField; PasswordValue)
                {
                    ApplicationArea = All;
                    Caption = 'Adgangskode';
                    ToolTip = 'Adgangskode til CVR API';
                    ExtendedDatatype = Masked;
                }
            }
        }
    }

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        CVRAPIClient: Codeunit "BDL CVR API Client";
    begin
        if CloseAction = Action::OK then begin
            if (UsernameValue = '') or (PasswordValue = '') then
                Error('Angiv både brugernavn og adgangskode.');
            CVRAPIClient.SetCredentials(UsernameValue, PasswordValue);
        end;
        exit(true);
    end;

    var
        UsernameValue: Text[100];
        PasswordValue: Text[100];
}
