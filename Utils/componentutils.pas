unit ComponentUtils;

{$mode ObjFPC}{$H+}

interface

uses
  Forms,
  Classes,
  SysUtils,
  Form.Utils.NewComponentPopUp;

type
	  ComponetNameDesc = record
	    Name: string;
	    Descricao: string;
	    Cancelar: boolean;
	  end;

function GetDescricao(AName, ADescricao: string): ComponetNameDesc;

function CountComponentsByType(AForm: TForm; AComponentType: TComponentClass): Integer;

implementation

function GetDescricao(AName, ADescricao: string): ComponetNameDesc;
var
  ComponentPopUp: TNewComponentPopUp;
begin
  ComponentPopUp:= TNewComponentPopUp.Create(AName, Adescricao);
  try
    ComponentPopUp.ShowModal;

    if ComponentPopUp.ComponentValues.Nome <> '' then
    begin
      Result.Name := ComponentPopUp.ComponentValues.Nome
		end
		else
    begin
      Result.Name := AName;
		end;

    if ComponentPopUp.ComponentValues.Descricao <> '' then
    begin
      Result.Descricao := ComponentPopUp.ComponentValues.Descricao;
		end
		else
    begin
      Result.Descricao := 'Loren ipsun';
		end;

    Result.Cancelar:= ComponentPopUp.Cancelar
    ;

	finally
    ComponentPopUp.Free;
	end;
end;

function CountComponentsByType(AForm: TForm; AComponentType: TComponentClass): Integer;
var
  i: Integer;
  Component: TComponent;
begin
  Result := 0;  // Inicializa o contador
  // Percorre todos os componentes do formulário
  for i := 0 to AForm.ComponentCount - 1 do
  begin
    Component := AForm.Components[i];
    // Verifica se o tipo do componente corresponde ao tipo fornecido
    if Component is AComponentType then
      Inc(Result);  // Incrementa o contador se for do tipo correto
  end;
end;

end.

