' �������������� ����������� ����������
on error goto 0

' ��������� ��� ������ ��� ������ ���������� ���������
' ��� ��� ������ ����� � �������
Dim DebugFlag '����������� ���������� ����������
' DebugFlag = True '�������� ����� ���������� ���������

  Dim wshShell
  Dim fso 'as FileSystemObject
  
  Dim LogFile 'as File
  Dim sLogFile 'as string
  Dim ResDict 'as Dictionary 
  Dim ConfDict 'as Dictionary 

  Dim strCOMConnector ' as string
  Dim sFullClusterName ' as string

'      Echo("WScript.ScriptFullName = " + WScript.ScriptFullName)
Wscript.Quit( main() )

'********************************************************************
' ���������� 1 ��� ������, 0 - ��� �������
Function main( )
    main = 1
    
  'Make sure the host is csript, if not then abort
  VerifyHostIsCscript()
  
' ��������� ������ Windows Script Host
  if CDbl(replace(WScript.Version,".",","))<5.6 then
    Echo "��� ������ �������� ��������� Windows Script Host ������ 5.6 � ���� !"
    Exit Function
  end if  

' ������������� ��������
if not Init() then
  Exit Function
end if
'Exit Function

    ServerName = ResDict.Item(LCase("ServerName")) ' "WorkServer" '��� ������� ��
    KlasterPortNumber = ResDict.Item(LCase("KlasterPortNumber")) ' 1541 '����� ���� ��������
    InfoBaseName = ResDict.Item(LCase("InfoBaseName")) ' "User_01" '��� ��

	sFullServerName = ServerName
	sFullClusterName = ServerName
	if "" <> CStr(KlasterPortNumber) then
		sFullServerName = ServerName + ":" + CStr(KlasterPortNumber)
		sFullClusterName = ServerName + ":" + CStr(CInt(KlasterPortNumber)-1)
	end if

    ServerName83 = ResDict.Item(LCase("ServerName83")) 
    KlasterPortNumber83 = ResDict.Item(LCase("KlasterPortNumber83")) 
    InfoBaseName83 = ResDict.Item(LCase("InfoBaseName83")) 

	sFullServerName83 = ServerName83
	if "" <> CStr(KlasterPortNumber83) then
		sFullServerName83 = sFullServerName83 + ":" + CStr(KlasterPortNumber83)
	end if

    RepositoryPath = ResDict.Item(LCase("RepositoryPath")) ' "E:\Repository\test" ' ���� � ���������

		' ����� - ���� ������ ���� ����� ���������������� ��� server:port\baseName - ��������, WorkServer:1541\User_01
		' ���� ���� ���� ���������������� ��� server\baseName (��� �������� �����) - ��� ������ � ���������� ����� ������ ��-�� ����������� ��������������� �������������� ����
		' ���� ����� ����������� �� ����, �� ������� ��������� ��������� �� ���������

    ' ����� �� ������ ���� ������� ������� ������������� � ������������ � ��������� � ����� ������������� !
    ' ����� ������ - (������������ ��� ���������������� � ���������.)

    ClasterAdminName = ResDict.Item(LCase("ClasterAdminName")) ' "" '��� �������������� ��������
    ClasterAdminPass = ResDict.Item(LCase("ClasterAdminPass")) ' "" '������ �������������� ��������
    InfoBasesAdminName = ResDict.Item(LCase("InfoBasesAdminName")) ' "�������������1" '��� �������������� ��
    InfoBasesAdminPass = ResDict.Item(LCase("InfoBasesAdminPass")) ' "" '������ �������������� ��
    RepositoryAdminName = ResDict.Item(LCase("RepositoryAdminName")) ' "�������������" ' ��� �������������� ���������
    RepositoryAdminPass = ResDict.Item(LCase("RepositoryAdminPass")) ' "" ' ������ �������������� ���������

		'FilePath = ResDict.Item(LCase("FilePath")) ' "\\WorkServer\Share\Admin1C\confupdate.vbs" '���� � �������� �����
    NetFile = ResDict.Item(LCase("NetFile")) ' "\\WorkServer\Share\Admin1C\confupdate_base.txt" '���� � log-����� � ���� - ������������ ������ ��� NeedCopyFiles = True

    Folder = ResDict.Item(LCase("Folder")) ' "\\WorkServer\Share\Admin1C\" '������� ��� �������� ����
    CountDB = CInt(ResDict.Item(LCase("CountDB"))) ' 7 '�� ������� ���� ������� �����
    Prefix = ResDict.Item(LCase("Prefix")) ' "base" '������� ����� ��������
    Out = ResDict.Item(LCase(LCase("LogFile"))) ' "\\WorkServer\Share\Admin1C\confupdate.txt" '���� � log-�����
    sLogFile = Out
    Debug "Out", Out

		'UpdateFromStorage = ResDict.Item(LCase("UpdateFromStorage")) ' " /ConfigurationRepositoryUpdateCfg -v -force -revised " ' ��������� �� ���������

	NeedUpdateFromStorage = UCase(ResDict.Item(LCase("NeedUpdateFromStorage"))) = "TRUE" ' ������������� ���������� ������������ �� ��������� ������������
    NeedDumpIB = UCase(ResDict.Item(LCase("NeedDumpIB"))) = "TRUE" ' True ' ������������� �������� ����
    NeedCopyFiles = UCase(ResDict.Item(LCase("NeedCopyFiles"))) = "TRUE" ' True ' ������������� �������� ����
    NeedTestIB = UCase(ResDict.Item(LCase("NeedTestIB"))) = "TRUE" ' False ' ������������� ������������ ����
    NeedRestartAgent = UCase(ResDict.Item(LCase("NeedRestartAgent"))) = "TRUE" ' False ' ������������� �������� ������ �������
    NeedRestoreIB = UCase(ResDict.Item(LCase("NeedRestoreIB"))) = "TRUE" ' ������������� �������������� ������������ �� �����
    NeedRestoreIB83 = UCase(ResDict.Item(LCase("NeedRestoreIB83"))) = "TRUE" ' ������������� �������������� ������������ �� ����� ���������� 8.3
    NeedStartIB = UCase(ResDict.Item(LCase("NeedStartIB"))) = "TRUE" ' ������������� ������� 1� ����� ���������� �� ��������� ��� ���������� � ������ �����������
        
    IBFile = ResDict.Item(LCase("IBFile")) ' "" '���� � ����� � ��������� ����
    LockMessageText = ResDict.Item(LCase("LockMessageText")) ' "���� ���������. ���������..." '����� ��������� � ���������� ����������� � ��
    LockPermissionCode = ResDict.Item(LCase("LockPermissionCode")) ' "�����" '���� ��� ������� ��������������� ��
    AuthStr = ResDict.Item(LCase("AuthStr")) ' "/WA+" 
    TimeSleep = ResDict.Item(LCase("TimeSleep")) ' 10000 '600000 '10 ������ 600 ������
    TimeSleepShort = ResDict.Item(LCase("TimeSleepShort")) ' 2000 '60000 '2 ������ 60 ������
    Cfg = ResDict.Item(LCase("Cfg")) ' "" '���� � ����� � ���������� �������������
    InfoCfgFile = ResDict.Item(LCase("InfoCfgFile")) ' "" '���������� � ����� ���������� ������������
    v8exe = ResDict.Item(LCase("v8exe")) ' "C:\Program Files (x86)\1cv82\8.2.18.96\bin\1cv8.exe" '���� � ������������ ����� 1�:����������� 8.2
	v83exe = ResDict.Item(LCase("v83exe"))
		'rem NewPass = "" '����� ������ ��������������, ������������ ��
    strCOMConnector = ResDict.Item(LCase("COMConnector"))

    bSuccess = OpenLogFile
    if not bSuccess then
		Echo(CStr(Now) + " �� ������� �������� ���-����. ���-���� ������������ ������ ����������")
		Exit Function
    end if

    TimeBeginLock = Now ' ����� ������ ���������� ��
    TimeEndLock = DateAdd("h", 2, TimeBeginLock) ' ����� ��������� ���������� ��

    Debug "ServerName", ServerName

	Echo(CStr(Now) + " ������ ���������� ������������")

    'Echo(CStr(Now) + " �������� COM-����������")
    Set ComConnector = CreateCOMConnector() ' CreateObject("v82.COMConnector")

    Echo(CStr(Now) + " ����������� � ������ �������")
    Set ServerAgent = ComConnector.ConnectAgent(sFullClusterName) ' ComConnector.ConnectAgent(ServerName)

    Echo(CStr(Now) + " ��������� ������� ��������� ������� � ������ �������")
    Clasters = ServerAgent.GetClusters()

    Echo(CStr(Now) + " ������ ���������� ������ �������������")

    Echo(CStr(Now) + " ������ ����� ���������� ������������ �������� �� �����")
    findClaster = false
    For i = LBound(Clasters) To UBound(Clasters)
                'If Claster.MainPort = KlasterPortNumber Then
        Set Claster = Clasters(i)
