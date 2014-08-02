// mainframe.pas
//
// Copyright Wave Software Limited.
//

unit mainframe;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ExtCtrls, StdCtrls;

type
  TfrmMainframe = class(TForm)
    pbxMainframe: TPaintBox;
    trkWidth: TTrackBar;
    trkHeight: TTrackBar;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure pbxMainframePaint(Sender: TObject);
    procedure trkWidthOrHeightChange(Sender: TObject);
  public
    procedure OnHotKey(var msg: TMessage); message WM_HOTKEY;
    procedure OnSysMessage(var msg: TWMSysCommand); message WM_SYSCOMMAND;
  private
    procedure LoadSettings;
    procedure SaveSettings;
    function WindowWidth: integer;
    function WindowHeight: integer;
    function MinWindowWidth: integer;
    function MaxWindowWidth: integer;
    function MinWindowHeight: integer;
    function MaxwindowHeight: integer;
  private
    FWindow: TBitmap;
  end;

var
  frmMainframe: TfrmMainframe;

implementation

{$R *.dfm}

uses
  Registry,
  aboutframe,
  strings;

const
  ID_HOTKEY = 1001;
  VK_A = $41;
  ID_ABOUT = WM_USER + 1;
  MAX_FONT_SIZE = 28.0;
  WIDTHS: array[0..12] of integer =
  (
    320,
    640,
    800, // default
    1024,
    1152,
    1280,
    1360,
    1440,
    1600,
    1680,
    1920,
    2048,
    2560
  );
  HEIGHTS: array[0..17] of integer =
  (
    200,
    240,
    480,
    600, // default
    720,
    768,
    800,
    854,
    864,
    900,
    960,
    1024,
    1050,
    1080,
    1200,
    1536,
    1600,
    2048
  );

  // DONT'T FORGET to keep these in sync with WIDTHS and HEIGHTS.
  DEFAULT_WIDTH_INDEX = 2;
  DEFAULT_HEIGHT_INDEX = 3;

procedure TfrmMainframe.FormCreate(Sender: TObject);
var
  pathname: string;
begin
  AppendMenu(GetSystemMenu(Handle, false), MF_SEPARATOR, 0, nil);
  AppendMenu(GetSystemMenu(Handle, false), MF_STRING, ID_ABOUT, pchar(rsAbout));

  Win32Check(RegisterHotKey(Self.Handle, ID_HOTKEY, MOD_SHIFT + MOD_CONTROL, VK_A));

  trkWidth.Max := High(WIDTHS);
  trkHeight.Max := High(HEIGHTS);

  pathname := ExtractFilePath(Application.ExeName) + 'res\window.bmp';

  FWindow := TBitmap.Create;
  FWindow.LoadFromResourceName(HInstance, 'WINDOW_BITMAP');

  LoadSettings;
end;

procedure TfrmMainframe.FormDestroy(Sender: TObject);
begin
  UnregisterHotKey(Self.Handle, ID_HOTKEY);
  FWindow.Free;
end;

procedure TfrmMainframe.OnHotKey(var msg: TMessage);
var
  pt: TPoint;
  wnd: HWND;
  x, y: integer;
  fwi: TFlashWInfo;
begin
  GetCursorPos(pt);
  wnd := WindowFromPoint(pt);

  if wnd <> 0 then
  begin
    // Find the topmost window.
    while true do
    begin
      if GetParent(wnd) <> 0 then
        wnd := GetParent(wnd)
      else
        break;
    end;

    x := (Screen.Width - WindowWidth) div 2;
    y := (Screen.Height - WindowHeight) div 2;

    SetWindowPos(
      wnd,
      HWND_TOP, // not used, see flags
      x,
      y,
      WindowWidth,
      WindowHeight,
      SWP_NOZORDER);

    fwi.cbSize := Sizeof(fwi);
    fwi.hwnd := wnd;
    fwi.dwFlags := FLASHW_TRAY;
    fwi.uCount := 1;
    fwi.dwTimeout := 0;

    FlashWindowEx(fwi);
  end;
end;

procedure TfrmMainframe.OnSysMessage(var msg: TWMSysCommand);
var
  f: TfrmAbout;
