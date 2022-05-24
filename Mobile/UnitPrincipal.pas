unit UnitPrincipal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.TabControl,
  FMX.Objects, FMX.Controls.Presentation, FMX.StdCtrls, FMX.ListView.Types,
  FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView,
  FMX.Ani, System.IniFiles, uFunctions, uLoading, FMX.DialogService,
  uSession;

type
  TFrmPrincipal = class(TForm)
    TabControl: TTabControl;
    TabItem1: TTabItem;
    TabItem2: TTabItem;
    TabItem3: TTabItem;
    rectAbas: TRectangle;
    imgAba1: TImage;
    imgAba2: TImage;
    imgAba3: TImage;
    rectAbaSelecao: TRectangle;
    rectToolbar1: TRectangle;
    Image4: TImage;
    imgAdd: TImage;
    Label1: TLabel;
    lvRemessa: TListView;
    Rectangle1: TRectangle;
    Label2: TLabel;
    Image5: TImage;
    imgRefreshEntrega: TImage;
    Rectangle2: TRectangle;
    Label3: TLabel;
    Image7: TImage;
    imgRefreshHistorico: TImage;
    imgBolaAmarela: TImage;
    imgBolaCinza: TImage;
    imgFundoValor2: TImage;
    imgFundoValor: TImage;
    imgLocais: TImage;
    imgLocais2: TImage;
    imgStatusAndamento: TImage;
    imgStatusFinalizado: TImage;
    lvEntrega: TListView;
    lvHistorico: TListView;
    procedure imgAba1Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure imgAddClick(Sender: TObject);
    procedure lvRemessaItemClick(const Sender: TObject; const AItem: TListViewItem);
    procedure lvEntregaItemClick(const Sender: TObject; const AItem: TListViewItem);
    procedure lvHistoricoItemClick(const Sender: TObject; const AItem: TListViewItem);
    procedure imgRefreshEntregaClick(Sender: TObject);
    procedure imgRefreshHistoricoClick(Sender: TObject);
  private
    imgAbaSelecionada: TImage;
    procedure SelecionarAba(img: TImage);
    procedure AddRemessa(id_remessa: integer; status, descricao, endereco: string; valor: double);
    procedure ListarMinhasRemessas;
    procedure ThreadRemessasTerminate(Sender: TObject);
    procedure AddEntrega(id_entrega: integer; descricao, endereco_origem, endereco_destino: string; valor: double);
    procedure AddHistorico(id_remessa, id_usuario: integer; status, dt_remessa, descricao, endereco_origem, endereco_destino: string; valor: double);
    procedure ListarEntregasDisponiveis;
    procedure ThreadEntregasTerminate(Sender: TObject);
    procedure ListarHistorico;
    procedure ThreadHistoricoTerminate(Sender: TObject);
    procedure ConfirmarColeta(id_remessa: integer);
    procedure ThreadColetaTerminate(Sender: TObject);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmPrincipal: TFrmPrincipal;

implementation

{$R *.fmx}

uses UnitNovaRemessa, UnitStatusRemessa, DataModule.Remessa;

procedure TFrmPrincipal.AddRemessa(id_remessa: integer;
                                   status, descricao, endereco: string;
                                   valor: double);
var
    item: TListViewItem;
begin
    item := lvRemessa.Items.Add;

    with item do
    begin
        Tag := id_remessa;
        Height := 70;

        TListItemText(Objects.FindDrawable('txtDescricao')).Text := descricao;
        TListItemText(Objects.FindDrawable('txtValor')).Text := FormatFloat('R$ #,##0.00', valor);
        TListItemText(Objects.FindDrawable('txtEndereco')).Text := endereco;

        TListItemImage(Objects.FindDrawable('imgValor')).Bitmap := imgFundoValor.Bitmap;

        if status = 'P' then
            TListItemImage(Objects.FindDrawable('imgIcone')).Bitmap := imgBolaCinza.Bitmap
        else
            TListItemImage(Objects.FindDrawable('imgIcone')).Bitmap := imgBolaAmarela.Bitmap;
    end;
end;

procedure TFrmPrincipal.AddEntrega(id_entrega: integer;
                                  descricao, endereco_origem, endereco_destino: string;
                                  valor: double);
var
    item: TListViewItem;
begin
    item := lvEntrega.Items.Add;

    with item do
    begin
        Tag := id_entrega;
        Height := 130;

        TListItemText(Objects.FindDrawable('txtDescricao')).Text := descricao;
        TListItemText(Objects.FindDrawable('txtValor')).Text := FormatFloat('R$ #,##0.00', valor);
        TListItemText(Objects.FindDrawable('txtOrigem')).Text := endereco_origem;
        TListItemText(Objects.FindDrawable('txtDestino')).Text := endereco_destino;

        TListItemImage(Objects.FindDrawable('imgValor')).Bitmap := imgFundoValor.Bitmap;
        TListItemImage(Objects.FindDrawable('imgLocal')).Bitmap := imgLocais.Bitmap;
    end;