'Debug "UCase(Claster.HostName)", UCase(Claster.HostName)

        if (UCase(Claster.HostName) = UCase(ServerName)) then
            findClaster = true
            Exit for
        End if
    Next
    if findClaster = false then
        Echo(CStr(Now) + " ������ - �� ����� ������� <"+sFullClusterName+">") 'ServerName
        Exit Function
    end if
            
    Echo(CStr(Now) + " ������������ � ���������� ��������: " + Claster.ClusterName + ", "+Claster.HostName)
	    'Echo(CStr(Now) + " ������������ � ���������� ��������: " + Claster.Name + ", "+Claster.HostName)
 
    ServerAgent.Authenticate Claster, ClasterAdminName, ClasterAdminPass

    Echo(CStr(Now) + " ��������� ������ ���������� ������� ��������� � ����� � �����")

    FindInfoBase = False

    WorkServers = ServerAgent.GetWorkingServers(Claster)
    For i = LBound(WorkServers) To UBound(WorkServers)
        Set WorkServer = WorkServers(i)
        Echo(CStr(Now) + " ����������� ������� ������ "+WorkServer.Name+": " + WorkServer.HostName)

        WorkingProcesses = ServerAgent.GetServerWorkingProcesses(Claster, WorkServer)
			'set WorkingProcesses = ServerAgent.GetWorkingProcesses(Claster, WorkServer)
			'���� ��������������� <> ������������ �����

        For j = LBound(WorkingProcesses) To UBound(WorkingProcesses)

            If WorkingProcesses(j).Running = 1 Then

                Echo(CStr(Now) + " �������� ���������� � ������� ��������� " + WorkingProcesses(j).HostName + ":" + CStr(WorkingProcesses(j).MainPort))
                Set ConnectToWorkProcess = ComConnector.ConnectWorkingProcess("tcp://" + WorkingProcesses(j).HostName + ":" + CStr(WorkingProcesses(j).MainPort))

                ConnectToWorkProcess.AuthenticateAdmin ClasterAdminName, ClasterAdminPass
                ConnectToWorkProcess.AddAuthentication InfoBasesAdminName, InfoBasesAdminPass

                If Not FindInfoBase Then

                    Echo(CStr(Now) + " ��������� ������ �� �������� ��������")
                    InfoBases = ConnectToWorkProcess.GetInfoBases()

                    Echo(CStr(Now) + " ����� ������ ��")
                    For h = LBound(InfoBases) To UBound(InfoBases)
                        Echo(CStr(Now) + " �������������� ��: " + InfoBases(h).Name)
                        If LCase(InfoBases(h).Name) = LCase(InfoBaseName) Then
                            Set InfoBase = InfoBases(h)
                            FindInfoBase = True
                            Echo(CStr(Now) + " ����� ������ ��")
                            Exit For
                        End If
                    Next

                    If Not FindInfoBase Then
                        Echo(CStr(Now) + " �� ����� ������ �� <"+InfoBaseName+">")
                        Exit Function
                    End If

                    Echo(CStr(Now) + " ��������� ������� �� ����������� � ��: " + InfoBase.Name)
                    InfoBase.ConnectDenied = True
                    InfoBase.ScheduledJobsDenied = True
                    InfoBase.DeniedFrom = TimeBeginLock
                    InfoBase.DeniedTo   = TimeEndLock
                    InfoBase.DeniedMessage = LockMessageText
                    InfoBase.PermissionCode = LockPermissionCode
                    ConnectToWorkProcess.UpdateInfoBase(InfoBase)

                    InfoBases = ServerAgent.GetInfoBases(Claster)

                    Echo(CStr(Now) + " ����� ������ �� ��� ������")
                    For h = LBound(InfoBases) To UBound(InfoBases)
                        Echo(CStr(Now) + " �������������� ��: " + InfoBases(h).Name)
                        If LCase(InfoBases(h).Name) = LCase(InfoBaseName) Then
                            Set InfoBaseSession = InfoBases(h)
								'FindInfoBase = True
                            Echo(CStr(Now) + " ����� ������ �� ��� ������")
                            Exit For
                        End If
                    Next

                    ' ������������� �������� ����������
                    Echo(CStr(Now) + " �������� ����� ������� ���������� ������ �������������")
                    'Echo(CStr(Now) + " �������� ����� ������� ���������� ������ �������������")
                    'set WshShell = WScript.CreateObject("WScript.Shell")
                    WScript.Sleep TimeSleep 

                End If

                Echo(CStr(Now) + " ������ ���������� ������ ������������� � �� " + InfoBase.Name)
                If FindInfoBase Then

                    Echo(CStr(Now) + " ��������� ������ �������")
                    Sessions = ServerAgent.GetInfoBaseSessions(Claster, InfoBaseSession)
                    For k = LBound(Sessions) To UBound(Sessions)
                        Set Session = Sessions(k)
                        UserName = Session.UserName
							'ConnID    = Session.ConnID;
                        AppID    = UCase(Session.AppID)        
                        
							'���� �� ��������������������� � ����(AppID) = "designer" �����
							'//���� ����(AppID) = "backgroundjob" ��� ����(AppID) = "designer" �����
							'    // ���� ��� ������ ������������� ��� �������� �������, �� �� ���������
							'    ����������;
							'���������;
							'//���� UserName = ���������������() �����
							'//    // ��� ������� ������������
							'//    ����������;
							'//���������;
                        Echo(CStr(Now) + " ��������� ����������: " + "User=["+UserName+"] ConnID=["+""+"] AppID=["+AppID+"]")
                        ServerAgent.TerminateSession Claster, Session
                    next

                    if false then
                        Echo(CStr(Now) + " ��������� ������ ����������")
                        Connections = ConnectToWorkProcess.GetInfoBaseConnections(InfoBase)
                        For k = LBound(Connections) To UBound(Connections)
                            Echo(CStr(Now) + " ��������� ����������: ������������ " + Connections(k).UserName + ", ��������� " + Connections(k).HostName + ", ����������� " + CStr(Connections(k).ConnectedAt) + ", ����� " + Connections(k).AppID)
                            If Connections(k).AppID = "SrvrConsole" Then
                                ' �� ������� ���������� �������, ��� ������ �� ������
                            ElseIf Connections(k).AppID = "COMConsole" Then
                                ' �� ������� ���������� �������, ��� ������ �� ������
                            Else
                                ConnectToWorkProcess.Disconnect(Connections(k))
                                Echo(CStr(Now) + " ��������� ����������: ������������ " + Connections(k).UserName + ", ��������� " + Connections(k).HostName + ", ����������� " + CStr(Connections(k).ConnectedAt) + ", ����� " + Connections(k).AppID)
                            End If
                        Next
                    End If
                End If

                Echo(CStr(Now) + " ��������� ���������� ������ �������������")

            End If

        Next

    next

    ComConnector = Null
    ServerAgent = Null
    Clasters = Null
    WorkingProcesses = Null
    ConnectToWorkProcess = Null
    InfoBases = Null
    InfoBase = Null
    Connections = Null

    If NeedRestartAgent Then
        RestartAgent TimeSleepShort
    End If

    If FindInfoBase Then

        '������� ��������� ����� �� ����� � ����������� ������ 1�
        Echo(CStr(Now) + " " + ShowFreeSpace(v8exe))
        '������� ��������� ����� �� ����� � ��������
        Echo(CStr(Now) + " " + ShowFreeSpace(Folder))
        
		If NeedRestoreIB Then
			Echo(CStr(Now) + " �������������� ��������� ����")

			strCommLine = " /RestoreIB """ + IBFile + """"

			sTempFile = FSO.GetSpecialFolder(2) + "\" +FSO.GetTempName()

			LineExe = """" + v8exe + """ DESIGNER /S""" + sFullServerName + "\" + InfoBaseName + """ /UC""" + LockPermissionCode + """ /DisableStartupMessages " + AuthStr + " " + strCommLine + " /Out""" + sTempFile +""""
			Echo(CStr(Now) + " ���.������ �������: " + LineExe)

			wshShell.Run LineExe, 5, True

			Show1CConfigLog sTempFile, " ������ ��� �������� ���� �� �����"
		End If

		if NeedUpdateFromStorage then
			Echo(CStr(Now) + " ���������� ������������ �� ���������")
			
			strRepository = " /ConfigurationRepositoryF"""+RepositoryPath+""""
			strRepository = strRepository + " /ConfigurationRepositoryN"""+RepositoryAdminName + """ /ConfigurationRepositoryP"""+RepositoryAdminPass+""""
			
			UpdateFromStorage = " /ConfigurationRepositoryUpdateCfg -v -force -revised " ' ��������� �� ���������
			' /LoadCfg � �������� ������������ �� �����; 
			' /UpdateCfg � ���������� ������������, ����������� �� ���������; 
			' /ConfigurationRepositoryUpdateCfg � ���������� ������������ �� ���������; 
			' /LoadConfigFiles � ��������� ����� ������������.

			sTempFile = FSO.GetSpecialFolder(2) + "\" +FSO.GetTempName()
			
			LineExe = """" + v8exe + """ DESIGNER /S""" + sFullServerName + "\" + InfoBaseName + """ /UC""" + LockPermissionCode + """ /DisableStartupMessages " + AuthStr + " " +UpdateFromStorage + strRepository + " /Out""" + sTempFile +""""
			Echo(CStr(Now) + " ���.������ �������: "+LineExe)
			'LogFile.Close()
			'LogFile = ""

			' ������� ������������ �� ���������
			wshShell.Run LineExe, 5, True

			' ���������� ��� ������ �������������, �.� ����� ���� ������, ��������, ������ ��� ���������� �������� � �������������� ����� ��� ������ ���������� ������������ �� ���������
			'��� ��� ���������� �������� ��������� ��������� ��������:
			'���  �������� � ���������� ������������ ��������
			' ����� ��� ������������� ��������� � ����� ����
			Show1CConfigLog sTempFile, " ������ ��� ���������� ������������ �� ���������"
		end if ' NeedUpdateFromStorage
		
        Echo(CStr(Now) + " ���������� ������������ ��") 'EchoWithOpenAndCloseLog

		sTempFile = FSO.GetSpecialFolder(2) + "\" +FSO.GetTempName()

        LineExe = """" + v8exe + """ DESIGNER /S""" + sFullServerName + "\" + InfoBaseName + """ /UC""" + LockPermissionCode + """ /DisableStartupMessages " + AuthStr + " " + " /UpdateDBCfg -Server /Out""" + sTempFile + """ -NoTruncate"
        Echo(CStr(Now) + " ���.������ �������: "+LineExe) ' EchoWithOpenAndCloseLog

        ' ������� ������������ ��
        wshShell.Run LineExe, 5, True

		' ���������� ��� ������ �������������, �.� ����� ���� ������ � ���� �� ���������
		' ����� ��� ������������� ��������� � ����� ����
		Show1CConfigLog sTempFile, " ������ ��� ���������� ���� ������"
		
        If FSO.FolderExists(Folder) = False Then
            FSO.CreateFolder Folder
        End if
        
        If NeedDumpIB = True Then
            Echo(CStr(Now) + " ��������� ���� ������ � �����") ' EchoWithOpenAndCloseLog
			
			formatDate = GetFormatDay
			sTempFile = FSO.GetSpecialFolder(2) + "\" +FSO.GetTempName()

            LineExe = """" + v8exe + """ DESIGNER /S""" + sFullServerName + "\" + InfoBaseName + """ /UC""" + LockPermissionCode + """ /DisableStartupMessages " + AuthStr + " /DumpIB""" + Folder + Prefix + formatDate + ".dt"" /Out""" + sTempFile + """ -NoTruncate"
            Echo(CStr(Now) + " ���.������: " + LineExe) ' EchoWithOpenAndCloseLog

            wshShell.Run LineExe, 5, True

			haveProblem = Show1CConfigLog(sTempFile, " ������ ��� �������� ���� ������")
			If Not haveProblem And NeedRestoreIB83 Then
    			Echo(CStr(Now) + " �������������� ���� � 8.3")

    			strCommLine = " /RestoreIB """ + Folder + Prefix + formatDate + ".dt"""

    			sTempFile = FSO.GetSpecialFolder(2) + "\" +FSO.GetTempName()

    			LineExe = """" + v83exe + """ DESIGNER /S """ + sFullServerName83 + "\" + InfoBaseName83 + """ /UC """ + LockPermissionCode + """ /DisableStartupMessages " + AuthStr + " " + strCommLine + " /Out """ + sTempFile +""""
    			Echo(CStr(Now) + " ���.������ �������: " + LineExe)

    			wshShell.Run LineExe, 5, True

    			Show1CConfigLog sTempFile, " ������ ��� �������� ���� �� �����"
			End If
        End if
		
        If NeedTestIB = True Then
            Echo(CStr(Now) + " ��������� ���� � ������������� �����.") ' EchoWithOpenAndCloseLog

			sTempFile = FSO.GetSpecialFolder(2) + "\" +FSO.GetTempName()
			
            LineExe = """" + v8exe + """ DESIGNER /S""" + sFullServerName + "\" + InfoBaseName + """ /UC""" + LockPermissionCode + """ /DisableStartupMessages " + AuthStr + " /IBCheckAndRepair -LogIntegrity -RecalcTotals /Out""" + sTempFile + """ -NoTruncate"
            Echo(CStr(Now) + " ���.������: " + LineExe) ' EchoWithOpenAndCloseLog

            wshShell.Run LineExe, 5, True

			Show1CConfigLog sTempFile, " ������ ��� �������� ���� ������"
        End if
        
        if NeedStartIB then
            Echo(CStr(Now) + " ��������� ���� � ������ �����������.") ' EchoWithOpenAndCloseLog

			sTempFile = FSO.GetSpecialFolder(2) + "\" +FSO.GetTempName()

            LineExe = """" + v8exe + """ ENTERPRISE /CCLOSE /S""" + sFullServerName + "\" + InfoBaseName + """ /UC""" + LockPermissionCode + """ /DisableStartupMessages " + AuthStr + " /Out""" + sTempFile + """ -NoTruncate"
            Echo(CStr(Now) + " ���.������: " + LineExe) ' EchoWithOpenAndCloseLog

            wshShell.Run LineExe, 5, True

			Show1CConfigLog sTempFile, " ������ ��� ���������� ���� � ������ �����������"
        end if

        'OpenLogFile

        Echo(CStr(Now) + " ��������� ���������� ����������� � ��")

        FindInfoBase = False
        
        EnableConnections ServerName, ClasterAdminName, ClasterAdminPass, InfoBasesAdminName, InfoBasesAdminPass, InfoBaseName

    End If ' FindInfoBase

    WriteLogIntoIBEventLog sFullServerName, InfoBaseName, sLogFile

    If NeedCopyFiles = True Then 
        If fso.FileExists(NetFile) Then
            fso.DeleteFile(NetFile)
        End If
