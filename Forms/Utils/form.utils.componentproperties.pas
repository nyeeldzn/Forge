unit Form.Utils.ComponentProperties;

{$mode Delphi}{$H+}

interface

uses
    Classes,
    SysUtils,
    Forms,
    Controls,
    ValEdit,
    Grids,
    TypInfo,
    Variants,
    Rtti,
    Form.Utils.ComponentFactory.Interfaces,
    Generics.Collections;

type

		{ TComponentProperties }

    TComponentProperties = class(TFrame)
				ValueListEditor1: TValueListEditor;
				procedure ValueListEditor1SetEditText(Sender: TObject; ACol,
						ARow: Integer; const Value: string);
    private
       ComponenteSelecionado : TComponent;
			 procedure ListarPropriedadesInterno(Comp: IInterface);
    public

     procedure ListarPropriedades(Comp: IInputComponent); overload;
     procedure ListarPropriedades(Comp: IActionComponent); overload;
     procedure ListarPropriedades(Comp: IDisplayComponent); overload;
    end;

implementation

uses
  ArrayUtils;

{$R *.lfm}

procedure TComponentProperties.ValueListEditor1SetEditText(Sender: TObject;
  ACol, ARow: Integer; const Value: string);
var
  NomeProp: string;
  ctx: TRttiContext;
  tipo: TRttiType;
  prop: TRttiProperty;
  propValue: TValue;

begin
  if Assigned(ComponenteSelecionado) then
  begin
    NomeProp := ValueListEditor1.Keys[ARow];
    ctx := TRttiContext.Create;
    try
      tipo := ctx.GetType(ComponenteSelecionado.ClassType);
      prop := tipo.GetProperty(NomeProp);
      if Assigned(prop) then
      begin
        // Verifica se a propriedade é pública ou publicada antes de alterar seu valor
        if (prop.Visibility in [mvPublic, mvPublished]) and prop.IsWritable then
        begin
          case prop.PropertyType.TypeKind of
            tkInteger:
              propValue := StrToIntDef(Value, 0);
            tkFloat:
              propValue := StrToFloatDef(Value, 0.0);
            tkChar, tkWChar, tkString, tkAString, tkLString, tkWString, tkUString:
              propValue := Value;
          else
            Exit;
          end;
          prop.SetValue(ComponenteSelecionado, propValue);
        end
        else
        begin
          // Se a propriedade não for pública ou publicada, você pode exibir uma mensagem ou registrar um log
          Writeln('Propriedade "' + NomeProp + '" não é pública ou publicada e não pode ser alterada.');
        end;
      end;
    finally
      ctx.Free;
    end;
  end;
end;

procedure TComponentProperties.ListarPropriedadesInterno(Comp: IInterface);
var
  ctx: TRttiContext;
  tipo: TRttiType;
  prop: TRttiProperty;
  Componente: TComponent;

  Properties: TArray<string>;
begin
  Componente := Comp as TComponent;
  ComponenteSelecionado := Componente;

  ValueListEditor1.Strings.Clear;
  ctx := TRttiContext.Create;
  try
    tipo := ctx.GetType(Componente.ClassType);

    if Comp is IDisplayComponent then
      Properties := (Comp as IDisplayComponent).Properties;

    if Comp is IInputComponent then
      Properties := (Comp as IInputComponent).Properties;

    if Comp is IActionComponent then
      Properties := (Comp as IActionComponent).Properties;

    for prop in tipo.GetProperties do
    begin
      if
        (prop.Visibility = mvPublished) and
        StringInArray(prop.Name, properties)
      then
        ValueListEditor1.InsertRow(prop.Name, VarToStr(prop.GetValue(Componente).ToString), True);
    end;
  finally
    ctx.Free;
  end;
end;


procedure TComponentProperties.ListarPropriedades(Comp: IInputComponent);
begin
  ListarPropriedadesInterno(Comp)
end;

procedure TComponentProperties.ListarPropriedades(Comp: IActionComponent);
begin
  ListarPropriedadesInterno(comp)
end;

procedure TComponentProperties.ListarPropriedades(Comp: IDisplayComponent);
begin
  ListarPropriedadesInterno(comp)
end;



end.

