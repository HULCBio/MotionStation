Attribute VB_Name = "Module1"
'Declare References to xPC API Interface Types needed
'to Interface with sf_car_xpc target application

Public xPCCommsobj1 As xPCProtocol  ' Communication Type represent Target PC
Public xPCTargetobj1  As xPCTarget  ' Application Type represents sf_car_xpc target application
Public xPCScopeobj1  As xPCScopes   ' Scope Types represents not used in this project.

Public Declare Function PlaySound Lib "winmm.dll" _
    Alias "PlaySoundA" (ByVal lpszName As String, _
    ByVal hModule As Long, ByVal dwFlags As Long) As Long
'Public Variables Declarations used in the Project for acquiring Signals, parameters, etc...
Public RPMSigIdx, SpeedSigIdx, GearSigIdx As Long
Public ThrottleBlckIdx, BrakeBlckIdx, AppName, AppStat As String
Public COM, IP, PortNum, TGDir, StrApp As String

Public Const SND_ASYNC = &H1
Public Const SND_NODEFAULT = &H2
Public Const SND_PURGE = &H40

Public Sub Main()

    Set xPCCommsobj1 = New xPCProtocol
    Set xPCTargetobj1 = New xPCTarget
    Set xPCScopeobj1 = New xPCScopes
    xPCCommsobj1.Init
    MainWin.Show

    If (FileisTrue("sfcarset.dat") = False) Then
        MsgBox "Can't find Setting File 'sfcarset.dat'. Setting File must exist in same directory to start Application", 48, "Error"
        Unload MainWin
        End
    Else 'file exist
        Loadfromfile
    End If
End Sub

    
'Loads from file setting.
Public Sub Loadfromfile()
  
   Dim fso, MyFile
   
   Set fso = CreateObject("Scripting.FileSystemObject")
   Set MyFile = fso.OpenTextFile("sfcarset.dat", 1)
   
   COM = MyFile.Readline
   IP = MyFile.Readline
   PortNum = MyFile.Readline
   TGDir = MyFile.Readline
   StrApp = MyFile.Readline
   
   If (COM = "") Or (IP = "") Or (PortNum = "") Or (TGDir = "") Or (StrApp = "") Then
        Exit Sub
   End If
   
   If (COM = 1) Then
        ComPortoneCallback
        Call LoadAppctrlAction(TGDir, StrApp)
        
        SerialSetupDlg.optCOMport1.Value = True
        
        LoadAppdlg.Dirpathdlg.Text = TGDir
        LoadAppdlg.StrAppNmaedlg.Text = StrApp
        
  ElseIf (COM = 2) Then
        ComPorttwoCallback
        Call LoadAppctrlAction(TGDir, StrApp)
        
        SerialSetupDlg.optCOMport2.Value = True
        
        LoadAppdlg.Dirpathdlg.Text = TGDir
        LoadAppdlg.StrAppNmaedlg.Text = StrApp
   Else 'must be with ethernet
       Call TcpConnctrlAction(IP, PortNum)
       Call LoadAppctrlAction(TGDir, StrApp)
       TCPSetupdlg.IPTextfld(0).Text = IP
       TCPSetupdlg.PortTextfld(1).Text = PortNum
       LoadAppdlg.Dirpathdlg.Text = TGDir
       LoadAppdlg.StrAppNmaedlg.Text = StrApp
       
   End If
     
End Sub

Public Function FileisTrue(ByVal FileName As String) As Boolean

    Dim fso
    
    Set fso = CreateObject("Scripting.FileSystemObject")
    If (fso.FileExists(FileName)) Then
        FileisTrue = True
    Else
        FileisTrue = False
    End If
        
End Function




' Function to handle error messages.  Use to be called for any function call from the xPC API
Public Function iserror() As Boolean
    
    Dim erridnum As Long
    Dim errmsg As String * 200
 
    erridnum = xPCCommsobj1.isxPCError()
    
    If Not (erridnum Eqv 0) Then
        errmsg = xPCCommsobj1.GetxPCErrorMsg
        MsgBox errmsg, vbExclamation, "Error"
        iserror = True
    Else
        iserror = False
    End If
End Function



