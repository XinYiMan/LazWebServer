unit uControl;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Classes, httpdefs, fpHTTP, fpWeb,
  uSmartDebugLog;

type

  { TFPController }

  TFPController = class(TFPWebModule)
    procedure indexRequest(Sender: TObject; ARequest: TRequest;
      AResponse: TResponse; var Handled: Boolean);
  private
         procedure LoginManagement(ARequest: TRequest;
  AResponse: TResponse);
         procedure LogOutManagement(ARequest: TRequest;
  AResponse: TResponse);
         procedure RefreshJwtCookie(jwt : string; ARequest: TRequest;
  AResponse: TResponse);
  public

  end;

var
  FPController: TFPController;


implementation
uses
    fpjson, uLogin, uCookieManagement, uConsts, uJWTAbstract;

{$R *.lfm}

{ TFPController }

procedure TFPController.indexRequest(Sender: TObject; ARequest: TRequest;
  AResponse: TResponse; var Handled: Boolean);
var
  action                : string;
  jObject               : TJSONObject;
  jArray                : TJSONArray;
  jData                 : TJSONData;
  code                  : integer;
  description           : string;
  jwt                   : string;
  id_user               : string;
begin

     {
          Controller da cui passano tutte le richieste di backend, in modo da centralizzarne la gestione in un unico posto
          La gestione dei login e delle relative sessioni è basata sul token jwt trasmesso/recuperato dal cookie dell'utente
          Quando l'utente non è in possesso di un token valido viene reindirizzato sempre alla pagina login.html
          Due pagine sono essenziali che ci siano per non mandare in errore l'applicazione:

              login.html
              index.html

          Tutte le iterazioni tra il frontend ed il backend devono essere gestite come chiamate ajax da parte del browser e gestire il dato di ritorno come meglio si crede.
          Il logout è gestito semplicemente come un azzeramento del token jwt e ritrasmesso ai cookie dell'utente. La validazione dell'utente avviene attraverso la classe TLogin
          presente nella unit uLogin all'interno della funzione ValidLogin (al momento la validazione è all'interno del codice, ma questo è un esempio, in produzione bisogna interfacciarsi
          con dei dati presenti in un database.



          Controller through which all backend requests pass, in order to centralize their management in one place
          The management of logins and related sessions is based on the jwt token transmitted/recovered from the user's cookie
          When the user does not have a valid token he is always redirected to the login.html page
          Two pages are essential to be there to avoid sending the application into error:

              login.html
              index.html

          All iterations between the frontend and backend must be handled as ajax calls by the browser and handle the return data as it sees fit.
          Logout is simply handled as a reset of the jwt token and passed back to the user's cookies. User validation occurs through the TLogin class
          present in the uLogin unit within the ValidLogin function (currently the validation is within the code, but this is an example, in production you need to interface
          with data present in a database.
     }

     action      := ARequest.QueryFields.values['a'];
     code        := 0;
     description := '';
     id_user     := '';

     jArray      := TJSONArray.Create;

     jwt         := CookieManagement(ARequest, AResponse);
     jwt         := VerifiedJWT(JWT_TOKEN_PWD, jwt,JWT_TOKEN_MIN_EXPIRED);

     if jwt = '' then
     begin
          Self.LoginManagement(ARequest, AResponse);
     end else begin
          id_user := GetIdUser(JWT_TOKEN_PWD, jwt);

          Self.RefreshJwtCookie(jwt,ARequest,AResponse);

          SmartDebugLog.write('uControl','User ' + id_user + ' action.',{$I %CURRENTROUTINE%}, LowerCase(action));

          case LowerCase(action) of
               'index','' :
                       begin
                            AResponse.SendRedirect('index.html');
                       end;
               'logout' :
                       begin
                            Self.LogOutManagement(ARequest, AResponse);
                       end;
               'get_name' :
                       begin
                            description := GetValue1(JWT_TOKEN_PWD, jwt);
                       end;
               'get_other' :
                       begin
                            jArray.Add(TJSONObject.Create(['date_time', DateTimeToStr(Now()), 'name_of_week', LongDayNames[DayOfWeek(Date)]]));
                       end;
               'get_table' :
                       begin
                            jArray.Add(TJSONObject.Create(['field1', 1, 'field2', 'Hello world 1', 'field3', 'Ciao Mondo 1', 'field4', 0.01]));
                            jArray.Add(TJSONObject.Create(['field1', 2, 'field2', 'Hello world 2', 'field3', 'Ciao Mondo 2', 'field4', 0.02]));
                            jArray.Add(TJSONObject.Create(['field1', 3, 'field2', 'Hello world 3', 'field3', 'Ciao Mondo 3', 'field4', 0.03]));
                            jArray.Add(TJSONObject.Create(['field1', 4, 'field2', 'Hello world 4', 'field3', 'Ciao Mondo 4', 'field4', 0.04]));
                       end;
          else
              code        := -1;
              description := 'Azione non trovata: ' + action;
          end;
     end;

     try
        try

           jObject                 := TJSONObject.Create(['code', code, 'description', description, 'variable', jArray]);

           jData                   := jObject;
           AResponse.ContentType   := 'text/json; charset=utf-8';
           AResponse.Contents.Text := jData.FormatJSON;

        finally

          if Assigned(jData) then
             FreeAndNil(jData);

          {if Assigned(jArray) then
             FreeAndNil(jArray);}


       end;
     except
           on E: Exception do
           begin

              SmartDebugLog.write('uControl','ECCEZIONE',{$I %CURRENTROUTINE%},E.Message);

           end;
     end;

     Handled                 := true;
end;



procedure TFPController.LoginManagement(ARequest: TRequest; AResponse: TResponse
  );
var
  username              : string;
  password              : string;
  login1                : TLogin;
  filename              : string;
  myfile                : TFileStream;
begin
     {
      Se devo leggere delle variabili POST uso
         ARequest.ContentFields.values['nome variabile'];
      altrimenti
         ARequest.QueryFields.values['nome variabile'];


      If I need to read variables I use POST
         ARequest.ContentFields.values['variable name'];
      otherwise
         ARequest.QueryFields.values['variable name'];
     }

     username := ARequest.ContentFields.values['username'];
     password := ARequest.ContentFields.values['password'];


     login1   := TLogin.Create(username, password);
     if login1.ValidLogin() then
     begin
          filename := ExtractFilePath(ParamStr(0)) + 'root' + System.DirectorySeparator + 'index.html';

          Self.RefreshJwtCookie(GetJwt(JWT_TOKEN_PWD, login1.GetIdUser, login1.GetNameUser, '', '', '', JWT_TOKEN_MIN_EXPIRED) ,ARequest,AResponse);
     end else begin
          filename := ExtractFilePath(ParamStr(0)) + 'root' + System.DirectorySeparator + 'login.html';
     end;

     {$IFDEF WINDOWS}

             filename := StringReplace(filename,'/',System.DirectorySeparator,[rfReplaceAll]);

     {$ENDIF}

     if FileExists(filename) then
     begin
          myfile          := TFileStream.Create(filename, fmOpenRead + fmShareDenyWrite);
          myfile.Position := 0;

          AResponse.ContentStream := myfile;
          AResponse.ContentType := 'text/html; charset=utf-8';
          AResponse.SendContent;

          myfile.Free;
          myfile := nil;
     end else begin
          SmartDebugLog.write('uControl','',{$I %CURRENTROUTINE%}, filename + ' not found.');
          AResponse.Contents.Text := '#1 FATAL ERROR file not FOUND!!!';
     end;

     login1.Free;
     login1:=nil;
end;

procedure TFPController.LogOutManagement(ARequest: TRequest;
  AResponse: TResponse);
var
   filename              : string;
   myfile                : TFileStream;
begin
     filename := ExtractFilePath(ParamStr(0)) + 'root' + System.DirectorySeparator + 'login.html';

     if FileExists(filename) then
     begin
          myfile          := TFileStream.Create(filename, fmOpenRead + fmShareDenyWrite);
          myfile.Position := 0;

          Self.RefreshJwtCookie('',ARequest,AResponse);

          AResponse.ContentStream := myfile;
          AResponse.ContentType := 'text/html; charset=utf-8';
          AResponse.SendContent;

          myfile.Free;
          myfile := nil;
     end else begin
          SmartDebugLog.write('uControl','',{$I %CURRENTROUTINE%}, filename + ' not found.');
          AResponse.Contents.Text := '#1 FATAL ERROR file not FOUND!!!';
     end;
end;

procedure TFPController.RefreshJwtCookie(jwt: string; ARequest: TRequest;
  AResponse: TResponse);
var
   C                     : TCookie;
begin
     AResponse.Cookies.Clear;
     C := AResponse.Cookies.Add;
     C.Name    := COOKIE_NAME;
     C.Value   := jwt;
end;

initialization
  //RegisterHTTPModule('TFPController', TFPController);
end.