end;

procedure TFrmPrincipal.AddHistorico(id_remessa, id_usuario: integer;
                                     status, dt_remessa, descricao, endereco_origem, endereco_destino: string;
                                     valor: double);
var
    item: TListViewItem;
begin
    item := lvHistorico.Items.Add;

    with item do
    begin
        Tag := id_remessa;
        Height := 150;

        TListItemText(Objects.FindDrawable('txtDescricao')).Text := descricao;
        TListItemText(Objects.FindDrawable('txtData')).Text := Copy(dt_remessa, 1, 16);
        TListItemText(Objects.FindDrawable('txtValor')).Text := FormatFloat('R$ #,##0.00', valor);
        TListItemText(Objects.FindDrawable('txtOrigem')).Text := endereco_origem;
        TListItemText(Objects.FindDrawable('txtDestino')).Text := endereco_destino;

        TListItemImage(Objects.FindDrawable('imgValor')).Bitmap := imgFundoValor2.Bitmap;
        TListItemImage(Objects.FindDrawable('imgLocal')).Bitmap := imgLocais2.Bitmap;

        if (status = 'F') then
            TListItemImage(Objects.FindDrawable('imgStatus')).Bitmap := imgStatusFinalizado.Bitmap
        else
            TListItemImage(Objects.FindDrawable('imgStatus')).Bitmap := imgStatusAndamento.Bitmap;
    end;
end;

procedure TFrmPrincipal.ThreadRemessasTerminate(Sender: TObject);
begin
    TLoading.Hide;
    lvRemessa.EndUpdate;

    if ErroThread(Sender) then
        exit;
end;

procedure TFrmPrincipal.ThreadEntregasTerminate(Sender: TObject);
begin
    TLoading.Hide;
    lvEntrega.EndUpdate;

    if ErroThread(Sender) then
        exit;
end;

procedure TFrmPrincipal.ThreadHistoricoTerminate(Sender: TObject);
begin
    TLoading.Hide;
    lvHistorico.EndUpdate;

    if ErroThread(Sender) then
        exit;
end;

procedure TFrmPrincipal.ThreadColetaTerminate(Sender: TObject);
begin
    TLoading.Hide;

    if ErroThread(Sender) then
        exit;

    ListarEntregasDisponiveis;
end;

procedure TFrmPrincipal.ListarMinhasRemessas;
var
    t: TThread;
begin
    TLoading.Show(FrmPrincipal, '');
    lvRemessa.Items.Clear;
    lvRemessa.BeginUpdate;

    t := TThread.CreateAnonymousThread(procedure
    begin
        DmRemessa.ListarMinhasRemessas(TSession.ID_USUARIO);

        with DmRemessa.TabRemessas do
        begin
            while NOT Eof do
            begin
                TThread.Synchronize(TThread.CurrentThread, procedure
                begin
                    AddRemessa(fieldbyname('id_remessa').asinteger,
                               fieldbyname('status')    .asstring,
                               fieldbyname('descricao') .asstring,
                               fieldbyname('destino')   .asstring,
                               fieldbyname('valor')     .asfloat);
                end);

                Next;
            end;
        end;
    end);

    t.OnTerminate := ThreadRemessasTerminate;
    t.Start;
end;

procedure TFrmPrincipal.ConfirmarColeta(id_remessa: integer);
var
    t: TThread;
begin
    TLoading.Show(FrmPrincipal, '');

    t := TThread.CreateAnonymousThread(procedure
    begin
        sleep(1000);

        DmRemessa.ColetarRemessa(Id_Remessa, TSession.ID_USUARIO);
    end);

    t.OnTerminate := ThreadColetaTerminate;
    t.Start;
end;

procedure TFrmPrincipal.lvEntregaItemClick(const Sender: TObject;
  const AItem: TListViewItem);
begin
    TDialogService.MessageDialog('Confirma a solicitação de coleta?',
                                 TMsgDlgType.mtConfirmation,
                                 [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo],
                                 TMsgDlgBtn.mbNo,
                                 0,
                                 procedure(const AResult: TModalResult)
                                 begin
                                    if AResult = mrYes then
                                        ConfirmarColeta(AItem.Tag);
                                 end);
end;

procedure TFrmPrincipal.lvHistoricoItemClick(const Sender: TObject;
  const AItem: TListViewItem);
begin
    if NOT Assigned(FrmStatusRemessa) then
        Application.CreateForm(TFrmStatusRemessa, FrmStatusRemessa);

    FrmStatusRemessa.ExecuteOnClose := ListarHistorico;
    FrmStatusRemessa.Id_remessa := AItem.tag;
    FrmStatusRemessa.Show;
end;

