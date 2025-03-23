unit Form.Utils.EventManager;

{$mode Delphi}

interface

uses
  SysUtils,
  Classes,
  Controls,
  StdCtrls,
  ExtCtrls,
  Forms,
  Form.Utils.Component.Events;

type

	{ TEventManagerPanel }

  TEventManagerPanel = class(TCustomControl)
  private
    FEventManager: TEventManager;
    FBtnAddEvent: TButton;
    FEventListPanel: TPanel;
    FComponentHolder: TComponent;
    procedure BtnAddEventClick(Sender: TObject);
    procedure EventButtonClick(Sender: TObject);
  public
    constructor Create(AOwner: TComponent; AComponentHolder: TComponent); reintroduce;
    procedure SetEventManager(AEventManager: TEventManager);
    procedure RenderEventList;
  end;

implementation

uses
  Form.Utils.EventEditForm;

constructor TEventManagerPanel.Create(AOwner: TComponent;
		AComponentHolder: TComponent);
begin
  inherited Create(AOwner);

  Self.Width := 200;
  Self.Height := 300;

  FBtnAddEvent := TButton.Create(Self);
  FBtnAddEvent.Parent := Self;
  FBtnAddEvent.Align := alTop;
  FBtnAddEvent.Caption := '+';
  FBtnAddEvent.OnClick := BtnAddEventClick;

  FEventListPanel := TPanel.Create(Self);
  FEventListPanel.Parent := Self;
  FEventListPanel.Align := alClient;
  FEventListPanel.AutoSize := True;

  FComponentHolder:= AComponentHolder;
end;

procedure TEventManagerPanel.SetEventManager(AEventManager: TEventManager);
begin
  FEventManager := AEventManager;
  RenderEventList;
end;

procedure TEventManagerPanel.BtnAddEventClick(Sender: TObject);
var
  NewEvent: TComponentEvent;
begin
  NewEvent := TComponentEvent.Create('');
  if Assigned(FEventManager) then
  begin
    if TEventEditForm.EditEvent(NewEvent, FEventManager, FComponentHolder) then
      begin
      FEventManager.AddEvent(NewEvent);
      RenderEventList;
    end;
  end;
end;

procedure TEventManagerPanel.RenderEventList;
var
  i: Integer;
  BtnEvent: TButton;
begin
  if not Assigned(FEventManager) then Exit;

  for i := FEventListPanel.ControlCount - 1 downto 0 do
    FEventListPanel.Controls[i].Free;

  for i := 0 to FEventManager.EventCount - 1 do
  begin
    BtnEvent := TButton.Create(FEventListPanel);
    BtnEvent.Parent := FEventListPanel;
    BtnEvent.Caption := FEventManager.Events[i].EventName;
    BtnEvent.Tag := i;
    BtnEvent.Align := alTop;
    BtnEvent.OnClick := EventButtonClick;
  end;
end;

procedure TEventManagerPanel.EventButtonClick(Sender: TObject);
var
  EventIndex: Integer;
  Event: TComponentEvent;
begin
  if not Assigned(FEventManager) then Exit;

  EventIndex := (Sender as TButton).Tag;
  Event := FEventManager.Events[EventIndex];
  if TEventEditForm.EditEvent(Event, FEventManager, FComponentHolder) then
  begin
//    FEventManager.UpdateEvent(EventIndex, Event);
    RenderEventList;
  end;
end;

end.

