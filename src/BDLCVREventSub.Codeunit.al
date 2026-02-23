codeunit 50202 "BDL CVR Event Sub"
{
    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnAfterInsertEvent', '', false, false)]
    local procedure OnAfterInsertCustomer(var Rec: Record Customer; RunTrigger: Boolean)
    begin
        if not RunTrigger then
            exit;

        if Rec."CVR Nr." = '' then
            exit;

        TryFetchCVRData(Rec);
    end;

    [TryFunction]
    local procedure TryFetchCVRData(var Customer: Record Customer)
    var
        CVRSyncMgt: Codeunit "BDL CVR Sync Mgt";
    begin
        CVRSyncMgt.FetchAndUpdateCustomer(Customer);
    end;
}
