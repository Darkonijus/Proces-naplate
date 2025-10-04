
unit fPayment;

interface

uses
  System.SysUtils, System.Classes, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, Vcl.Dialogs,
  uDM;

type
  TfrmPayment = class(TForm)
    btnCash: TButton;
    btnCard: TButton;
    lblInfo: TLabel;
    procedure btnCashClick(Sender: TObject);
    procedure btnCardClick(Sender: TObject);
  private
    FOrderId: Integer;
    procedure DoPay(const Method: string);
  public
    procedure Init(AOrderId: Integer);
  end;

var
  frmPayment: TfrmPayment;

implementation

{$R *.dfm}

procedure TfrmPayment.Init(AOrderId: Integer);
begin
  FOrderId := AOrderId;
  Caption := 'Plaćanje';
  lblInfo.Caption := 'Odaberi metod plaćanja';
end;

procedure TfrmPayment.DoPay(const Method: string);
var
  total: Currency;
  receipt: string;
begin
  total := DM.CalcTotal(FOrderId);
  DM.AddPayment(FOrderId, Method, total);
  receipt := DM.IssueReceipt(FOrderId);
  ShowMessage('Plaćanje uspešno. Račun: ' + receipt);
  ModalResult := mrOk;
end;

procedure TfrmPayment.btnCashClick(Sender: TObject);
begin
  DoPay('CASH');
end;

procedure TfrmPayment.btnCardClick(Sender: TObject);
begin
  DoPay('CARD');
end;

end.