Debug "Out", Out
Debug "NetFile", NetFile
        fso.MoveFile Out, NetFile
Debug "NetFile", NetFile
    End if

    If NeedDumpIB = True Then 
        CALL DelOldFiles(Folder, CountDB)
    End if

    main = 0
End Function

Function Show1CConfigLog(sTempFile, errorMessage)
	Set configLogFile = fso.OpenTextFile(sTempFile, 1)

	haveProblem = false
	Do While configLogFile.AtEndOfStream <> True
		errorString = configLogFile.ReadLine
		Echo errorString
		errorPos = InStr(1, errorString, "������", 1)
		If errorPos > 0 Then
			haveProblem = true
		end if
	Loop
	if haveProblem = true then
		Echo(CStr(Now) + errorMessage) ' EchoWithOpenAndCloseLog '" ������ ��� ���������� ������������ �� ���������")
	end if
	configLogFile.Close()

	Show1CConfigLog = haveProblem
End Function

Sub WriteLogIntoIBEventLog(sFullServerName, InfoBaseName, sLogFile)
		'Sub WriteLogIntoIBEventLog(ServerName, KlasterPortNumber, InfoBaseName, sLogFile)
    Echo(CStr(Now) + " ���������� ���� � ������ ����������� ��")
    Set ComConnector = CreateCOMConnector() ' CreateObject("v82.COMConnector")
        'Set connection = ComConnector.Connect("Srvr=" + ServerName + ":" + CStr(KlasterPortNumber) + ";Ref=" + InfoBaseName + ";Usr=" + InfoBasesAdminName + ";Pwd=" + InfoBasesAdminPass)
    Set connection = ComConnector.Connect("Srvr=" + sFullServerName + ";Ref=" + InfoBaseName)

    Echo(CStr(Now) + " ���������� ���������� ������������")

    'LogFile.Close()
    'LogFile = ""

    Set f = fso.OpenTextFile(sLogFile, 1, False, -2) 'Out
    Text = f.ReadAll

    '������� ��� ���������� �� log-����� � ������ �����������
    connection.WriteLogEvent "������������ ���������� ��", connection.EventLogLevel.Information,,, Text

    connection = Null
    ComConnector = Null
    f = Null
