// ANTI-PATTERN: re-declaring a base object and re-implementing base logic.

// 1. The base Customer table is table 18. Re-declaring it here does not
//    "extend" anything — it collides with the supported object and will not
//    survive the next base-application update.
table 18 Customer
{
    fields
    {
        field(1; "No."; Code[20]) { }
        field(50100; "Loyalty Points"; Integer) { }
    }
}

// 2. A copy of a base posting routine, edited in place, so callers can be
//    pointed at this one instead. Base fixes and upgrades never reach it.
codeunit 50100 "Sales-Post Copy"
{
    procedure PostSalesDocument(var SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
    begin
        // ...several hundred lines transcribed from the base codeunit,
        // with two lines changed in the middle...
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindSet() then
            repeat
                PostSalesLine(SalesLine);
            until SalesLine.Next() = 0;
    end;

    local procedure PostSalesLine(var SalesLine: Record "Sales Line")
    begin
        // copied base logic
    end;
}