procedure TFrmPrincipal.lvRemessaItemClick(const Sender: TObject;
  const AItem: TListViewItem);
begin
    if NOT Assigned(FrmNovaRemessa) then
        Application.CreateForm(TFrmNovaRemessa, FrmNovaRemessa);

    FrmNovaRemessa.ExecuteOnClose := ListarMinhasRemessas;
    FrmNovaRemessa.Id_Remessa := AItem.Tag;
    FrmNovaRemessa.Show;
end;

procedure TFrmPrincipal.ListarEntregasDisponiveis;
var
    t : TThread;
begin
    TLoading.Show(FrmPrincipal, '');
    lvEntrega.Items.Clear;
    lvEntrega.BeginUpdate;

    t := TThread.CreateAnonymousThread(procedure
    var
        i: integer;
    begin
        DmRemessa.ListarEntregasDisponiveis(TSession.ID_USUARIO);

        with DmRemessa.TabRemessas do
        begin
            while NOT Eof do
            begin
                TThread.Synchronize(TThread.CurrentThread, procedure
                begin
                    AddEntrega(fieldbyname('id_remessa').asinteger,
                               fieldbyname('descricao').asstring,
                               fieldbyname('origem').asstring,
                               fieldbyname('destino').asstring,
                               fieldbyname('valor').asfloat);
                end);

                Next;
            end;
        end;
    end);

    t.OnTerminate := ThreadEntregasTerminate;
    t.Start;
end;

procedure TFrmPrincipal.ListarHistorico;
var
    t : TThread;
begin
    TLoading.Show(FrmPrincipal, '');
    lvHistorico.Items.Clear;
    lvHistorico.BeginUpdate;

    t := TThread.CreateAnonymousThread(procedure
    var
        i: integer;
    begin
        DmRemessa.ListarHistorico(TSession.ID_USUARIO);

        with DmRemessa.TabRemessas do
        begin
            while NOT Eof do
            begin
                TThread.Synchronize(TThread.CurrentThread, procedure
                begin
                    AddHistorico(fieldbyname('id_remessa').asinteger,
                                 fieldbyname('id_usuario').asinteger,
                                 fieldbyname('status').asstring,
                                 UTCtoDateBR(fieldbyname('dt_cadastro').asstring),
                                 fieldbyname('descricao').asstring,
                                 fieldbyname('origem').asstring,
                                 fieldbyname('destino').asstring,
                                 fieldbyname('valor').asfloat);
                end);

                Next;
            end;
        end;
    end);


    t.OnTerminate := ThreadHistoricoTerminate;
    t.Start;
end;

procedure TFrmPrincipal.SelecionarAba(img: TImage);
begin
    imgAbaSelecionada := img;

    //rectAbaSelecao.Position.X := img.Position.x;
    TAnimator.AnimateFloat(rectAbaSelecao, 'Position.X', img.Position.x, 0.2,
                           TAnimationType.In, TInterpolationType.Circular);

    TabControl.GotoVisibleTab(img.Tag);

    if img.Tag = 1 then
        ListarEntregasDisponiveis
    else
    if img.Tag = 2 then
        ListarHistorico;
end;

procedure TFrmPrincipal.FormCreate(Sender: TObject);
begin
    SelecionarAba(imgAba1);
end;

procedure TFrmPrincipal.FormResize(Sender: TObject);
begin
    if Assigned(imgAbaSelecionada) then
    begin
        rectAbaSelecao.Position.X := imgAbaSelecionada.Position.X;
        rectAbaSelecao.Width := imgAbaSelecionada.Width;
    end;
end;

procedure TFrmPrincipal.FormShow(Sender: TObject);
begin
    // Dados do login...
    TSession.ID_USUARIO := 1;
    TSession.NOME := 'Jh';
    TSession.EMAIL := 'j.h@gmail.com';

    //TSession.ID_USUARIO := 2;
    //TSession.NOME := 'jc';
    //TSession.EMAIL := 'j_c@hotmail.com';
    //------------------

    ListarMinhasRemessas;
end;

procedure TFrmPrincipal.imgAba1Click(Sender: TObject);
begin
    SelecionarAba(TImage(Sender));
end;

procedure TFrmPrincipal.imgAddClick(Sender: TObject);
begin
    if NOT Assigned(FrmNovaRemessa) then
        Application.CreateForm(TFrmNovaRemessa, FrmNovaRemessa);

    FrmNovaRemessa.ExecuteOnClose := ListarMinhasRemessas;
    FrmNovaRemessa.Id_Remessa := 0;
    FrmNovaRemessa.Show;
end;

procedure TFrmPrincipal.imgRefreshEntregaClick(Sender: TObject);
begin
    ListarEntregasDisponiveis;
end;

procedure TFrmPrincipal.imgRefreshHistoricoClick(Sender: TObject);
begin
    ListarHistorico;
end;

end.
