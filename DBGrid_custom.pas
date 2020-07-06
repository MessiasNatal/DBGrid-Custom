{ -----------------------------------------------------------------------------
  Author:    Messias Antonio Natal
  Date:      23-Fevereiro-2020
  Description: Componente para gestão de colunas do BDGrid - FREE
  ----------------------------------------------------------------------------- }
{ ******************************************************************************
  |* Historico
  |*
  |* 23/02/2020: Messias Antonio Natal
  |*  - Criação e distribuição da Primeira Versão
  *******************************************************************************}

unit DBGrid_custom;

interface

uses
  System.SysUtils, Vcl.ActnList, Vcl.Dialogs, System.Classes,
  Vcl.Forms, Vcl.DBGrids,Vcl.CheckLst,Vcl.Controls, Vcl.Buttons,
  DBGrid_custom_connectionFD,DBGrid_custom_table;

  procedure register;

  type
     TDBGrid_custom = class(TComponent)

     private
       FDBGrid_custom_Connection: TDBGrid_custom_connectionFD;
       FDBGrid : TDBGrid;

     public
       constructor Create; virtual;
       destructor Destroy; override;

       procedure  save(pForm: TForm);
       procedure  load(pForm: TForm);
       procedure  reset(pForm: TForm);
       procedure  showFormColumns;

     private
       function   getColumns(pCheckListBox: TCheckListBox): TCheckListBox;
       procedure  setColumns(pCheckListBox: TCheckListBox);

     published
       property DBGrid_custom_Connection : TDBGrid_custom_connectionFD read FDBGrid_custom_Connection write FDBGrid_custom_Connection;
       property DBGrid : TDBGrid read FDBGrid write FDBGrid;

     end;


implementation

{ TDBGrid_custom }

procedure register;
begin
  RegisterComponents('DBGrid_custom', [TDBGrid_custom,TDBGrid_custom_connectionFD,TDBGrid_custom_table]);
end;

constructor TDBGrid_custom.Create;
begin

end;

destructor TDBGrid_custom.Destroy;
begin
  inherited;
end;


function TDBGrid_custom.getColumns(pCheckListBox: TCheckListBox):TCheckListBox;
 var
  i : integer;
begin
  pCheckListBox.Items.Clear;
  for I := 0 to DBGrid.Columns.Count - 1 do
  begin
    pCheckListBox.AddItem( DBGrid.Columns[i].Title.Caption , DBGrid);

    if DBGrid.Columns[i].Width = -1 then
      pCheckListBox.Checked[i] := False
    else
      pCheckListBox.Checked[i] := True;
  end;

  result := pCheckListBox;
end;

procedure TDBGrid_custom.setColumns(pCheckListBox: TCheckListBox);
 var
  i: integer;
begin
  for i := 0 to DBGrid.Columns.Count - 1 do
  begin
    if DBGrid.Columns[i].Title.Caption = pCheckListBox.Items[i] then
    DBGrid.Columns[i].Visible := pCheckListBox.Checked[i];
  end;
end;

procedure TDBGrid_custom.showFormColumns;
 var
  FormVisibilidadesColunas : TForm;
  CheckList : TCheckListBox;
  BtnAplicar: TBitBtn;
begin
    FormVisibilidadesColunas := TForm.Create(Application);
    CheckList := TCheckListBox.Create(Application);
    BtnAplicar:= TBitBtn.Create(Application);

  try
      FormVisibilidadesColunas.Width  := 200;
      FormVisibilidadesColunas.Height :=  DBGrid_custom_Connection.getDBGRID.Height;
      FormVisibilidadesColunas.Align := alNone;
      FormVisibilidadesColunas.BorderStyle := bsSizeToolWin;
      FormVisibilidadesColunas.AutoSize := false;
      FormVisibilidadesColunas.Visible := false;
      FormVisibilidadesColunas.WindowState := wsNormal;
      FormVisibilidadesColunas.Position := poScreenCenter;
      FormVisibilidadesColunas.Caption := 'Visibilidade das Colunas';

      CheckList.Align := alClient;
      CheckList.Parent := FormVisibilidadesColunas;
      CheckList.Flat := True;

      BtnAplicar.AlignWithMargins := True;
      BtnAplicar.Kind := bkOK;
      BtnAplicar.Height := 27;
      BtnAplicar.Align := alBottom;
      BtnAplicar.Caption := 'Aplicar';
      BtnAplicar.Parent := FormVisibilidadesColunas;

      self.getColumns(CheckList);

      FormVisibilidadesColunas.ShowModal;

      if FormVisibilidadesColunas.ModalResult = mrOk then
      begin
        self.setColumns(CheckList);
      end;

  finally
    FreeAndNil(BtnAplicar);
    FreeAndNil(CheckList);
    FreeAndNil(FormVisibilidadesColunas);
  end;
end;

procedure TDBGrid_custom.load(pForm: TForm);
begin
  DBGrid_custom_Connection.setDBGRID(DBGrid);
  DBGrid_custom_Connection.loadTable;
  DBGrid_custom_Connection.loadConfig(pForm);
end;

procedure TDBGrid_custom.reset(pForm: TForm);
begin
  DBGrid_custom_Connection.setDBGRID(DBGrid);
  DBGrid_custom_Connection.reset(pForm);
end;

procedure TDBGrid_custom.save(pForm: TForm);
begin
  DBGrid_custom_Connection.setDBGRID(DBGrid);
  DBGrid_custom_Connection.save(pForm);
end;

end.
