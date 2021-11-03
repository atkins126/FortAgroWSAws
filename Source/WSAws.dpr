program WSAws;

uses
  System.StartUpCopy,
  FMX.Forms,
  UPrincipal in 'UPrincipal.pas' {frmPrincipal},
  UDM in 'dm\UDM.pas' {dm: TDataModule},
  UdmPost in 'dm\UdmPost.pas' {dmPost: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.CreateForm(Tdm, dm);
  Application.CreateForm(TdmPost, dmPost);
  Application.Run;
end.
