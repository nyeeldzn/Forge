unit DesignTimeForm;

{$mode Delphi}{$H+}

interface

uses
    Classes,
    SysUtils,
    Forms,
    Controls,
    Graphics,
    Dialogs,
    ExtCtrls,
    StdCtrls,
		Form.Utils.PalleteTools,
    Form.Utils.ComponentsBoard,
    Form.Utils.ToolBar,
    Form.Utils.ComponentProperties,
    Form.Utils.ComponentFactory,
    Form.Utils.ComponentFactory.Interfaces,
    Form.Utils.EventManager,
    Form.Utils.Component.Events,
		AnchorDockPanel,
    FileUtils,
    Form.Utils.ComponentFactory.Components,
    JSONUtils,
    Form.Utils.RuntimeForm;

const
  LISTA_COMPONENTES: array of TComponentType = [
    ctTexto,
    ctCampoTexto,
    ctBotao
  ];

type

		{ TForm1 }

    TForm1 = class(TForm)
				DesignBoard: TComponentsBoard ;
				PalleteTools1: TPalleteTools;
				pnlPalleteTools: TPanel;
				pnlComponentProperties: TPanel;
				ActionBar: TPanel;
				Splitter1: TSplitter;
				ToolBarFrame1: TToolBarFrame;
				procedure DesignBoardMouseDown(Sender: TObject; Button: TMouseButton;
						Shift: TShiftState; X, Y: Integer);
				procedure FormCreate(Sender: TObject);
    procedure FormDragOver(Sender, Source: TObject; X, Y: Integer;
						State: TDragState; var Accept: Boolean);
		private
        RuntimeForm: TRunTimeForm;

        procedure SetFileName(AValue: string);
    private
      FFileName: string;
      ComponentProperties1: TComponentProperties;
      FEventManagerPanel: TEventManagerPanel;
      FEventManager: TEventManager;

      procedure OnAbrirToolClick(Sender: TObject);
      procedure OnSalvarToolClick(Sender: TObject);
      procedure OnExecutarToolClick(Sender: TObject);
      procedure OnPararToolClick(Sender: TObject);

      procedure OnComponentClick(Sender: TObject);

      procedure OnAbrirPropriedades(Sender: TObject);
      procedure OnAbrirEventos(Sender: TObject);

      property FileName: string read FFileName write SetFileName;
    public

    end;

var
    Form1: TForm1;

implementation

uses
  Constants;

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormDragOver(Sender, Source: TObject; X, Y: Integer;
		State: TDragState; var Accept: Boolean);
begin
    accept := Source is Form.Utils.PalleteTools.TSpeedButton;
end;

procedure TForm1.SetFileName(AValue: string);
begin
  if FFileName=AValue then Exit;
		FFileName:=AValue;

  Caption := FFileName + ' - Forge';
end;

procedure TForm1.OnAbrirToolClick(Sender: TObject);
var
  LFileName: string;
  LComponents: string;
  LEvents: string;
begin
  if FileName = '' then
  begin
    if MessageDlg('Arquivo Pendente', 'Deseja sair sem salvar o arquivo atual?', mtConfirmation, [mbYes, mbNo], 0) = mrNo then
      abort;
	end;

  LFileName := SelectOpenFile();

  if LFileName <> '' then
  begin
    FileName := LFileName;

    TJSONStorage.LoadFromFile(
      LFileName,
      LComponents,
      LEvents
    );

    DesignBoard.LoadFromJSONString(LComponents);
    FEventManager.LoadFromJson(LEvents, DesignBoard);
	end;
end;

procedure TForm1.OnComponentClick(Sender: TObject);
begin
  OnAbrirPropriedades(Sender);
  OnAbrirEventos(Sender);
end;

procedure TForm1.OnSalvarToolClick(Sender: TObject);
begin
  if FileName = '' then
    FileName := SelectSaveFile();


  if FileName <> '' then
    TJSONStorage.SaveToFile(
      FileName,
      DesignBoard.SaveToJSONString,
      FEventManager.SaveToJson
    );
end;

procedure TForm1.OnExecutarToolClick(Sender: TObject);
begin
  if FileName = '' then
    FileName := SelectSaveFile();

  if FileName <> '' then
  begin
    RuntimeForm:= TRunTimeForm.Create(Self, FileName);
    RuntimeForm.Show();
	end
end;

procedure TForm1.OnPararToolClick(Sender: TObject);
begin
  if Assigned(RuntimeForm) then
  begin
    RuntimeForm.Close;

    FreeAndNil(RuntimeForm);
	end;
end;

procedure TForm1.OnAbrirPropriedades(Sender: TObject);
begin
  if Assigned(ComponentProperties1) then
    FreeAndNIl(ComponentProperties1);

  pnlComponentProperties.Visible:= True;
  ComponentProperties1 := TComponentProperties.Create(self);
  ComponentProperties1.Width:= 300;
  ComponentProperties1.Align:= alClient;
  ComponentProperties1.Parent := pnlComponentProperties;

  if Sender is TLabel then
  begin
    ComponentProperties1.ListarPropriedades(TLabel(Sender));
  end
  else
  if Sender is TSpeedButton then
  begin
    ComponentProperties1.ListarPropriedades(TSpeedButton(Sender));
  end
  else
  if Sender is TLabeledEdit then
  begin
    ComponentProperties1.ListarPropriedades(TLabeledEdit(Sender));
  end;

end;

procedure TForm1.OnAbrirEventos(Sender: TObject);
begin
//
end;

procedure TForm1.DesignBoardMouseDown(Sender: TObject; Button: TMouseButton;
		Shift: TShiftState; X, Y: Integer);
begin
  DesignBoard.DesativarResize();

  if Assigned(ComponentProperties1) then
  begin
    FreeAndNil(ComponentProperties1);
    pnlComponentProperties.Visible:= False;
	end;

  if Button = mbLeft then
  begin
    if Assigned(PalleteTools1.BotaoSelecionado) then
      begin
        DesignBoard.AdicionarComponente(PalleteTools1.BotaoSelecionado.ToolType, X, Y, 0, 0, False);
        PalleteTools1.LimparSelecao();
			end;
	end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  MODO_EDICAO := True;

  PalleteTools1 := TPalleteTools.Create(Self, LISTA_COMPONENTES);
  PalleteTools1.Parent := pnlPalleteTools;

  ToolBarFrame1:= TToolBarFrame.Create(Self);
  ToolBarFrame1.Parent := ActionBar;
  ToolBarFrame1.OnAbrirClick:= OnAbrirToolClick;
  ToolBarFrame1.OnSalvarClick:= OnSalvarToolClick;
  ToolBarFrame1.OnExecutarClick:= OnExecutarToolClick;
  ToolBarFrame1.OnPararClick:= OnPararToolClick;

  DesignBoard.OnComponentClick:= OnComponentClick;

  FEventManager := TEventManager.Create;

  FEventManagerPanel:= TEventManagerPanel.Create(Self, DesignBoard);
  FEventManagerPanel.Parent := pnlComponentProperties;
  FEventManagerPanel.Align:= alBottom;
  FEventManagerPanel.SetEventManager(FEventManager);

  FEventManager.AfterInitialize:= FEventManagerPanel.RenderEventList;
end;

end.

