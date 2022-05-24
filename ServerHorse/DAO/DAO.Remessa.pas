unit DAO.Remessa;

interface

{
Como configurar o DataSet.Serialize:
https://youtu.be/Im4LPpGmgAc
}

uses FireDAC.Comp.Client,
     FireDAC.DApt,
     Data.DB,
     System.JSON,
     System.SysUtils,
     DataSet.Serialize,
     StrUtils;

type
   TRemessa = class
   private
      FConn: TFDConnection;
      FID_USUARIO: integer;
      FORIGEM_LONGITUDE: double;
      FVALOR: double;
      FDESCRICAO: string;
      FSTATUS: string;
      FID_ENTREGADOR: integer;
      FORIGEM_LATITUDE: double;
      FDESTINO: string;
      FORIGEM: string;
      FID_REMESSA: integer;

   public
      constructor Create(conn: TFDConnection);

      property ID_USUARIO: integer read FID_USUARIO write FID_USUARIO;
      property ID_REMESSA: integer read FID_REMESSA write FID_REMESSA;
      property DESCRICAO: string read FDESCRICAO write FDESCRICAO;
      property ORIGEM: string read FORIGEM write FORIGEM;
      property DESTINO: string read FDESTINO write FDESTINO;
      property VALOR: double read FVALOR write FVALOR;
      property STATUS: string read FSTATUS write FSTATUS;
      property ORIGEM_LATITUDE: double read FORIGEM_LATITUDE write FORIGEM_LATITUDE;
      property ORIGEM_LONGITUDE: double read FORIGEM_LONGITUDE write FORIGEM_LONGITUDE;
      property ID_ENTREGADOR: integer read FID_ENTREGADOR write FID_ENTREGADOR;

      function ListarMinhasRemessas: TJSONArray;
      function ListarRemessasDisponiveis: TJSONArray;
      function ListarHistorico: TJSONArray;
      procedure Inserir;
      procedure CancelarColetarRemessa;
      procedure ColetarRemessa;
      procedure Editar;
      procedure Excluir;
      procedure FinalizarEntrega;
   end;

implementation

constructor TRemessa.Create(conn: TFDConnection);
begin
    FConn := conn;
end;

function TRemessa.ListarMinhasRemessas: TJSONArray;
var
    qry: TFDQuery;
begin
    try
        qry := TFDQuery.Create(nil);
        qry.Connection := FConn;

        with qry do
        begin
            Active := false;
            SQL.Clear;
            SQL.Add('SELECT * FROM REMESSA');
            SQL.Add('WHERE ID_REMESSA > 0');

            if ID_USUARIO > 0 then
            begin
                SQL.Add('AND ID_USUARIO = :ID_USUARIO');
                ParamByName('ID_USUARIO').Value := ID_USUARIO;
            end;

            if ID_REMESSA > 0 then
            begin
                SQL.Add('AND ID_REMESSA = :ID_REMESSA');
                ParamByName('ID_REMESSA').Value := ID_REMESSA;
            end;

            if STATUS <> '' then
            begin
                SQL.Add('AND STATUS = :STATUS');
                ParamByName('STATUS').Value := STATUS;
            end;

            SQL.Add('ORDER BY ID_REMESSA DESC');
            Active := true;
        end;

        Result := qry.ToJSONArray;

    finally
        qry.DisposeOf;
    end;
end;

function TRemessa.ListarHistorico: TJSONArray;
var
    qry: TFDQuery;
begin
    try
        qry := TFDQuery.Create(nil);
        qry.Connection := FConn;

        with qry do
        begin
            Active := false;
            SQL.Clear;
            SQL.Add('SELECT * FROM REMESSA');
            SQL.Add('WHERE (ID_USUARIO = :ID_USUARIO OR ID_ENTREGADOR = :ID_ENTREGADOR)');
            SQL.Add('AND STATUS IN (''E'', ''F'')');
            SQL.Add('ORDER BY ID_REMESSA DESC');

            ParamByName('ID_USUARIO').Value := ID_USUARIO;
            ParamByName('ID_ENTREGADOR').Value := ID_USUARIO;

            Active := true;
        end;

        Result := qry.ToJSONArray;

    finally
        qry.DisposeOf;
    end;
end;

function TRemessa.ListarRemessasDisponiveis: TJSONArray;
var
    qry: TFDQuery;
begin
    try
        qry := TFDQuery.Create(nil);
        qry.Connection := FConn;

        with qry do
        begin
            Active := false;
            SQL.Clear;
            SQL.Add('SELECT * FROM REMESSA');
            SQL.Add('WHERE ID_USUARIO <> :ID_USUARIO');
            SQL.Add('AND STATUS = :STATUS');
            SQL.Add('ORDER BY ID_REMESSA DESC');

            ParamByName('ID_USUARIO').Value := ID_USUARIO;
            ParamByName('STATUS').Value := 'P';

            Active := true;
        end;

        Result := qry.ToJSONArray;

    finally
        qry.DisposeOf;
    end;
end;

procedure TRemessa.Inserir;
var
    qry : TFDQuery;
