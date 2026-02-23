permissionset 50001 "BDL CVR Integration"
{
    Assignable = true;
    Caption = 'BDL CVR Integration';

    Permissions =
        tabledata "BDL CVR Company" = RIMD,
        tabledata "BDL CVR Address History" = RIMD,
        tabledata "BDL CVR Name History" = RIMD,
        tabledata "BDL CVR Industry History" = RIMD,
        tabledata "BDL CVR Participant" = RIMD,
        tabledata "BDL CVR Employment" = RIMD,
        tabledata "BDL CVR Status History" = RIMD,
        table "BDL CVR Company" = X,
        table "BDL CVR Address History" = X,
        table "BDL CVR Name History" = X,
        table "BDL CVR Industry History" = X,
        table "BDL CVR Participant" = X,
        table "BDL CVR Employment" = X,
        table "BDL CVR Status History" = X,
        page "BDL CVR Company Card" = X,
        page "BDL CVR Address History" = X,
        page "BDL CVR Name History" = X,
        page "BDL CVR Industry History" = X,
        page "BDL CVR Participant" = X,
        page "BDL CVR Employment" = X,
        page "BDL CVR Status History" = X,
        page "BDL CVR Setup" = X,
        codeunit "BDL CVR API Client" = X,
        codeunit "BDL CVR Sync Mgt" = X,
        codeunit "BDL CVR Event Sub" = X;
}
