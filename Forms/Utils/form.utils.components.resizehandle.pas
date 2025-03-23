unit Form.Utils.Components.ResizeHandle;

interface

uses
  Classes, Controls, Graphics, ExtCtrls, LCLType;

type
  TResizeHandlePosition = (rhLeft, rhRight, rhTop, rhBottom);

  TResizeHandle = class(TShape)
  private
    FTarget: TControl;
    FPosition: TResizeHandlePosition;
    FDragging: Boolean;
    FStartX, FStartY: Integer;
    FOnEndDrag: TNotifyEvent;

    procedure SetTarget(Value: TControl);
    procedure SetPosition(Value: TResizeHandlePosition);
    procedure UpdatePosition;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure UpdateHandle;
  published
    property Target: TControl read FTarget write SetTarget;
    property Position: TResizeHandlePosition read FPosition write SetPosition;
    property OnEndDrag: TNotifyEvent read FOnEndDrag write FOnEndDrag;
  end;

implementation

{ TResizeHandle }

constructor TResizeHandle.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Shape := stRectangle;
  Color := clWhite;
  Width := 8;
  Height := 8;
  Cursor := crSize;
end;

procedure TResizeHandle.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FTarget) then
    FTarget := nil;
end;

procedure TResizeHandle.SetTarget(Value: TControl);
begin
  if FTarget <> Value then
  begin
    FTarget := Value;
    if Assigned(FTarget) then
    begin
      Parent := FTarget.Parent;
      UpdatePosition;
    end;
  end;
end;

procedure TResizeHandle.SetPosition(Value: TResizeHandlePosition);
begin
  if FPosition <> Value then
  begin
    FPosition := Value;
    UpdatePosition;
  end;
end;

procedure TResizeHandle.UpdateHandle;
begin
  if Assigned(FTarget) then
    UpdatePosition;
end;

procedure TResizeHandle.UpdatePosition;
begin
  if not Assigned(FTarget) then Exit;

  case FPosition of
    rhLeft:
      begin
        Left := FTarget.Left - (Width div 2);
        Top := FTarget.Top + (FTarget.Height div 2) - (Height div 2);
        Cursor := crSizeWE;
      end;
    rhRight:
      begin
        Left := FTarget.Left + FTarget.Width - (Width div 2);
        Top := FTarget.Top + (FTarget.Height div 2) - (Height div 2);
        Cursor := crSizeWE;
      end;
    rhTop:
      begin
        Left := FTarget.Left + (FTarget.Width div 2) - (Width div 2);
        Top := FTarget.Top - (Height div 2);
        Cursor := crSizeNS;
      end;
    rhBottom:
      begin
        Left := FTarget.Left + (FTarget.Width div 2) - (Width div 2);
        Top := FTarget.Top + FTarget.Height - (Height div 2);
        Cursor := crSizeNS;
      end;
  end;
end;

procedure TResizeHandle.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  DeltaX, DeltaY: Integer;
begin
  inherited MouseMove(Shift, X, Y);
  if FDragging and Assigned(FTarget) then
  begin
    DeltaX := X - FStartX;
    DeltaY := Y - FStartY;

    case FPosition of
      rhLeft:
        begin
          FTarget.Left := FTarget.Left + X;
          FTarget.Width := FTarget.Width - DeltaX - X;
        end;
      rhRight:
        FTarget.Width := FTarget.Width + X;
      rhTop:
        begin
          FTarget.Top := FTarget.Top + Y;
          FTarget.Height := FTarget.Height - DeltaY - Y;
        end;
      rhBottom:
        FTarget.Height := FTarget.Height + Y;
    end;

    FStartX := X;
    FStartY := Y;
    UpdateHandle;
  end;
end;


procedure TResizeHandle.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  if Button = mbLeft then
  begin
    FDragging := True;
    FStartX := X;
    FStartY := Y;
  end;
end;

procedure TResizeHandle.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseUp(Button, Shift, X, Y);
  if Button = mbLeft then
  begin
    FDragging := False;
      if Assigned(FOnEndDrag) then
        FOnEndDrag(Self);
	end;
end;

end.
