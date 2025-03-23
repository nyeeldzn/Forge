unit Form.Utils.ComponentsBoard;

{$mode Delphi}{$H+}

interface

uses
  Classes,
  SysUtils,
  Forms,
  Controls,
  ExtCtrls,
  Math,
  Buttons,
  Graphics, StdCtrls,
  Form.Utils.PalleteTools,
  Form.Utils.ComponentFactory,
  TypInfo,
  Form.Utils.Components.ResizeHandle,
  Form.Utils.Components.ResizeFrame,
  ComponentUtils,
  PopUpUtils,
  Form.Utils.ComponentFactory.Components,
  Form.Utils.ComponentFactory.Interfaces,
  {$IFDEF FPC}
  fpJSON,
  jsonparser;  // Para Lazarus
  {$ELSE}
  System.JSON;  // Para Delphi
  {$ENDIF}

type

  TGuideLineDirection = (dtHorizontal, dtVertical);

  TGuideLinePosition = record
    Top: integer;
    Left: integer;
    Height: integer;
    Width: integer;
	end;

	{ TGuideLine }

  TGuideLine = class(TPanel)
    constructor Create(AOwner: TComponent; ADirection: TGuideLineDirection; APosition: TGuideLinePosition); reintroduce;
	end;

  { TComponentsBoard }

  TComponentsBoard = class(TFrame)
			procedure SpeedButton1Click(Sender: TObject);
  private
    DraggingControl: TControl;
    OffsetX, OffsetY: Integer;
    FGuideline: TGuideLine;
    FResizeFrame: TResizeFrame;
    LastSender : TObject;
    FOnComponentClick: TNotifyEvent;


		procedure AssignMouseEvents(AComponent: TControl);
		procedure CheckGuideLine(Top, Left, Height, Width: Integer);
    procedure DoDrag(Sender: TObject; Shift: TShiftState; X, Y: Integer);
		procedure EditarComponent(Sender: TObject);
		function ExportToJSON: TJSONData;
		function GetComponentPropertiesFromJson(AJSON: TJSONObject): TStringList;
		procedure ImportFromJSON(AJSON: TJSONData);
		procedure LimparFormulario;

		procedure OnDeleteComponent(Sender: TObject);
		procedure OnEditarComponent(Sender: TObject);
    procedure StartDrag(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure StopDrag(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  public
		procedure LoadFromJSONString(const AJSONString: string);
		function SaveToJSONString: string;

    procedure AdicionarComponente(AComponentType: TComponentType; LeftPos, TopPos,
				Width, Height: integer; RunTime: boolean); overload;
    procedure AdicionarComponente(AComponentType: TComponentType; PropertiesJson: TStringList; RunTime: boolean; isFromJSON: boolean = false); overload;
    procedure DesativarResize();

    property OnComponentClick: TNotifyEvent read FOnComponentClick write FOnComponentClick;
  end;

implementation

{$R *.lfm}

{ TGuideLine }

constructor TGuideLine.Create(AOwner: TComponent;
		ADirection: TGuideLineDirection; APosition: TGuideLinePosition);
begin
  inherited Create(AOwner);

  case ADirection of
    dtHorizontal:
      begin
        Height := 2;
        Width := TControl(AOwner).Width;
			end;
    dtVertical:
      begin
        Height := TControl(AOwner).Height;
        Width := 2;
			end;
  end;

  Top := APosition.Top;
  Left := APosition.Left;
  Height := APosition.Height;

  Color := $00FFF5B7;
  ParentBackground := False;
  ParentColor := False;
  Parent := TWinControl(AOwner);
end;

{ TComponentsBoard }

procedure TComponentsBoard.AdicionarComponente(AComponentType: TComponentType; LeftPos, TopPos, Width, Height: integer; RunTime: boolean);
var
  NewComponent: TControl;
begin
  NewComponent := TComponentFactory.CreateComponent(Self, AComponentType, RunTime);

  if Assigned(NewComponent) then
  begin
    NewComponent.Left := LeftPos;
    NewComponent.Top := TopPos;

    if Width <> 0 then
      NewComponent.Width:= width;

    if Height <> 0 then
      NewComponent.Height:= Height;

    NewComponent.Parent := Self;
    AssignMouseEvents(NewComponent);
  end;
end;

procedure TComponentsBoard.AdicionarComponente(AComponentType: TComponentType;
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
    AssignMouseEvents(NewComponent);
  end;
end;

procedure TComponentsBoard.DesativarResize();
begin
  if Assigned(FResizeFrame) then
    FreeAndNil(FResizeFrame);
end;

procedure TComponentsBoard.SpeedButton1Click(Sender: TObject);
begin
  if Assigned(FResizeFrame) then
    FreeAndNil(FResizeFrame);

  FResizeFrame := TResizeFrame.Create(Self);
  FResizeFrame.Target := TWinControl(Sender);

  if TControl(Sender).AutoSize then
    TControl(Sender).AutoSize := False
end;

procedure TComponentsBoard.AssignMouseEvents(AComponent: TControl);
begin
  if AComponent is TLabel then
    begin
      TLabel(AComponent).OnMouseDown := StartDrag;
      TLabel(AComponent).OnMouseMove := DoDrag;
      TLabel(AComponent).OnMouseUp := StopDrag;
    end
    else if AComponent is TSpeedButton then
    begin
      TSpeedButton(AComponent).OnMouseDown := StartDrag;
      TSpeedButton(AComponent).OnMouseMove := DoDrag;
      TSpeedButton(AComponent).OnMouseUp := StopDrag;
    end
    else if AComponent is TLabeledEdit then
    begin
      TLabeledEdit(AComponent).OnMouseDown := StartDrag;
      TLabeledEdit(AComponent).OnMouseMove := DoDrag;
      TLabeledEdit(AComponent).OnMouseUp := StopDrag;
    end;

 AComponent.OnClick:= SpeedButton1Click;
end;

procedure TComponentsBoard.StartDrag(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  AbsolutePos: TPoint;
begin
  LastSender := Sender;
  AbsolutePos := TControl(Sender).ClientToScreen(Point(0, 0));

  if Button = mbLeft then
  begin
    DraggingControl := TControl(Sender);
    OffsetX := X;
    OffsetY := Y;
  end;

  if Button = mbRight then
    PopUpHelper.ShowPopupEdicaoComponente(Sender, Self, AbsolutePos.X + X, AbsolutePos.Y + Y, OnEditarComponent, OnDeleteComponent);

  if Assigned(FOnComponentClick) then
    FOnComponentClick(Sender);
end;

procedure TComponentsBoard.OnDeleteComponent(Sender: TObject);
begin
  LastSender.Free;
end;

procedure TComponentsBoard.EditarComponent(Sender: TObject);
var
  ComponenteData: ComponetNameDesc;
begin
  with TControl(Sender) do
  begin
    ComponenteData := GetDescricao(Name, Caption);

    if not ComponenteData.Cancelar then
    begin
      Name := ComponenteData.Name;
      Caption := ComponenteData.Descricao;
		end;

	end;
end;

procedure TComponentsBoard.OnEditarComponent(Sender: TObject);
begin
  EditarComponent(LastSender)
end;

procedure TComponentsBoard.CheckGuideLine(Top, Left, Height, Width: Integer);
var
  Control: TControl;
  Position: TGuideLinePosition;
  i: Integer;
  Distance: Integer;
begin
  if Assigned(FGuideline) then
    FreeAndNil(FGuideline);

  if Self.ControlCount > 1 then
  begin
    for i := 0 to Pred(Self.ControlCount) do
    begin
      Control := Self.Controls[i];

      Distance := Abs(Control.Left - Left);
      if (Distance < 10) then
      begin
        Position.Left := Control.Left;
        Position.Top := Min(Top, Control.Top);
        Position.Height := Max(Top + Height, Control.Top + Control.Height) - Position.Top;
        Position.Width := 2;

        FGuideline := TGuideLine.Create(Self, dtVertical, Position);


        DraggingControl.Left := Control.Left;

        Exit;
      end;

      Distance := Abs(Control.Top - Top);
      if (Distance < 10) then
      begin
        Position.Top := Control.Top;
        Position.Left := Min(Left, Control.Left);
        Position.Width := Max(Left + Width, Control.Left + Control.Width) - Position.Left;
        Position.Height := 2;

        FGuideline := TGuideLine.Create(Self, dtHorizontal, Position);

        DraggingControl.Top := Control.Top;

        Exit;
      end;
    end;
  end;
end;



procedure TComponentsBoard.DoDrag(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  if Assigned(FResizeFrame) then
    FResizeFrame.UpdatePositions;

  if Assigned(DraggingControl) then
  begin
    DraggingControl.Left := DraggingControl.Left + (X - OffsetX);
    DraggingControl.Top := DraggingControl.Top + (Y - OffsetY);

    CheckGuideLine(DraggingControl.Top, DraggingControl.Left, DraggingControl.Height, DraggingControl.Width);
  end;
end;


procedure TComponentsBoard.StopDrag(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Assigned(FResizeFrame) then
    FResizeFrame.UpdatePositions;

  if Assigned(FGuideline) then
    FreeAndNil(FGuideline);

  DraggingControl := nil;
end;

function TComponentsBoard.ExportToJSON: TJSONData;
var
  JSONRoot: TJSONObject;
  ComponentArray: TJSONArray;
  JSONComponent: TJSONObject;
  control: TControl;
  enumName: string;
  i, x: Integer;
  Properties: TStringList;
begin
  JSONRoot := TJSONObject.Create;
  ComponentArray := TJSONArray.Create;

  // Definindo as propriedades gerais do layout
  JSONRoot.Add('width', Self.Width);
  JSONRoot.Add('height', Self.Height);

  for i := 0 to ControlCount - 1 do
  begin
    if Controls[i] is TControl then
    begin
      control := Controls[i];
      JSONComponent := TJSONObject.Create;

      if (Control is TBoundLabel) or (Control is TResizeHandle) then
        continue;

      enumName := GetEnumName(TypeInfo(TComponentType), Ord(GetComponentTypeByName(control.ClassName)));
      JSONComponent.Add('Type', enumName);

      case TComponentType(Ord(GetComponentTypeByName(control.ClassName))) of
        ctTexto:
          begin
            Properties := (Control as IDisplayComponent).GetProperites();
            for x := 0 to Properties.Count - 1 do
              JSONComponent.Add(Properties.Names[x], Properties.ValueFromIndex[x]);
          end;
        ctBotao:
          begin
            Properties := (Control as IActionComponent).GetProperites();
            for x := 0 to Properties.Count - 1 do
              JSONComponent.Add(Properties.Names[x], Properties.ValueFromIndex[x]);
          end;
        ctCampoTexto:
          begin
            Properties := (Control as IInputComponent).GetProperites();
            for x := 0 to Properties.Count - 1 do
              JSONComponent.Add(Properties.Names[x], Properties.ValueFromIndex[x]);
          end;
      end;

      ComponentArray.Add(JSONComponent);
    end;
  end;

  JSONRoot.Add('components', ComponentArray);
  Result := JSONRoot;
end;


procedure TComponentsBoard.LimparFormulario;
var
  i: Integer;
begin
  for i := ComponentCount - 1 downto 0 do
    Components[i].Free;
end;

function TComponentsBoard.GetComponentPropertiesFromJson(AJSON: TJSONObject): TStringList;
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


procedure TComponentsBoard.ImportFromJSON(AJSON: TJSONData);
var
  i: Integer;
  JSONRoot, JSONComponent: TJSONObject;
  JSONComponentArray: TJSONArray;
  ComponentType: string;
  PropertiesJson: TStringList;
  JsonString: string;
begin
  if not (AJSON is TJSONObject) then
    Exit;

  // Converte AJSON para um objeto JSONRoot
  JSONRoot := AJSON as TJSONObject;
  JsonString := JSONRoot.AsJSON;;
  // Define as propriedades do formulário
  Self.Width := JSONRoot.Get('width', Self.Width);
  Self.Height := JSONRoot.Get('height', Self.Height);

  // Obtém o array de componentes
  JSONComponentArray := JSONRoot.Get('components', TJSONArray.Create);

  // Limpa os componentes atuais antes de importar novos
  LimparFormulario;

  // Itera sobre os componentes e os recria
  for i := 0 to JSONComponentArray.Count - 1 do
  begin
    JSONComponent := JSONComponentArray.Items[i] as TJSONObject;
    PropertiesJson := GetComponentPropertiesFromJson(JSONComponent);
    ComponentType := JSONComponent.Get('Type', '');

    AdicionarComponente(TComponentType(GetEnumValue(TypeInfo(TComponentType), ComponentType)), PropertiesJson, True, True);
  end;
end;



function TComponentsBoard.SaveToJSONString: string;
var
  JSONData: TJSONData;
begin
  JSONData := ExportToJSON;
  try
    Result := JSONData.AsJSON;
  finally
    JSONData.Free;
  end;
end;

procedure TComponentsBoard.LoadFromJSONString(const AJSONString: string);
var
  JSONData: TJSONData;
begin
  if AJSONString = '' then
    Exit;

  JSONData := GetJSON(AJSONString);
  try
    ImportFromJSON(JSONData);
  finally
    JSONData.Free;
  end;
end;



end.

