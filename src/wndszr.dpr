// wndszr.dpr
//
// Copyright Wave Software Limited.
//

program wndszr;

{$R *.dres}

uses
  Forms,
  mainframe in 'mainframe.pas' {frmMainframe},
  aboutframe in 'aboutframe.pas' {frmAbout},
  strings in 'strings.pas',
  fileversioninfo in 'fileversioninfo.pas',
  singleinstancelimiter in 'singleinstancelimiter.pas';

{$R *.res}

const
  WNDZZR_INSTANCE_ID = 'Global\{D48D0760-6987-42C8-AD7B-37FD233A24B6}';

var
  g_SingleInstanceLimiter: TSingleInstanceLimiter;

begin
  g_SingleInstanceLimiter := TSingleInstanceLimiter.Create(WNDZZR_INSTANCE_ID);

  if g_SingleInstanceLimiter.IsInstanceAlreadyRunning then
    Application.MessageBox('Window Sizer is already running.', 'Window Sizer')
  else
  begin
    Application.Initialize;
    Application.MainFormOnTaskbar := True;
    Application.Title := 'Window Sizer';
    Application.CreateForm(TfrmMainframe, frmMainframe);
    Application.Run;
  end;

  g_SingleInstanceLimiter.Free;
end.
