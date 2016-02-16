Attribute VB_Name = "Module1"
' SqlFmt.dll のエクスポート関数 iCopyToPreparedStr() を
' VBへインポートして使う為のサンプルコード

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
    Dim szOrgStmt As String       ' 整形前の文
    Dim szFmtStmt As String       ' 整形後の文
    Dim iFmtStmt As Long          ' 整形後の文を格納するバッファの最大長
    Dim iStrLen As Long           ' 整形後の文に格納されたバイト数
    Dim iRet As Long              'インポート関数の戻り値
                                  '0: 正常終了 非0: 異常終了
    ' 変数の初期化
    szOrgStmt = "set serveroutput on; " & _
        "declare cursor c1 is select empno, ename from emp; " & _
        "begin for r1 in c1 loop dbms_output.put(r1.empno); " & _
        "dbms_output.put('='); dbms_output.put_line(r1.ename); " & _
        "end loop; end;/"
    iFmtStmt = 512       ' これを 512 から 100 へ変更して何が起こるか確認してみて下さい。
    szFmtStmt = String(iFmtStmt, vbNullChar)
    
    ' 整形の実行
    iRet = iCopyToPreparedStr(szOrgStmt, "  ", 14, 50, szFmtStmt, iStrLen, iFmtStmt)
    
    ' インポート関数のステータスをレポート
    If iRet = 0 Then
        MsgBox szFmtStmt, vbOKOnly, "整形済みの文 (" & "バイト数：" & Str(iStrLen) & ")"
    Else
        MsgBox "文の整形に失敗しました。エラー番号：" & Str(iRet), vbOKOnly, "エラーが発生 (" & "バイト数：" & Str(iStrLen) & ")"
    End If
    
End Sub