' Actions taken when the Stopping the application
Public Sub StopCtrlAction()
    Dim StopxPCTargApp As Long
    StopxPCTargApp = xPCTargetobj1.StopApp
    
    MainWin.StartBttn.Enabled = True
    MainWin.StopBttn.Enabled = False
    MainWin.STcom.Enabled = True
    MainWin.stopcom.Enabled = True
    MainWin.Timer1.Enabled = False
    MainWin.Mnu1UnloadApp.Enabled = True
    MainWin.Label1(7).Caption = "stopped"
    MainWin.Label1(9).Caption = "-"
    MainWin.Dkmhled.Caption = " "
    init_values

End Sub

'Actions taken when Starting the application
Public Sub StartCtrlAction()
    Dim StartxPCTargApp As Long
    StartxPCTargApp = xPCTargetobj1.StartApp
    lFlags = SND_ASYNC Or SND_NODEFAULT Or SND_FILENAME
    l = PlaySound("keySound", 0, lFlags)
    iserror
   
    MainWin.Timer1.Enabled = True
    MainWin.Mnu1LoadApp.Enabled = False
    MainWin.Mnu1UnloadApp.Enabled = True
    MainWin.SpeedMPH.Enabled = True
    MainWin.STcom.Enabled = False
    MainWin.stopcom.Enabled = False
    MainWin.RPM.Enabled = True
    If (MainWin.Timer1.Enabled = False) Then
        MainWin.Timer1.Enabled = True 'Start the timer
    End If

End Sub


Public Sub ComPortoneCallback()

 'Assign Port number depending on selected Port by user connect via com 1
        stat = xPCCommsobj1.RS232Connect(0, 0)
        stat = xPCTargetobj1.Init(xPCCommsobj1) 'initializing Target object to the Target
        
        If (iserror = True) Then
            MainWin.Label1(12).ForeColor = &HC0&
            MainWin.Label1(12).Caption = "Connection can not be establishhed via serial link!"
            Unload SerialSetupDlg
        Else
            MainWin.Label1(12).ForeColor = &H8000000E
            MainWin.Mnu1LoadApp.Enabled = True
            MainWin.Label1(12).Caption = "Serial Connection Establshed successfully .......................................................COM Port 1"
            MainWin.Mnu1LoadApp.Enabled = True
            MainWin.mnu2closeCom.Enabled = True
            MainWin.Mnu1EstConn = False
            TCPSetupdlg.IPTextfld(0).Text = ""
            TCPSetupdlg.PortTextfld(1).Text = ""
            SerialSetupDlg.Hide
        End If
        
End Sub

Public Sub ComPorttwoCallback()

'Assign Port number depending on selected Port by user connect via com 2

        stat = xPCCommsobj1.RS232Connect(1, 0)
         stat = xPCTargetobj1.Init(xPCCommsobj1) 'initializing Target object to the Target
        If (iserror = True) Then
            MainWin.Label1(12).ForeColor = &HC0&
            MainWin.Label1(12).Caption = "Connection can not be establishhed via serial link!"
            Unload SerialSetupDlg
        Else
            MainWin.Label1(12).ForeColor = &H8000000E
            MainWin.Mnu1LoadApp.Enabled = True
            MainWin.mnu2closeCom.Enabled = True
            MainWin.Label1(12).ForeColor = &H8000000E
            MainWin.Label1(12).Caption = "Connection Established Successfully Via RS232......................................................Com Port 2"
            MainWin.Mnu1LoadApp.Enabled = True
            MainWin.Mnu1EstConn = False
            TCPSetupdlg.IPTextfld(0).Text = "0"
            TCPSetupdlg.PortTextfld(1).Text = "0"
            SerialSetupDlg.Hide
        End If

End Sub

'Action taken when connection via ethernet
Public Sub TcpConnctrlAction(ByVal IPStr As String, ByVal PortNum As String)
 
    Port = xPCCommsobj1.TcpIpConnect(IPStr, PortNum)
     stat = xPCTargetobj1.Init(xPCCommsobj1) 'initializing Target object to the Target
    
    If (iserror = True) Then
        MainWin.Label1(12).ForeColor = &HC0&
        MainWin.Label1(12).Caption = "Connection can not be establishhed!"
        Unload TCPSetupdlg
    Else
        MainWin.Mnu1EstConn.Enabled = False
        MainWin.mnu2closeCom.Enabled = True
        MainWin.Mnu1LoadApp.Enabled = True
        MainWin.Label1(12).ForeColor = &H8000000E
        MainWin.Label1(12).Caption = "Connection Established Successfully Via Ethernet..............................Target IP Address: " + TCPSetupdlg.IPTextfld(0).Text
        MainWin.Mnu1LoadApp.Enabled = True
        TCPSetupdlg.Hide
    End If
 
