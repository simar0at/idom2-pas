unit uBrowser;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uDockForm, OleCtrls, SHDocVw;

type
  TBrowserForm = class(TDockableForm)
    WebBrowser: TWebBrowser;
    procedure FormDockOver(Sender: TObject; Source: TDragDockObject;
  X, Y: Integer; State: TDragState; var Accept: Boolean); override;
    procedure FormShow(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
    procedure showHTML(html: WideString);
    procedure appendHTML(html: WideString);
  end;

var
  BrowserForm: TBrowserForm;

implementation

uses Activex, MSHTML;

{$R *.dfm}

{ TBrowserForm }

procedure TBrowserForm.appendHTML(html: WideString);
var
   Range: IHTMLTxtRange;
begin
   while WebBrowser.ReadyState < READYSTATE_INTERACTIVE do
    Application.ProcessMessages;
   if Assigned(WebBrowser.Document) then
   begin
   Range := ((WebBrowser.Document AS IHTMLDocument2).body AS IHTMLBodyElement).createTextRange;
   Range.Collapse(False) ;
   Range.PasteHTML(html) ;
   end;
end;

procedure TBrowserForm.FormDockOver(Sender: TObject; Source: TDragDockObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
  Accept := False;
end;

procedure TBrowserForm.FormShow(Sender: TObject);
begin
   inherited;
   WebBrowser.Navigate('about:blank');
end;


procedure TBrowserForm.showHTML(html: WideString);
var
   ms: TMemoryStream;
begin
   WebBrowser.Navigate('about:blank') ;
   while WebBrowser.ReadyState < READYSTATE_INTERACTIVE do
    Application.ProcessMessages;

   if Assigned(WebBrowser.Document) then
   begin
       ms := TMemoryStream.Create;
       try
         ms.Write(html[1], Length(html) * 2);
         ms.Seek(0, 0) ;
         (WebBrowser.Document as IPersistStreamInit).Load(TStreamAdapter.Create(ms)) ;
       finally
         ms.Free;
       end;
   end;
end;

end.
