program Server;

uses
  System.StartUpCopy,
  FMX.Forms,
  UnitPrincipal in 'UnitPrincipal.pas' {FrmPrincipal},
  DataModule.Global in 'DataModule\DataModule.Global.pas' {DmGlobal: TDataModule},
  DAO.Remessa in 'DAO\DAO.Remessa.pas',
  Controllers.Remessa in 'Controller\Controllers.Remessa.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFrmPrincipal, FrmPrincipal);
  Application.CreateForm(TDmGlobal, DmGlobal);
  Application.Run;
end.
