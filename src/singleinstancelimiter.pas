// singleinstancelimiter.pas
//
// Copyright Wave Software Limited.
//

unit singleinstancelimiter;

interface

type
  ISingleInstanceLimiter = interface(IInterface)
    ['{3EA35E27-E02A-4BF0-9580-B44E9C118FAE}']
    function IsRunning: boolean;
  end;

  TSingleInstanceLimiter = class(TInterfacedObject, ISingleInstanceLimiter)
  public
    constructor Create(const uniqueName: string);
    destructor Destroy; override;
    class function CreateObject(const uniqueName: string)
      : ISingleInstanceLimiter;

  public
    function IsRunning: boolean;

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
  inherited Create;
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

class function TSingleInstanceLimiter.CreateObject(const uniqueName: string)
  : ISingleInstanceLimiter;
begin
  Result := TSingleInstanceLimiter.Create(uniqueName);
end;

// public
function TSingleInstanceLimiter.IsRunning: boolean;
begin
  // We have to check both return codes because if the object is
  // grabbed by a process running under one account and the second
  // instance is started under another, the returned error will be
  // ERROR_ACCESS_DENIED, not ERROR_ALREADY_EXISTS.  Windows eh?
  Result := (ERROR_ALREADY_EXISTS = FLastError) or
    (ERROR_ACCESS_DENIED = FLastError);
end;

end.
