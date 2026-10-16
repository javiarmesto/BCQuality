page 50380 "WS Margin Line API Good"
{
    PageType = API;
    Caption = 'marginLine';
    APIPublisher = 'contoso';
    APIGroup = 'salesMargin';
    APIVersion = 'v1.0';
    EntityName = 'marginLine';
    EntitySetName = 'marginLines';
    EntityCaption = 'Margin Line';
    EntitySetCaption = 'Margin Lines';
    AboutTitle = 'Sales line margins';
    AboutText = 'One item line of an open sales quote, order or invoice, with its document number, item and line amount. Read-only; credit memos and non-item lines are not included.';
    ODataKeyFields = SystemId;
    SourceTable = "Sales Line";
    SourceTableView = where(Type = const(Item));
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            repeater(records)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'id';
                    Editable = false;
                }
                field(documentNumber; Rec."Document No.")
                {
                    Caption = 'documentNumber';
                }
                field(itemNumber; Rec."No.")
                {
                    Caption = 'itemNumber';
                }
                field(lineAmount; Rec."Line Amount")
                {
                    Caption = 'lineAmount';
                }
            }
        }
    }
}
