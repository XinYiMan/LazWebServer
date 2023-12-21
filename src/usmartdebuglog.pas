unit uSmartDebugLog;

{$mode objfpc}{$H+}


{

Custom options:

       -dSmartDebugLogWriteActive //use writeln
       -dSmartDebugLogActive      //use file

Example:
        SmartDebugLog.write('Start Button1Click');

}

interface

uses
  Classes, SysUtils;

type

    { TSmartDebugLog }

    TSmartDebugLog = class
      private
             {$ifdef SmartDebugLogActive}
             file_name_output : string;
             content          : TStringList;
             {$endif}
      public
            constructor Create;
            destructor Free;
            procedure write(unit_name : string; class_name: string; method_name : string; message: string);
            procedure SetFileOutput(value : string);
    end;

var
   SmartDebugLog : TSmartDebugLog;

implementation

{ TSmartDebugLog }

constructor TSmartDebugLog.Create;
begin
  {$ifdef SmartDebugLogActive}
  file_name_output := GetTempDir(true) + 'smart_debug_log.log';
  if FileExists(file_name_output) then
     DeleteFile(file_name_output);

  content          := TStringList.Create;
  {$endif}
end;

destructor TSmartDebugLog.Free;
begin
  {$ifdef SmartDebugLogActive}
  content.Free;
  content := nil;
  {$endif}
end;

procedure TSmartDebugLog.write(unit_name: string; class_name: string;
  method_name: string; message: string);
begin
     {$ifdef SmartDebugLogActive}
             content.Append(DateTimeToStr(now) + '[' + unit_name + ' - ' + class_name + ' - ' + method_name + ']: ' + message);
             if FileExists(file_name_output) then
                DeleteFile(file_name_output);
             content.SaveToFile(file_name_output);
     {$endif}
     {$ifdef SmartDebugLogWriteActive}
             writeln(DateTimeToStr(now) + '[' + unit_name + ' - ' + class_name + ' - ' + method_name + ']: ' + message);
     {$endif}
end;

procedure TSmartDebugLog.SetFileOutput(value: string);
begin
     {$ifdef SmartDebugLogActive}
             file_name_output := value;
     {$endif}
end;

initialization
  {$ifdef SmartDebugLogActive}
  SmartDebugLog := TSmartDebugLog.Create;
  {$endif}

finalization
  {$ifdef SmartDebugLogActive}
  SmartDebugLog.Free;
  SmartDebugLog := nil;
  {$endif}

end.
