unit Form.Utils.PalleteTools;

{$mode Delphi}{$H+}

interface

uses
    Classes,
    SysUtils,
    Forms,
    Controls,
    Buttons,
    StdCtrls,
    LCLIntf,
    LCLType,
    Graphics, ExtCtrls;

type
    TComponentType = (ctTexto, ctBotao, ctCampoTexto);

const
    TComponentTypeNames: array[TComponentType] of string = (
      'Texto',
      'Botão',
      'Campo de Texto'
    );

    TComponentName: array[TComponentType] of string = (
      'TLabel',
      'TSpeedButton',
      'TLabeledEdit'
    );

    TComponentIconIndex: array[TComponentType] of integer = (
      2,
      0,
      1
    );

type
    IToolAction = interface
      ['{42EBFA37-3B55-0B95-6E71-2E4E13E714A5}']

      function GetToolType: TComponentType;
      procedure SetToolType(AType: TComponentType);

      function GetSelecionado: boolean;
      procedure SetSelecionado(ASelecionado: Boolean);

      property ToolType: TComponentType read GetToolType write SetToolType;
      property Selecionado: boolean read GetSelecionado write SetSelecionado;
    end;

		{ TBotaoDesignAction }

		{ TSpeedButton }

    TSpeedButton = class(Buttons.TSpeedButton, IToolAction)
      private
        FToolType: TComponentType;
        FSelecionado: boolean;

        function GetToolType: TComponentType;
        procedure SetToolType(AType: TComponentType);

        function GetSelecionado: boolean;
        procedure SetSelecionado(ASelecionado: Boolean);
      public
        property ToolType: TComponentType read GetToolType write SetToolType;
        property Selecionado: boolean read GetSelecionado write SetSelecionado;
    end;

		{ TPalleteTools }

    TPalleteTools = class(TFrame)
        FBotaoSelecionado: TSpeedButton;
				ImageList1: TImageList;
				ScrollBox1: TScrollBox;

        procedure onToolButtonClick(ASender: TObject);
    private
      FListaComponentes: TArray<TComponentType>;

      procedure InicializarComponentes;
      procedure CreateComponente(AComponentType: TComponentType);
    public
      constructor Create(AOwner: TComponent; AComponents: TArray<TComponentType>);
					reintroduce;

      procedure LimparSelecao();
      property BotaoSelecionado: TSpeedButton read FBotaoSelecionado write FBotaoSelecionado;
    end;

function GetComponentTypeByName(const AName: string): TComponentType;

implementation

{$R *.lfm}

{ TSpeedButton }

function TSpeedButton.GetToolType: TComponentType;
begin
  Result := FToolType
end;

procedure TSpeedButton.SetToolType(AType: TComponentType);
begin
  FToolType := AType;
end;

function TSpeedButton.GetSelecionado: boolean;
begin
  Result := FSelecionado;
end;

procedure TSpeedButton.SetSelecionado(ASelecionado: Boolean);
begin
  FSelecionado := ASelecionado;
  Flat := FSelecionado;
end;

{ TPalleteTools }

procedure TPalleteTools.onToolButtonClick(ASender: TObject);
begin
  if FBotaoSelecionado <> TSpeedButton(ASender) then
  begin
    if Assigned(FBotaoSelecionado) then
      FBotaoSelecionado.Selecionado:= False;

    FBotaoSelecionado := TSpeedButton(ASender);
    TSpeedButton(ASender).Selecionado:= True;
	end
	else
  begin
    FBotaoSelecionado := nil;
    TSpeedButton(ASender).Selecionado:= False;
	end;
end;

procedure TPalleteTools.InicializarComponentes;
var
  ComponentType : TComponentType;
begin
  for ComponentType in FListaComponentes do
  begin
    CreateComponente(ComponentType);
	end;
end;

procedure TPalleteTools.CreateComponente(AComponentType: TComponentType);
begin
  with TSpeedButton.Create(Self) do
  begin
    Caption := TComponentTypeNames[AComponentType];
    ToolType := AComponentType;
    Images := ImageList1;
    ImageIndex := TComponentIconIndex[AComponentType];
    Parent := ScrollBox1;
    Align := alTop;
    OnClick := onToolButtonClick;
	end;
end;

constructor TPalleteTools.Create(AOwner: TComponent; AComponents: TArray<TComponentType>);
begin
   inherited Create(AOwner);

   FListaComponentes := AComponents;

   InicializarComponentes();
end;

procedure TPalleteTools.LimparSelecao();
begin
  if Assigned(FBotaoSelecionado) then
    FBotaoSelecionado.Selecionado:= False;

  FBotaoSelecionado := nil;
end;


function GetComponentTypeByName(const AName: string): TComponentType;
var
  Component: TComponentType;
begin
  for Component := Low(TComponentType) to High(TComponentType) do
  begin
    if TComponentName[Component] = AName then
      Exit(Component);
  end;

end;


end.



