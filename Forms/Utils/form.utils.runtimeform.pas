unit Form.Utils.RuntimeForm;

{$mode Delphi}{$H+}

interface

uses
    Classes,
    SysUtils,
    Forms,
    Controls,
    fpjson,
    Form.Utils.Component.Events,
    Form.Utils.ComponentFactory,
    Form.Utils.ComponentFactory.Interfaces,
    Form.Utils.ComponentFactory.Components,
    Form.Utils.PalleteTools,
    JSONUtils,
    TypInfo;

type

	{ TRuntimeForm }

  TRuntimeForm = class(TForm)
    private
      FFilename: string;
      FEventManager: TEventManager;
			procedure AdicionarComponente(AComponentType: TComponentType;
					PropertiesJson: TStringList; RunTime: boolean; isFromJSON: boolean);
			function GetComponentPropertiesFromJson(AJSON: TJSONObject): TStringList;
      procedure LoadComponentFromJSON(AJSON: TJSONData);
			procedure LoadComponentsFromJSONString(const AJSONString: string);
    public
      constructor Create(AOwner: TComponent; const AFileName: string); reintroduce;
	end;

implementation

{ TRuntimeForm }

constructor TRuntimeForm.Create(AOwner: TComponent; const AFileName: string);
var
  Components: string;
  Events: string;
begin
  inherited CreateNew(AOwner);

  Position := poMainFormCenter;

  FFilename := AFileName;

  if FFilename <> '' then
  begin
    TJSONStorage.LoadFromFile(
      FFilename,
      Components,
      Events
    );

    LoadComponentsFromJSONString(Components);

    FEventManager:= TEventManager.Create;
    FEventManager.LoadFromJson(Events, Self);
	end;
end;

procedure TRuntimeForm.AdicionarComponente(AComponentType: TComponentType;
		PropertiesJson: TStringList; RunTime: boolean; isFromJSON: boolean);
var
  NewComponent: TControl;
begin
  NewComponent := TComponentFactory.CreateComponent(Self, AComponentType, RunTime, isFromJSON);

  if Assigned(NewComponent) then
  begin
    case AComponentType of
      ctTexto:
        begin
          (NewComponent as IDisplayComponent).ApplyProperties(PropertiesJson);
				end;
      ctBotao:
        begin
          (NewComponent as IActionComponent).ApplyProperties(PropertiesJson);
				end;
			ctCampoTexto:
        begin
          (NewComponent as IInputComponent).ApplyProperties(PropertiesJson);
				end;
    end;

    NewComponent.Parent := Self;
  end;
end;

function TRuntimeForm.GetComponentPropertiesFromJson(AJSON: TJSONObject): TStringList;
var
  i: Integer;
  Key: String;
  Properties: TStringList;
begin
  Properties := TStringList.Create;
  try
    for i := 0 to AJSON.Count - 1 do
    begin
      Key := AJSON.Names[i];
      if Key <> 'Type' then
        Properties.Add(Key + '=' + AJSON.Items[i].AsString);
    end;
    Result := Properties;
  except
    Properties.Free;
    raise;
  end;
end;

procedure TRuntimeForm.LoadComponentFromJSON(AJSON: TJSONData);
var
  i: Integer;
  JSONRoot, JSONComponent: TJSONObject;
  JSONComponentArray: TJSONArray;
  ComponentType: string;
  PropertiesJson: TStringList;
begin
  if not Assigned(AJSON) or not (AJSON.JSONType = jtObject) then
    Exit;

  JSONRoot := AJSON as TJSONObject;

  Self.Width := JSONRoot.Get('width', Self.Width);
  Self.Height := JSONRoot.Get('height', Self.Height);

  if JSONRoot.FindPath('components') is TJSONArray then
    JSONComponentArray := JSONRoot.FindPath('components') as TJSONArray
  else
    Exit;

  for i := 0 to JSONComponentArray.Count - 1 do
  begin
    if not (JSONComponentArray.Items[i] is TJSONObject) then
      Continue;

    JSONComponent := JSONComponentArray.Items[i] as TJSONObject;
    PropertiesJson := GetComponentPropertiesFromJson(JSONComponent);
    ComponentType := JSONComponent.Get('Type', '');

    AdicionarComponente(TComponentType(GetEnumValue(TypeInfo(TComponentType), ComponentType)), PropertiesJson, False, True);
  end;
end;

procedure TRuntimeForm.LoadComponentsFromJSONString(const AJSONString: string);
var
  JSONData: TJSONData;
begin
  if AJSONString = '' then
    Exit;

  JSONData := GetJSON(AJSONString);
  try
    LoadComponentFromJSON(JSONData);
  finally
    JSONData.Free;
  end;
end;

end.

