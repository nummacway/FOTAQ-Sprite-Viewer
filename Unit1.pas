unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls;

type
  TPaletteEntry = packed record
    R, G, B: Byte;
  end;

type
  TUncompressedLZWEncoder = class
    strict private
      BlockData: TMemoryStream;
      SymbolTemp: Byte;
      TempShift: Byte;
      FTarget: TStream;
      procedure Write();
    public
      constructor Create(Target: TStream);
      procedure WriteSymbol(Symbol: Word);
      procedure Finalize();
  end;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    Button1: TButton;
    Button2: TButton;
    ListView1: TListView;
    OpenDialogPAL: TOpenDialog;
    OpenDialogSAM: TOpenDialog;
    Panel2: TPanel;
    Image1: TImage;
    Button3: TButton;
    ListViewPAL: TListView;
    ListViewSAM: TListView;
    SaveDialogGIF: TSaveDialog;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure ListViewPALSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure ListViewSAMSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure Button3Click(Sender: TObject);
  private
    { Private-Deklarationen }
    procedure LoadPAL(FileName: string);
    procedure LoadSAM(FileName: string);
    procedure MakeGIF();
    var
      Count: Word;
      l, t, r, b: SmallInt;
  public
    { Public-Deklarationen }
    var
      Stream: TStream;
      Palette: packed array[Byte] of TPaletteEntry;
  end;

var
  Form1: TForm1;

implementation

uses
  GIFImg, GIFConsts, Math, IOUtils;

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
var
  s: string;
begin
  if OpenDialogPAL.Execute() then
  begin
    LoadPAL(OpenDialogPAL.FileName);

    ListViewPAL.Items.BeginUpdate();
    try
      ListViewPAL.Items.Clear();
      for s in TDirectory.GetFiles(ExtractFilePath(OpenDialogPAL.FileName), '*.pcx') do
      with ListViewPAL.Items.Add do
      begin
        Caption := ExtractFileName(s);
        SubItems.Add(s);
      end;
    finally
      ListViewPAL.Items.EndUpdate();
    end;
  end;
end;
function Predicate(const Path: string; const SearchRec: TSearchRec): Boolean;
var
  Ext: string;
begin
  Ext := Lowercase(ExtractFileExt(SearchRec.Name));
  if Ext = '.sam' then
  Exit(True);
  if Ext = '.bbk' then
  Exit(True);
  if Ext = '.act' then
  Exit(True);
  Result := False;
end;

procedure TForm1.Button2Click(Sender: TObject);

var
  s: string;
begin
  if OpenDialogSAM.Execute() then
  begin
    LoadSAM(OpenDialogSAM.FileName);

    ListViewSAM.Items.BeginUpdate();
    try
      ListViewSAM.Items.Clear();
      for s in TDirectory.GetFiles(ExtractFilePath(OpenDialogSAM.FileName), Predicate) do
      with ListViewSAM.Items.Add do
      begin
        Caption := ExtractFileName(s);
        SubItems.Add(s);
      end;
    finally
      ListViewSAM.Items.EndUpdate();
    end;
  end;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  if Assigned(Stream) then
  if SaveDialogGIF.Execute() then
  (Image1.Picture.Graphic as TGIFImage).SaveToFile(SaveDialogGIF.FileName);
end;

procedure TForm1.ListViewPALSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  if Selected then
  LoadPAL(Item.SubItems[0]);
end;

procedure TForm1.ListViewSAMSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  if Selected then
  LoadSAM(Item.SubItems[0]);
end;

procedure TForm1.LoadPAL(FileName: string);
var
  Stream: TFileStream;
begin
  Stream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
  try
    Stream.Position := Stream.Size - 768;
    Stream.Read(Palette[0], 768);
    MakeGIF();
  finally
    Stream.Free();
  end;
end;

procedure TForm1.LoadSAM(FileName: string);
var
  i: Integer;
  w, h, x, y: SmallInt;
begin
  l := 0;
  t := 0;
  r := 0;
  b := 0;
  FreeAndNil(Stream);
  Stream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
  ListView1.Items.BeginUpdate();
  try
    ListView1.Items.Clear();
    Stream.ReadData(Count);
    for i := 0 to Count - 1 do
    with ListView1.Items.Add do
    begin
      Caption := IntToStr(i);
      Data := Pointer(Stream.Position);
      Stream.ReadData(w);
      Stream.ReadData(h);
      Stream.ReadData(x);
      Stream.ReadData(y);
      l := Max(l, x);
      t := Max(t, y);
      r := Max(r, w-x);
      b := Max(b, h-y);
      SubItems.Add(IntToStr(w));
      SubItems.Add(IntToStr(h));
      SubItems.Add(IntToStr(x));
      SubItems.Add(IntToStr(y));
      Stream.Position := Stream.Position + w*h;
    end;

    MakeGIF();
  finally
    ListView1.Items.EndUpdate();
  end;
