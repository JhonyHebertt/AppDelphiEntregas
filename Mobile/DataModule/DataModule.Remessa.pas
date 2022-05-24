unit DataModule.Remessa;

interface

uses
  System.SysUtils, System.Classes, RESTRequest4D, DataSet.Serialize.Config,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, System.JSON;

type
  TDmRemessa = class(TDataModule)
    TabRemessas: TFDMemTable;
    TabRemessa: TFDMemTable;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
  public
    procedure ListarMinhasRemessas(id_usuario: integer);
    procedure ListarEntregasDisponiveis(id_usuario: integer);
    procedure ListarRemessaId(id_remessa: integer);
    procedure ListarHistorico(id_usuario: integer);
    procedure InserirRemessa(descricao, origem, destino: string;
                            origem_latitude, origem_longitude, valor: double; id_usuario: integer);
    procedure EditarRemessa(id_remessa: integer; descricao, origem,
                            destino: string; origem_latitude, origem_longitude, valor: double);
    procedure ExcluirRemessa(id_remessa: integer);
    procedure ColetarRemessa(id_remessa, id_entregador: integer);
    procedure CancelarColetarRemessa(id_remessa: integer);
    procedure FinalizarRemessa(id_remessa: integer);
  end;

var
  DmRemessa: TDmRemessa;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

Const
    BASE_URL = 'http://localhost:3000';
    USER_NAME = '99coders';
    PASSWORD = '112233';

procedure TDmRemessa.ListarMinhasRemessas(id_usuario: integer);
var
    resp: IResponse;
begin
    resp := TRequest.New.BaseURL(BASE_URL)
            .Resource('remessas')
            .AddParam('id_usuario', id_usuario.ToString)
            .Accept('application/json')
            .BasicAuthentication(USER_NAME, PASSWORD)
            .DataSetAdapter(TabRemessas)
            .Get;

    if (resp.StatusCode = 0) then
        raise Exception.Create('Não foi possível acessar o servidor')
    else if (resp.StatusCode <> 200) then
        raise Exception.Create(resp.Content);
end;

procedure TDmRemessa.DataModuleCreate(Sender: TObject);
begin
    // Configurar o Dataset Serialize...
    TDataSetSerializeConfig.GetInstance.CaseNameDefinition := cndLower;
end;

procedure TDmRemessa.ListarRemessaId(id_remessa: integer);
var
    resp: IResponse;
begin
    resp := TRequest.New.BaseURL(BASE_URL)
            .Resource('remessas')
            .ResourceSuffix(id_remessa.tostring)
            .Accept('application/json')
            .BasicAuthentication(USER_NAME, PASSWORD)
            .DataSetAdapter(TabRemessa)
            .Get;

    if (resp.StatusCode = 0) then
        raise Exception.Create('Não foi possível acessar o servidor')
    else if (resp.StatusCode <> 200) then
        raise Exception.Create(resp.Content);
end;

procedure TDmRemessa.ListarEntregasDisponiveis(id_usuario: integer);
var
    resp: IResponse;
begin
    resp := TRequest.New.BaseURL(BASE_URL)
            .Resource('remessas/disponivel')
            .AddParam('id_usuario', id_usuario.ToString)
            .Accept('application/json')
            .BasicAuthentication(USER_NAME, PASSWORD)
            .DataSetAdapter(TabRemessas)
            .Get;

    if (resp.StatusCode = 0) then
        raise Exception.Create('Não foi possível acessar o servidor')
    else if (resp.StatusCode <> 200) then
        raise Exception.Create(resp.Content);
end;

procedure TDmRemessa.InserirRemessa(descricao, origem, destino: string;
                                    origem_latitude, origem_longitude, valor: double;
                                    id_usuario: integer);
var
    resp: IResponse;
    json: TJsonObject;
begin
    try
        json := TJsonObject.Create;
        json.AddPair('descricao', descricao);
        json.AddPair('origem', origem);
        json.AddPair('destino', destino);
        json.AddPair('origem_latitude', TJSONNumber.Create(origem_latitude));
        json.AddPair('origem_longitude', TJSONNumber.Create(origem_longitude));
        json.AddPair('valor', TJSONNumber.Create(valor));
        json.AddPair('id_usuario', TJSONNumber.Create(id_usuario));

        resp := TRequest.New.BaseURL(BASE_URL)
                .Resource('remessas')
                .AddBody(json.ToJSON)
                .Accept('application/json')
                .BasicAuthentication(USER_NAME, PASSWORD)
                .Post;

        if (resp.StatusCode = 0) then
            raise Exception.Create('Não foi possível acessar o servidor')
        else if (resp.StatusCode <> 201) then
            raise Exception.Create(resp.Content);
    finally
        json.DisposeOf;
    end;
end;

