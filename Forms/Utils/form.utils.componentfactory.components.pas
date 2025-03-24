unit Form.Utils.ComponentFactory.Components;

{$mode Delphi}{$H+}

interface

uses
  Classes,
  SysUtils,
  StdCtrls,
  Buttons,
  Form.Utils.ComponentFactory.Interfaces,
  Generics.Collections,
  Variants,
  ExtCtrls;

type
	{ TSpeedButton }

  TSpeedButton = class(Buttons.TSpeedButton, IActionComponent)
  private
			function GetOnClick: TNotifyEvent;
    function GetProperties: TArray<string>;
		procedure SetOnClick(AValue: TNotifyEvent);
    procedure SetProperties(AProperties: TArray<string>);
  public
    procedure ApplyProperties(AProperties: TStringList);
    function GetProperites(): TStringList;

    property OnClick: TNotifyEvent read GetOnClick write SetOnClick;
  published
    property Properties: TArray<string> read GetProperties write SetProperties;
	end;

	{ TLabel }

  TLabel = class(StdCtrls.TLabel, IDisplayComponent)
  public
    function GetProperties: TArray<string>;
    procedure SetProperties(AProperties: TArray<string>);
    procedure SetText(AText: string);
    function GetText: string;
    procedure ApplyProperties(AProperties: TStringList);
    function GetProperites(): TStringList;
  published
    property Properties: TArray<string> read GetProperties write SetProperties;
    property Text: string read GetText write SetText;
	end;

	{ TEdit }

	{ TLabeledEdit }

  TLabeledEdit = class(ExtCtrls.TLabeledEdit, IInputComponent)
  private
			function GetCaption: string;
    function GetProperties: TArray<string>;
		procedure SetCaption(AValue: string);
    procedure SetProperties(AProperties: TArray<string>);

    function GetValue: Variant;
	  procedure SetValue(AValue: Variant);
  public
    procedure ApplyProperties(AProperties: TStringList);
    function GetProperites(): TStringList;
  published
    property Properties: TArray<string> read GetProperties write SetProperties;
    property Caption: string read GetCaption write SetCaption;
	end;

implementation

{ TSpeedButton }

function TSpeedButton.GetOnClick: TNotifyEvent;
begin
  Result := inherited OnClick;
end;

function TSpeedButton.GetProperties: TArray<string>;
begin
  Result := ['Caption', 'Top', 'Left', 'Right', 'Bottom', 'Name'];
end;

procedure TSpeedButton.SetOnClick(AValue: TNotifyEvent);
begin
  inherited OnClick := AValue;
end;

procedure TSpeedButton.SetProperties(AProperties: TArray<string>);
begin
//
end;


procedure TSpeedButton.ApplyProperties(AProperties: TStringList);
begin
  Self.Left := StrToIntDef(AProperties.Values['Left'], 0);
  Self.Top := StrToIntDef(AProperties.Values['Top'], 0);
  Self.Width := StrToIntDef(AProperties.Values['Width'], 0);
  Self.Height := StrToIntDef(AProperties.Values['Height'], 0);
  Self.Caption:= AProperties.Values['Caption'];
  Self.Name:= AProperties.Values['Name'];
end;

function TSpeedButton.GetProperites(): TStringList;
begin
  Result := TStringList.Create;
  try
    Result.Values['Left'] := IntToStr(Self.Left);
    Result.Values['Top'] := IntToStr(Self.Top);
    Result.Values['Width'] := IntToStr(Self.Width);
    Result.Values['Height'] := IntToStr(Self.Height);
    Result.Values['Caption'] := Self.Caption;
    Result.Values['Name'] := Self.Name;
  except
    Result.Free;
    raise;
  end;
end;

{ TLabel }


function TLabel.GetProperties: TArray<string>;
begin
  Result := ['Text', 'Top', 'Left', 'Right', 'Bottom', 'Name'];
end;

procedure TLabel.SetProperties(AProperties: TArray<string>);
begin
//
end;

procedure TLabel.SetText(AText: string);
begin
  Self.Caption := AText;
end;

function TLabel.GetText: string;
begin
  Result := Self.Caption;
end;

procedure TLabel.ApplyProperties(AProperties: TStringList);
begin
  Self.Left := StrToIntDef(AProperties.Values['Left'], 0);
  Self.Top := StrToIntDef(AProperties.Values['Top'], 0);
  Self.Width := StrToIntDef(AProperties.Values['Width'], 0);
  Self.Height := StrToIntDef(AProperties.Values['Height'], 0);
  Self.Caption:= AProperties.Values['Caption'];
  Self.Name:= AProperties.Values['Name'];
end;

function TLabel.GetProperites(): TStringList;
begin
  Result := TStringList.Create;
  try
    Result.Values['Left'] := IntToStr(Self.Left);
    Result.Values['Top'] := IntToStr(Self.Top);
    Result.Values['Width'] := IntToStr(Self.Width);
    Result.Values['Height'] := IntToStr(Self.Height);
    Result.Values['Caption'] := Self.Caption;
    Result.Values['Name'] := Self.Name;
  except
    Result.Free;
    raise;
  end;
end;

{ TEdit }

function TLabeledEdit.GetCaption: string;
begin
  Result := EditLabel.Caption;
end;

function TLabeledEdit.GetProperties: TArray<string>;
begin
  Result := ['Caption', 'Text', 'Top', 'Left', 'Right', 'Bottom', 'Name'];
end;

procedure TLabeledEdit.SetCaption(AValue: string);
begin
  EditLabel.Caption := AValue;
end;

procedure TLabeledEdit.SetProperties(AProperties: TArray<string>);
begin
//
end;

function TLabeledEdit.GetValue: Variant;
begin
  Result := Self.Text;
end;

procedure TLabeledEdit.SetValue(AValue: Variant);
begin
  Self.Text := VarToStr(AValue);
end;

procedure TLabeledEdit.ApplyProperties(AProperties: TStringList);
begin
  Self.Left := StrToIntDef(AProperties.Values['Left'], 0);
  Self.Top := StrToIntDef(AProperties.Values['Top'], 0);
  Self.Width := StrToIntDef(AProperties.Values['Width'], 0);
  Self.Height := StrToIntDef(AProperties.Values['Height'], 0);
  Self.Caption:= AProperties.Values['Caption'];
  Self.Text := AProperties.Values['Text'];
  Self.Name:= AProperties.Values['Name'];
end;

function TLabeledEdit.GetProperites(): TStringList;
begin
  Result := TStringList.Create;
  try
    Result.Values['Left'] := IntToStr(Self.Left);
    Result.Values['Top'] := IntToStr(Self.Top);
    Result.Values['Width'] := IntToStr(Self.Width);
    Result.Values['Height'] := IntToStr(Self.Height);
    Result.Values['Caption'] := Self.Caption;
    Result.Values['Text'] := Self.Text;
    Result.Values['Name'] := Self.Name;
  except
    Result.Free;
    raise;
  end;
end;

end.

