unit uKeyHook;

interface

uses
  Classes, Windows, SysUtils, Messages;

type
  TKeyEvent = procedure (AKey: Cardinal; var AHandle: Boolean) of object;

  procedure AttachEvent(AEvent: TKeyEvent);
  procedure DetachEvent;

implementation

var
  hKeyHook: Integer;
  KeyEvent: TKeyEvent = nil;


procedure AttachEvent(AEvent: TKeyEvent);
begin
  KeyEvent := AEvent;
end;

procedure DetachEvent;
begin
  KeyEvent := nil;
end;

//ȫ�ּ��̹�����Ϣ��������
function KeyHookProc(nCode:Integer; wP:WPARAM; lP:LPARAM):LRESULT; stdcall;
var
  pEvt: TEventMsg;
  vKey: Cardinal;
  LHandle: Boolean;
begin
  LHandle := False;
  if (nCode = HC_ACTION) then
  begin
    vKey := 0;
    case wP of
      WM_SYSKEYDOWN, WM_KEYDOWN:
      begin
        pEvt := PEventMsg(LP)^;
        vKey := LOBYTE(pEvt.message);
        if Assigned(KeyEvent) then
        begin
          KeyEvent(vKey, LHandle);
        end;
      end;
      WM_SYSKEYUP, WM_KEYUP:;
    end;
  end;
  if not LHandle then
    result := CallNextHookEx(hKeyHook, nCode, wP, lP);
end;


procedure AttachHook;
begin
  hKeyHook := SetWindowsHookEx(WH_KEYBOARD_LL, @KeyHookProc, hInstance, 0);
end;

procedure DetachHook;
begin
  UnhookWindowsHookEx(hKeyHook);
end;

initialization
{$IFNDEF DEBUG}
  AttachHook;
{$ENDIF}

finalization
{$IFNDEF DEBUG}
  DetachHook;
{$ENDIF}


end.