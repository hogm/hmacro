VERSION 5.00
Begin VB.Form frmOracleDic 
   BorderStyle     =   1  '固定(実線)
   Caption         =   "Oracle辞書設定"
   ClientHeight    =   3390
   ClientLeft      =   45
   ClientTop       =   330
   ClientWidth     =   3720
   ClipControls    =   0   'False
   ControlBox      =   0   'False
   BeginProperty Font 
      Name            =   "ＭＳ ゴシック"
      Size            =   9
      Charset         =   128
      Weight          =   400
      Underline       =   0   'False
      Italic          =   0   'False
      Strikethrough   =   0   'False
   EndProperty
   Icon            =   "frmOracleDic.frx":0000
   LinkTopic       =   "Form1"
   LockControls    =   -1  'True
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   3390
   ScaleWidth      =   3720
   ShowInTaskbar   =   0   'False
   StartUpPosition =   1  'ｵｰﾅｰ ﾌｫｰﾑの中央
   Begin VB.CommandButton cmdNameDictionary 
      Caption         =   "ネーム辞書"
      BeginProperty Font 
         Name            =   "ＭＳ Ｐゴシック"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   300
      Left            =   690
      TabIndex        =   4
      Top             =   3060
      Width           =   1140
   End
   Begin VB.ListBox lstDictionary 
      Height          =   3000
      Left            =   690
      Style           =   1  'ﾁｪｯｸﾎﾞｯｸｽ
      TabIndex        =   1
      Top             =   30
      Width           =   3000
   End
   Begin VB.CommandButton cmdCancel 
      Cancel          =   -1  'True
      Caption         =   "ｷｬﾝｾﾙ"
      BeginProperty Font 
         Name            =   "ＭＳ Ｐゴシック"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   300
      Left            =   2790
      TabIndex        =   3
      Top             =   3060
      Width           =   900
   End
   Begin VB.CommandButton cmdChange 
      Caption         =   "切替"
      Default         =   -1  'True
      Enabled         =   0   'False
      BeginProperty Font 
         Name            =   "ＭＳ Ｐゴシック"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   300
      Left            =   1860
      TabIndex        =   2
      Top             =   3060
      Width           =   900
   End
   Begin VB.Label lbl1 
      AutoSize        =   -1  'True
      Caption         =   "選択(&S)"
      BeginProperty Font 
         Name            =   "ＭＳ Ｐゴシック"
         Size            =   9
         Charset         =   128
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   180
      Left            =   60
      TabIndex        =   0
      Top             =   90
      Width           =   585
   End
End
Attribute VB_Name = "frmOracleDic"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

'指定されたクラス名とウィンドウ名を持つトップレベルウィンドウを探す。
Private Declare Function FindWindow Lib "user32" Alias "FindWindowA" (ByVal lpClassName As String, ByVal lpWindowName As String) As Long
'指定されたウィンドウが所有するポップアップウィンドウのうち、
'直前にアクティブであったウィンドウを調べる。
Private Declare Function GetLastActivePopup Lib "user32" (ByVal hWndOwnder As Long) As Long
'指定されたウィンドウを作成したスレッドをフォアグラウンドにし、そのウィンドウをアクティブにする。
Private Declare Function SetForegroundWindow Lib "user32" (ByVal hWnd As Long) As Long
'指定されたウィンドウの表示状態を設定する。
Private Declare Function ShowWindow Lib "user32" (ByVal hWnd As Long, ByVal nCmdShow As Long) As Long
Private Const SW_RESTORE = 9

Private Declare Function GetPrivateProfileString Lib "kernel32" Alias "GetPrivateProfileStringA" (ByVal lpApplicationName As String, ByVal lpKeyName As Any, ByVal lpDefault As String, ByVal lpReturnedString As String, ByVal nSize As Long, ByVal lpFileName As String) As Long

Private Type typDictionary
    Key                 As String
    Title               As String
    Database            As String
    ConnectionString    As String
    FileType            As String
    FileName            As String
End Type

Private Declare Function ShellExecute Lib "shell32.dll" Alias _
      "ShellExecuteA" (ByVal hWnd As Long, ByVal lpszOp As _
      String, ByVal lpszFile As String, ByVal lpszParams As String, _
      ByVal lpszDir As String, ByVal FsShowCmd As Long) As Long

Private Declare Function GetDesktopWindow Lib "user32" () As Long

Const SW_SHOWNORMAL = 1

