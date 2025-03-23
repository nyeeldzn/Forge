unit Form.Utils.EventEditForm;

{$mode Delphi}

interface

uses
  SysUtils,
  Classes,
  Controls,
  Forms,
  StdCtrls,
  Form.Utils.Component.Events,
  Form.Utils.ComponentFactory.Interfaces,
  Dialogs,
  Generics.Collections,
  Form.Utils.ComponentFactory.Components;

type

	{ TEventEditForm }

  TEventEditForm = class(TForm)
  private
    FEditEventName : TEdit;
    FComboAction: TComboBox;
    FComboInput: TComboBox;
    FComboDisplay: TComboBox;
    FComponentHolder: TComponent;
    FBtnSave: TButton;
    FBtnCancel: TButton;
    FBtnTeste: TButton;
    FEventManager: TEventManager;
    FEvent: TComponentEvent;
    FConfirmed: Boolean;

    procedure LoadComponents;
    procedure BtnSaveClick(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
    procedure BtnTestarClick(Sender: TObject);
  public
    constructor CreateNew(AEventManager: TEventManager; AComponentHolder: TComponent); reintroduce;
    class function EditEvent(var AEvent: TComponentEvent;
				AEventManager: TEventManager; AComponentHolder: TComponent): Boolean;
  end;

implementation

constructor TEventEditForm.CreateNew(AEventManager: TEventManager;
  AComponentHolder: TComponent);
const
  MarginX = 20;   // Margem padrão à esquerda
  LabelWidth = 100; // Largura dos rótulos
  FieldWidth = 200; // Largura dos campos de entrada
  SpacingY = 10;  // Espaçamento vertical entre os elementos
var
  BaseY: Integer; // Posição Y base para os componentes
begin
  inherited CreateNew(nil);

  Self.Width := 400;
  Self.Height := 280;
  Self.Caption := 'Editar Evento';
  Self.Position := poScreenCenter;

  FEventManager := AEventManager;
  FConfirmed := False;
  FComponentHolder := AComponentHolder;

  BaseY := 20;

  // Nome do Evento
  with TLabel.Create(Self) do
  begin
    Parent := Self;
    Caption := 'Nome do Evento:';
    Left := MarginX;
    Top := BaseY;
  end;

  FEditEventName := TEdit.Create(Self);
  with FEditEventName do
  begin
    Parent := Self;
    Left := MarginX + LabelWidth;
    Top := BaseY;
    Width := FieldWidth;
  end;

  Inc(BaseY, 40);

  // Ação (Botão)
  with TLabel.Create(Self) do
  begin
    Parent := Self;
    Caption := 'Ação (Botão):';
    Left := MarginX;
    Top := BaseY;
  end;

  FComboAction := TComboBox.Create(Self);
  with FComboAction do
  begin
    Parent := Self;
    Left := MarginX + LabelWidth;
    Top := BaseY;
    Width := FieldWidth;
    Style := csDropDownList;
  end;

  Inc(BaseY, 40);

  // Origem (Entrada)
  with TLabel.Create(Self) do
  begin
    Parent := Self;
    Caption := 'Origem (Entrada):';
    Left := MarginX;
    Top := BaseY;
  end;

  FComboInput := TComboBox.Create(Self);
  with FComboInput do
  begin
    Parent := Self;
    Left := MarginX + LabelWidth;
    Top := BaseY;
    Width := FieldWidth;
    Style := csDropDownList;
  end;

  Inc(BaseY, 40);

  // Destino (Saída)
  with TLabel.Create(Self) do
  begin
    Parent := Self;
    Caption := 'Destino (Saída):';
    Left := MarginX;
    Top := BaseY;
  end;

  FComboDisplay := TComboBox.Create(Self);
  with FComboDisplay do
  begin
    Parent := Self;
    Left := MarginX + LabelWidth;
    Top := BaseY;
    Width := FieldWidth;
    Style := csDropDownList;
  end;

  Inc(BaseY, 50); // Aumenta o espaço antes dos botões

  // Botões - Organizados horizontalmente no centro
  FBtnSave := TButton.Create(Self);
  with FBtnSave do
  begin
    Parent := Self;
    Caption := 'Salvar';
    Width := 80;
    Left := (Self.Width div 2) - 120;
    Top := BaseY;
    OnClick := BtnSaveClick;
  end;

  FBtnCancel := TButton.Create(Self);
  with FBtnCancel do
  begin
    Parent := Self;
    Caption := 'Cancelar';
    Width := 80;
    Left := (Self.Width div 2) - 30;
    Top := BaseY;
    OnClick := BtnCancelClick;
  end;

  FBtnTeste := TButton.Create(Self);
  with FBtnTeste do
  begin
    Parent := Self;
    Caption := 'Testar';
    Width := 80;
    Left := (Self.Width div 2) + 60;
    Top := BaseY;
    OnClick := BtnTestarClick;
  end;

  // Carregar componentes disponíveis
  LoadComponents;
end;


procedure TEventEditForm.LoadComponents;
var
  i: Integer;
  Component: TComponent;
begin
  // Obtém os componentes disponíveis do formulário principal
  for i := 0 to TForm(FComponentHolder).ComponentCount - 1 do
  begin
    Component := TForm(FComponentHolder).Components[i];

    // Adiciona os componentes às listas apropriadas
    if Supports(Component, IActionComponent) then
      FComboAction.Items.Add(Component.Name);

    if Supports(Component, IInputComponent) then
      FComboInput.Items.Add(Component.Name);

    if Supports(Component, IDisplayComponent) then
      FComboDisplay.Items.Add(Component.Name);
  end;
end;

procedure TEventEditForm.BtnSaveClick(Sender: TObject);
begin
  if
    (FEditEventName.Text = '') or
    (FComboAction.ItemIndex = -1) or
    (FComboInput.ItemIndex = -1) or
    (FComboDisplay.ItemIndex = -1)
  then
  begin
    ShowMessage('Preencha todos os campos.');
    Exit;
  end;

  // Salva os valores no evento


  // Verifica e atribui TriggerComponent
  FEvent.TriggerComponent := TForm(FComponentHolder).FindComponent(FComboAction.Text) as IActionComponent;
  FEvent.SourceComponent := TForm(FComponentHolder).FindComponent(FComboInput.Text) as IInputComponent;
  FEvent.TargetComponent := TForm(FComponentHolder).FindComponent(FComboDisplay.Text) as IDisplayComponent;
  FEvent.EventName := FEditEventName.Text;

  FConfirmed := True;
  Close;
end;


procedure TEventEditForm.BtnCancelClick(Sender: TObject);
begin
  FConfirmed := False;
  Close;
end;

procedure TEventEditForm.BtnTestarClick(Sender: TObject);
var
  TestEvent: TComponentEvent;
begin
  if
      (FEditEventName.Text = '') or
      (FComboAction.ItemIndex = -1) or
      (FComboInput.ItemIndex = -1) or
      (FComboDisplay.ItemIndex = -1)
  then
  begin
      ShowMessage('Preencha todos os campos.');
      Exit;
  end;

  TestEvent := TComponentEvent.Create('');

  TestEvent.TriggerComponent := TForm(FComponentHolder).FindComponent(FComboAction.Text) as IActionComponent;
  TestEvent.SourceComponent := TForm(FComponentHolder).FindComponent(FComboInput.Text) as IInputComponent;
  TestEvent.TargetComponent := TForm(FComponentHolder).FindComponent(FComboDisplay.Text) as IDisplayComponent;
  TestEvent.EventName := FEditEventName.Text;

  TestEvent.Execute(Sender);
end;

class function TEventEditForm.EditEvent(var AEvent: TComponentEvent;
		AEventManager: TEventManager; AComponentHolder: TComponent): Boolean;
var
  Form: TEventEditForm;
begin
  Form := TEventEditForm.CreateNew(AEventManager, AComponentHolder);
  try
    Form.FEvent := AEvent;

    if
      Assigned(Form.FEvent) and
      (Form.FEvent.EventName <> '')
    then
    begin
      Form.FEditEventName.Text := AEvent.EventName;
      Form.FComboAction.ItemIndex := Form.FComboAction.Items.IndexOf((AEvent.TriggerComponent as TComponent).Name);
      Form.FComboInput.ItemIndex := Form.FComboInput.Items.IndexOf((AEvent.SourceComponent as TComponent).Name);
      Form.FComboDisplay.ItemIndex := Form.FComboDisplay.Items.IndexOf((AEvent.TargetComponent as TComponent).Name);
		end;

    Form.ShowModal;
    Result := Form.FConfirmed;

    if Result then
      AEvent := Form.FEvent;
  finally
    Form.Free;
  end;
end;

end.