begin
  if msg.CmdType = ID_ABOUT then
  begin
    f := TfrmAbout.Create(Self);

    try
      f.ShowModal;
    finally
      FreeAndNil(f);
    end;
  end
  else
    inherited;
end;

procedure TfrmMainframe.pbxMainframePaint(Sender: TObject);
var
  w, h: integer;
  dw, dh, f: double;
  r: TRect;
  lbl: string;
begin
  pbxMainframe.Canvas.Brush.Style := bsSolid;
  pbxMainframe.Canvas.Brush.Color := clBlue;

  pbxMainframe.Canvas.FillRect(pbxMainframe.ClientRect);

  w := Trunc(FWindow.Width * WindowWidth / MaxWindowWidth);
  h := Trunc(FWindow.Height * WindowHeight / MaxWindowHeight);

  r.Left :=  (pbxMainframe.Width - w) div 2;
  r.Right := r.Left + w;
  r.Top := (pbxMainframe.Height - h) div 2;
  r.Bottom := r.Top + h;

  pbxMainframe.Canvas.StretchDraw(r, FWindow);

  lbl := Format('%dx%d', [WindowWidth, WindowHeight]);


  pbxMainframe.Canvas.Font.Color := clWhite;

  dw := WindowWidth / MaxWindowWidth;
  dh := WindowHeight / MaxWindowHeight;

  if dw > dh then
    f := dw
  else
    f := dh;

  pbxMainframe.Canvas.Font.Size := Trunc(MAX_FONT_SIZE);
  pbxMainframe.Canvas.TextOut(
    (pbxMainframe.Width - pbxMainframe.Canvas.TextWidth(rsHotKey)) div 2,
    0,
    rsHotKey);

  pbxMainframe.Canvas.Font.Size := Round(MAX_FONT_SIZE * f);
  pbxMainframe.Canvas.Font.Style := [fsBold];

  pbxMainframe.Canvas.TextOut(
    (pbxMainframe.Width - pbxMainframe.Canvas.TextWidth(lbl)) div 2,
    pbxMainframe.Height - pbxMainframe.Canvas.TextHeight(lbl),
    lbl);
end;

procedure TfrmMainframe.trkWidthOrHeightChange(Sender: TObject);
begin
  pbxMainframe.Refresh;

  SaveSettings;
end;

// private
procedure TfrmMainframe.LoadSettings;
var
  r: TRegistry;
  width_index, height_index: integer;
begin
  width_index := DEFAULT_WIDTH_INDEX;
  height_index := DEFAULT_HEIGHT_INDEX;

  r := TRegistry.Create;

  try
    r.RootKey := HKEY_CURRENT_USER;

    if r.OpenKey('Software\WaveSoftware\WindowSizer\Settings', false) then
    begin
      width_index := r.ReadInteger('Width');
      height_index := r.ReadInteger('Height');
    end;
  finally
    FreeAndNil(r);
  end;

  trkWidth.Position := width_index;
  trkHeight.Position := height_index;
end;

// private
procedure TfrmMainframe.SaveSettings;
var
  r: TRegistry;
begin
  r := TRegistry.Create;

  try
    r.RootKey := HKEY_CURRENT_USER;

    if r.OpenKey('Software\WaveSoftware\WindowSizer\Settings', true) then
    begin
      r.WriteInteger('Width', trkWidth.Position);
      r.WriteInteger('Height', trkHeight.Position);
    end;
  finally
    FreeAndNil(r);
  end;
end;

function TfrmMainframe.WindowWidth: integer;
begin
  Result := WIDTHS[trkWidth.Position];
end;

function TfrmMainframe.WindowHeight: integer;
begin
  Result := HEIGHTS[trkHeight.Position];
end;

function TfrmMainframe.MinWindowWidth: integer;
begin
  Result := WIDTHS[Low(WIDTHS)];
end;

function TfrmMainframe.MaxWindowWidth: integer;
begin
  Result := WIDTHS[High(WIDTHS)];
end;

function TfrmMainframe.MinWindowHeight: integer;
begin
  Result := HEIGHTS[Low(HEIGHTS)];
end;

function TfrmMainframe.MaxWindowHeight: integer;
begin
  Result := HEIGHTS[High(HEIGHTS)];
end;

end.
