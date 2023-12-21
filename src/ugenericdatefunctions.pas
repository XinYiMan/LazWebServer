unit uGenericDateFunctions;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, DateUtils, StrUtils;

  function FromDateTimeToStrYMDHNS(value : TDateTime) : string;
  function FromStrYMDHNSToDateTime(value : string) : TDateTime;

implementation

function FromDateTimeToStrYMDHNS(value: TDateTime): string;
var
  AYear        : Word;
  AMonth       : Word;
  ADay         : Word;
  AHour        : Word;
  AMinute      : Word;
  ASecond      : Word;
  AMilliSecond : Word;
begin
     result := '';

     DecodeDateTime(value, AYear, AMonth, ADay, AHour, AMinute, ASecond, AMilliSecond);

     result := IntToStr(AYear);

     if (AMonth<10) then
        result  := result + AddChar('0',IntToStr(AMonth),2)
     else
         result := result + IntToStr(AMonth);

     if (ADay<10) then
        result  := result + AddChar('0',IntToStr(ADay),2)
     else
         result := result + IntToStr(ADay);

     if (AHour<10) then
        result  := result + AddChar('0',IntToStr(AHour),2)
     else
         result := result + IntToStr(AHour);

     if (AMinute<10) then
        result  := result + AddChar('0',IntToStr(AMinute),2)
     else
         result := result + IntToStr(AMinute);

     if (ASecond<10) then
        result  := result + AddChar('0',IntToStr(ASecond),2)
     else
         result := result + IntToStr(ASecond);

end;

function FromStrYMDHNSToDateTime(value: string): TDateTime;
var
  AYear        : Word;
  AMonth       : Word;
  ADay         : Word;
  AHour        : Word;
  AMinute      : Word;
  ASecond      : Word;
begin
     if Length(value)=14 then
     begin
       AYear        := StrToIntDef(Copy(value,1,4),2000);
       AMonth       := StrToIntDef(Copy(value,5,2),1);
       ADay         := StrToIntDef(Copy(value,7,2),1);
       AHour        := StrToIntDef(Copy(value,9,2),0);
       AMinute      := StrToIntDef(Copy(value,11,2),0);
       ASecond      := StrToIntDef(Copy(value,13,2),1);
     end else begin
       AYear        := 2000;
       AMonth       := 1;
       ADay         := 1;
       AHour        := 0;
       AMinute      := 0;
       ASecond      := 1;
     end;
     result         := EncodeDateTime(AYear, AMonth, ADay, AHour, AMinute, ASecond, 0);
end;

end.