End Sub

Function CreateCOMConnector()
    Echo(CStr(Now) + " �������� COM-���������� <"+ strCOMConnector + ">")
    Set ComConnector = CreateObject(strCOMConnector) ' CreateObject("v82.COMConnector")

    set CreateCOMConnector = ComConnector
End Function

Function EnableConnections(ServerName, ClasterAdminName, ClasterAdminPass, InfoBasesAdminName, InfoBasesAdminPass, InfoBaseName)
    EnableConnections = false
    
    Set ComConnector = CreateCOMConnector() ' CreateObject("v82.COMConnector")
    Set ServerAgent = ComConnector.ConnectAgent(sFullClusterName) 'ServerName)
    Clasters = ServerAgent.GetClusters()

    findClaster = false
    For i = LBound(Clasters) To UBound(Clasters)
    
                'If Claster.MainPort = KlasterPortNumber Then
        Set Claster = Clasters(i)
        if (UCase(Claster.HostName) = UCase(ServerName)) then
            findClaster = true
            Exit for
        End if
    Next
    if findClaster = false then
        Echo(CStr(Now) + " ������ - �� ����� ������� "+sFullClusterName) 'ServerName
        Exit Function
    end if

    ServerAgent.Authenticate Claster, ClasterAdminName, ClasterAdminPass

    'WorkingProcesses = ServerAgent.GetWorkingProcesses(Claster)
    
    WorkServers = ServerAgent.GetWorkingServers(Claster)
    For i = LBound(WorkServers) To UBound(WorkServers)
        Set WorkServer = WorkServers(i)
        Echo(CStr(Now) + " ����������� ������� ������ "+WorkServer.Name+": " + WorkServer.HostName)

        WorkingProcesses = ServerAgent.GetServerWorkingProcesses(Claster, WorkServer)

        For j = LBound(WorkingProcesses) To UBound(WorkingProcesses)

            If WorkingProcesses(j).Running = 1 Then

                Set ConnectToWorkProcess = ComConnector.ConnectWorkingProcess("tcp://" + WorkingProcesses(j).HostName + ":" + CStr(WorkingProcesses(j).MainPort))
                ConnectToWorkProcess.AuthenticateAdmin ClasterAdminName, ClasterAdminPass
                ConnectToWorkProcess.AddAuthentication InfoBasesAdminName, InfoBasesAdminPass

                ' �������� ������ �� �������� ��������
                InfoBases = ConnectToWorkProcess.GetInfoBases()
                For h = LBound(InfoBases) To UBound(InfoBases)
                    If LCase(InfoBases(h).Name) = LCase(InfoBaseName) Then
                        Set InfoBase = InfoBases(h)
                        FindInfoBase = True
                        Exit For
                    End If
                Next

                If FindInfoBase Then
                    ' ������������� ���������� �� ����������� ����������
                    InfoBase.ConnectDenied = False
                    InfoBase.ScheduledJobsDenied = false
                    InfoBase.DeniedMessage = ""
                    InfoBase.PermissionCode = ""
                    ConnectToWorkProcess.UpdateInfoBase(InfoBase)
                    Exit For
                End If
                
                if not FindInfoBase then
                    Echo(CStr(Now) + " ������ - �� ����� ���� ��� ������ ������� �� ����������� ���������� <"+InfoBaseName+">")
                    Exit Function
                end if

            End If

        Next
    Next

    EnableConnections = true
