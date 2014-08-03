unit uXMLForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uDockForm, StdCtrls;

type
  TXMLForm = class(TDockableForm)
    XMLText: TMemo;
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  XMLForm: TXMLForm;

implementation

{$R *.dfm}

end.
