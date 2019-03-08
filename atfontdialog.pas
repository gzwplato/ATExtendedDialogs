(*
This source code is dual licensed: MPL 2.0 and LGPL.
Copyright (c) Alexey Torgashin
*)

unit ATFontDialog;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ButtonPanel, ExtCtrls,
  StdCtrls, Math;

type

  { TfrmFont }

  TfrmFont = class(TForm)
    BtnPanel: TButtonPanel;
    EditSize: TEdit;
    LabelFamily: TLabel;
    LabelStyle: TLabel;
    LabelSize: TLabel;
    LabelPreview: TLabel;
    ListboxStyle: TListBox;
    ListboxFamily: TListBox;
    ListboxSize: TListBox;
    PanelSize: TPanel;
    PanelStyle: TPanel;
    PanelFamily: TPanel;
    PanelMain: TPanel;
    PanelPreviewText: TPanel;
    PanelPreview: TPanel;
    procedure EditSizeKeyPress(Sender: TObject; var Key: char);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ListboxFamilyClick(Sender: TObject);
    procedure ListboxSizeClick(Sender: TObject);
    procedure ListboxStyleClick(Sender: TObject);
  private
    FOptShowNames: boolean;
    FOptShowStyles: boolean;
    FOptShowSizes: boolean;
    FOptShowPreview: boolean;
    FPreviewInitialHeight: integer;
    FMinFontSize: integer;
    FMaxFontSize: integer;
    function GetFont: TFont;
    function GetPreviewText: string;
    procedure SetPreviewText(const AValue: string);
    procedure UpdateLayout;
    procedure UpdatePreview;
  public
    property Font: TFont read GetFont;
    property PreviewText: string read GetPreviewText write SetPreviewText;
    property MinFontSize: integer read FMinFontSize write FMinFontSize;
    property MaxFontSize: integer read FMaxFontSize write FMaxFontSize;
    property OptShowNames: boolean read FOptShowNames write FOptShowNames;
    property OptShowStyles: boolean read FOptShowStyles write FOptShowStyles;
    property OptShowSizes: boolean read FOptShowSizes write FOptShowSizes;
    property OptShowPreview: boolean read FOptShowPreview write FOptShowPreview;
  end;

var
  frmFont: TfrmFont;

implementation

{$R *.lfm}

{ TfrmFont }

procedure TfrmFont.FormCreate(Sender: TObject);
var
  i: integer;
begin
  PanelPreviewText.Caption:= 'abcdefghijk ABCDEFGHIJK';

  ListboxFamily.Items.Assign(Screen.Fonts);

  Constraints.MinWidth:= 300;
  Constraints.MinHeight:= 200;

  FPreviewInitialHeight:= PanelPreviewText.Height;

  FMinFontSize:= 6;
  FMaxFontSize:= 72;

  FOptShowNames:= true;
  FOptShowStyles:= true;
  FOptShowSizes:= true;
  FOptShowPreview:= true;

  with ListboxStyle do
  begin
    Items.Clear;
    Items.Add('Regular');
    Items.Add('Italic');
    Items.Add('Bold');
    Items.Add('Bold Italic');
  end;

  with ListboxSize do
  begin
    Items.Clear;
    for i:= 6 to 18 do
      Items.Add(IntToStr(i));
    Items.Add('20');
    Items.Add('22');
    Items.Add('24');
    Items.Add('26');
    Items.Add('28');
    Items.Add('32');
    Items.Add('36');
    Items.Add('40');
    Items.Add('48');
    Items.Add('56');
    Items.Add('64');
    Items.Add('72');
  end;
end;

procedure TfrmFont.EditSizeKeyPress(Sender: TObject; var Key: char);
begin
  case Key of
    #13:
      begin
        UpdatePreview;
        Key:= #0;
      end;
    //disble letters
    'a'..'z', 'A'..'Z':
      Key:= #0;
  end;
end;

procedure TfrmFont.FormShow(Sender: TObject);
begin
  ListboxFamily.ItemIndex:= ListboxFamily.Items.IndexOf(Font.Name);

  Font.Style:= Font.Style-[fsUnderline, fsStrikeOut];
  if Font.Style=[fsItalic] then
    ListboxStyle.ItemIndex:= 1
  else
  if Font.Style=[fsBold] then
    ListboxStyle.ItemIndex:= 2
  else
  if Font.Style=[fsBold, fsItalic] then
    ListboxStyle.ItemIndex:= 3
  else
    ListboxStyle.ItemIndex:= 0;

  EditSize.Text:= IntToStr(Font.Size);
  ListboxSize.ItemIndex:= ListboxSize.Items.IndexOf(EditSize.Text);

  UpdatePreview;
end;

procedure TfrmFont.ListboxFamilyClick(Sender: TObject);
begin
  UpdatePreview;
end;

procedure TfrmFont.ListboxSizeClick(Sender: TObject);
begin
  if ListboxSize.ItemIndex>=0 then
  begin
    EditSize.Text:= ListboxSize.Items[ListboxSize.ItemIndex];
    UpdatePreview;
  end;
end;

procedure TfrmFont.ListboxStyleClick(Sender: TObject);
begin
  UpdatePreview;
end;

function TfrmFont.GetFont: TFont;
begin
  Result:= PanelPreviewText.Font;
end;

function TfrmFont.GetPreviewText: string;
begin
  Result:= PanelPreviewText.Caption;
end;

procedure TfrmFont.SetPreviewText(const AValue: string);
begin
  if GetPreviewText=AValue then Exit;
  PanelPreviewText.Caption:= AValue;
  UpdatePreview;
end;

procedure TfrmFont.UpdatePreview;
var
  N, NNewPanelHeight: integer;
begin
  if ListboxFamily.ItemIndex>=0 then
    Font.Name:= ListboxFamily.Items[ListboxFamily.ItemIndex];

  if ListboxStyle.ItemIndex>=0 then
    case ListboxStyle.ItemIndex of
      0: Font.Style:= [];
      1: Font.Style:= [fsItalic];
      2: Font.Style:= [fsBold];
      3: Font.Style:= [fsBold, fsItalic];
    end;

  N:= StrToIntDef(EditSize.Text, -1);
  if FOptShowPreview and (N>0) then
  begin
    Font.Size:= Max(FMinFontSize, Min(FMaxFontSize, N));

    PanelPreviewText.Canvas.Font.Assign(PanelPreviewText.Font);
    NNewPanelHeight:= Max(30, PanelPreviewText.Canvas.TextHeight(PanelPreviewText.Caption));
    Height:= Height + NNewPanelHeight - PanelPreviewText.Height;
    PanelPreview.Height:= NNewPanelHeight + LabelPreview.Height + 6*3;
  end;

  BtnPanel.Top:= Height; // fix relative pos of BtnPanel
end;


procedure TfrmFont.UpdateLayout;
begin
  PanelSize.Visible:= FOptShowSizes;
  PanelStyle.Visible:= FOptShowStyles;
  PanelFamily.Visible:= FOptShowNames;
  PanelPreview.Visible:= FOptShowPreview;

  PanelStyle.Align:= alRight;
  PanelSize.Align:= alRight;
  if not PanelFamily.Visible then
  begin
    if PanelStyle.Visible then
      PanelStyle.Align:= alClient
    else
    if PanelSize.Visible then
      PanelSize.Align:= alClient;
  end;
end;

end.