End Function

Sub RestartAgent(TimeSleepShort)
    Set objWMIService = GetObject("winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2")
    
    'Stop Service
    strServiceName = "1C:Enterprise 8.2 Server Agent" ' "1C:Enterprise 8.1 Server Agent"
    Set colListOfServices = objWMIService.ExecQuery("Select * from Win32_Service Where Name ='" & strServiceName & "'")
    For Each objService in colListOfServices
        objService.StopService()
        Echo(CStr(Now) + " " + CStr(objService.Name) + " ��������� ������ ������� 1� �����������")
    Next
        
    WScript.Sleep TimeSleep
        
    TerminateProcess "ragent.exe"
    TerminateProcess "rmngr.exe"
    TerminateProcess "rphost.exe"
                    
    WScript.Sleep TimeSleepShort
    
    'Start Service
    strServiceName = "1C:Enterprise 8.2 Server Agent" ' "1C:Enterprise 8.1 Server Agent"
        'Set colListOfServices = objWMIService.ExecQuery ("Select * from Win32_Service Where Name ='" & strServiceName & "'")
    For Each objService in colListOfServices
        objService.StartService()
        Echo(CStr(Now) + " " + CStr(objService.Name) + " ������ ������ ������� 1� �����������")
    Next
        
    WScript.Sleep TimeSleepShort
