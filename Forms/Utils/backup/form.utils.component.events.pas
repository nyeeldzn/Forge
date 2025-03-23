unit Form.Utils.Component.Events;

{$mode Delphi}{$H+}

interface

uses
    Classes,
    SysUtils,
    Generics.Collections,
    fpjson,
    jsonparser,
    Form.Utils.ComponentFactory.Interfaces,
    Form.Utils.ComponentFactory.Components;

type

	{ TComponentEvent }

  TComponentEvent = class
    private
      FTriggerComponent: IActionComponent;
      FSourceComponent: IInputComponent;
      FTargetComponent: IDisplayComponent;
      FEventName: string;
			procedure SetSourceComponent(AValue: IInputComponent);
     procedure SetTriggerComponent(AValue: IActionComponent);
    public
      constructor Create(AEventName: string);

      procedure Execute(ASender: TObject);

      procedure TexteExecute(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
      function ToJsonObject: TJSONObject;
      procedure FromJsonObject(AJson: TJSONObject; AComponentHolder: TComponent);


      property EventName: string read FEventName write FEventName;
      property TriggerComponent: IActionComponent read FTriggerComponent write SetTriggerComponent;
      property SourceComponent: IInputComponent read FSourceComponent write SetSourceComponent;
      property TargetComponent: IDisplayComponent read FTargetComponent write FTargetComponent;
	end;

	{ TEventManager }

  TOnAfterInitialize = procedure of object;

  TEventManager = class
  private
    FEventList: TObjectList<TComponentEvent>;
    FAfterInitialize: TOnAfterInitialize;
		function GetEventCount: integer;

  public
    constructor Create;
    destructor Destroy; override;
    procedure AddEvent(AEvent: TComponentEvent);
    procedure RemoveEvent(AEvent: TComponentEvent);
    procedure ExecuteAll;
		procedure LoadFromJson(const AJsonString: string;
				AComponentHolder: TComponent);
		function SaveToJson: string;

    property EventCount: integer read GetEventCount;
    property Events: TObjectList<TComponentEvent> read FEventList;
    property AfterInitialize: TOnAfterInitialize read FAfterInitialize write FAfterInitialize;
  end;

implementation

uses
  Variants;

{ TComponentEvent }

function TComponentEvent.ToJsonObject: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.Add('EventName', FEventName);

  // Salvamos apenas os nomes dos componentes
  if Assigned(FTriggerComponent) then
    Result.Add('TriggerComponent', (FTriggerComponent as TComponent).Name)
  else
    Result.Add('TriggerComponent', '');

  if Assigned(FSourceComponent) then
    Result.Add('SourceComponent', (FSourceComponent as TComponent).Name)
  else
    Result.Add('SourceComponent', '');

  if Assigned(FTargetComponent) then
    Result.Add('TargetComponent', (FTargetComponent as TComponent).Name)
  else
    Result.Add('TargetComponent', '');
end;

procedure TComponentEvent.FromJsonObject(AJson: TJSONObject;
		AComponentHolder: TComponent);
begin
  FEventName := AJson.Get('EventName', '');

  TriggerComponent := AComponentHolder.FindComponent(AJson.Get('TriggerComponent', '')) as IActionComponent;
  SourceComponent := AComponentHolder.FindComponent(AJson.Get('SourceComponent', '')) as IInputComponent;
  TargetComponent := AComponentHolder.FindComponent(AJson.Get('TargetComponent', '')) as IDisplayComponent;
end;


procedure TComponentEvent.SetTriggerComponent(AValue: IActionComponent);
begin
  if FTriggerComponent=AValue then Exit;

  FTriggerComponent:=AValue;

  if Assigned(FTriggerComponent) then
  begin
    if FTriggerComponent is TSpeedButton then
    begin
      TSpeedButton(FTriggerComponent).OnClick := Execute;
      TSpeedButton(FTriggerComponent).OnMouseDown := TexteExecute;
		end;
	end;
end;

procedure TComponentEvent.SetSourceComponent(AValue: IInputComponent);
begin
  if FSourceComponent=AValue then
    Exit;

  FSourceComponent:=AValue;
end;

constructor TComponentEvent.Create(AEventName: string);
begin
  FEventName := AEventName;
end;

procedure TComponentEvent.Execute(ASender: TObject);
var
  Text: string;
begin
  if
    Assigned(FSourceComponent) and
    Assigned(FTargetComponent)
  then
  begin
    if FTargetComponent is TLabel then
    begin
      if FSourceComponent is TLabeledEdit then
      begin
        Text := VarToStr(FSourceComponent.GetValue);
        FTargetComponent.SetText(Text);
			end;
		end;
  end;
end;

procedure TComponentEvent.TexteExecute(Sender: TObject; Button: TMouseButton;
		Shift: TShiftState; X, Y: Integer);
begin
  inherited;

  Execute(Sender);
end;

{ TEventManager }

function TEventManager.GetEventCount: integer;
begin
  Result := FEventList.Count;
end;

constructor TEventManager.Create;
begin
  FEventList := TObjectList<TComponentEvent>.Create(True);
end;

destructor TEventManager.Destroy;
begin
  FEventList.Free;
  inherited;
end;

procedure TEventManager.AddEvent(AEvent: TComponentEvent);
begin
  FEventList.Add(AEvent);
end;

procedure TEventManager.RemoveEvent(AEvent: TComponentEvent);
begin
  FEventList.Remove(AEvent);
end;

procedure TEventManager.ExecuteAll;
var
  Event: TComponentEvent;
begin
  for Event in FEventList do
    Event.Execute(Self);
end;

procedure TEventManager.LoadFromJson(const AJsonString: string; AComponentHolder: TComponent);
var
  JSONArray: TJSONArray;
  JSONParser: TJSONParser;
  EventJSON: TJSONObject;
  Event: TComponentEvent;
  EventString: string;
  i: Integer;
begin
  if AJsonString = '' then
    Exit;

  JSONParser := TJSONParser.Create(AJsonString);
  try
    JSONArray := JSONParser.Parse as TJSONArray;
    if JSONArray = nil then
      Exit;

    FEventList.Clear; // Limpa eventos anteriores

    for i := 0 to JSONArray.Count - 1 do
    begin
      EventJSON := JSONArray.Objects[i];
      EventString := EventJSON.AsJSON;
      Event := TComponentEvent.Create(EventJSON.Get('EventName', ''));
      Event.FromJsonObject(EventJSON, AComponentHolder);
      FEventList.Add(Event);
    end;

    if Assigned(FAfterInitialize) then FAfterInitialize()

  finally
    JSONParser.Free;
  end;
end;

function TEventManager.SaveToJson: string;
var
  JSONArray: TJSONArray;
  Event: TComponentEvent;
begin
  JSONArray := TJSONArray.Create;
  try
    for Event in FEventList do
      JSONArray.Add(Event.ToJsonObject);

    Result := JSONArray.AsJSON;
  finally
    JSONArray.Free;
  end;
end;


end.

