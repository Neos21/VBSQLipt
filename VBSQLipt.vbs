Option Explicit

' VBSQLipt : �Θb�� SQL ���s�X�N���v�g
' 
' IE ���R���\�[����ʂƂ��Ďg�p���ADB �ڑ��� SQL �����s����B
' Oracle DB �ɐڑ�������̂Ƃ��č쐬�������AConnectionString ��ύX�����
' ODBC �ڑ����\�Ȃ̂ŁA���̑��� DBMS �ɂ��g�p�\�B

' ���[�U�ݒ肷�鍀�� (DB �ڑ�����)
Const HOST     = "127.0.0.1"
Const PORT     = "1521"
Const SERVICE  = "NeosService"
Const USER_ID  = "Neos21"
Const PASSWORD = "NeosPassword"



' �e�������Ăяo��
Call Confirmation()
Call OpenIE()
Call Main()
Call CloseIE()
WScript.Quit

' ���R�[�h�o�͎��̃t�B�[���h��؂蕶��
Const DELIMITER = " , "

' �R���\�[����ʂƂ��Ďg�p���� IE ��ێ�����
Dim PIE

' ���s�O�m�F�̃_�C�A���O��\������
Sub Confirmation()
  Dim shell
  Set shell = CreateObject("WScript.Shell")
  If shell.Popup("���s���܂����H", 0, "���s�m�F", vbOKCancel + vbQuestion) = vbCancel Then
    MsgBox "�I�����܂��B"
    Set shell = Nothing
    WScript.Quit
  End If
  Set shell = Nothing
End Sub

' �R���\�[����ʂƂ��Ďg�p���� IE ���N�����A�\���d�l��ݒ肷��
Sub OpenIE()
  Set PIE = CreateObject("InternetExplorer.Application")
  With PIE
    .Navigate "about:blank"
    .ToolBar = False
    .StatusBar = False
    .Width = .Document.parentWindow.screen.availWidth
    .Height = .Document.parentWindow.screen.availHeight
    .Top = 0
    .Left = 0
    .Visible = True
    .Document.Title = "VBSQLipt"
    .Document.Body.style.color = "#0c0"
    .Document.Body.style.background = "#000"
    ' �����t�H���g
    .Document.Body.style.fontFamily = "'�l�r �S�V�b�N', monospace"
  End With
End Sub

' �R���\�[����ʂ̃��C������
Sub Main()
  On Error Resume Next
  
  Dim con
  Set con = CreateObject("ADODB.Connection")
  
  ' ODBC �ɓo�^���Ă���f�[�^�\�[�X���g�p����ꍇ�̏������F
  '   conStr = "Provider=MSDASQL.1;Password=NeosPassword;Persist Security Info=True;User ID=Neos21;Data Source=NeosDataSource"
  ' ������ ODBC �ɓo�^���Ă���f�[�^�\�[�X�� DSN �ŎQ�Ƃ���ꍇ�̏������F
  '   conStr = "DSN=NeosDataSource;UID=Neos21;PWD=NeosPassword;DBQ=NeosService;"
  ' �ȉ��� tnsnames.ora �ɋL�ڂ���ڑ�������Őڑ�������@
  Dim conStr
  conStr = "Provider=OraOLEDB.Oracle;" & _
           "Data Source=(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=" & HOST & ")(PORT=" & PORT & ")))(CONNECT_DATA=(SERVICE_NAME=" & SERVICE & ")));" & _
           "User Id=" & USER_ID & ";Password=" & PASSWORD & ";"
  IEMsg("�ڑ�������F" & conStr & "<br>")
  
  con.ConnectionString = conStr
  con.Open
  
  If Err.Number <> 0 Then
    IEMsg("DB �ڑ����s" & "<br>" & Err.Number & "<br>" & Err.Source & "<br>" & Err.Description)
    Exit Sub
  Else
    IEMsg("DB �ڑ�����...")
  End If
  
  ' �N���C�A���g�T�C�h�J�[�\���ɕύX����
  ' rs.RecordCount ��L���ɂ��邽�߂̐ݒ�B��������Ȃ��� RecordCount �� -1 �ɂȂ�
  con.CursorLocation = 3  ' adUseClient
  
  ' �Θb���X�N���v�g�J�n
  Do While True
    IEMsg("<br>")
    
    ' SQL �����[�U�ɓ��͂�����
    Dim sql
    sql = SqlPrompt
    
    ' ���͕����� exit �� quit �Ȃ� Do While True �𔲂��ďI������
    Select Case Lcase(sql)
      Case "exit"
        Exit Do
      Case "quit"
        Exit Do
    End Select
    
    ' ���͒l�� SQL �����s���ARecordset �I�u�W�F�N�g�Ɍ��ʂ��i�[����
    IEMsg("&gt; " & sql & "<br>")
    Dim rs
    Set rs = con.Execute(sql)
    
    If Err.Number <> 0 Then
      IEMsg("SQL ���s���s" & "<br>" & Err.Number & "<br>" & Err.Source & "<br>" & Err.Description)
    Else
      IEMsg("SQL ���s����...")
      ' ���ʏo�͏���
      printResult(rs)
    End If
    
    ' Recordset ���N���[�Y����
    rs.Close
    Set rs = Nothing
    
    ' �G���[���N���A����
    Err.Clear
  Loop
  
  con.Close
  Set con = Nothing
  IEMsg("DB �ڑ��ؒf")
