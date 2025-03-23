unit Form.Utils.ToolBar;

{$mode Delphi}{$H+}

interface

uses
    Classes, SysUtils, Forms, Controls, Buttons;

type
    TToolType = (
      ttOpenFile,
      ttSaveFile,
      ttRun,
      ttStop
    );

const
    TToolNames: array[TToolType] of string = (
      'Abrir',
      'Salvar',
      'Executar',
      'Parar'
    );

    TToolIconIndex: array[TToolType] of integer = (
      0,
      2,
      1,
      3
    );

  TOOL_COMPONENTS: array of TToolType = [
    ttOpenFile,
    ttSaveFile,
    ttRun,
    ttStop
  ];

var
  FToolAction: array[TToolType] of TNotifyEvent;

type

		{ TToolButton }

    TToolButton = class(TSpeedButton)
      constructor Create(AOwner: TComponent; ATool: TToolType; AImages: TImageList);
					reintroduce;
    end;


		{ TToolBarFrame }

    TToolBarFrame = class(TFrame)
				ImageList1: TImageList;
    private
      FOnAbrirClick: TNotifyEvent;
      FOnSalvarClick: TNotifyEvent;
      FOnExecutarClick: TNotifyEvent;
      FOnPararClick: TNotifyEvent;


      procedure CriarTool(ATool: TToolType; AOnClick: TNotifyEvent);
			procedure HandleAbrirToolClick(Sender: TObject);
			procedure HandleExecutarToolClick(Sender: TObject);
			procedure HandlePararToolClick(Sender: TObject);
			procedure HandleSalvarToolClick(Sender: TObject);
    public
      constructor Create(AOwner: TComponent); reintroduce;

      property OnAbrirClick: TNotifyEvent read FOnAbrirClick write FOnAbrirClick;
      property OnSalvarClick: TNotifyEvent read FOnSalvarClick write FOnSalvarClick;
      property OnExecutarClick: TNotifyEvent read FOnExecutarClick write FOnExecutarClick;
      property OnPararClick: TNotifyEvent read FOnPararClick write FOnPararClick;
    end;

implementation

{$R *.lfm}

{ TToolButton }

constructor TToolButton.Create(AOwner: TComponent; ATool: TToolType; AImages: TImageList);
begin
  inherited Create(AOwner);

  Height := 27;
  Width := 27;
  Align := alLeft;
  Hint := TToolNames[ATool];
  Images := AImages;
  ImageIndex:= TToolIconIndex[ATool];
  BorderSpacing.Left := 3;
  BorderSpacing.Top := 5;
  BorderSpacing.Bottom := 5;
  Parent := TWinControl(AOwner);
end;

{ TToolBarFrame }

procedure TToolBarFrame.HandleAbrirToolClick(Sender: TObject);
begin
    //
end;

procedure TToolBarFrame.HandleSalvarToolClick(Sender: TObject);
begin
    //
end;

procedure TToolBarFrame.HandleExecutarToolClick(Sender: TObject);
begin
    //
end;

procedure TToolBarFrame.HandlePararToolClick(Sender: TObject);
begin
    //
end;

procedure TToolBarFrame.CriarTool(ATool: TToolType; AOnClick: TNotifyEvent);
var
  ToolButton: TToolButton;
begin
  ToolButton := TToolButton.Create(Self, ATool, ImageList1);
  ToolButton.OnClick:= AOnClick;
end;

constructor TToolBarFrame.Create(AOwner: TComponent);
var
  Tool: TToolType;
  i: Integer;
begin
  inherited;

  FToolAction[ttOpenFile] := HandleAbrirToolClick;
  FToolAction[ttSaveFile] := HandleSalvarToolClick;
  FToolAction[ttRun] := HandleExecutarToolClick;
  FToolAction[ttStop] := HandlePararToolClick;

  for i := High(TOOL_COMPONENTS) downto Low(TOOL_COMPONENTS) do
  begin
    Tool := TOOL_COMPONENTS[i];
    CriarTool(Tool, FToolAction[Tool]);
  end;
end;

end.

