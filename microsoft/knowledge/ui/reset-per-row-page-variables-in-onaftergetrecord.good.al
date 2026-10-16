page 50390 "UI Margin Lines Good"
{
    PageType = ListPart;
    SourceTable = "Sales Line";
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(Lines)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field(ExceptionEntryNo; ExceptionEntryNo)
                {
                    ApplicationArea = All;
                    Caption = 'Exception Entry No.';
                }
                field(AuthorizedBy; AuthorizedBy)
                {
                    ApplicationArea = All;
                    Caption = 'Authorized By';
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        ApprovalEntry: Record "Approval Entry";
    begin
        Clear(ExceptionEntryNo);
        Clear(AuthorizedBy);
        ApprovalEntry.SetRange("Record ID to Approve", Rec.RecordId());
        ApprovalEntry.SetRange(Status, ApprovalEntry.Status::Approved);
        if not ApprovalEntry.FindLast() then
            exit;
        ExceptionEntryNo := ApprovalEntry."Entry No.";
        AuthorizedBy := ApprovalEntry."Approver ID";
    end;

    var
        ExceptionEntryNo: Integer;
        AuthorizedBy: Code[50];
}
