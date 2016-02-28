program converter;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  converter_lib in 'converter_lib.pas',
  libxml2 in '..\Open_libxml2\libxml2.pas',
  libxslt in '..\Open_libxslt\libxslt.pas',
  iconv in '..\Open_libxml2\iconv.pas';

var
  gConverter: TConverter;

begin
  gConverter:= TConverter.create;
  try
    gConverter.read;
    gConverter.convert;
    gConverter.write;
  except
    on e: exception do begin
       writeln(e.Message);
       readln;
    end;
  end;
  gConverter.Free;
end.
