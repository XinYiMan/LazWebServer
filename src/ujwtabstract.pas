unit uJWTAbstract;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Crypto_JWT, DateUtils, uGenericDateFunctions;

  function GetJwt(jwt_password: string; id_user : string; value1 : string; value2 : string; value3 : string; value4 : string; min_expired : integer) : string;
  function VerifiedJWT(jwt_password: string; mytoken: string; min_expired : integer)       : string;
  function GetIdUser(jwt_password: string; mytoken: string)                                : string;
  function GetValue1(jwt_password: string; mytoken: string)                                : string;
  function GetValue2(jwt_password: string; mytoken: string)                                : string;
  function GetValue3(jwt_password: string; mytoken: string)                                : string;
  function GetValue4(jwt_password: string; mytoken: string)                                : string;
  function GetWebAppVersion(jwt_password: string; mytoken: string)                         : string;

implementation

function GetJwt(jwt_password: string; id_user: string; value1: string;
  value2: string; value3: string; value4: string; min_expired: integer): string;
var
   expired_dt : string;
begin

     if min_expired<=0 then
        expired_dt := '0'
     else
         expired_dt := FromDateTimeToStrYMDHNS(IncMinute(Now(),min_expired));

     result     := JWTSign(jwt_password,'{ "iduser" : "' + id_user + '" , "value1" : "' + value1 + '" , "value2" : "' + value2 + '", "value3" : "' + value3 + '", "value4" : "' + value4 + '" , "expired" : "' + expired_dt + '" }');
end;

function VerifiedJWT(jwt_password: string; mytoken: string; min_expired: integer
  ): string;
var
   output       : string;
   error        : string;
   id_user      : string;
   ret          : string;
   expired_str  : string;
   expired      : TDateTime;
   value1       : string;
   value2       : string;
   value3       : string;
   value4       : string;
   expired_dt   : string;
begin
  ret := '';
  if JWTParse(mytoken, jwt_password, Output) then
  begin
        if ExtractValue(mytoken, 'iduser',id_user, error) then
        begin
             if id_user <> '-1' then
             begin

                  ExtractValue(mytoken, 'value1',value1, error);
                  ExtractValue(mytoken, 'value2',value2, error);
                  ExtractValue(mytoken, 'value3',value3, error);
                  ExtractValue(mytoken, 'value4',value4, error);
                  ExtractValue(mytoken, 'expired',expired_str, error);

                  if min_expired <= 0 then
                     expired := Now()
                  else
                     expired := FromStrYMDHNSToDateTime(expired_str);

                  if (min_expired <= 0) or (expired>now()) then
                  begin
                       if min_expired<=0 then
                          expired_dt := '0'
                       else
                           expired_dt := FromDateTimeToStrYMDHNS(IncMinute(Now(),min_expired));

                       ret := JWTSign(jwt_password,'{ "iduser" : "' + id_user + '" , "value1" : "' + value1 + '" , "value2" : "' + value2 + '", "value3" : "' + value3 + '", "value4" : "' + value4 + '" , "expired" : "' + expired_dt + '" }');
                  end;

             end;

        end;
  end;
  result := ret;
end;

function GetIdUser(jwt_password: string; mytoken: string): string;
var
   app         : string;
   error       : string;
begin
     result := '';
     if JWTParse(mytoken, jwt_password, app) then
     begin
          if ExtractValue(mytoken, 'iduser', app, error) then
          begin
               result := app;
          end;
     end;
end;

function GetValue1(jwt_password: string; mytoken: string): string;
var
   app         : string;
   error       : string;
begin
     result := '';
     if JWTParse(mytoken, jwt_password, app) then
     begin
          if ExtractValue(mytoken, 'value1', app, error) then
          begin
               result := app;
          end;
     end;
end;

function GetValue2(jwt_password: string; mytoken: string): string;
var
   app         : string;
   error       : string;
begin
     result := '';
     if JWTParse(mytoken, jwt_password, app) then
     begin
          if ExtractValue(mytoken, 'value2', app, error) then
          begin
               result := app;
          end;
     end;
end;

function GetValue3(jwt_password: string; mytoken: string): string;
var
   app         : string;
   error       : string;
begin
     result := '';
     if JWTParse(mytoken, jwt_password, app) then
     begin
          if ExtractValue(mytoken, 'value3', app, error) then
          begin
               result := app;
          end;
     end;
end;

function GetValue4(jwt_password: string; mytoken: string): string;
var
   app         : string;
   error       : string;
begin
     result := '';
     if JWTParse(mytoken, jwt_password, app) then
     begin
          if ExtractValue(mytoken, 'value4', app, error) then
          begin
               result := app;
          end;
     end;
end;

function GetWebAppVersion(jwt_password: string; mytoken: string): string;
var
   app         : string;
   error       : string;
begin
     result := '';
     if JWTParse(mytoken, jwt_password, app) then
     begin
          if ExtractValue(mytoken, 'web_app_version', app, error) then
          begin
               result := app;
          end;
     end;
end;

end.