Const SE_ERR_FNF = 2&
Const SE_ERR_PNF = 3&
Const SE_ERR_ACCESSDENIED = 5&
Const SE_ERR_OOM = 8&
Const SE_ERR_DLLNOTFOUND = 32&
Const SE_ERR_SHARE = 26&
Const SE_ERR_ASSOCINCOMPLETE = 27&
Const SE_ERR_DDETIMEOUT = 28&
Const SE_ERR_DDEFAIL = 29&
Const SE_ERR_DDEBUSY = 30&
Const SE_ERR_NOASSOC = 31&
Const ERROR_BAD_FORMAT = 11&

Private OraSession                  As OraSession
Private OraDatabase                 As OraDatabase
Private OraParameters               As OraParameters
Private OraDynaset                  As OraDynaset
Private strDatabaseName             As String
Private strConnectionString         As String
Private strIniFile                  As String
Private strDicFile                  As String
Private FileSystemObject            As FileSystemObject
Private Dictionarys()               As typDictionary

Private Function IniRead(ByVal lpApplicationName As String, _
                         ByVal lpKeyName As String, _
                         ByVal lpFileName As String, _
                         Optional ByVal lpDefault As String = vbNullString) As String
    Dim Size                As Long
    Dim lpReturnedString    As String * 1024
    Dim intZeroPos          As Integer

    'INIファイル読み込み
    Size = GetPrivateProfileString(lpApplicationName, lpKeyName, lpDefault, lpReturnedString, Len(lpReturnedString), lpFileName)
    If Size > 0 Then
        intZeroPos = InStr(lpReturnedString, vbNullChar)
        If intZeroPos > 0 Then
            IniRead = Left$(lpReturnedString, intZeroPos - 1)
        Else
            IniRead = lpReturnedString
        End If
    End If
End Function

Private Sub cmdCancel_Click()
    Unload Me
End Sub

Private Sub cmdChange_Click()
    Dim DicFile                     As File
    Dim DicTextStream               As TextStream
    Dim SrcFile                     As File
    Dim SrcTextStream               As TextStream
    Dim strSQL                      As String
    Dim lngX                        As Long
    Dim lngListIndex                As Long
    Dim lngRecordCount              As Long
    Dim lngDictionaryItemCount      As Long
    Dim strDictionaryItems()        As String
    Dim strNewDictionaryItems()     As String
    
         
    With FileSystemObject
        If Not .FileExists(strDicFile) Then
            Set DicTextStream = .CreateTextFile(strDicFile)
            DicTextStream.Close
        End If
        Set DicFile = .GetFile(strDicFile)
    End With
         
    lngDictionaryItemCount = 0
    For lngListIndex = 0 To lstDictionary.ListCount - 1
        If lstDictionary.Selected(lngListIndex) Then
            If Dictionarys(lngListIndex).FileType = "SQL" Then
                With Dictionarys(lngListIndex)
                    Set OraDatabase = OraSession.OpenDatabase(.Database, .ConnectionString, ORADB_ORAMODE)
                    Set OraParameters = OraDatabase.Parameters
                    Set SrcFile = FileSystemObject.GetFile(FileSystemObject.BuildPath(App.Path, .FileName))
                    Set SrcTextStream = SrcFile.OpenAsTextStream(ForReading)
                    strSQL = SrcTextStream.ReadAll
                    SrcTextStream.Close
                End With
                Set OraDynaset = OraDatabase.CreateDynaset(strSQL, ORADYN_READONLY)
                With OraDynaset
                    lngX = 0
                    lngRecordCount = .RecordCount
                    If lngRecordCount > 0 Then
                        ReDim strDictionaryItems(0 To lngRecordCount - 1)
                        Do Until .EOF
                            If Not IsNull(.Fields(0).Value) Then
                                strDictionaryItems(lngX) = .Fields(0).Value
                            Else
                                strDictionaryItems(lngX) = vbNullString
                            End If
                            lngX = lngX + 1
                            .MoveNext
                        Loop
                    End If
                End With
            Else
                With Dictionarys(lngListIndex)
                    Set SrcFile = FileSystemObject.GetFile(FileSystemObject.BuildPath(App.Path, .FileName))
                    Set SrcTextStream = SrcFile.OpenAsTextStream(ForReading)
                    If SrcFile.Size > 0 Then
                        strDictionaryItems = Split(SrcTextStream.ReadAll, vbNewLine)
                        lngRecordCount = UBound(strDictionaryItems) + 1
                    Else
                        lngRecordCount = 0
                    End If
                    SrcTextStream.Close
                End With
            End If
            ReDim Preserve strNewDictionaryItems(0 To (lngDictionaryItemCount + lngRecordCount - 1))
            For lngX = 0 To (lngRecordCount - 1)
                strNewDictionaryItems(lngDictionaryItemCount + lngX) = strDictionaryItems(lngX)
            Next lngX
            lngDictionaryItemCount = lngDictionaryItemCount + lngRecordCount
        End If
    Next lngListIndex
        
    Set DicTextStream = DicFile.OpenAsTextStream(ForWriting)
    DicTextStream.Write Join(strNewDictionaryItems, vbNewLine)
    DicTextStream.Close
    
    Set DicFile = Nothing
    Set DicTextStream = Nothing
    Set SrcFile = Nothing
    Set SrcTextStream = Nothing
    Erase strDictionaryItems
    Erase strNewDictionaryItems
    
    Unload Me
