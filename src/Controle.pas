unit Controle;
interface
uses Winapi.Windows, System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.Buttons, System.SysUtils, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.MySQL,
  FireDAC.Phys.MySQLDef, FireDAC.VCLUI.Wait, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client;
type
  TControleLicenca = class(TForm)
    lbStatus: TLabel;
    lbPorta: TLabel;
    btnStop: TBitBtn;
    btnStart: TBitBtn;
    Conexao: TFDConnection;
    FDPhysMySQLDriverLink1: TFDPhysMySQLDriverLink;
    Q_Licenca: TFDQuery;
    procedure btnStopClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnStartClick(Sender: TObject);
  private
    procedure Status;
    procedure Start;
    procedure Stop;
  end;
var
  ControleLicenca: TControleLicenca;
implementation
uses Horse;
{$R *.dfm}
procedure TControleLicenca.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if THorse.IsRunning then
    Stop;
end;
procedure TControleLicenca.Start;
begin
  THorse.Get('/situacao/:Codigo_Cliente',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    var
     Codigo: Integer;
    begin
      Q_Licenca.Close;
      Codigo := Req.Params.Items['Codigo_Cliente'].ToInteger;
      Q_Licenca.ParamByName('Codigo_Cliente').AsInteger := Codigo;
      Q_Licenca.Open();
      Res.Send(Q_Licenca.FieldByName('Situacao').AsString);
    end);
  THorse.Listen(50000);
end;
procedure TControleLicenca.Status;
begin
  btnStop.Enabled := THorse.IsRunning;
  btnStart.Enabled := not THorse.IsRunning;
  if THorse.IsRunning then
  begin
    lbStatus.Caption := 'Status: Online';
    lbPorta.Caption := 'Port: ' + IntToStr(THorse.Port);
  end
  else
  begin
    lbStatus.Caption := 'Status: Offline';
    lbPorta.Caption := 'Port: ';
  end;
end;
procedure TControleLicenca.Stop;
begin
  THorse.StopListen;
end;
procedure TControleLicenca.btnStartClick(Sender: TObject);
begin
  Start;
  Status;
end;
procedure TControleLicenca.btnStopClick(Sender: TObject);
begin
  Stop;
  Status;
end;
end.
