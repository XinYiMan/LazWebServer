program lazwebserver;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  {$IFDEF OpenSslOk}
  opensslsockets,
  {$ENDIF}
  fphttpapp, HTTPDefs, fphttp, Classes, sysutils, uControl, uSmartDebugLog, uCustomException,
  uCustomGetModule, uCookieManagement, uConsts, uJWTAbstract;

var
   application_path : string;
   MyCustomException : TCustomException;
   MyCustomGetModule : TCustomGetModule;

procedure MyShowRequestException(AResponse: TResponse; AnException: Exception; var handled: boolean);
var
  filename : string;
  myfile   : TFileStream;
  jwt      : string;
begin

     {
           Ogni volta che si genera un'eccezione sull'instradamento passa di qui e così gestisco il passaggio dei file al browser
           Every time an exception is thrown on the route it goes through here and this is how I manage the passing of the files to the browser
     }

     try
        try

           filename := ExtractFilePath(ParamStr(0)) + 'root' + AResponse.Request.URI;
           {$IFDEF WINDOWS}

                   filename := StringReplace(filename,'/',System.DirectorySeparator,[rfReplaceAll]);

           {$ENDIF}

           if (lowercase(ExtractFileExt(filename)) = '.html') then
           begin
                jwt := CookieManagement(AResponse.Request, AResponse);
                jwt := VerifiedJWT(JWT_TOKEN_PWD, jwt,JWT_TOKEN_MIN_EXPIRED);

                if trim(jwt)='' then
                begin
                     {
                                Se non sono loggato le pagine html devono tutte ricondurre al login
                                If I am not logged in, the html pages must all lead back to the login
                     }
                     filename := ExtractFilePath(ParamStr(0)) + 'root' + System.DirectorySeparator + 'login.html';
                end;
           end;

           if FileExists(filename) then
           begin
                myfile          := TFileStream.Create(filename, fmOpenRead + fmShareDenyWrite);
                myfile.Position := 0;

                AResponse.ContentStream := myfile;

                case lowercase(ExtractFileExt(filename)) of

                     '.js' : begin
                             AResponse.ContentType := 'application/javascript; charset=utf-8';
                     end;

                     '.gif' : begin
                             AResponse.ContentType := 'image/gif';
                     end;

                     '.css' : begin
                             AResponse.ContentType := 'text/css; charset=utf-8';
                     end;

                     '.tiff','.tif' : begin
                             AResponse.ContentType := 'image/tiff';
                     end;

                     '.jpg' : begin
                             AResponse.ContentType := 'image/jpeg';
                     end;

                     '.ico' : begin
                             AResponse.ContentType := 'image/ico';
                     end;

                     '.jpeg' : begin
                             AResponse.ContentType := 'image/jpeg';
                     end;

                     '.png' : begin
                             AResponse.ContentType := 'image/png';
                     end;

                     '.html' : begin
                             AResponse.ContentType := 'text/html; charset=utf-8';
                     end;

                     '.json' : begin
                             AResponse.ContentType := 'text/json; charset=utf-8';
                     end;

                     '.txt' : begin
                             AResponse.ContentType := 'text/plain; charset=utf-8';
                     end;

                     '.ttf' : begin
                             AResponse.ContentType := 'text/html; charset=utf-8';
                     end;

                     '.zip' : begin
                             AResponse.ContentType := 'application/zip';
                     end;

                     '.exe' : begin
                             AResponse.ContentType := 'application/octet-stream';
                     end;

                     '.pdf' : begin
                             AResponse.ContentType := 'application/pdf';
                     end;

                     '.mpeg' : begin
                             AResponse.ContentType := 'video/mpeg';
                     end;

                     '.rtf' : begin
                             AResponse.ContentType := 'application/rtf';
                     end;

                     else
                           AResponse.ContentType := 'text/html; charset=utf-8';

                end;


                AResponse.SendContent;
                Handled := true;


                myfile.Free;
                myfile := nil;


           end else begin
               SmartDebugLog.write('lpr file','',{$I %CURRENTROUTINE%},AResponse.Request.URI + ' ' + AnException.Message);

               AResponse.SendRedirect('index.html');
               Handled            := true;

           end;

        finally


       end;
     except
           on E: Exception do
           begin

               SmartDebugLog.write('lpr file','',{$I %CURRENTROUTINE%},'Eccezione MyShowRequestException: ' + AResponse.Request.URI + ' ' + E.Message);

               Handled := false;

           end;
     end;
end;



begin

  MyCustomException := TCustomException.Create;
  MyCustomGetModule := TCustomGetModule.Create;

  RegisterHTTPModule('index', TFPController);

  Application.Title                  := 'Laz Web Server';

  {
      La gestione dei tre eventi qui sotto serve per la gestione dei file presenti nella cartella root, in modo da mantenere il frontend fuori dall'eseguibile, mentre il backend è nell'eseguibile
      The management of the three events below is used to manage the files present in the root folder, in order to keep the frontend out of the executable, while the backend is in the executable
  }
  Application.OnShowRequestException := @MyShowRequestException;
  Application.OnException            := @MyCustomException.MyException;
  Application.OnGetModule            := @MyCustomGetModule.MyGetModule;

  Application.Port                   := 5555;
  Application.Threaded               := True;
  Application.LegacyRouting          := false;  {Importante che il routing di default dell'applicazione sia disattivata, altrimenti bypassa MyShowRequestException - It is important that the application's default routing is disabled, otherwise it bypasses MyShowRequestException}
  SmartDebugLog.write('lpr file','MAIN CLASS',{$I %CURRENTROUTINE%},Application.Title);
  {$IFDEF OpenSslOk}
  application_path                   := ExtractFilePath(paramStr(0));
  Application.UseSSL                 := True;
  Application.HTTPhandler.HTTPServer.CertificateData.Certificate.FileName := application_path + 'certificate.crt';
  Application.HTTPhandler.HTTPServer.CertificateData.PrivateKey.FileName := application_path + 'privateKey.key';
  SmartDebugLog.write('lpr file','MAIN CLASS',{$I %CURRENTROUTINE%},'https://localhost:' + IntToStr(Application.Port) + '/index');
  {$ELSE}
  SmartDebugLog.write('lpr file','MAIN CLASS',{$I %CURRENTROUTINE%},'http://localhost:' + IntToStr(Application.Port) + '/index');
  {$ENDIF}

  Application.Initialize;
  Application.Run;

  MyCustomGetModule.Free;
  MyCustomGetModule := nil;
  MyCustomException.Free;
  MyCustomException := nil;
end.