End Sub

Sub TerminateProcess(strProcessName)
    Set colProcess = objWMIService.ExecQuery ("Select * from Win32_Process Where Name = '" & strProcessName & "'")
    For Each objProcess in colProcess
        objProcess.Terminate()
        Echo(CStr(Now) + " " + CStr(objProcess.Name) + " ���������� �������� ������ ������� 1� �����������")
    Next
End Sub

' ������������� ��������
Function Init( )
      Init = false
        
      set wshShell = wScript.createObject("wScript.shell")
      Set fso = CreateObject("Scripting.FileSystemObject") 
      
    ' ������ ��� ini-�����
      Dim IniFileName

        intOpMode = intParseCmdLine(IniFileName)

			' ������ ���� ini-���� � �������� ���������
			'  IniFileName = Replace(LCase(WScript.ScriptFullName),".vbs",".ini")
    Debug "IniFileName", IniFileName

      if not GetDataFromIniFile(IniFileName, ResDict) then
        Exit Function
      end if

    On Error Resume Next
      Dim sDebugFlag
      sDebugFlag = ResDict.Item(LCase("DebugFlag"))
      Debug "sDebugFlag",sDebugFlag
      if sDebugFlag<>"" then
        DebugFlag = CBool(sDebugFlag)
      end if
      Debug "DebugFlag",DebugFlag
    On Error Goto 0

        '' �������� ���-����
        '  LogFile = Null '�� �������� � ���-����, ���� �� ����� ���� � ����
        '  Dim sLogFile
        '  sLogFile = ResDict.Item(LCase("LogFile"))
        '  if sLogFile<>"" then
        '    If (NOT blnOpenFile(sLogFile, LogFile)) Then
        '      Call Wscript.Echo ("�� ���� ������� ���-���� <"+sLogFile+"> .")
        '      Exit Function
        '    End If
        '  End If    

  Init = true
