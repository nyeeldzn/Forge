unit Form.Utils.ComponentFactory;

{$mode Delphi}{$H+}

interface

uses
  Classes,
  SysUtils,
  Controls,
  Buttons,
  Forms,
  Form.Utils.PalleteTools,
  Form.Utils.ComponentFactory.Interfaces,
  ComponentUtils,
  Form.Utils.ComponentFactory.Components;

type

	{ TComponentFactory }

  TComponentFactory = class
  public
    class function CreateComponent(AOwner: TWinControl;
				AComponentType: TComponentType; Runtime: boolean; isFromJson: boolean=false
		): TControl;
    class function GetComponentFromTObject(AComponent: TObject): IComponentBase;
  end;

implementation

class function TComponentFactory.CreateComponent(AOwner: TWinControl; AComponentType: TComponentType; Runtime: boolean; isFromJson: boolean = false): TControl;
var
  ComponenteData: ComponetNameDesc;
  Name: string;
  Caption: string;
begin
  case AComponentType of
    ctTexto:
    begin
      Name := 'TLabel' + CountComponentsByType(TForm(AOwner), TLabel).ToString;
      Caption := 'Loren Ipsun';

      if not isFromJson then
      begin
        // Se não for em tempo de execução, obter dados de descrição
        ComponenteData := GetDescricao(Name, Caption);
        if not ComponenteData.Cancelar then
        begin
          Result := TLabel.Create(AOwner);

          TLabel(Result).AutoSize := not isFromJson;
          TLabel(Result).Name := ComponenteData.Name;
          TLabel(Result).Caption := ComponenteData.Descricao;
        end
      end
      else
      begin
        // Se for em tempo de execução, criar diretamente com valores padrão
        Result := TLabel.Create(AOwner);

        TLabel(Result).AutoSize := not isFromJson;
        TLabel(Result).Name := Name;
        TLabel(Result).Caption := Caption;
      end;
    end;

    ctBotao:
    begin
      Name := 'TSpeedButton' + CountComponentsByType(TForm(AOwner), TSpeedButton).ToString;
      Caption := 'Loren Ipsun';

      if not isFromJson then
      begin
        // Se não for em tempo de execução, obter dados de descrição
        ComponenteData := GetDescricao(Name, Caption);
        if not ComponenteData.Cancelar then
        begin
          Result := TSpeedButton.Create(AOwner);
            TSpeedButton(Result).AutoSize := not isFromJson;
            TSpeedButton(Result).Name := ComponenteData.Name;
            TSpeedButton(Result).Caption := ComponenteData.Descricao;
        end;
      end
      else
      begin
        // Se for em tempo de execução, criar diretamente com valores padrão
        Result := TSpeedButton.Create(AOwner);

        with TSpeedButton(Result) do
        begin
          TSpeedButton(Result).AutoSize := not isFromJson;
          TSpeedButton(Result).Name := Name;
          TSpeedButton(Result).Caption := Caption;
        end;
      end;
    end;

    ctCampoTexto:
    begin
      Name := 'TLabeledEdit' + CountComponentsByType(TForm(AOwner), TLabeledEdit).ToString;
      Caption := 'Loren Ipsun';

      if not isFromJson then
      begin
        // Se não for em tempo de execução, obter dados de descrição
        ComponenteData := GetDescricao(Name, Caption);
        if not ComponenteData.Cancelar then
        begin
          Result := TLabeledEdit.Create(AOwner);

          TLabeledEdit(Result).AutoSize := not isFromJson;
          TLabeledEdit(Result).EditLabel.Caption := ComponenteData.Descricao;
          TLabeledEdit(Result).Name := ComponenteData.Name;
        end;
      end
      else
      begin
        // Se for em tempo de execução, criar diretamente com valores padrão
        Result := TLabeledEdit.Create(AOwner);

	      TLabeledEdit(Result).AutoSize := not isFromJson;
	      TLabeledEdit(Result).EditLabel.Caption := Caption;
	      TLabeledEdit(Result).Name := Name;

      end;
    end;
  else
    Result := nil;
  end;

  if Assigned(Result) then
  begin
    Result.Parent := AOwner;
  end;
end;


class function TComponentFactory.GetComponentFromTObject(AComponent: TObject
		): IComponentBase;
var
  Comp: TControl;
begin

  if AComponent is TLabel then
    Comp := TLabel(AComponent)
  else
  if AComponent is TSpeedButton then
    Comp := TSpeedButton(AComponent)
  else
  if AComponent is TLabeledEdit then
    Comp := TLabeledEdit(AComponent);
end;



end.

