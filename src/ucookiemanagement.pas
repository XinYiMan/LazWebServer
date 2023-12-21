unit uCookieManagement;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, httpdefs;

  function CookieManagement(ARequest: TRequest;
  AResponse: TResponse) : string;

implementation
uses
    uConsts, uSmartDebugLog;

function CookieManagement(ARequest: TRequest;
  AResponse: TResponse) : string;
var
  JWT                   : string;
  i                     : integer;
  str_support           : string;
begin
     JWT := '';

     i   := 0;
     jwt := '';
     while (i<ARequest.CookieFields.Count) and (jwt = '') do
     begin
          str_support := trim(ARequest.CookieFields[i]);
          if str_support<>'' then
          begin
               if copy(str_support,1,Pos('=',str_support)-1) = COOKIE_NAME then
                  jwt := copy(str_support,Pos('=', str_support)+1);
          end;
          Inc(i);
     end;

     If trim(jwt) <> '' then
     begin
          SmartDebugLog.write('uControl','',{$I %CURRENTROUTINE%},' -- Iterazione cookie basata su JWT chiamata ' + COOKIE_NAME + ' vale ' + JWT);
     end else begin
          SmartDebugLog.write('uControl','',{$I %CURRENTROUTINE%},' -- Iterazione cookie basata su JWT assente');
     end;

     result := jwt;
end;

end.

