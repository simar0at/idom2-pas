program FPTest;

{$mode objfpc}{$H+}

uses
  libxml2,
  libxmldom,
  {$ifdef mswindows}
  msxml_impl,
  {$endif}
  Interfaces, Forms, GUITestRunner,
  fpcunit,
  testregistry,
  testdom2methodsmsxml,
  testdom2methodslibxml,
  TestXSLTLibXML;

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TGuiTestRunner, TestRunner);
  Application.Run;
end.