End Sub

'Action Taken when loading Target Application
Public Sub LoadAppctrlAction(ByVal Dirpath As String, ByVal AppName As String)

    Dim App_Name As String * 20

    Call xPCTargetobj1.LoadApp(Dirpath, AppName)
            
    If (iserror = True) Then
        Unload LoadAppdlg
        Exit Sub
    End If

    LoadAppdlg.Hide
    App_Name = xPCTargetobj1.GetAppName()
    
    ThrottleBlckIdx = xPCTargetobj1.GetParamIdx("Throttle", "Value")
    
    BrakeBlckIdx = xPCTargetobj1.GetParamIdx("Brake", "Value")
    
    RPMSigIdx = xPCTargetobj1.GetSignalIdx("Engine/rpm")
    
    SpeedSigIdx = xPCTargetobj1.GetSignalIdx("Vehicle/mph")
    
    GearSigIdx = xPCTargetobj1.GetSignalIdx("shift_logic/ SFunction ")
                                            
    
    init_values
    
    'set timer interval to timer
    
    MainWin.Timer1.Interval = xPCTargetobj1.GetSampleTime * 1000
    
    'update labels accordingly
    MainWin.StartBttn.Enabled = True
    MainWin.STcom.Enabled = True
    MainWin.stopcom.Enabled = True
    MainWin.Slider1(0).Enabled = True
    MainWin.Slider2(1).Enabled = True
    MainWin.Label1(5).Caption = CStr(xPCTargetobj1.GetSampleTime)
    MainWin.Label1(3).Caption = CStr(xPCTargetobj1.GetStopTime)
    MainWin.Label1(7).Caption = "Stopped"
    MainWin.Label1(9).Caption = "-"
    MainWin.Label1(12).Caption = xPCTargetobj1.GetAppName
    MainWin.Mnu1LoadApp.Enabled = False
    MainWin.Mnu1UnloadApp.Enabled = True
      
    MainWin.mnuSaveSet.Enabled = True
    MainWin.mnuSaveSet.Checked = False
    
    
End Sub

'Action taken when unloading the Target application
Public Sub UnloadAppctrlAction()
   
   Dim i As Long
  
   Call xPCTargetobj1.UnLoadApp
   
   'Update controls
   LoadAppdlg.Dirpathdlg.Text = ""
   MainWin.mnuSaveSet.Enabled = True
   MainWin.Mnu1UnloadApp.Enabled = False
   MainWin.StartBttn.Enabled = False
   MainWin.STcom.Enabled = False
   MainWin.stopcom.Enabled = False
   MainWin.Label1(12).Caption = ""
   For i = 3 To 9 Step 2
      MainWin.Label1(i).Caption = ""
   Next
   MainWin.Slider1(0).Enabled = False
   MainWin.Slider2(1).Enabled = False
   MainWin.Mnu1LoadApp.Enabled = True

End Sub
'Initialize controls
Public Sub init_values()
    
    Dim ThrInitVal, BrkInitVal As Variant
     
    ThrInitVal = xPCTargetobj1.GetParam(ThrottleBlckIdx, 1)
    BrkInitVal = xPCTargetobj1.GetParam(ThrottleBlckIdx, 1)
    
    MainWin.Slider1(0).Value = CInt(ThrInitVal(0))
    MainWin.Slider2(1).Value = CInt(BrkInitVal(0))
    MainWin.Percent1.Caption = CStr(CInt((ThrInitVal(0) / 100) * 100))
    MainWin.BrakeLED.Caption = CStr(CInt(ThrInitVal(0)))
    MainWin.RPM = ""
    MainWin.SpeedMPH = ""
    MainWin.Gear1(1).BackColor = &H80000008
    MainWin.Gear2(2).BackColor = &H80000008
    MainWin.Gear3(3).BackColor = &H80000008
    MainWin.Gear4(4).BackColor = &H80000008
     
End Sub