End Sub

' SQL �����[�U�ɓ��͂�����
private Function SqlPrompt()
  Dim input
  
  ' ��������l�����͂����܂Ń��[�v���� (�󗓂�u�L�����Z���v�{�^���̉����Ȃǂ����e���Ȃ�)
  Do While True
    input = InputBox("SQL ����͂��Ă��������B�I������Ƃ��́uexit�v���uquit�v�Ɠ��͂��Ă��������B", "Prompt")
    
    If Trim(input) <> "" Then
      Exit Do
    End If
  Loop
  
  SqlPrompt = Trim(input)
End Function

' SQL ���s���ʂ��o�͂���
private Sub printResult(rs)
  ' ���ʌ������擾����
  Dim cnt
  cnt = rs.RecordCount
  
  If cnt = 0 Then
    ' 0���Ȃ猋�ʏo�͂Ȃ�
    IEMsg("���ʁF0�� �c �q�b�g���܂���ł���")
    Exit Sub
  End If
  
  ' ���ʌ����� -1 ������ȊO�̂Ƃ��͌��ʏo�͂���
  If cnt = -1 Then
    ' �J�[�\���T�[�r�X�̏ꏊ���N���C�A���g�T�C�h�ɐݒ�ł��Ă��Ȃ��ꍇ (�Ǝv����)
    IEMsg("���������܂��擾�ł��܂���ł����B" & "<br>")
  Else
    IEMsg(cnt & " ���̃��R�[�h���擾���܂����B" & "<br>")
  End If
  
  Dim shell
  Set shell = CreateObject("WScript.Shell")
  Select Case shell.Popup("���ʂ��o�͂��܂����H", 0, "���ʏo�͊m�F", vbOKCancel + vbQuestion)
    Case vbOK
      ' Recordset �̏o�͏���
      printRecordset(rs)
    Case vbCancel
      IEMsg("���ʏo�͂��L�����Z������܂���")
  End Select
  Set shell = Nothing
End Sub

' Recordset ���o�͂���
private Sub printRecordset(rs)
  ' �t�B�[���h�����o�͂���
  Dim headerStr
  headerStr = ""
  
  ' ����1�s�ڂ���t�B�[���h�����擾����
  ' (���ʌ�����0���̏ꍇ�ɌĂяo���Ă��t�B�[���h���͎擾�\)
  Dim fieldName
  For Each fieldName In rs.Fields
    headerStr = headerStr & fieldName.Name & DELIMITER
  Next
  
  ' �s���ɂ����؂蕶������������
  If Right(headerStr, 3) = DELIMITER Then
    headerStr = Left(headerStr, Len(headerStr) - Len(DELIMITER))
  End If
  
  IEMsg(headerStr)
  
  ' 1�s���o�͂���
  Do Until rs.EOF = True
    Dim recordStr
    recordStr = ""
    
    Dim field
    For Each field In rs.Fields
      recordStr = recordStr & field.Value & DELIMITER
    Next
    
    If Right(recordStr, 3) = DELIMITER Then
      recordStr = Left(recordStr, Len(recordStr) - Len(DELIMITER))
    End If
    
    IEMsg(recordStr)
    rs.MoveNext
  Loop
End Sub

' IE �Ƀ��b�Z�[�W���o�͂���
Sub IEMsg(val)
  With PIE
    .Document.Body.innerHTML = .Document.Body.innerHTML & val & "<br>"
    .Document.Script.setTimeout "javascript:scrollTo(0, " & .Document.Body.ScrollHeight & ");", 0
  End With
End Sub

' IE �����
Sub CloseIE()
  MsgBox "�I�����܂�"
  PIE.Quit
  Set PIE = Nothing
End Sub