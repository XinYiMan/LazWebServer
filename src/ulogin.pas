unit uLogin;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

  type

      { TLogin }

      TLogin = class
             private
                   FUsername : string;
                   FPassword : string;
                   Fid_user  : string;
                   FName     : string;
             public
                   constructor Create(AUsername : string; APassword : string);
                   function ValidLogin() : boolean;
                   function GetIdUser : string;
                   function GetNameUser : string;
                   destructor Free;
      end;

implementation

{ TLogin }

constructor TLogin.Create(AUsername: string; APassword: string);
begin
     FUsername := AUsername;
     FPassword := APassword;
     FName     := '';
     Fid_user  := '-1';
end;

function TLogin.ValidLogin: boolean;
begin
     if (FUsername = 'sys@admin.it') and (FPassword = 'pwd1') then
     begin
          Fid_user  := '0';
          FName     := 'SyS Admin';
          result    := true;
     end
     else if (FUsername = 'xinyi@man.it') and (FPassword = 'pwd2') then
          begin
               Fid_user  := '1';
               FName     := 'Xin Yi Man';
               result    := true;
          end
     else
     begin
          Fid_user  := '-1';
          FName     := '';
          result := false;
     end;
end;

function TLogin.GetIdUser: string;
begin
     result := Self.Fid_user;
end;

function TLogin.GetNameUser: string;
begin
     result := Self.FName;
end;

destructor TLogin.Free;
begin

end;

end.