Public Sub ExitCtrlAction()

   If (xPCTargetobj1.IsAppRunning() = 1) Then  'If App is Running

       ButNum = MsgBox("sf_car is running. Do you wish to exit", 4, "Exit sf_car") 'only prompt (yes/no)
                   
       If (ButNum = 6) Then 'If yes is pressed
           SaveAppSetting ("sftemp.dat") 'create temp file

           If (CompWhenSaved("sfcarset.dat", "sftemp.dat") = True) Then 'if no change in settings then exit right away
               DeleteFileSet ("sftemp.dat")
               Call xPCTargetobj1.StopApp
               Call xPCCommsobj1.Close
               
               Unload MainWin
               End
        
           ElseIf (CompWhenSaved("sfcarset.dat", "sftemp.dat") = False) Then 'if detected changes then prompt to save
                   ButNum2 = MsgBox(" Do you want to save the current settings?", 3, "Exit")

                    If (ButNum2 = 6) Then 'Yes is pressed
                        SaveAppSetting ("sfcarset.dat")
                        DeleteFileSet ("sftemp.dat")
                        
                        Call xPCTargetobj1.StopApp
                        Call xPCCommsobj1.Close
                        
                        Unload MainWin
                        End
                    ElseIf (ButNum2 = 7) Then 'No is pressed don't save settings and Exit but close connection
                        DeleteFileSet ("sftemp.dat")
                        
                        Call xPCTargetobj1.StopApp
                        Call xPCCommsobj1.Close
                        
                        Unload MainWin
                        End
                    ElseIf (ButNum2 = 2) Then
                        Exit Sub
                    End If
                    
            End If
                  
   ElseIf (ButNum = 7) Then   'If app is running an select No to continue running application
            Exit Sub
   End If

   ElseIf (MainWin.Mnu1EstConn.Enabled = False) Then 'if not running but connection is open just close immediatley
          
           SaveAppSetting ("sftemp.dat")
           If (CompWhenSaved("sfcarset.dat", "sftemp.dat") = True) Then
               DeleteFileSet ("sftemp.dat")
               Call xPCCommsobj1.Close
               
               Unload MainWin
               End
           ElseIf (CompWhenSaved("sfcarset.dat", "sftemp.dat") = False) Then
                   ButNum2 = MsgBox(" Do you want to save the current settings?", 3, "Exit")
                   If (ButNum2 = 6) Then 'Yes is pressed
                       SaveAppSetting ("sfcarset.dat")
                       DeleteFileSet ("sftemp.dat")
                       'Call xPCClosePort(port)
                       
                       Call xPCCommsobj1.Close
                       
                       Unload MainWin
                       End
                    ElseIf (ButNum2 = 7) Then 'No is pressed
                       DeleteFileSet ("sftemp.dat")
                       'Call xPCClosePort(port)
                       
                       Call xPCCommsobj1.Close
                       Unload MainWin
                       End
                    ElseIf (ButNum2 = 2) Then
                        Exit Sub
                    End If
           End If
 Else 'connection is closed so exit
       SaveAppSetting ("sftemp.dat")
       If (CompWhenSaved("sfcarset.dat", "sftemp.dat") = True) Then
           DeleteFileSet ("sftemp.dat")
           Unload MainWin
           End
       ElseIf (CompWhenSaved("sfcarset.dat", "sftemp.dat") = False) Then
               ButNum2 = MsgBox(" Do you want to save the current settings?", 3, "Exit")
               If (ButNum2 = 6) Then 'Yes is pressed
                   SaveAppSetting ("sfcarset.datv")
                   DeleteFileSet ("sftemp.dat")
                   Unload MainWin
                   End
               ElseIf (ButNum2 = 7) Then 'No is pressed
                   DeleteFileSet ("sftemp.dat")
                   Unload MainWin
                   End
               ElseIf (ButNum2 = 2) Then 'Cancel
                   Exit Sub
               End If
       End If
 End If
 xPCCOMobj1.Term
 
End Sub

