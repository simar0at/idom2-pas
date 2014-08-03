
//---------------------------------------------------------------------------

// This software is Copyright (c) 2011 Embarcadero Technologies, Inc. 
// You may only use this software if you are an authorized licensee
// of Delphi, C++Builder or RAD Studio (Embarcadero Products).
// This software is considered a Redistributable as defined under
// the software license agreement that comes with the Embarcadero Products
// and is subject to that software license agreement.

//---------------------------------------------------------------------------
unit uMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, StdCtrls, ComCtrls, ActnList, ToolWin, ExtCtrls, uDockForm, uDockMemoForm,
  Tabs, DockTabSet, Grids, idom2, System.Actions;

type
  TMainForm = class(TForm)
    CoolBar1: TCoolBar;
    ToolBar1: TToolBar;
    ToolBar2: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    ToolButton13: TToolButton;
    ActionList1: TActionList;
    ViewToolBar1: TAction;
    ViewToolBar2: TAction;
    LeftDockPanel: TPanel;
    BottomDockPanel: TPanel;
    VSplitter: TSplitter;
    HSplitter: TSplitter;
    MainMenu1: TMainMenu;
    File2: TMenuItem;
    Exit2: TMenuItem;
    View2: TMenuItem;
    N2: TMenuItem;
    ToolBar21: TMenuItem;
    ToolBar11: TMenuItem;
    ViewBrowserWindow: TAction;
    ExitAction: TAction;
    ViewLogWindow: TAction;
    ViewXMLWindow: TAction;
    ViewXSLTWindow: TAction;
    ViewTealWindow: TAction;
    ViewPurpleWindow: TAction;
    ViewLimeWindow: TAction;
    ToolButton4: TToolButton;
    White1: TMenuItem;
    Blue1: TMenuItem;
    Green1: TMenuItem;
    Lime1: TMenuItem;
    Purple1: TMenuItem;
    Red1: TMenuItem;
    Teal1: TMenuItem;
    N1: TMenuItem;
    Floatonclosedocked1: TMenuItem;
    LeftDockTabSet: TDockTabSet;
    BottomDockTabSet: TDockTabSet;
    VSplitterR: TSplitter;
    RightDockTabSet: TDockTabSet;
    RightDockPanel: TPanel;
    CentralDockPanel: TPanel;
    CentralDockTab: TDockTabSet;
    ToolButton8: TToolButton;
    ToolButton9: TToolButton;
    Label1: TLabel;
    URLEdit: TEdit;
    ToolButton10: TToolButton;
    Back: TAction;
    Forward: TAction;
    Go: TAction;
    ToolButton11: TToolButton;
    Load: TAction;
    procedure FormCreate(Sender: TObject);
    procedure CoolBar1DockOver(Sender: TObject; Source: TDragDockObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
    procedure ViewToolBar1Execute(Sender: TObject);
    procedure ViewToolBar2Execute(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure DockPanelDockDrop(Sender: TObject; Source: TDragDockObject; X, Y: Integer);
    procedure LeftDockPanelDockOver(Sender: TObject; Source: TDragDockObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
    procedure BottomDockPanelDockOver(Sender: TObject; Source: TDragDockObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
    procedure DockPanelUnDock(Sender: TObject; Client: TControl; NewTarget: TWinControl; var Allow: Boolean);
    procedure ExitActionExecute(Sender: TObject);
    procedure Floatonclosedocked1Click(Sender: TObject);
    procedure ViewWindowExecute(Sender: TObject);
    procedure DockPanelGetSiteInfo(Sender: TObject; DockClient: TControl; var InfluenceRect: TRect; MousePos: TPoint; var CanDock: Boolean);
    procedure DockTabSetDockDrop(Sender: TObject; Source: TDragDockObject; X,
      Y: Integer);
    procedure DockTabSetGetSiteInfo(Sender: TObject; DockClient: TControl;
      var InfluenceRect: TRect; MousePos: TPoint; var CanDock: Boolean);
    procedure DockTabSetTabAdded(Sender: TObject);
    procedure DockTabSetTabRemoved(Sender: TObject);
    procedure RightDockPanelDockOver(Sender: TObject; Source: TDragDockObject;
      X, Y: Integer; State: TDragState; var Accept: Boolean);
    procedure CentralDockPanelDockOver(Sender: TObject; Source: TDragDockObject;
      X, Y: Integer; State: TDragState; var Accept: Boolean);
    procedure FormShow(Sender: TObject);
    procedure GoExecute(Sender: TObject);
    procedure BackExecute(Sender: TObject);
    procedure ForwardExecute(Sender: TObject);
    procedure URLEditKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure URLEditKeyPress(Sender: TObject; var Key: Char);
    procedure LoadExecute(Sender: TObject);
  private
    /// <summary>Creates all dockable windows in advance and stores them in DockWindows.
    /// </summary>
    procedure CreateDockableWindows;
  public
    FCreateDom: IDomImplementation;
    FXmlDom: IDomDocument;
    FXslDom: IDomDocument;
    /// <summary>Implements logic that shows and "hides" cocking panels
    /// </summary>
    /// <param name="APanel"> (TPanel) The panel representing the desired dock area.</param>
    /// <param name="MakeVisible"> (Boolean) Whether the docking panel should be visible or invisible</param>
    /// <param name="Client"> (TControl) The docked client to show if we are re-showing the panel.
    /// Client is ignored if hiding the panel.</param>
    procedure ShowDockPanel(APanel: TPanel; MakeVisible: Boolean; Client: TControl);
  end;

var
  MainForm: TMainForm;

implementation

uses uTabHost, uConjoinHost, uBrowser, uXMLForm, uXSLTForm, idom2_ext,
  {libxmldom, }msxml_impl;

{$R *.dfm}

const
  Colors: array[0..6] of TColor = (clWhite, clBlue, clGreen, clRed, clTeal,
                                   clPurple, clLime);
  ColStr: array[0..6] of string = ('White', 'Blue', 'Green', 'Red', 'Teal',
                                   'Purple', 'Lime');
  DockAreaHiddenWidth = 8;

var
  DockWindows: array[0..6] of TDockableForm;

{TMainForm}

procedure TMainForm.FormCreate(Sender: TObject);
begin
  LeftDockTabSet.Width := 0;
  RightDockTabSet.Width := 0;
  BottomDockTabSet.Height := 0;
  CentralDockTab.Height := 0;
  LeftDockPanel.Width := DockAreaHiddenWidth;
  RightDockPanel.Width := DockAreaHiddenWidth;
  BottomDockPanel.Height := DockAreaHiddenWidth;
  FCreateDom := getDOM('MSXML2_RENTAL_MODEL');
  FXmlDom := FCreateDom.createDocument('','',nil);
  FXslDom := FCreateDom.createDocument('','',nil);
  CreateDockableWindows;
end;

procedure TMainForm.CreateDockableWindows;
var
  I: Integer;
begin
  DockWindows[0] := TBrowserForm.Create(Application);
  DockWindows[1] := TDockableMemoForm.Create(Application);
  with TDockableMemoForm(DockWindows[1]) do
  begin
    Caption := 'Log';
    Memo1.Lines.Clear;
  end;
  DockWindows[2] := TXMLForm.Create(Application);
  DockWindows[3] := TXSLTForm.Create(Application);
  for I := 4 to High(DockWindows) do
  begin
    //rnelson
    DockWindows[I] := TDockableMemoForm.Create(Application);
    DockWindows[I].Caption := ColStr[I];

    TDockableMemoForm(DockWindows[I]).Memo1.Color := Colors[I];
    TDockableMemoForm(DockWindows[I]).Memo1.Font.Color := Colors[I] xor $00FFFFFF;
    TDockableMemoForm(DockWindows[I]).Memo1.Text := ColStr[I] + ' window ';
  end;
  for I := Low(DockWindows) to High(DockWindows) do
    DockWindows[I].FloatOnCloseDock := true;
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  DockWindows[0].ManualDock(RightDockPanel);
  DockWindows[0].Show;
  with TBrowserForm(DockWindows[0]) do
  begin
    showHTML('<html><title></title><body><h6>إن ساء ألله Works </h6></body></html>');
  end;
  DockWindows[1].ManualDock(BottomDockPanel);
  DockWindows[1].Show;
  DockWindows[2].ManualDock(LeftDockPanel);
  DockWindows[2].Show;
  DockWindows[3].ManualDock(CentralDockPanel);
  DockWindows[3].Show;
end;

procedure TMainForm.ForwardExecute(Sender: TObject);
begin
  if DockWindows[0].Visible then
      with TBrowserForm(DockWindows[0]) do
      begin
        WebBrowser.GoForward;
      end;
end;

procedure TMainForm.GoExecute(Sender: TObject);
begin
  if DockWindows[0].Visible then
      with TBrowserForm(DockWindows[0]) do
      begin
        WebBrowser.Navigate(URLEdit.Text);
      end;
end;

procedure TMainForm.BackExecute(Sender: TObject);
begin
  if DockWindows[0].Visible then
      with TBrowserForm(DockWindows[0]) do
      begin
        WebBrowser.GoBack;
      end;
end;

procedure TMainForm.LeftDockPanelDockOver(Sender: TObject;
  Source: TDragDockObject; X, Y: Integer; State: TDragState;
  var Accept: Boolean);
var
  ARect: TRect;
begin
  Accept := Source.Control is TDockableForm;
  if Accept then
  begin
    //Modify the DockRect to preview dock area.
    ARect.TopLeft := LeftDockPanel.ClientToScreen(Point(0, 0));
    ARect.BottomRight := LeftDockPanel.ClientToScreen(Point(Self.ClientWidth div 3, LeftDockPanel.Height));
    Source.DockRect := ARect;
  end;
end;

procedure TMainForm.LoadExecute(Sender: TObject);
var
  html: WideString;
  xmlNode: IDomNodeExt;
  xslNode: IDomNode;
begin
  if DockWindows[0].Visible then begin
   if not (FXmlDom as IDomPersist).loadxml(XMLForm.XMLText.Lines.Text) then
      with TDockableMemoForm(DockWindows[1]) do
        Memo1.Lines.Add('XML?');
  if not (FXSLDom as IDomPersist).loadxml(XSLTForm.XSLTText.Lines.Text) then
      with TDockableMemoForm(DockWindows[1]) do
        Memo1.Lines.Add('XSLT?');
  xmlNode := (FXmlDom as IDomNodeExt);
  xslNode := (FXslDom.documentElement as IDomNode);
  xmlNode.transformNode(xslNode, html);
  with TBrowserForm(DockWindows[0]) do
      begin
        showHTML(html);
        appendHTML('<h6>إن ساء ألله Works </h6>');
      end;
  end;
  with TDockableMemoForm(DockWindows[1]) do
  begin
    Memo1.Lines.Append(UTF8encode(html));
  end;
end;

procedure TMainForm.RightDockPanelDockOver(Sender: TObject;
  Source: TDragDockObject; X, Y: Integer; State: TDragState;
  var Accept: Boolean);
var
  ARect: TRect;
begin
  Accept := Source.Control is TDockableForm;
  if Accept then
  begin
    //Modify the DockRect to preview dock area.
    ARect.TopLeft := RightDockPanel.ClientToScreen(Point(-Self.ClientWidth div 3, 0));
    ARect.BottomRight := RightDockPanel.ClientToScreen(Point(0, RightDockPanel.Height));
    Source.DockRect := ARect;
  end;
end;


procedure TMainForm.BottomDockPanelDockOver(Sender: TObject;
  Source: TDragDockObject; X, Y: Integer; State: TDragState;
  var Accept: Boolean);
var
  ARect: TRect;
begin
  Accept := Source.Control is TDockableForm;
  if Accept then
  begin
    //Modify the DockRect to preview dock area.
    ARect.TopLeft := BottomDockPanel.ClientToScreen(
      Point(0, -Self.ClientHeight div 3));
    ARect.BottomRight := BottomDockPanel.ClientToScreen(
      Point(BottomDockPanel.Width, BottomDockPanel.Height));
    Source.DockRect := ARect;
  end;
end;

procedure TMainForm.DockTabSetDockDrop(Sender: TObject;
  Source: TDragDockObject; X, Y: Integer);
var
  SendingTab : TDockTabSet;
begin
  SendingTab := Sender as TDockTabSet;
  if Source.Control.Visible then
    SendingTab.ShowDockClient(Source.Control);
end;

procedure TMainForm.DockTabSetGetSiteInfo(Sender: TObject;
  DockClient: TControl; var InfluenceRect: TRect; MousePos: TPoint;
  var CanDock: Boolean);
var
  SendingTab : TDockTabSet;
begin
  SendingTab := Sender as TDockTabSet;
  InfluenceRect.Right := SendingTab.DestinationDockSite.ClientWidth;
  CanDock := (DockClient is TDockableForm) and (SendingTab.Tabs.Count > 0);
end;

procedure TMainForm.DockTabSetTabAdded(Sender: TObject);
var
  SendingTab : TDockTabSet;
  i: Integer;
const
  cDockTabHeight = 23;
begin
    SendingTab := Sender as TDockTabSet;
    if SendingTab.Tabs.Count = 1 then
    begin
       if SendingTab.Align in [alBottom, alTop] then
       begin
        SendingTab.Height := cDockTabHeight;
        if SendingTab.Align = alTop then
            SendingTab.Top := 0
        else
            SendingTab.Top := ClientHeight;
       end
       else
       begin
        SendingTab.Width := cDockTabHeight;
        if SendingTab.Align = alLeft then
            SendingTab.Left := 0
        else
           SendingTab.Left := ClientWidth;
       end;
    end;
    for i := Low(DockWindows) to High(DockWindows) do
       if DockWindows[i].LRDockWidth = DockAreaHiddenWidth then
          DockWindows[i].LRDockWidth := ClientWidth div 3;
end;

procedure TMainForm.DockTabSetTabRemoved(Sender: TObject);
var
  SendingTab : TDockTabSet;
begin
    SendingTab := Sender as TDockTabSet;
    if SendingTab.Tabs.Count = 0 then
       if SendingTab.Align in [alBottom,alTop] then
            SendingTab.Height := 0
        else
        begin
            SendingTab.Width := 0;
        end;
end;

procedure TMainForm.DockPanelDockDrop(Sender: TObject; Source: TDragDockObject; X, Y: Integer);
begin
  //OnDockDrop gets called AFTER the client has actually docked,
  //so we check for DockClientCount = 1 before making the dock panel visible.
  if (Sender as TPanel).DockClientCount = 1 then
    ShowDockPanel(Sender as TPanel, True, nil);
    if (Sender as TPanel).Align = alBottom then
       BottomDockTabSet.Top  := ClientHeight;
  (Sender as TPanel).DockManager.ResetBounds(True);
  //Make DockManager repaints it's clients.
end;

procedure TMainForm.DockPanelGetSiteInfo(Sender: TObject;
  DockClient: TControl; var InfluenceRect: TRect; MousePos: TPoint;
  var CanDock: Boolean);
begin
  //if CanDock is true, the panel will not automatically draw the preview rect.
  CanDock := (DockClient is TDockableForm);
end;

procedure TMainForm.DockPanelUnDock(Sender: TObject; Client: TControl;
  NewTarget: TWinControl; var Allow: Boolean);
begin
  //OnUnDock gets called BEFORE the client is undocked, in order to optionally
  //disallow the undock. DockClientCount is never 0 when called from this event.
  if ((Sender as TPanel).DockClientCount = 1) then
    ShowDockPanel(Sender as TPanel, False, nil);
end;

procedure TMainForm.ShowDockPanel(APanel: TPanel; MakeVisible: Boolean; Client: TControl);
begin

  //Since docking to a non-visible docksite isn't allowed, instead of setting
  //Visible for the panels we set the width to zero. The default InfluenceRect
  //for a control extends a few pixels beyond it's boundaries, so it is possible
  //to dock to zero width controls.

  //Don't try to hide a panel which has visible dock clients.

  if not MakeVisible and (APanel.VisibleDockClientCount > 1) then
    Exit;

  if APanel = LeftDockPanel then
    VSplitter.Visible := MakeVisible
  else if APanel = RightDockPanel then
    VSplitterR.Visible := MakeVisible
  else if APanel = BottomDockPanel then
    HSplitter.Visible := MakeVisible;

  if MakeVisible then
  begin
    if APanel = LeftDockPanel then
    begin
      APanel.Width := ClientWidth div 3;
      VSplitter.Left := APanel.Width + VSplitter.Width;
    end
    else if APanel = RightDockPanel then
    begin
      APanel.Width := ClientWidth div 3;
      VSplitterR.Left := MainForm.Width - (APanel.Width + VSplitterR.Width);
    end
    else if APanel = BottomDockPanel then
    begin
      APanel.Height := ClientHeight div 3;
      HSplitter.Top := ClientHeight - APanel.Height - HSplitter.Width;
    end
  end
    else
    if APanel = LeftDockPanel then
      APanel.Width := DockAreaHiddenWidth
    else if APanel = RightDockPanel then
      APanel.Width := DockAreaHiddenWidth
    else if APanel = BottomDockPanel then
      APanel.Height := DockAreaHiddenWidth;
  if MakeVisible and (Client <> nil) then
    Client.Show;
end;

procedure TMainForm.URLEditKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = 13 then
  begin
    Go.Execute;
    Key := 0;
  end;
end;

procedure TMainForm.URLEditKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
    Key := #0;
end;

procedure TMainForm.CentralDockPanelDockOver(Sender: TObject;
  Source: TDragDockObject; X, Y: Integer; State: TDragState;
  var Accept: Boolean);
begin
  Accept := Source.Control is TDockableForm;
end;

procedure TMainForm.CoolBar1DockOver(Sender: TObject; Source: TDragDockObject;
  X, Y: Integer; State: TDragState; var Accept: Boolean);
var
  ARect: TRect;
begin
  Accept := (Source.Control is TToolBar);
  if Accept then
  begin
    //Modify the DockRect to preview dock area (Coolbar client area)
    ARect.TopLeft := CoolBar1.ClientToScreen(CoolBar1.ClientRect.TopLeft);
    ARect.BottomRight := CoolBar1.ClientToScreen(CoolBar1.ClientRect.BottomRight);
    Source.DockRect := ARect;
  end;
end;


procedure TMainForm.ViewToolBar1Execute(Sender: TObject);
begin
  //Toggles the visible state of Toolbar1, regardless of it's docked state.
  ToolBar11.Checked := not ToolBar11.Checked;
  if ToolBar1.Floating then
    ToolBar1.HostDockSite.Visible := ToolBar11.Checked
  else
    ToolBar1.Visible := ToolBar11.Checked;
end;

procedure TMainForm.ViewToolBar2Execute(Sender: TObject);
begin
  //Toggles the visible state of Toolbar2, regardless of it's docked state.
  ToolBar21.Checked := not ToolBar21.Checked;
  if ToolBar2.Floating then
    TToolDockForm(ToolBar2.HostDockSite).Visible := ToolBar21.Checked
  else
    ToolBar2.Visible := ToolBar21.Checked;
end;

procedure TMainForm.Exit1Click(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.ExitActionExecute(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.Floatonclosedocked1Click(Sender: TObject);
var
  I: Integer;
begin
  Floatonclosedocked1.Checked:= not Floatonclosedocked1.Checked;

  for I := Low(DockWindows) to High(DockWindows) do
    DockWindows[I].FloatOnCloseDock:= Floatonclosedocked1.Checked;
end;

procedure TMainForm.ViewWindowExecute(Sender: TObject);
var
  DockWindow: TDockableForm;

begin
  DockWindow := DockWindows[(Sender as TComponent).Tag];
  //if the docked window is TabDocked, it is docked to the PageControl
  //(owned by TTabDockHost) so show the host form.
  if DockWindow.HostDockSite is TPageControl then
    TTabDockHost(DockWindow.HostDockSite.Owner).Show
  else
  //If window is conjoin-docked, host and/or form may not be visible
  //so show both.
  if (DockWindow.HostDockSite is TConjoinDockHost) and not
    DockWindow.HostDockSite.Visible then
  begin
    DockWindow.HostDockSite.Show;
    TConjoinDockHost(DockWindow.HostDockSite).UpdateCaption(nil);
    DockWindow.Show;
  end
  else
  //If form is docked to one of the "hidden" docking panels, resize the
  //panel and re-show the docked form.
  if (DockWindow.HostDockSite is TPanel) and
    ((DockWindow.HostDockSite.Height = DockAreaHiddenWidth) or (DockWindow.HostDockSite.Width = DockAreaHiddenWidth)) then
    MainForm.ShowDockPanel(DockWindow.HostDockSite as TPanel, True, DockWindow)
  else
    //if the window isn't docked at all, simply show it.
    DockWindow.Show;
end;


end.
