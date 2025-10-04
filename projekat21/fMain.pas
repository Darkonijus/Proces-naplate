
unit fMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  uDM, fOrder, fCloseDay;

type
  TfrmMain = class(TForm)
    pnlTop: TPanel;
    btnCloseDay: TButton;
    btnReload: TButton;
    lblShift: TLabel;
    scrollTables: TScrollBox;
    procedure FormCreate(Sender: TObject);
    procedure btnReloadClick(Sender: TObject);
    procedure btnCloseDayClick(Sender: TObject);
  private
    FShiftId: Integer;
    procedure BuildTablesGrid;
    procedure OpenOrderForTable(ATable: Integer);
    procedure TableBtnClick(Sender: TObject);
  public
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  ShowMessage('DBG: TfrmMain.FormCreate start');
  // ensure we have an open shift id
  FShiftId := DM.ShiftOpenId;
  lblShift.Caption := 'Smena: ' + IntToStr(FShiftId);
  BuildTablesGrid;
  ShowMessage('DBG: TfrmMain.FormCreate end');
end;

procedure TfrmMain.BuildTablesGrid;
const
  COLS = 6;
  ROWS = 4;
var
  i, c, r: Integer;
  btn: TButton;
  pad, w, h: Integer;
begin
  scrollTables.DisableAlign;
  try
    scrollTables.Align := alClient;
    scrollTables.VertScrollBar.Range := 0;
    scrollTables.HorzScrollBar.Range := 0;
    // clear previous
    while scrollTables.ControlCount > 0 do
      scrollTables.Controls[0].Free;

    pad := 8;
    w := 90;
    h := 48;

    for i := 1 to COLS * ROWS do
    begin
      btn := TButton.Create(scrollTables);
      btn.Parent := scrollTables;
      btn.Caption := IntToStr(i);
      btn.Tag := i;
      c := (i-1) mod COLS;
      r := (i-1) div COLS;
      btn.Left := pad + c * (w + pad);
      btn.Top  := pad + r * (h + pad);
      btn.Width := w;
      btn.Height := h;
      btn.OnClick := TableBtnClick;
    end;
  finally
    scrollTables.EnableAlign;
  end;
end;

procedure TfrmMain.TableBtnClick(Sender: TObject);
begin
  if Sender is TButton then
    OpenOrderForTable(TButton(Sender).Tag);
end;

procedure TfrmMain.OpenOrderForTable(ATable: Integer);
begin
  with TfrmOrder.Create(Self) do
  try
    InitForTable(ATable, FShiftId);
    ShowModal;
  finally
    Free;
  end;
end;

procedure TfrmMain.btnReloadClick(Sender: TObject);
begin
  BuildTablesGrid;
  ShowMessage('DBG: TfrmMain.FormCreate end');
end;

procedure TfrmMain.btnCloseDayClick(Sender: TObject);
begin
  with TfrmCloseDay.Create(Self) do
  try
    Init(FShiftId);
    ShowModal;
  finally
    Free;
  end;
end;

end.
