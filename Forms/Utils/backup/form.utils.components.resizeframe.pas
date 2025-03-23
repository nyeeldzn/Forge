unit Form.Utils.Components.ResizeFrame;

interface

{$mode Delphi}

uses
  Classes,
  Controls,
  Graphics,
  ExtCtrls,
  Form.Utils.Components.ResizeHandle;

type

	{ TResizeFrame }

  TResizeFrame = class(TComponent)
  private
    FTarget: TControl;
    FHandles: array[TResizeHandlePosition] of TResizeHandle;
		procedure Atualizar(Sender: TObject);
    procedure SetTarget(Value: TControl);
    procedure UpdateHandles;
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure UpdatePositions;
  published
    property Target: TControl read FTarget write SetTarget;
  end;

implementation

{ TResizeFrame }

constructor TResizeFrame.Create(AOwner: TComponent);
var
  Pos: TResizeHandlePosition;
begin
  inherited Create(AOwner);
  for Pos := Low(TResizeHandlePosition) to High(TResizeHandlePosition) do
  begin
    FHandles[Pos] := TResizeHandle.Create(Self);
    FHandles[Pos].Parent := TWinControl(AOwner);
    FHandles[Pos].Position := Pos;
    FHandles[Pos].OnEndDrag:= Atualizar;
  end;
end;

destructor TResizeFrame.Destroy;
begin
  inherited Destroy;
end;

procedure TResizeFrame.UpdatePositions;
begin
  Self.Atualizar(Self);
end;

procedure TResizeFrame.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FTarget) then
    FTarget := nil;
end;

procedure TResizeFrame.SetTarget(Value: TControl);
var
  Pos: TResizeHandlePosition;
begin
  if FTarget <> Value then
  begin
    FTarget := Value;
    for Pos := Low(TResizeHandlePosition) to High(TResizeHandlePosition) do
    begin
      FHandles[Pos].Target := FTarget;
    end;
    UpdateHandles;
  end;
end;

procedure TResizeFrame.Atualizar(Sender: TObject);
begin
  UpdateHandles();
end;

procedure TResizeFrame.UpdateHandles;
var
  Pos: TResizeHandlePosition;
begin
  if Assigned(FTarget) then
  begin
    for Pos := Low(TResizeHandlePosition) to High(TResizeHandlePosition) do
    begin
      FHandles[Pos].UpdateHandle;
    end;
  end;

  Application.ProcessMessages();
end;

end.

