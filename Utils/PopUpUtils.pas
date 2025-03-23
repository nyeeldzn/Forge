unit PopUpUtils;

{$mode Delphi}{$H+}

interface

uses
  Forms,
  Menus,
  Controls,
  Sysutils,
  Classes;

type

	{ PopUpHelper }

  PopUpHelper = class
    private
      class var LastSender: TObject;
      class var FOnEditarClick: TNotifyEvent;

      procedure OnEditarClick(Sender: TObject);

    public
      class procedure ShowPopupEdicaoComponente(Sender: TObject; Form: TComponent; X, Y: Integer; onEditarComponent, onExcluirComponent: TNotifyEvent);
	end;



implementation

procedure PopUpHelper.OnEditarClick(Sender: TObject);
begin
  if Assigned(FOnEditarClick) then
    FOnEditarClick(LastSender);
end;

class procedure PopUpHelper.ShowPopupEdicaoComponente(Sender: TObject; Form: TComponent; X, Y: Integer; onEditarComponent, onExcluirComponent: TNotifyEvent);
var
  PopupMenu: TPopupMenu;
  MenuItem1, MenuItem2: TMenuItem;
begin
  LastSender := Sender;
  FOnEditarClick := onEditarComponent;

  PopupMenu := TPopupMenu.Create(Form);

  MenuItem1 := TMenuItem.Create(PopupMenu);
  MenuItem1.Caption := 'Editar';
  MenuItem1.OnClick := OnEditarClick;
  PopupMenu.Items.Add(MenuItem1);

  MenuItem2 := TMenuItem.Create(PopupMenu);
  MenuItem2.Caption := 'Excluir';
  MenuItem2.OnClick := onExcluirComponent;
  PopupMenu.Items.Add(MenuItem2);

  PopupMenu.PopUp(X, Y);
end;


initialization

finalization
begin;

  if Assigned(PopUpHelper.FOnEditarClick) then
    FreeAndNil(PopUpHelper.FOnEditarClick);

end;

end.

