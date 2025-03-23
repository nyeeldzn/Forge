unit Form.Utils.NewComponentPopUp;

{$mode ObjFPC}{$H+}

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
    LCLType, Buttons;

type

    TComponentValues = record
      Nome: string;
      Descricao:string;
		end;

		{ TNewComponentPopUp }

    TNewComponentPopUp = class(TForm)
				Button1: TButton;
				edNome: TLabeledEdit;
				edDescricao: TLabeledEdit;
				procedure Button1Click(Sender: TObject);
				procedure edNomeKeyDown(Sender: TObject; var Key: Word;
						Shift: TShiftState);
				procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    private
        FComponentValues: TComponentValues;

    public
        Cancelar: boolean;

        constructor Create(AName, ADescricao: string); reintroduce;
        property ComponentValues: TComponentValues read FComponentValues write FComponentValues;

    end;

var
    NewComponentPopUp: TNewComponentPopUp;

implementation

{$R *.lfm}

{ TNewComponentPopUp }

procedure TNewComponentPopUp.Button1Click(Sender: TObject);
begin
  Close;
end;

procedure TNewComponentPopUp.edNomeKeyDown(Sender: TObject; var Key: Word;
		Shift: TShiftState);
begin
  if Key = VK_RETURN then
  begin
    Cancelar := False;
    Button1Click(Sender);
	end
  else
  if Key = VK_ESCAPE then
  begin
    Cancelar := True;
    Close;
	end;
end;

procedure TNewComponentPopUp.FormCloseQuery(Sender: TObject;
		var CanClose: Boolean);
begin
  FComponentValues.Nome:= edNome.Text;
  FComponentValues.Descricao:= edDescricao.Text;
end;

constructor TNewComponentPopUp.Create(AName, ADescricao: string);
begin
  inherited Create(nil);

  edNome.Text := AName;
  edDescricao.Text := ADescricao;
end;

end.

