Attribute VB_Name = "Module1"
' SqlFmt.dll �̃G�N�X�|�[�g�֐� iCopyToPreparedStr() ��
' VB�փC���|�[�g���Ďg���ׂ̃T���v���R�[�h

Private Declare Function iCopyToPreparedStr _
Lib "..\..\sqlfmt.dll" ( _
    ByVal szOrgStmt As String _
    , ByVal szIdtStr As String _
    , ByVal iMinNumComma As Long _
    , ByVal iMinPartSize As Long _
    , ByVal szFmtStmt As String _
    , ByRef iStrLen As Long _
    , ByVal iFmtStmt As Long _
) As Long

Sub main()
    Dim szOrgStmt As String       ' ���`�O�̕�
    Dim szFmtStmt As String       ' ���`��̕�
    Dim iFmtStmt As Long          ' ���`��̕����i�[����o�b�t�@�̍ő咷
    Dim iStrLen As Long           ' ���`��̕��Ɋi�[���ꂽ�o�C�g��
    Dim iRet As Long              '�C���|�[�g�֐��̖߂�l
                                  '0: ����I�� ��0: �ُ�I��
    ' �ϐ��̏�����
    szOrgStmt = "set serveroutput on; " & _
        "declare cursor c1 is select empno, ename from emp; " & _
        "begin for r1 in c1 loop dbms_output.put(r1.empno); " & _
        "dbms_output.put('='); dbms_output.put_line(r1.ename); " & _
        "end loop; end;/"
    iFmtStmt = 512       ' ����� 512 ���� 100 �֕ύX���ĉ����N���邩�m�F���Ă݂ĉ������B
    szFmtStmt = String(iFmtStmt, vbNullChar)
    
    ' ���`�̎��s
    iRet = iCopyToPreparedStr(szOrgStmt, "  ", 14, 50, szFmtStmt, iStrLen, iFmtStmt)
    
    ' �C���|�[�g�֐��̃X�e�[�^�X�����|�[�g
    If iRet = 0 Then
        MsgBox szFmtStmt, vbOKOnly, "���`�ς݂̕� (" & "�o�C�g���F" & Str(iStrLen) & ")"
    Else
        MsgBox "���̐��`�Ɏ��s���܂����B�G���[�ԍ��F" & Str(iRet), vbOKOnly, "�G���[������ (" & "�o�C�g���F" & Str(iStrLen) & ")"
    End If
    
End Sub

