// BEST PRACTICE: extend the base object, subscribe to what it publishes.

// 1. New data on a base table goes in a tableextension, in the extension's
//    own field-ID range. The base object stays untouched and upgradeable.
tableextension 50100 "Customer Loyalty" extends Customer
{
    fields
    {
        field(50100; "Loyalty Points"; Integer)
        {
            Caption = 'Loyalty Points';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }
}

// 2. Behaviour hooks into base posting through a published event, with the
//    publisher's exact signature. Base upgrades keep the contract; if the
//    event is ever removed, compilation fails loudly instead of drifting.
codeunit 50101 "Loyalty Posting Subscribers"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterPostSalesDoc', '', false, false)]
    local procedure AwardLoyaltyPointsOnAfterPostSalesDoc(var SalesHeader: Record "Sales Header")
    var
        Customer: Record Customer;
    begin
        if not Customer.Get(SalesHeader."Sell-to Customer No.") then
            exit;

        Customer."Loyalty Points" += CalculatePoints(SalesHeader);
        Customer.Modify(true);
        // No Commit here — the posting transaction owns the commit boundary.
    end;

    local procedure CalculatePoints(SalesHeader: Record "Sales Header"): Integer
    begin
        exit(Round(SalesHeader."Amount Including VAT" / 10, 1, '<'));
    end;
}