End Function 'Init      

Function GetFormatDay()
    iDay = Day(Now)
    mDay = CStr(Day(Now))
    iMonth = Month(Now)
    mMonth = CStr(Month(Now))
    mYear = CStr(Year(Now))

    nCDay = "_" + mYear + "_"
    If iMonth < 10 Then
       nCDay = nCDay + "0"
    End If
    nCDay = nCDay + mMonth + "_"
    If iDay < 10 Then
       nCDay = nCDay + "0"
    End If
    nCDay = nCDay + mDay
	
	GetFormatDay = nCDay
End Function

' ������� ��� ����������� ���������� ����� �� �����
Function ShowFreeSpace(drvPath)
  Dim d, s
  on error Resume next
  Set d = fso.GetDrive(fso.GetDriveName(drvPath))
  s = "Drive " & UCase(drvPath) & " - " 
  s = s & d.VolumeName  & " "
  s = s & "Free Space: " & FormatNumber(d.FreeSpace/1024/1024, 0) 
  s = s & " Mbytes"
  on error goto 0
  ShowFreeSpace = s
End Function

' ������ ��� ��������� ���������� ������: 
' ������� ������ ����� � ������� �������� ��������
Sub DelOldFiles(Folder_Name, Stack_Depth)
    Set folder = fso.GetFolder(Folder_Name)
    Set files = folder.Files
    For Each f in files
        fdate = f.DateCreated
        fPrefix = Left(f.Name,Len(Prefix))
        If ((Date - fdate) > Stack_Depth) And fPrefix = Prefix Then
            f.Delete
        End If
    Next
End Sub

' �������� ������ �� INI-�����
' ResDict - ������ Dictionary, ��� �������� ���� ����/��������
Function GetDataFromIniFile(ByVal IniFileName, ByRef ResDict)
      GetDataFromIniFile = false
  
    ' ����� �������������
    Dim IniFile 'As TextStream

    On Error Resume Next
    Dim ForRead
    ForRead =1
    Set IniFile = fso.OpenTextFile(IniFileName,ForRead)
    if err.Number<>0 then
      Err.Clear()
      echo "Ini-���� "& IniFileName &" �� ������� �������!"
      Exit Function
    end if
    on error goto 0

    Set ResDict = CreateObject("Scripting.Dictionary")
    Dim s, Matches, Match
    Dim reg 'As RegExp
    Set reg = new RegExp
      reg.Pattern="^\s*([^=]+)\s*=\s*([^;']+)[;']?"
      reg.IgnoreCase = True

    Dim elem, index

    Do While IniFile.AtEndOfStream <> True
      s = IniFile.ReadLine
    ' ���� �� ������-�����������  
      if not RegExpTest("^\s*[;']",s) then
    '  For index=0 To IniDict.Count-1
    '    reg.Pattern="\s*"+elem(index)+"\s*=\s*(.+)"
    ' �������� ���� � �������� � Ini-�����, ����� ��������� �����������
        Set Matches = reg.Execute(s)
        if Matches.Count>0 then
   
		' �������� ����� ����, �������� �� �������� ��������� � �����(� ������) �������    
					'ResDict.Add elem(index),Trim(replace(Matches(0).SubMatches(0),vbTab," "))
            lkey = LCase(Trim(replace(Matches(0).SubMatches(0),vbTab," ")))
            lvalue = replace(Matches(0).SubMatches(1), vbTab, " ")
            lvalue = Trim(replace(lvalue, chr(34), "")) '������ �������
            
            ResDict.Add lkey, lvalue
					'ResDict.Add LCase(Trim(replace(Matches(0).SubMatches(0),vbTab," "))),Trim(replace(Matches(0).SubMatches(1),vbTab," "))

Debug "lkey=lvalue", lkey + " = [" + lvalue + "]"
        end if
      end if
    Loop
    IniFile.Close()

    if ResDict.Count=0 then
      echo "�� ������� �������� ������ �� Ini-����� " & IniFileName
      GetDataFromIniFile = false
    else  
      GetDataFromIniFile = true
    end if
End Function 'GetDataFromIniFile


' ��������� �� ������������ �������
' ������� �������� �� �����
  Dim regExTest               ' Create variable.
Function RegExpTest(ByVal patrn, ByVal strng)
  if IsEmpty(regExTest) then
    Set regExTest = New RegExp         ' Create regular expression.
  end if
  regExTest.Pattern = patrn         ' Set pattern.
  regExTest.IgnoreCase = true      ' disable case sensitivity.
  RegExpTest = regExTest.Test(strng)      ' Execute the search test.
'  regEx = null
End Function

Function OpenLogFile()
	Echo sLogFile

	on error resume next
    Set LogFile = fso.OpenTextFile(sLogFile, 8, True)
  
    if err.Number<>0 then
    	err.Clear()
        LogFile = nothing
	    OpenLogFile = false
	    on error goto 0
	    Exit Function
    end if
	on error goto 0

    OpenLogFile = true 'set OpenLogFile = LogFile
End Function

Sub Echo(text)
  WScript.Echo(text)
on error resume next
  If IsObject(LogFile) then        'LogFile should be a file object
    LogFile.WriteLine text
  end if
on error goto 0
End Sub'Echo

Sub EchoWithOpenAndCloseLog(text)
    OpenLogFile

    Echo(text)    

    LogFile.Close()    
    LogFile = ""
End Sub'Echo

