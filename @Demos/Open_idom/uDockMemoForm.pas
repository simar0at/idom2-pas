unit uDockMemoForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uDockForm, StdCtrls;

type
  TDockableMemoForm = class(TDockableForm)
    Memo1: TMemo;
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  DockableMemoForm: TDockableMemoForm;

implementation

{$R *.dfm}

end.