'Save settings to ACSII file
Public Sub SaveAppSetting(ByVal FileName As String)

    Dim fso, MyFile
        
    Set fso = CreateObject("Scripting.FileSystemObject")
    Set MyFile = fso.CreateTextFile(FileName, True)
        
    'Check if connnection is via serial.
    'If connected via serial link then com 1 or com 2 must be selected
    'and set TCP/IP settings to 0
    
    'if com1 selected
    
    If (SerialSetupDlg.optCOMport1.Value = True) And (TCPSetupdlg.IPTextfld(0).Text = "") And _
    (TCPSetupdlg.PortTextfld(1).Text = "") Then
    
        MyFile.Writeline ("1")
        MyFile.Writeline ("0") 'Write 0 for IP Address
        MyFile.Writeline ("0") 'Write 0 for Port Number
        MyFile.Writeline (LoadAppdlg.Dirpathdlg.Text) 'path to sf_car.dlm
        MyFile.Writeline (LoadAppdlg.StrAppNmaedlg.Text) 'Target App name
        MyFile.Close
    'if com2 selected
    
    ElseIf (SerialSetupDlg.optCOMport2.Value = True) And (TCPSetupdlg.IPTextfld(0).Text = "") And _
    (TCPSetupdlg.PortTextfld(1).Text = "") Then
    
        MyFile.Writeline ("2")
        MyFile.Writeline ("0")  'Write 0 for IP Address
        MyFile.Writeline ("0")  'Write 0 for Port Number
        MyFile.Writeline (LoadAppdlg.Dirpathdlg.Text) 'path to sf_car.dlm
        MyFile.Writeline (LoadAppdlg.StrAppNmaedlg.Text) 'Target App name
        MyFile.Close
    'If TCP/IP connection Selected
    ElseIf (TCPSetupdlg.IPTextfld(0).Text <> "") And (TCPSetupdlg.PortTextfld(1).Text <> "") Then
         MyFile.Writeline ("0")
         MyFile.Writeline (TCPSetupdlg.IPTextfld(0).Text) 'ipaddress
         MyFile.Writeline (TCPSetupdlg.PortTextfld(1).Text) 'port number
         MyFile.Writeline (LoadAppdlg.Dirpathdlg.Text) 'path to sf_car.dlm
         MyFile.Writeline (LoadAppdlg.StrAppNmaedlg.Text) 'Target App name
         MyFile.Close
    Else 'App has no settings for connections and loading are made so don't write settings
         MyFile.Writeline ("")
         MyFile.Writeline ("")
         MyFile.Writeline ("")
         MyFile.Writeline ("")
         MyFile.Writeline (LoadAppdlg.StrAppNmaedlg.Text)
         MyFile.Close
         Exit Sub
    End If
        
  End Sub

Public Function CompWhenSaved(ByVal FileName1 As String, ByVal FileName2 As String) As Boolean

    Savedinfo = ReadAllTextFile(FileName1)
    Tempinfo = ReadAllTextFile(FileName2)
    comres = StrComp(Savedinfo, Tempinfo)

    If (comres = 0) Then
        CompWhenSaved = True
    Else
        CompWhenSaved = False
    End If

End Function

Public Function ReadAllTextFile(ByVal FileName As String) As String
   
   Dim fso, f
   
   Set fso = CreateObject("Scripting.FileSystemObject")
   Set f = fso.OpenTextFile(FileName, 1)
   ReadAllTextFile = f.ReadAll

End Function

' Delete Settings

Sub DeleteFileSet(ByVal FileName As String)

    Dim fso
    Set fso = CreateObject("Scripting.FileSystemObject")
    fso.DeleteFile (FileName)
   
 End Sub

'Action taken when Connecting to Target via serial link
Public Sub SerialComctrlAction()
    
    If (SerialSetupDlg.optCOMport1.Value = True) Then
    
        ComPortoneCallback
    End If

    If (SerialSetupDlg.optCOMport2.Value = True) Then
    
        ComPorttwoCallback
    End If
End Sub

'Action Taken when Application is stopped
Public Sub WhenAppStopAction()
       MainWin.Timer1.Enabled = False
       MainWin.StopBttn.Enabled = False
       MainWin.StartBttn.Enabled = True
       MainWin.STcom.Enabled = True
       MainWin.stopcom.Enabled = True
       MainWin.Label1(7).Caption = "stopped"
       MainWin.Label1(9).Caption = "-"
       MainWin.Mnu1UnloadApp.Enabled = True
       MainWin.Dkmhled.Caption = " "
       init_values
       
End Sub

'While application is running
Public Sub WhenAppIsRunAction()
        
        'update labels that depend on run time
        MainWin.StartBttn.Enabled = False
        MainWin.StopBttn.Enabled = True
        MainWin.Mnu1UnloadApp.Enabled = False
        MainWin.Label1(7).Caption = "Running"
        MainWin.Label1(9).Caption = CStr(xPCTargetobj1.GetExecTime())
        MainWin.SpeedMPH.Caption = Format((xPCTargetobj1.GetSignal(SpeedSigIdx)), "Fixed")
        MainWin.RPM.Caption = Format((xPCTargetobj1.GetSignal(RPMSigIdx)), "Fixed")
        MainWin.Dkmhled.Caption = Format(((xPCTargetobj1.GetSignal(SpeedSigIdx) * 1.609)), "Fixed")
        Gearlighton
        
