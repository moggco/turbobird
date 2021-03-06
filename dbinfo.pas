unit dbInfo;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Buttons, ExtCtrls;

type

  { TfmDBInfo }

  TfmDBInfo = class(TForm)
    bbClose: TBitBtn;
    bbRefresh: TBitBtn;
    edCreationDate: TEdit;
    edConnections: TEdit;
    edServerTime: TEdit;
    edPageSize: TEdit;
    edDBSize: TEdit;
    edName: TEdit;
    edODSVer: TEdit;
    edCharset: TEdit;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    meClients: TMemo;
    procedure bbCloseClick(Sender: TObject);
    procedure bbRefreshClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
  private
    { private declarations }
    fdbIndex: Integer;
  public
    procedure Init(dbIndex: Integer);
    { public declarations }
  end; 

var
  fmDBInfo: TfmDBInfo;

implementation

{$R *.lfm}

{ TfmDBInfo }

uses Main, SysTables;

procedure TfmDBInfo.bbCloseClick(Sender: TObject);
begin
  Close;
  Parent.Free;
end;

procedure TfmDBInfo.bbRefreshClick(Sender: TObject);
begin
  Init(fdbIndex);
end;

procedure TfmDBInfo.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  CloseAction:= caFree;
end;

procedure TfmDBInfo.Init(dbIndex: Integer);
var
  dbName, CreationDate, ACharSet: string;
  MajorVer, MinorVer, Pages, PageSize: Integer;
  ProcessList: TStringList;
  dbSize: Double;
  AType: string;
  ServerTime: string;
  ErrorMsg: string;
begin
  fdbIndex:= dbIndex;
  ProcessList:= TStringList.Create;

  // Read database info
  if dmSysTables.GetDatabaseInfo(dbIndex, dbName, ACharSet, CreationDate, ServerTime,
    MajorVer, MinorVer, Pages, PageSize, ProcessList, ErrorMsg) then
  begin
    edName.Text:= dbName;
    edODSVer.Text:= IntToStr(MajorVer) + '.' + IntToStr(MinorVer);
    edCharset.Text:= ACharSet;
    edCreationDate.Text:= CreationDate;
    edPageSize.Text:= IntToStr(PageSize);
    edConnections.Text:= IntToStr(ProcessList.Count);
    dbSize:= Pages * PageSize;

    // Display database size in readable format
    if dbSize > 1000000000 then
    begin
      dbSize:= ((dbSize / 1024) / 1024) / 1024;
      AType:= 'Giga bytes';
    end
    else
    if dbSize > 1000000 then
    begin
      dbSize:= ((dbSize / 1024) / 1024);
      AType:= 'Mega bytes';
    end
    else
    if dbSize > 1000 then
    begin
      dbSize:= (dbSize / 1024);
      AType:= 'Kilo bytes';
    end
    else
    begin
      AType:= 'Bytes';
    end;

    edDBSize.Text:= Format('%3.1n %s', [dbSize, AType]);
    fmDBInfo.edServerTime.Text:= ServerTime;
    meClients.Lines.Text:= ProcessList.Text;
    meClients.Lines.Insert(0, '');
    ProcessList.Free;
    Show;
  end
  else
    ShowMessage('Unable to get database information' + #10 + ErrorMsg);
end;



end.

