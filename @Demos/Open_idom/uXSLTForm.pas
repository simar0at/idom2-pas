unit uXSLTForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uDockForm, StdCtrls;

type
  TXSLTForm = class(TDockableForm)
    XSLTText: TMemo;
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  XSLTForm: TXSLTForm;

implementation

{$R *.dfm}

end.
