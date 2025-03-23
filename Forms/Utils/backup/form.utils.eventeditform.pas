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
begin
  inherited CreateNew(nil);

  Self.Width := 350;
  Self.Height := 250;
  Self.Caption := 'Editar Evento';
  Self.Position := poScreenCenter;

  FEventManager := AEventManager;
  FConfirmed := False;
  FComponentHolder := AComponentHolder;

  // Labels
  with TLabel.Create(Self) do
  begin
    Parent := Self;
    Caption := 'Nome do Evento:';
    Left := 20;
    Top := 20;
  end;

  with TLabel.Create(Self) do
  begin
    Parent := Self;
    Caption := 'Ação (Botão):';
    Left := 20;
    Top := 60;
  end;

  with TLabel.Create(Self) do
  begin
    Parent := Self;
    Caption := 'Origem (Entrada):';
    Left := 20;
    Top := 100;
  end;

  with TLabel.Create(Self) do
  begin
    Parent := Self;
    Caption := 'Destino (Saída):';
    Left := 20;
    Top := 140;
  end;

  // Campo de Nome do Evento
  FEditEventName := TEdit.Create(Self);
  FEditEventName.Parent := Self;
  FEditEventName.Left := 120;
  FEditEventName.Top := 20;
  FEditEventName.Width := 200;

  // Combos
  FComboAction := TComboBox.Create(Self);
  FComboAction.Parent := Self;
  FComboAction.Left := 120;
  FComboAction.Top := 60;
  FComboAction.Width := 200;
  FComboAction.Style := csDropDownList;

  FComboInput := TComboBox.Create(Self);
  FComboInput.Parent := Self;
  FComboInput.Left := 120;
  FComboInput.Top := 100;
  FComboInput.Width := 200;
  FComboInput.Style := csDropDownList;

  FComboDisplay := TComboBox.Create(Self);
  FComboDisplay.Parent := Self;
  FComboDisplay.Left := 120;
  FComboDisplay.Top := 140;
  FComboDisplay.Width := 200;
  FComboDisplay.Style := csDropDownList;

  // Botão Salvar
  FBtnSave := TButton.Create(Self);
  FBtnSave.Parent := Self;
  FBtnSave.Caption := 'Salvar';
  FBtnSave.Left := 50;
  FBtnSave.Top := 180;
  FBtnSave.OnClick := BtnSaveClick;

  // Botão Cancelar
  FBtnCancel := TButton.Create(Self);
  FBtnCancel.Parent := Self;
  FBtnCancel.Caption := 'Cancelar';
  FBtnCancel.Left := 180;
  FBtnCancel.Top := 180;
  FBtnCancel.OnClick := BtnCancelClick;

  FBtnTeste := TButton.Create(Self);
  FBtnTeste.Parent := Self;
  FBtnTeste.Caption := 'Testar';
  FBtnTeste.Left := 310;
  FBtnTeste.Top := 180;
  FBtnTeste.OnClick := BtnTestarClick;

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

