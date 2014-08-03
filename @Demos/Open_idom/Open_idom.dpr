program Open_idom;

uses
  Forms,
  uMain in 'uMain.pas' {MainForm},
  DockingUtils in 'DockingUtils.pas',
  uConjoinHost in 'uConjoinHost.pas' {ConjoinDockHost},
  uDockForm in 'uDockForm.pas' {DockableForm},
  uTabHost in 'uTabHost.pas' {TabDockHost},
  uDockMemoForm in 'uDockMemoForm.pas' {DockableMemoForm},
  uBrowser in 'uBrowser.pas' {BrowserForm},
  uXMLForm in 'uXMLForm.pas' {XMLForm},
  uXSLTForm in 'uXSLTForm.pas' {XSLTForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TConjoinDockHost, ConjoinDockHost);
  Application.CreateForm(TTabDockHost, TabDockHost);
  Application.CreateForm(TDockableMemoForm, DockableMemoForm);
  Application.CreateForm(TBrowserForm, BrowserForm);
  Application.CreateForm(TXMLForm, XMLForm);
  Application.CreateForm(TXSLTForm, XSLTForm);
  Application.Run;
end.