End Sub

'Action taken for closing Communication
Public Sub CloseComCtrlAction()
   Call xPCCommsobj1.Close
   
   If (iserror = True) Then
        Exit Sub
   Else
        'update labels accordingly
        MainWin.Mnu1LoadApp.Enabled = False
        MainWin.Mnu1LoadApp.Enabled = False
        MainWin.Mnu1EstConn.Enabled = True
        MainWin.mnu2closeCom.Enabled = False
        MainWin.Label1(12).ForeColor = &H8000000E
        MainWin.Label1(12).Caption = "Connection Closed!"
        TCPSetupdlg.IPTextfld(0).Text = ""
        TCPSetupdlg.PortTextfld(1).Text = ""
    End If
    
End Sub

'Turn on appropriate gear box
Public Sub Gearlighton()

    If (CInt(xPCTargetobj1.GetSignal(GearSigIdx)) = 1) Then
        MainWin.Gear1(1).BackColor = &HC0&
        MainWin.Gear2(2).BackColor = &H80000008
        MainWin.Gear3(3).BackColor = &H80000008
        MainWin.Gear4(4).BackColor = &H80000008
    End If
    If (CInt(xPCTargetobj1.GetSignal(GearSigIdx)) = 2) Then
        MainWin.Gear3(3).BackColor = &H80000008
        MainWin.Gear2(2).BackColor = &HC0&
        MainWin.Gear4(4).BackColor = &H80000008
        MainWin.Gear1(1).BackColor = &H80000008
    End If
    If (CInt(xPCTargetobj1.GetSignal(GearSigIdx)) = 3) Then
        MainWin.Gear2(2).BackColor = &H80000008
        MainWin.Gear1(1).BackColor = &H80000008
        MainWin.Gear3(3).BackColor = &HC0&
        MainWin.Gear4(4).BackColor = &H80000008
    End If
    If (CInt(xPCTargetobj1.GetSignal(GearSigIdx)) = 4) Then
        MainWin.Gear1(1).BackColor = &H80000008
        MainWin.Gear2(2).BackColor = &H80000008
        MainWin.Gear3(3).BackColor = &H80000008
        MainWin.Gear4(4).BackColor = &HC0&
    End If

End Sub

'Action when throttle Slider is pressed
Public Sub SliderthrottlectrlAction()
    Dim xPCParamBrkID As Long
    Dim begVal(0) As Double
    Dim slideVal(0) As Double

    begVal(0) = 0
    xPCParamBrkID = xPCTargetobj1.SetParam(BrakeBlckIdx, begVal)
    MainWin.Slider2(1).Value = 0
    MainWin.BrakeLED.Caption = "0"
    slideVal(0) = CDbl(MainWin.Slider1(0).Value)
    xPCParamBrkID = xPCTargetobj1.SetParam(ThrottleBlckIdx, slideVal)
    MainWin.Percent1.Caption = Format((CDbl(MainWin.Slider1(0).Value) / 100), "Percent")
End Sub

'Action Taken when brake slider is pressed
Public Sub SliderbrakectrlAction()
    Dim xPCParamThrID As Long
    Dim begVal(0) As Double
    Dim slideVal(0) As Double
    begVal(0) = 0
    xPCParamThrID = xPCTargetobj1.SetParam(ThrottleBlckIdx, begVal)
    MainWin.Slider1(0).Value = 0
    MainWin.Percent1.Caption = Format(0, "percent")
    slideVal(0) = CDbl(MainWin.Slider2(1).Value)
    xPCParamThrID = xPCTargetobj1.SetParam(BrakeBlckIdx, slideVal)
    MainWin.BrakeLED.Caption = CStr(CDbl(MainWin.Slider2(1).Value))
End Sub

Function GetFilePath(filespec)
   Dim fso, d, f, s, length
   Set fso = CreateObject("Scripting.FileSystemObject")
   Set f = fso.GetFile(filespec)
   length = Len(f.Path) - (Len(filespec) + 1)
   s = Mid(f.Path, 1, length)
   GetFilePath = s
End Function