Sub Debug(ByVal title, ByVal msg)
'exit sub
on error resume next
  DebugFlag = DebugFlag
  if err.Number<>0 then
    err.Clear()
    on error goto 0
    Exit Sub
  end if
  if DebugFlag then
    if not (IsEmpty(msg) or IsNull(msg)) then
      msg = CStr(msg)
    end if
    if not (IsEmpty(title) or IsNull(title)) then
      title = CStr(title)
    end if
    If msg="" Then
      Echo(title)
    else
      Echo(title+" - <"+msg+">")
    End If
  End If
on error goto 0
End Sub'Debug

Private Function intParseCmdLine( ByRef strFileName)

	Dim strFlag 'intParseCmdLine

'    ON ERROR RESUME NEXT
    If Wscript.Arguments.Count > 0 Then
        strFlag = Wscript.arguments.Item(0)
    End If

    If IsEmpty(strFlag) Then                'No arguments have been received
        ShowUsage 'intParseCmdLine = CONST_SHOW_USAGE
        Exit Function
    End If

        'Check if the user is asking for help or is just confused
    If (strFlag="help") OR (strFlag="/h") OR (strFlag="\h") OR (strFlag="-h") _
        OR (strFlag = "\?") OR (strFlag = "/?") OR (strFlag = "?") _
        OR (strFlag="h") Then
        ShowUsage 'intParseCmdLine = CONST_SHOW_USAGE
        Exit Function
    End If
    intParseCmdLine = 0 'CONST_LIST

    strFilename = strFlag
End Function

Sub ShowUsage ()

    Wscript.Echo ""
'    Wscript.Echo "�������� ���� �� ���� A:. ��� �� ��������� ����� �����."
    Wscript.Echo "��������� ���������������� �������� � ����� 1� 8.2"
    Wscript.Echo ""
    Wscript.Echo "��������� ������:"
    Wscript.Echo "  "+ WScript.ScriptName +" [����-�������� | /? | /h]"
    Wscript.Echo ""
    Wscript.Echo "������:"
    Wscript.Echo "1. cscript "+ WScript.ScriptName +" ����.ini"
    Wscript.Echo "2. cscript "+ WScript.ScriptName
    Wscript.Echo "   ���������� ���� �����."

End Sub

'********************************************************************
'* 
'* Function blnOpenFile
'*
'* Purpose: Opens a file.
'*
'* Input:   strFileName         A string with the name of the file.
'*
'* Output:  Sets objOpenFile to a FileSystemObject and setis it to 
'*            Nothing upon Failure.
'* 
'********************************************************************
Private Function blnOpenFile(ByVal strFileName, ByRef objOpenFile)

    ON ERROR RESUME NEXT

    If IsEmpty(strFileName) OR strFileName = "" Then
        blnOpenFile = False
        Set objOpenFile = Nothing
        Exit Function
    End If

    'fso.DeleteFile(strFileName)
    'Open the file for output
    Set objOpenFile = fso.CreateTextFile(strFileName, True)
    If blnErrorOccurred("���������� �������") Then
        blnOpenFile = False
        Set objOpenFile = Nothing
        Exit Function
    End If
    blnOpenFile = True

End Function

'********************************************************************
'*
'* Sub      VerifyHostIsCscript()
'*
'* Purpose: Determines which program is used to run this script.
'*
'* Input:   None
'*
'* Output:  If host is not cscript, then an error message is printed 
'*          and the script is aborted.
'*
'********************************************************************
Sub VerifyHostIsCscript()

    ON ERROR RESUME NEXT

    'Define constants
    CONST CONST_ERROR                   = 0
    CONST CONST_WSCRIPT                 = 1
    CONST CONST_CSCRIPT                 = 2
    
    Dim strFullName, strCommand, i, j, intStatus

    strFullName = WScript.FullName

    If Err.Number then
        Call Echo( "Error 0x" & CStr(Hex(Err.Number)) & " occurred." )
        If Err.Description <> "" Then
            Call Echo( "Error description: " & Err.Description & "." )
        End If
        intStatus =  CONST_ERROR
    End If

    i = InStr(1, strFullName, ".exe", 1)
    If i = 0 Then
        intStatus =  CONST_ERROR
    Else
        j = InStrRev(strFullName, "\", i, 1)
        If j = 0 Then
            intStatus =  CONST_ERROR
        Else
            strCommand = Mid(strFullName, j+1, i-j-1)
            Select Case LCase(strCommand)
                Case "cscript"
                    intStatus = CONST_CSCRIPT
                Case "wscript"
                    intStatus = CONST_WSCRIPT
                Case Else       'should never happen
                    Call Echo( "An unexpected program was used to " _
                                       & "run this script." )
                    Call Echo( "Only CScript.Exe or WScript.Exe can " _
                                       & "be used to run this script." )
                    intStatus = CONST_ERROR
                End Select
        End If
    End If

    If intStatus <> CONST_CSCRIPT Then
        Call Echo( "Please run this script using CScript." & vbCRLF & _
             "This can be achieved by" & vbCRLF & _
             "1. Using ""CScript SystemAccount.vbs arguments"" for Windows 95/98 or" _
             & vbCRLF & "2. Changing the default Windows Scripting Host " _
             & "setting to CScript" & vbCRLF & "    using ""CScript " _
             & "//H:CScript //S"" and running the script using" & vbCRLF & _
             "    ""SystemAccount.vbs arguments"" for Windows NT/2000/XP." )
        WScript.Quit(0)
    End If
End Sub 'VerifyHostIsCscript
