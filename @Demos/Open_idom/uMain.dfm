object MainForm: TMainForm
  Left = 530
  Top = 233
  Caption = 'Open_idom Demo'
  ClientHeight = 460
  ClientWidth = 667
  Color = clWindow
  ParentFont = True
  Menu = MainMenu1
  OldCreateOrder = False
  Position = poDesigned
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object VSplitter: TSplitter
    Left = 164
    Top = 48
    Width = 6
    Height = 324
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Visible = False
    ExplicitLeft = 28
    ExplicitTop = 52
    ExplicitHeight = 304
  end
  object HSplitter: TSplitter
    Left = 0
    Top = 372
    Width = 667
    Height = 4
    Cursor = crVSplit
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Align = alBottom
    Visible = False
    ExplicitLeft = 7
    ExplicitTop = 344
  end
  object VSplitterR: TSplitter
    Left = 497
    Top = 48
    Width = 6
    Height = 324
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Align = alRight
    Visible = False
    ExplicitLeft = 445
    ExplicitTop = 44
    ExplicitHeight = 304
  end
  object BottomDockPanel: TPanel
    Left = 0
    Top = 376
    Width = 667
    Height = 63
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Align = alBottom
    BevelOuter = bvNone
    Color = clWindow
    DockSite = True
    ParentBackground = False
    TabOrder = 2
    OnDockDrop = DockPanelDockDrop
    OnDockOver = BottomDockPanelDockOver
    OnGetSiteInfo = DockPanelGetSiteInfo
    OnUnDock = DockPanelUnDock
  end
  object CoolBar1: TCoolBar
    Left = 0
    Top = 0
    Width = 667
    Height = 48
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    AutoSize = True
    BandMaximize = bmDblClick
    Bands = <
      item
        Break = False
        Control = ToolBar1
        ImageIndex = -1
        MinHeight = 21
        Width = 661
      end
      item
        Control = ToolBar2
        ImageIndex = -1
        MinHeight = 21
        Width = 661
      end>
    DockSite = True
    OnDockOver = CoolBar1DockOver
    object ToolBar1: TToolBar
      Left = 11
      Top = 0
      Width = 652
      Height = 21
      AutoSize = True
      ButtonHeight = 21
      ButtonWidth = 30
      Caption = 'ToolBar1'
      Constraints.MaxWidth = 800
      DragKind = dkDock
      DragMode = dmAutomatic
      ShowCaptions = True
      TabOrder = 0
      Transparent = True
      Wrapable = False
      object ToolButton8: TToolButton
        Left = 0
        Top = 0
        Action = Back
      end
      object ToolButton9: TToolButton
        Left = 30
        Top = 0
        Action = Forward
      end
      object Label1: TLabel
        Left = 60
        Top = 0
        Width = 23
        Height = 21
        Caption = 'URL:'
        Layout = tlCenter
      end
      object URLEdit: TEdit
        Left = 83
        Top = 0
        Width = 185
        Height = 21
        TabOrder = 0
        Text = 'http://haz.io/'
        OnKeyPress = URLEditKeyPress
        OnKeyUp = URLEditKeyDown
      end
      object ToolButton10: TToolButton
        Left = 268
        Top = 0
        Action = Go
      end
      object ToolButton11: TToolButton
        Left = 298
        Top = 0
        Action = Load
      end
      object ToolButton13: TToolButton
        Left = 328
        Top = 0
        Action = ExitAction
        Caption = 'Exit'
      end
    end
    object ToolBar2: TToolBar
      Left = 11
      Top = 23
      Width = 652
      Height = 21
      AutoSize = True
      ButtonHeight = 21
      ButtonWidth = 46
      Caption = 'ToolBar2'
      Constraints.MaxWidth = 800
      DragKind = dkDock
      DragMode = dmAutomatic
      ShowCaptions = True
      TabOrder = 1
      Transparent = True
      Wrapable = False
      object ToolButton1: TToolButton
        Left = 0
        Top = 0
        Action = ViewBrowserWindow
        Caption = 'Browser'
      end
      object ToolButton2: TToolButton
        Left = 46
        Top = 0
        Action = ViewLogWindow
        Caption = 'Log'
      end
      object ToolButton3: TToolButton
        Left = 92
        Top = 0
        Action = ViewXMLWindow
        Caption = 'XML'
      end
      object ToolButton7: TToolButton
        Left = 138
        Top = 0
        Action = ViewXSLTWindow
        Caption = 'XSLT'
      end
      object ToolButton4: TToolButton
        Left = 184
        Top = 0
        Action = ViewTealWindow
        Caption = 'Teal'
      end
      object ToolButton5: TToolButton
        Left = 230
        Top = 0
        Action = ViewLimeWindow
        Caption = 'Lime'
      end
      object ToolButton6: TToolButton
        Left = 276
        Top = 0
        Action = ViewPurpleWindow
        Caption = 'Purple'
      end
    end
  end
  object LeftDockPanel: TPanel
    Left = 23
    Top = 48
    Width = 141
    Height = 324
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Align = alLeft
    BevelOuter = bvNone
    Color = clWindow
    DockSite = True
    ParentBackground = False
    TabOrder = 0
    OnDockDrop = DockPanelDockDrop
    OnDockOver = LeftDockPanelDockOver
    OnGetSiteInfo = DockPanelGetSiteInfo
    OnUnDock = DockPanelUnDock
  end
  object LeftDockTabSet: TDockTabSet
    Left = 0
    Top = 48
    Width = 23
    Height = 324
    Align = alLeft
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ShrinkToFit = True
    Style = tsModernTabs
    TabPosition = tpRight
    AutoSelect = True
    DestinationDockSite = LeftDockPanel
    OnDockDrop = DockTabSetDockDrop
    OnGetSiteInfo = DockTabSetGetSiteInfo
    OnTabAdded = DockTabSetTabAdded
    OnTabRemoved = DockTabSetTabRemoved
  end
  object BottomDockTabSet: TDockTabSet
    Left = 0
    Top = 439
    Width = 667
    Height = 21
    Align = alBottom
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    SoftTop = True
    Style = tsModernTabs
    DestinationDockSite = BottomDockPanel
    OnDockDrop = DockTabSetDockDrop
    OnGetSiteInfo = DockTabSetGetSiteInfo
    OnTabAdded = DockTabSetTabAdded
    OnTabRemoved = DockTabSetTabRemoved
  end
  object RightDockTabSet: TDockTabSet
    Left = 644
    Top = 48
    Width = 23
    Height = 324
    Align = alRight
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ShrinkToFit = True
    Style = tsModernTabs
    TabPosition = tpLeft
    AutoSelect = True
    DestinationDockSite = RightDockPanel
    OnDockDrop = DockTabSetDockDrop
    OnGetSiteInfo = DockTabSetGetSiteInfo
    OnTabAdded = DockTabSetTabAdded
    OnTabRemoved = DockTabSetTabRemoved
  end
  object RightDockPanel: TPanel
    Left = 503
    Top = 48
    Width = 141
    Height = 324
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Align = alRight
    BevelOuter = bvNone
    Color = clWindow
    DockSite = True
    ParentBackground = False
    TabOrder = 6
    OnDockDrop = DockPanelDockDrop
    OnDockOver = RightDockPanelDockOver
    OnGetSiteInfo = DockPanelGetSiteInfo
    OnUnDock = DockPanelUnDock
  end
  object CentralDockPanel: TPanel
    Left = 170
    Top = 48
    Width = 327
    Height = 324
    Align = alClient
    Caption = 'Dock here!'
    Color = clWindow
    DockSite = True
    TabOrder = 7
    OnDockDrop = DockPanelDockDrop
    OnDockOver = CentralDockPanelDockOver
    OnGetSiteInfo = DockPanelGetSiteInfo
    OnUnDock = DockPanelUnDock
    object CentralDockTab: TDockTabSet
      Left = 1
      Top = 1
      Width = 325
      Height = 21
      Align = alTop
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      SoftTop = True
      Style = tsModernTabs
      TabPosition = tpTop
      DestinationDockSite = CentralDockPanel
      OnDockDrop = DockTabSetDockDrop
      OnGetSiteInfo = DockTabSetGetSiteInfo
      OnTabAdded = DockTabSetTabAdded
      OnTabRemoved = DockTabSetTabRemoved
    end
  end
  object ActionList1: TActionList
    Left = 136
    Top = 80
    object ViewToolBar1: TAction
      Category = 'ViewToolBars'
      Caption = 'ToolBar &1'
      Checked = True
      ImageIndex = 1
      OnExecute = ViewToolBar1Execute
    end
    object ViewToolBar2: TAction
      Category = 'ViewToolBars'
      Caption = 'ToolBar &2'
      Checked = True
      ImageIndex = 2
      OnExecute = ViewToolBar2Execute
    end
    object ViewBrowserWindow: TAction
      Category = 'ViewWindows'
      Caption = '&Browser'
      Hint = 'View Browser window'
      OnExecute = ViewWindowExecute
    end
    object ExitAction: TAction
      Caption = 'E&xit'
      OnExecute = ExitActionExecute
    end
    object ViewLogWindow: TAction
      Tag = 1
      Category = 'ViewWindows'
      Caption = '&Log'
      OnExecute = ViewWindowExecute
    end
    object ViewXMLWindow: TAction
      Tag = 2
      Category = 'ViewWindows'
      Caption = '&XML'
      OnExecute = ViewWindowExecute
    end
    object ViewXSLTWindow: TAction
      Tag = 3
      Category = 'ViewWindows'
      Caption = 'X&SLT'
      OnExecute = ViewWindowExecute
    end
    object ViewTealWindow: TAction
      Tag = 4
      Category = 'ViewWindows'
      Caption = '&Teal'
      OnExecute = ViewWindowExecute
    end
    object ViewPurpleWindow: TAction
      Tag = 5
      Category = 'ViewWindows'
      Caption = '&Purple'
      OnExecute = ViewWindowExecute
    end
    object ViewLimeWindow: TAction
      Tag = 6
      Category = 'ViewWindows'
      Caption = '&Lime'
      OnExecute = ViewWindowExecute
    end
    object Back: TAction
      Category = 'Browser'
      Caption = '<-'
      OnExecute = BackExecute
    end
    object Forward: TAction
      Category = 'Browser'
      Caption = '->'
      OnExecute = ForwardExecute
    end
    object Go: TAction
      Category = 'Browser'
      Caption = 'Go'
      OnExecute = GoExecute
    end
    object Load: TAction
      Category = 'Browser'
      Caption = 'Load'
      OnExecute = LoadExecute
    end
  end
  object MainMenu1: TMainMenu
    Left = 176
    Top = 80
    object File2: TMenuItem
      Caption = '&File'
      object Exit2: TMenuItem
        Action = ExitAction
      end
    end
    object View2: TMenuItem
      Caption = '&View'
      object ToolBar11: TMenuItem
        Action = ViewToolBar1
      end
      object ToolBar21: TMenuItem
        Action = ViewToolBar2
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object Floatonclosedocked1: TMenuItem
        Caption = 'Float on close docked'
        Checked = True
        OnClick = Floatonclosedocked1Click
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object White1: TMenuItem
        Action = ViewBrowserWindow
      end
      object Blue1: TMenuItem
        Action = ViewLogWindow
      end
      object Green1: TMenuItem
        Action = ViewXMLWindow
      end
      object Lime1: TMenuItem
        Action = ViewLimeWindow
      end
      object Purple1: TMenuItem
        Action = ViewPurpleWindow
      end
      object Red1: TMenuItem
        Action = ViewXSLTWindow
      end
      object Teal1: TMenuItem
        Action = ViewTealWindow
      end
    end
  end
end