begin
    //Validate('Inserir');

    try
        qry := TFDQuery.Create(nil);
        qry.Connection := FConn;

        try
            with qry do
            begin
                Active := false;
                sql.Clear;
                SQL.Add('INSERT INTO REMESSA(DESCRICAO, ORIGEM, DESTINO, VALOR, STATUS, ORIGEM_LATITUDE,');
                SQL.Add('ORIGEM_LONGITUDE, ID_USUARIO, DT_CADASTRO)');
                SQL.Add('VALUES(:DESCRICAO, :ORIGEM, :DESTINO, :VALOR, :STATUS, :ORIGEM_LATITUDE, ');
                SQL.Add(':ORIGEM_LONGITUDE, :ID_USUARIO, now());');
                SQL.Add('SELECT LAST_INSERT_ID() AS ID_REMESSA '); // MYSQL

                ParamByName('DESCRICAO').Value := DESCRICAO;
                ParamByName('ORIGEM').Value := ORIGEM;
                ParamByName('DESTINO').Value := DESTINO;
                ParamByName('VALOR').Value := VALOR;
                ParamByName('STATUS').Value := 'P';
                ParamByName('ORIGEM_LATITUDE').Value := ORIGEM_LATITUDE;
                ParamByName('ORIGEM_LONGITUDE').Value := ORIGEM_LONGITUDE;
                ParamByName('ID_USUARIO').Value := ID_USUARIO;

                Active := true;
                ID_REMESSA := FieldByName('ID_REMESSA').AsInteger;
            end;

        except on ex:exception do
            raise Exception.Create(ex.Message);
        end;

    finally
        qry.DisposeOf;
    end;

end;

procedure TRemessa.Editar;
var
    qry : TFDQuery;
begin
    //Validate('Editar');

    try
        qry := TFDQuery.Create(nil);
        qry.Connection := FConn;

        with qry do
        begin
            Active := false;
            sql.Clear;
            SQL.Add('UPDATE REMESSA SET DESCRICAO=:DESCRICAO, ORIGEM=:ORIGEM, DESTINO=:DESTINO, VALOR=:VALOR, ');
            SQL.Add('ORIGEM_LATITUDE=:ORIGEM_LATITUDE, ORIGEM_LONGITUDE=:ORIGEM_LONGITUDE');
            SQL.Add('WHERE ID_REMESSA=:ID_REMESSA');

            ParamByName('DESCRICAO').Value := DESCRICAO;
            ParamByName('ORIGEM').Value := ORIGEM;
            ParamByName('DESTINO').Value := DESTINO;
            ParamByName('VALOR').Value := VALOR;
            ParamByName('ORIGEM_LATITUDE').Value := ORIGEM_LATITUDE;
            ParamByName('ORIGEM_LONGITUDE').Value := ORIGEM_LONGITUDE;
            ParamByName('ID_REMESSA').Value := ID_REMESSA;
            ExecSQL;
        end;

    finally
        qry.DisposeOf;
    end;
end;

procedure TRemessa.Excluir;
var
    qry : TFDQuery;
begin
    //Validate('Excluir');

    try
        qry := TFDQuery.Create(nil);
        qry.Connection := FConn;

        with qry do
        begin
             // Valida se algum entregador já pegou a remessa...
            Active := false;
            sql.Clear;
            SQL.Add('SELECT STATUS FROM REMESSA WHERE ID_REMESSA = :ID_REMESSA');
            ParamByName('ID_REMESSA').Value := ID_REMESSA;
            Active := true;

            if FieldByName('STATUS').AsString <> 'P' then
                raise Exception.Create('A remessa não pode ser excluída (entregador já iniciou a entrega)');


            Active := false;
            sql.Clear;
            SQL.Add('DELETE FROM REMESSA WHERE ID_REMESSA=:ID_REMESSA');
            ParamByName('ID_REMESSA').Value := ID_REMESSA;
            ExecSQL;
        end;

    finally
        qry.DisposeOf;
    end;
end;

procedure TRemessa.ColetarRemessa;
var
    qry : TFDQuery;
begin
    //Validate('ColetarRemessa');

    try
        qry := TFDQuery.Create(nil);
        qry.Connection := FConn;

        with qry do
        begin
            Active := false;
            sql.Clear;
            SQL.Add('UPDATE REMESSA SET STATUS = ''E'', ID_ENTREGADOR=:ID_ENTREGADOR');
            SQL.Add('WHERE ID_REMESSA=:ID_REMESSA');

            ParamByName('ID_ENTREGADOR').Value := ID_ENTREGADOR;
            ParamByName('ID_REMESSA').Value := ID_REMESSA;
            ExecSQL;
        end;

    finally
        qry.DisposeOf;
    end;

end;

procedure TRemessa.CancelarColetarRemessa;
var
    qry : TFDQuery;
begin
    //Validate('CancelarColetarRemessa');

    try
        qry := TFDQuery.Create(nil);
        qry.Connection := FConn;

        with qry do
        begin
            Active := false;
            sql.Clear;
            SQL.Add('UPDATE REMESSA SET STATUS = ''P'', ID_ENTREGADOR=NULL');
            SQL.Add('WHERE ID_REMESSA=:ID_REMESSA');

            ParamByName('ID_REMESSA').Value := ID_REMESSA;
            ExecSQL;
        end;

    finally
        qry.DisposeOf;
    end;

end;

procedure TRemessa.FinalizarEntrega;
var
    qry : TFDQuery;
begin
    //Validate('FinalizarEntrega');

    try
        qry := TFDQuery.Create(nil);
        qry.Connection := FConn;

        with qry do
        begin
            Active := false;
            sql.Clear;
            SQL.Add('UPDATE REMESSA SET STATUS = ''F'' ');
            SQL.Add('WHERE ID_REMESSA=:ID_REMESSA');

            ParamByName('ID_REMESSA').Value := ID_REMESSA;
            ExecSQL;
        end;

    finally
        qry.DisposeOf;
    end;

end;

end.
