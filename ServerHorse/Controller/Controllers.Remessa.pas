unit Controllers.Remessa;

interface

uses Horse,
     System.JSON,
     DAO.Remessa,
     DataModule.Global,
     System.SysUtils;

procedure RegistrarRotas;
procedure ListarMinhasRemessas(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure ListarEntregasDisponiveis(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure ListarHistorico(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure CadastrarRemessa(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure EditarRemessa(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure ExcluirRemessa(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure AlterarStatusRemessa(Req: THorseRequest; Res: THorseResponse; Next: TProc);

implementation

procedure RegistrarRotas;
begin
    THorse.Get('remessas/:id_remessa', ListarMinhasRemessas); // /remessas/123
    THorse.Get('remessas', ListarMinhasRemessas); //  /remessas?status=E&id_usuario=7

    THorse.Post('remessas', CadastrarRemessa);
    THorse.Put('remessas/:id_remessa', EditarRemessa);
    THorse.Delete('remessas/:id_remessa', ExcluirRemessa);

    THorse.Get('remessas/disponivel', ListarEntregasDisponiveis);
    THorse.Get('remessas/historico', ListarHistorico);
    THorse.Put('remessas/status/:id_remessa', AlterarStatusRemessa);
end;

procedure ListarMinhasRemessas(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    rem: TRemessa;
begin
    try
        try
            rem := TRemessa.Create(DmGlobal.conn);

            try
                rem.ID_REMESSA := Req.Params.Items['id_remessa'].ToInteger;
            except
                rem.ID_REMESSA := 0;
            end;

            try
                rem.ID_USUARIO := Req.Query['id_usuario'].ToInteger;
            except
                rem.ID_USUARIO := 0;
            end;

            try
                rem.STATUS := Req.Query['status'];
            except
                rem.STATUS := '';
            end;

            res.Send<TJSONArray>(rem.ListarMinhasRemessas).Status(200);

        except on ex:exception do
            res.Send(ex.message).Status(500);
        end;
    finally
        rem.DisposeOf;
    end;
end;

procedure ListarEntregasDisponiveis(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    rem: TRemessa;
begin
    try
        try
            rem := TRemessa.Create(DmGlobal.conn);

            try
                rem.ID_USUARIO := Req.Query['id_usuario'].ToInteger;
            except
                rem.ID_USUARIO := 0;
            end;

            res.Send<TJSONArray>(rem.ListarRemessasDisponiveis).Status(200);

        except on ex:exception do
            res.Send(ex.message).Status(500);
        end;
    finally
        rem.DisposeOf;
    end;
end;

procedure ListarHistorico(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    rem: TRemessa;
begin
    try
        try
            rem := TRemessa.Create(DmGlobal.conn);

            try
                rem.ID_USUARIO := Req.Query['id_usuario'].ToInteger;
            except
                rem.ID_USUARIO := 0;
            end;

            res.Send<TJSONArray>(rem.ListarHistorico).Status(200);

        except on ex:exception do
            res.Send(ex.message).Status(500);
        end;
    finally
        rem.DisposeOf;
    end;
end;

procedure CadastrarRemessa(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    rem: TRemessa;
    body: TJSONValue;
    json: TJSONObject;
begin
    try
        try
            rem := TRemessa.Create(DmGlobal.conn);

            body := Req.Body<TJSONObject>;
            rem.DESCRICAO := body.GetValue<string>('descricao', '');
            rem.ORIGEM := body.GetValue<string>('origem', '');
            rem.DESTINO := body.GetValue<string>('destino', '');
            rem.VALOR := body.GetValue<double>('valor', 0);
            rem.ORIGEM_LATITUDE := body.GetValue<double>('origem_latitude', 0);
            rem.ORIGEM_LONGITUDE := body.GetValue<double>('origem_longitude', 0);
            rem.ID_USUARIO := body.GetValue<integer>('id_usuario', 0);

            rem.Inserir;

            // Montar json de retorno...
            json := TJSONObject.Create;
            json.AddPair('id_remessa', TJSONNumber.Create(rem.ID_REMESSA));

            res.Send<TJSONObject>(json).Status(201);

        except on ex:exception do
            res.Send(ex.message).Status(500);
        end;
    finally
        rem.DisposeOf;
    end;
end;

procedure EditarRemessa(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    rem: TRemessa;
    body: TJSONValue;
    json: TJSONObject;
begin
    try
        try
            rem := TRemessa.Create(DmGlobal.conn);

            try
                rem.ID_REMESSA := Req.Params.Items['id_remessa'].ToInteger;
            except
                rem.ID_REMESSA := 0;
            end;

            body := Req.Body<TJSONObject>;
            rem.DESCRICAO := body.GetValue<string>('descricao', '');
            rem.ORIGEM := body.GetValue<string>('origem', '');
            rem.DESTINO := body.GetValue<string>('destino', '');
            rem.VALOR := body.GetValue<double>('valor', 0);
            rem.ORIGEM_LATITUDE := body.GetValue<double>('origem_latitude', 0);
            rem.ORIGEM_LONGITUDE := body.GetValue<double>('origem_longitude', 0);

            rem.Editar;

            // Montar json de retorno...
            json := TJSONObject.Create;
            json.AddPair('id_remessa', TJSONNumber.Create(rem.ID_REMESSA));

            res.Send<TJSONObject>(json).Status(200);

        except on ex:exception do
            res.Send(ex.message).Status(500);
        end;
    finally
        rem.DisposeOf;
    end;
end;

procedure ExcluirRemessa(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    rem: TRemessa;
    json: TJSONObject;
begin
    try
        try
            rem := TRemessa.Create(DmGlobal.conn);

            try
                rem.ID_REMESSA := Req.Params.Items['id_remessa'].ToInteger;
            except
                rem.ID_REMESSA := 0;
            end;

            rem.Excluir;

            // Montar json de retorno...
            json := TJSONObject.Create;
            json.AddPair('id_remessa', TJSONNumber.Create(rem.ID_REMESSA));

            res.Send<TJSONObject>(json).Status(200);

        except on ex:exception do
            res.Send(ex.message).Status(500);
        end;
    finally
        rem.DisposeOf;
    end;
end;

procedure AlterarStatusRemessa(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    rem: TRemessa;
    body: TJSONValue;
    json: TJSONObject;
begin
    try
        try
            rem := TRemessa.Create(DmGlobal.conn);

            try
                rem.ID_REMESSA := Req.Params.Items['id_remessa'].ToInteger;
            except
                rem.ID_REMESSA := 0;
            end;

            body := Req.Body<TJSONObject>;
            rem.ID_ENTREGADOR := body.GetValue<integer>('id_entregador', 0);
            rem.STATUS := body.GetValue<string>('status', '');

            if rem.STATUS = 'P' then
                rem.CancelarColetarRemessa
            else
            if rem.STATUS = 'E' then
                rem.ColetarRemessa
            else
            if rem.STATUS = 'F' then
                rem.FinalizarEntrega
            else
                raise Exception.Create('Status inválido');

            // Montar json de retorno...
            json := TJSONObject.Create;
            json.AddPair('id_remessa', TJSONNumber.Create(rem.ID_REMESSA));

            res.Send<TJSONObject>(json).Status(200);

        except on ex:exception do
            res.Send(ex.message).Status(500);
        end;
    finally
        rem.DisposeOf;
    end;
end;

end.
