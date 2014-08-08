// singleinstancelimiter.pas
//
// Copyright Wave Software Limited.
//

unit singleinstancelimiter;

interface

type
  TSingleInstanceLimiter = class
  public
    constructor Create(const uniqueName: string);
    destructor Destroy; override;
    
  public
    function IsInstanceAlreadyRunning: boolean;
    
  private
    FLastError: cardinal;
    FMutex: THandle;
  end;
  
implementation

uses
  WinApi.Windows,
  System.SysUtils;

// public
constructor TSingleInstanceLimiter.Create(const uniqueName: string);
begin
  FMutex := INVALID_HANDLE_VALUE;
  FMutex := CreateMutex(nil, false, pchar(uniqueName));
  FLastError := GetLastError;
end;

// public
destructor TSingleInstanceLimiter.Destroy;
begin
  if FMutex <> INVALID_HANDLE_VALUE then
    CloseHandle(FMutex);

  FMutex := INVALID_HANDLE_VALUE;

  inherited;
end;

// public
function TSingleInstanceLimiter.IsInstanceAlreadyRunning: boolean;
begin
  // We have to check both return codes because if the object is
  // grabbed by a process running under one account and the second
  // instance is started under another, the returned error will be
  // ERROR_ACCESS_DENIED, not ERROR_ALREADY_EXISTS.  Windows eh?
  Result :=
    (ERROR_ALREADY_EXISTS = FLastError) or
    (ERROR_ACCESS_DENIED = FLastError);
end;

end.
