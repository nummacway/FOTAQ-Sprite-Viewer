object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'ACT/BBK/SAM editor'
  ClientHeight = 736
  ClientWidth = 1171
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  TextHeight = 15
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 1171
    Height = 41
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object Button1: TButton
      Left = 8
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Load PCX...'
      TabOrder = 0
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 88
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Load File...'
      TabOrder = 1
      OnClick = Button2Click
    end
    object Button3: TButton
      Left = 168
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Save GIF...'
      TabOrder = 2
      OnClick = Button3Click
    end
  end
  object ListView1: TListView
    Left = 256
    Top = 41
    Width = 289
    Height = 695
    Align = alLeft
    Columns = <
      item
        Caption = 'Index'
      end
      item
        Alignment = taRightJustify
        Caption = 'w'
      end
      item
        Alignment = taRightJustify
        Caption = 'h'
      end
      item
        Alignment = taRightJustify
        Caption = 'x'
      end
      item
        Alignment = taRightJustify
        Caption = 'y'
      end>
    DoubleBuffered = True
    ReadOnly = True
    RowSelect = True
    ParentDoubleBuffered = False
    TabOrder = 1
    ViewStyle = vsReport
    ExplicitHeight = 694
  end
  object Panel2: TPanel
    Left = 545
    Top = 41
    Width = 626
    Height = 695
    Align = alClient
    TabOrder = 2
    ExplicitWidth = 622
    ExplicitHeight = 694
    object Image1: TImage
      Left = 1
      Top = 1
      Width = 624
      Height = 693
      Align = alClient
      Center = True
      Transparent = True
      ExplicitLeft = 360
      ExplicitTop = 280
      ExplicitWidth = 105
      ExplicitHeight = 105
    end
  end
  object ListViewPAL: TListView
    Left = 0
    Top = 41
    Width = 128
    Height = 695
    Align = alLeft
    Columns = <
      item
        Caption = 'File'
        Width = 100
      end>
    DoubleBuffered = True
    ReadOnly = True
    RowSelect = True
    ParentDoubleBuffered = False
    TabOrder = 3
    ViewStyle = vsReport
    OnSelectItem = ListViewPALSelectItem
    ExplicitHeight = 694
  end
  object ListViewSAM: TListView
    Left = 128
    Top = 41
    Width = 128
    Height = 695
    Align = alLeft
    Columns = <
      item
        Caption = 'File'
        Width = 100
      end>
    DoubleBuffered = True
    ReadOnly = True
    RowSelect = True
    ParentDoubleBuffered = False
    TabOrder = 4
    ViewStyle = vsReport
    OnSelectItem = ListViewSAMSelectItem
    ExplicitHeight = 694
  end
  object OpenDialogPAL: TOpenDialog
    Filter = 'Zsoft Paintbrush (*.pcx)|*.pcx'
    Left = 520
    Top = 168
  end
  object OpenDialogSAM: TOpenDialog
    Filter = 'Queen BBK/SAM/ACT (*.sam, *.bbk, *.act)|*.sam;*.bbk;*.act'
    Left = 592
    Top = 184
  end
  object SaveDialogGIF: TSaveDialog
    DefaultExt = '.gif'
    Filter = 'Compuserve GIF (*.gif)|*.gif'
    Left = 761
    Top = 241
  end
end
