unit uConsts;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

const
     JWT_TOKEN_PWD            = 'MyJwtToken123';     {Password per cifrare il token - Password to encrypt the token}
     JWT_TOKEN_MIN_EXPIRED    = 20;                  {Durata temporale in minuti del singolo token, praticamente serve per gestire la durata delle sessioni basate sul jwt trasmesso tramite cookie - Time duration in minutes of the single token, practically used to manage the duration of sessions based on the jwt transmitted via cookies}
     COOKIE_NAME              = 'LAZWEBSERVER_JWT';  {Nome del cookie che conterrà il token jwt sul browser dell'utente - Name of the cookie that will contain the jwt token on the user's browser}

implementation

end.

