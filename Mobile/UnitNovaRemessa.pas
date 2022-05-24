unit UnitNovaRemessa;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Edit,
  FMX.Objects, FMX.Controls.Presentation, FMX.StdCtrls, uLoading, uFunctions,
  uSession;

type
  TCallbackRemessa = procedure of object;

  TFrmNovaRemessa = class(TForm)
    rectToolbar1: TRectangle;
    lblTitulo: TLabel;
    imgVoltar: TImage;
    imgSalvar: TImage;
    edtDescricao: TEdit;
    edtValor: TEdit;
    edtDestino: TEdit;
    edtOrigem: TEdit;
    imgDelete: TImage;
    procedure imgVoltarClick(Sender: TObject);
    procedure imgSalvarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure imgDeleteClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FId_Remessa: integer;
    FExecuteOnClose: TCallbackRemessa;
    procedure ThreadLoadTerminate(Sender: TObject);
    procedure ThreadRemessaTerminate(Sender: TObject);
    { Private declarations }
  public
    property ExecuteOnClose: TCallbackRemessa read FExecuteOnClose write FExecuteOnClose;
    property Id_Remessa: integer read FId_Remessa write FId_remessa;
  end;

var
  FrmNovaRemessa: TFrmNovaRemessa;

implementation

{$R *.fmx}

uses DataModule.Remessa;

procedure TFrmNovaRemessa.ThreadLoadTerminate(Sender: TObject);
begin
    TLoading.Hide;

    if ErroThread(Sender) then
        exit;
end;

procedure TFrmNovaRemessa.ThreadRemessaTerminate(Sender: TObject);
begin
    TLoading.Hide;

    if ErroThread(Sender) then
        exit;

    close;
end;

procedure TFrmNovaRemessa.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    if Assigned(ExecuteOnClose) then
        ExecuteOnClose;

    Action := TCloseAction.caFree;
    FrmNovaRemessa := nil;
end;

procedure TFrmNovaRemessa.FormShow(Sender: TObject);
var
    t: TThread;
begin
    imgDelete.Visible := Id_Remessa > 0;

    if Id_Remessa > 0 then
    begin
        lblTitulo.Text := 'Editar Remessa';
        TLoading.Show(FrmNovaRemessa, '');

        t := TThread.CreateAnonymousThread(procedure
        begin
            DmRemessa.ListarRemessaId(Id_Remessa);

            with DmRemessa.TabRemessa do
            begin
                TThread.Synchronize(TThread.CurrentThread, procedure
                begin
                    edtDescricao.Text := fieldbyname('descricao').asstring;
                    edtOrigem.Text := fieldbyname('origem').asstring;
                    edtDestino.Text := fieldbyname('destino').asstring;
                    edtValor.Text := FormatFloat('#,##0.00', fieldbyname('valor').asfloat);
                end);
                if fieldbyname('status').asstring <> 'P' then
                begin
                  edtDescricao.ENABLED := False;
                  edtOrigem   .ENABLED := False;
                  edtDestino  .ENABLED := False;
                  edtValor    .ENABLED := False;
                end ;
            end;
        end);

        t.OnTerminate := ThreadLoadTerminate;
        t.Start;
    end;
end;

procedure TFrmNovaRemessa.imgDeleteClick(Sender: TObject);
var
    t: TThread;
begin
    TLoading.Show(FrmNovaRemessa, '');

    t := TThread.CreateAnonymousThread(procedure
    begin
        sleep(1500);

        DmRemessa.ExcluirRemessa(Id_Remessa);
    end);

    t.OnTerminate := ThreadRemessaTerminate;
    t.Start;
end;

procedure TFrmNovaRemessa.imgSalvarClick(Sender: TObject);
var
    t: TThread;
begin
    TLoading.Show(FrmNovaRemessa, '');

    t := TThread.CreateAnonymousThread(procedure
    begin
        sleep(1500);

        if Id_Remessa = 0 then
            DmRemessa.InserirRemessa(edtDescricao.Text,
                                     edtOrigem.Text,
                                     edtDestino.Text,
                                     0,
                                     0,
                                     uFunctions.StringToDouble(edtValor.Text),
                                     TSession.ID_USUARIO)
        else
            DmRemessa.EditarRemessa(Id_Remessa,
                                    edtDescricao.Text,
                                    edtOrigem.Text,
                                    edtDestino.Text,
                                    0,
                                    0,
                                    uFunctions.StringToDouble(edtValor.Text));
    end);

    t.OnTerminate := ThreadRemessaTerminate;
    t.Start;
end;

procedure TFrmNovaRemessa.imgVoltarClick(Sender: TObject);
begin
    ExecuteOnClose := nil;
    close;
end;

end.
