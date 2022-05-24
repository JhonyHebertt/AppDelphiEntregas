unit UnitStatusRemessa;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, uLoading, uFunctions,
  uSession;

type
  TCallbackRemessa = procedure of object;

  TFrmStatusRemessa = class(TForm)
    rectToolbar1: TRectangle;
    Label1: TLabel;
    imgVoltar: TImage;
    lblDescricao: TLabel;
    Layout1: TLayout;
    Image1: TImage;
    lblOrigem: TLabel;
    lblDestino: TLabel;
    lblValor: TLabel;
    rectCancelar: TRectangle;
    Label6: TLabel;
    rectFinalizar: TRectangle;
    Label7: TLabel;
    procedure imgVoltarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure rectCancelarClick(Sender: TObject);
    procedure rectFinalizarClick(Sender: TObject);
  private
    FId_Remessa: integer;
    FExecuteOnClose: TCallbackRemessa;
    procedure ThreadLoadTerminate(Sender: TObject);
    procedure ThreadStatusTerminate(Sender: TObject);
    { Private declarations }
  public
    property ExecuteOnClose: TCallbackRemessa read FExecuteOnClose write FExecuteOnClose;
    property Id_Remessa: integer read FId_Remessa write FId_remessa;
  end;

var
  FrmStatusRemessa: TFrmStatusRemessa;

implementation

{$R *.fmx}

uses DataModule.Remessa;

procedure TFrmStatusRemessa.ThreadLoadTerminate(Sender: TObject);
begin
    TLoading.Hide;

    if ErroThread(Sender) then
        exit;
end;

procedure TFrmStatusRemessa.ThreadStatusTerminate(Sender: TObject);
begin
    TLoading.Hide;

    if ErroThread(Sender) then
        exit;

    close;
end;

procedure TFrmStatusRemessa.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
    if Assigned(ExecuteOnClose) then
        ExecuteOnClose;

    Action := TCloseAction.caFree;
    FrmStatusRemessa := nil;
end;

procedure TFrmStatusRemessa.FormShow(Sender: TObject);
var
    t: TThread;
begin
    TLoading.Show(FrmStatusRemessa, '');

    t := TThread.CreateAnonymousThread(procedure
    begin
        sleep(1000);
        DmRemessa.ListarRemessaId(Id_Remessa);

        with DmRemessa.TabRemessa do
        begin
            TThread.Synchronize(TThread.CurrentThread, procedure
            begin
                lblDescricao.Text := fieldbyname('descricao').asstring;
                lblOrigem   .Text := fieldbyname('origem').asstring;
                lblDestino  .Text := fieldbyname('destino').asstring;
                lblValor    .Text := FormatFloat('#,##0.00', fieldbyname('valor').asfloat);

                // Tratar os botoes...
                if ((fieldbyname('id_usuario').AsInteger = TSession.ID_USUARIO) or (fieldbyname('status').AsString = 'F')) then
                begin
                    rectCancelar .Visible := false;
                    rectFinalizar.Visible := false;
                end;
            end);
        end;
    end);

    t.OnTerminate := ThreadLoadTerminate;
    t.Start;

end;

procedure TFrmStatusRemessa.imgVoltarClick(Sender: TObject);
begin
    ExecuteOnClose := nil;
    close;
end;

procedure TFrmStatusRemessa.rectCancelarClick(Sender: TObject);
var
    t: TThread;
begin
    TLoading.Show(FrmStatusRemessa, '');

    t := TThread.CreateAnonymousThread(procedure
    begin
        sleep(1000);
        DmRemessa.CancelarColetarRemessa(Id_Remessa);
    end);

    t.OnTerminate := ThreadStatusTerminate;
    t.Start;
end;

procedure TFrmStatusRemessa.rectFinalizarClick(Sender: TObject);
var
    t: TThread;
begin
    TLoading.Show(FrmStatusRemessa, '');

    t := TThread.CreateAnonymousThread(procedure
    begin
        sleep(1000);
        DmRemessa.FinalizarRemessa(Id_Remessa);
    end);

    t.OnTerminate := ThreadStatusTerminate;
    t.Start;
end;

end.