procedure TDmRemessa.EditarRemessa(id_remessa: integer;
                                   descricao, origem, destino: string;
                                   origem_latitude, origem_longitude, valor: double);
var
    resp: IResponse;
    json: TJsonObject;
begin
    try
        json := TJsonObject.Create;
        json.AddPair('descricao', descricao);
        json.AddPair('origem', origem);
        json.AddPair('destino', destino);
        json.AddPair('origem_latitude', TJSONNumber.Create(origem_latitude));
        json.AddPair('origem_longitude', TJSONNumber.Create(origem_longitude));
        json.AddPair('valor', TJSONNumber.Create(valor));

        resp := TRequest.New.BaseURL(BASE_URL)
                .Resource('remessas')
                .ResourceSuffix(id_remessa.ToString)
                .AddBody(json.ToJSON)
                .Accept('application/json')
                .BasicAuthentication(USER_NAME, PASSWORD)
                .Put;

        if (resp.StatusCode = 0) then
            raise Exception.Create('Não foi possível acessar o servidor')
        else if (resp.StatusCode <> 200) then
            raise Exception.Create(resp.Content);
    finally
        json.DisposeOf;
    end;
end;

procedure TDmRemessa.ExcluirRemessa(id_remessa: integer);
var
    resp: IResponse;
begin
    resp := TRequest.New.BaseURL(BASE_URL)
            .Resource('remessas')
            .ResourceSuffix(id_remessa.ToString)
            .Accept('application/json')
            .BasicAuthentication(USER_NAME, PASSWORD)
            .Delete;

    if (resp.StatusCode = 0) then
        raise Exception.Create('Não foi possível acessar o servidor')
    else if (resp.StatusCode <> 200) then
        raise Exception.Create(resp.Content);
end;

procedure TDmRemessa.ListarHistorico(id_usuario: integer);
var
    resp: IResponse;
begin
    resp := TRequest.New.BaseURL(BASE_URL)
            .Resource('remessas/historico')
            .AddParam('id_usuario', id_usuario.ToString)
            .Accept('application/json')
            .BasicAuthentication(USER_NAME, PASSWORD)
            .DataSetAdapter(TabRemessas)
            .Get;

    if (resp.StatusCode = 0) then
        raise Exception.Create('Não foi possível acessar o servidor')
    else if (resp.StatusCode <> 200) then
        raise Exception.Create(resp.Content);
end;

procedure TDmRemessa.ColetarRemessa(id_remessa, id_entregador: integer);
var
    resp: IResponse;
    json: TJsonObject;
begin
    try
        json := TJsonObject.Create;
        json.AddPair('status', 'E');
        json.AddPair('id_entregador', TJSONNumber.Create(id_entregador));

        resp := TRequest.New.BaseURL(BASE_URL)
                .Resource('remessas/status')
                .ResourceSuffix(id_remessa.ToString)
                .AddBody(json.ToJSON)
                .Accept('application/json')
                .BasicAuthentication(USER_NAME, PASSWORD)
                .Put;

        if (resp.StatusCode = 0) then
            raise Exception.Create('Não foi possível acessar o servidor')
        else if (resp.StatusCode <> 200) then
            raise Exception.Create(resp.Content);
    finally
        json.DisposeOf;
    end;
end;

procedure TDmRemessa.CancelarColetarRemessa(id_remessa: integer);
var
    resp: IResponse;
    json: TJsonObject;
begin
    try
        json := TJsonObject.Create;
        json.AddPair('status', 'P');

        resp := TRequest.New.BaseURL(BASE_URL)
                .Resource('remessas/status')
                .ResourceSuffix(id_remessa.ToString)
                .AddBody(json.ToJSON)
                .Accept('application/json')
                .BasicAuthentication(USER_NAME, PASSWORD)
                .Put;

        if (resp.StatusCode = 0) then
            raise Exception.Create('Não foi possível acessar o servidor')
        else if (resp.StatusCode <> 200) then
            raise Exception.Create(resp.Content);
    finally
        json.DisposeOf;
    end;
end;

procedure TDmRemessa.FinalizarRemessa(id_remessa: integer);
var
    resp: IResponse;
    json: TJsonObject;
begin
    try
        json := TJsonObject.Create;
        json.AddPair('status', 'F');

        resp := TRequest.New.BaseURL(BASE_URL)
                .Resource('remessas/status')
                .ResourceSuffix(id_remessa.ToString)
                .AddBody(json.ToJSON)
                .Accept('application/json')
                .BasicAuthentication(USER_NAME, PASSWORD)
                .Put;

        if (resp.StatusCode = 0) then
            raise Exception.Create('Não foi possível acessar o servidor')
        else if (resp.StatusCode <> 200) then
            raise Exception.Create(resp.Content);
    finally
        json.DisposeOf;
    end;
end;

end.