End Sub

Private Sub cmdNameDictionary_Click()
    Dim lngScrhDC As Long
    lngScrhDC = GetDesktopWindow()
    ShellExecute lngScrhDC, "Open", FileSystemObject.BuildPath(App.Path, "Oracleネーミングルール.xls"), "", App.Path, SW_SHOWNORMAL
End Sub

Private Sub Form_Load()
    Dim strAppCaption           As String
    Dim lngFirstTophWnd         As Long
    Dim lngFirstPophWnd         As Long
    Dim lngResult               As Long
    Dim strDictionaryKey        As String
    Dim strKeyAry()             As String
    Dim strKey                  As String
    Dim lngX                    As Long
    
    '複数起動の制御
    If App.PrevInstance Then
        ' 多重起動を許さない。
        ' アプリケーションのキャプションを得る。
        strAppCaption = App.Title
        ' 自アプリのキャプションを変更しておく。
        App.Title = strAppCaption & " "
        ' トップレベルのウィンドウハンドルを得る。
        lngFirstTophWnd = FindWindow("ThunderRT6Main", strAppCaption)
        ' 直前にアクティブなウィンドウハンドルを得る。
        lngFirstPophWnd = GetLastActivePopup(lngFirstTophWnd)
        ' ウィンドウをアクティブにする。
        lngResult = SetForegroundWindow(lngFirstPophWnd)
        ' 最小化されタスクバーに格納されてある場合があるので、ウィンドウを通常表示にさせる。
        lngResult = ShowWindow(lngFirstPophWnd, SW_RESTORE)
        ' アプリケーションを終了させる。
        End
    End If
    
    Set FileSystemObject = New FileSystemObject
    Set OraSession = CreateObject("OracleInProcServer.XOraSession")
    strIniFile = FileSystemObject.BuildPath(App.Path, "OracleDic.ini")
    strDicFile = FileSystemObject.BuildPath(App.Path, "OracleDic.dic")
    strDictionaryKey = IniRead("Dictionary", "ListItemKey", strIniFile)
    
    strKeyAry() = Split(strDictionaryKey, ",")
    If UBound(strKeyAry) > -1 Then
        ReDim Dictionarys(0 To UBound(strKeyAry))
    End If
    For lngX = 0 To UBound(strKeyAry)
        strKey = strKeyAry(lngX)
        With Dictionarys(lngX)
            .Key = strKey
            .Title = IniRead(strKey, "Title", strIniFile, strKey)
            .Database = IniRead(strKey, "Database", strIniFile)
            .ConnectionString = IniRead(strKey, "ConnectionString", strIniFile)
            .FileType = IniRead(strKey, "FileType", strIniFile, "SQL")
            .FileName = IniRead(strKey, "FileName", strIniFile, "DefaultDic.sql")
            lstDictionary.AddItem .Title
        End With
    Next lngX
    Erase strKeyAry
End Sub

Private Sub Form_LostFocus()
    Unload Me
End Sub

Private Sub Form_Unload(Cancel As Integer)
    Set OraParameters = Nothing
    Set OraDynaset = Nothing
    Set OraDatabase = Nothing
    Set OraSession = Nothing
    Set FileSystemObject = Nothing
    Erase Dictionarys
    Set frmOracleDic = Nothing
End Sub

Private Sub lstDictionary_Click()
    Dim lngListIndex                As Long
    Dim blnEnabled                  As Boolean
    
    For lngListIndex = 0 To lstDictionary.ListCount - 1
        blnEnabled = lstDictionary.Selected(lngListIndex)
        If blnEnabled Then Exit For
    Next lngListIndex
    cmdChange.Enabled = blnEnabled
End Sub
