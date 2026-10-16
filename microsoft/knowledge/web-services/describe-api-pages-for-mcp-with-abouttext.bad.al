page 50381 "WS Margin Line API Bad"
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