end;

procedure TForm1.MakeGIF;
var
  GIF: TMemoryStream;
  i, j: Integer;
  w, h, x, y: SmallInt;
  Enc: TUncompressedLZWEncoder;
  Temp: Byte;
begin
  if not Assigned(Stream) then
  Exit;
  GIF := TMemoryStream.Create();
  try
    GIF.WriteData(AnsiChar('G')); // Header
    GIF.WriteData(AnsiChar('I'));
    GIF.WriteData(AnsiChar('F'));
    GIF.WriteData(AnsiChar('8'));
    GIF.WriteData(AnsiChar('9'));
    GIF.WriteData(AnsiChar('a'));
    // Logical Screen Descriptor
    GIF.WriteData(Word(l+r)); // Logical Screen Width
    GIF.WriteData(Word(t+b)); // Logical Screen Height
    GIF.WriteData(Byte($f7));
    GIF.WriteData(Byte(0));
    GIF.WriteData(Byte(0));
    // Global Color Table
    GIF.Write(Palette[0], 768);

    // Read and write stream
    Stream.Position := 2;
    for i := 0 to Count - 1 do
    begin
      // Graphic Control Extension
      GIF.WriteData(AnsiChar('!'));
      GIF.WriteData(Byte($f9));
      GIF.WriteData(Byte(4));
      GIF.WriteData($09); // Transparency (last bit) and disposal mode
      GIF.WriteData(Word(10)); // Delay
      GIF.WriteData(Byte(0)); // Transparent Color
      GIF.WriteData(Byte(0));
      Stream.ReadData(w);
      Stream.ReadData(h);
      Stream.ReadData(x);
      Stream.ReadData(y);
      // Image Descriptor
      GIF.WriteData(AnsiChar(','));
      GIF.WriteData(Word(l-x)); // Logical Screen Position X
      GIF.WriteData(Word(t-y)); // Logical Screen Position Y
      GIF.WriteData(w);
      GIF.WriteData(h);
      GIF.WriteData(Byte(False)); // Local Palette?
      // Image Data
      GIF.WriteData(Byte(8));
      Enc := TUncompressedLZWEncoder.Create(GIF);
      try
        for j := 0 to w*h-1 do
        begin
          Stream.ReadData(Temp);
          Enc.WriteSymbol(Temp);
        end;
        Enc.Finalize();
      finally
        Enc.Free();
      end;
    end;
    GIF.WriteData(AnsiChar(';'));
    GIF.Position := 0;
    Image1.Picture.LoadFromStream(GIF);
    (Image1.Picture.Graphic as TGIFImage).Animate := True;
    (Image1.Picture.Graphic as TGIFImage).Transparent := True;
    //GIF.SaveToFile('temp.gif');
  finally
    GIF.Free();
  end;
end;

{ TUncompressedLZWEncoder }

constructor TUncompressedLZWEncoder.Create(Target: TStream);
begin
  FTarget := Target;
  BlockData := TMemoryStream.Create();
  TempShift := 0;
  SymbolTemp := 0;
  WriteSymbol($100);
end;

procedure TUncompressedLZWEncoder.Finalize;
begin
  while TempShift <> 7 do // I don't know how padding works, so I spam CLEAR until I do not need padding
  WriteSymbol($100);
  WriteSymbol($101);
  Write();
  FTarget.WriteData(Byte(0));
end;

procedure TUncompressedLZWEncoder.Write;
begin
  FTarget.WriteData(Byte(BlockData.Size));
  BlockData.Position := 0;
  FTarget.CopyFrom(BlockData, BlockData.Size);
  BlockData.Clear();
  WriteSymbol($100);
end;

procedure TUncompressedLZWEncoder.WriteSymbol(Symbol: Word);
var
  i: Integer;
begin
  // Swaps bit-order
  for i := 0 to 8 do
  begin
    SymbolTemp := SymbolTemp or (((Symbol shr i) and 1) shl TempShift);
    Inc(TempShift);
    if TempShift = 8 then
    begin
      BlockData.WriteData(SymbolTemp);
      TempShift := 0;
      SymbolTemp := 0;
      if BlockData.Size = 252 then // 224 9-bit symbols written
      Write();
    end;
  end;
end;

end.
