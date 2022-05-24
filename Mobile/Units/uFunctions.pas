unit uFunctions;

interface

uses
  System.SysUtils, FMX.Dialogs, System.Classes;

function StringToDouble(vl: string): double;
function UTCtoDateBR(dt: string): string;
function ErroThread(Sender: TObject): boolean;

implementation

function StringToDouble(vl: string): Double;
begin
    try
        vl := StringReplace(vl, FormatSettings.ThousandSeparator, '', [rfReplaceAll]);

        Result := StrToFloat(vl);
    except
        Result := 0;
    end;
end;

function UTCtoDateBR(dt: string): string;
begin
    // 2022-05-05 15:23:52.000
    Result := Copy(dt, 9, 2) + '/' + Copy(dt, 6, 2) + '/' + Copy(dt, 1, 4) + ' ' + Copy(dt, 12, 8);
end;

function ErroThread(Sender: TObject): boolean;
begin
    Result := false;

    if Sender is TThread then
        if Assigned(TThread(Sender).FatalException) then
        begin
            Result := true;
            showmessage(Exception(TThread(sender).FatalException).Message);
        end;
end;

end.
