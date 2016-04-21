VERSION 5.00
Begin VB.Form MainWin 
   BackColor       =   &H00000000&
   BorderStyle     =   0  'None
   Caption         =   "sf_car Dashboard"
   ClientHeight    =   9390
   ClientLeft      =   150
   ClientTop       =   435
   ClientWidth     =   13455
   ControlBox      =   0   'False
   BeginProperty Font 
      Name            =   "MS Sans Serif"
      Size            =   8.25
      Charset         =   0
      Weight          =   700
      Underline       =   0   'False
      Italic          =   0   'False
      Strikethrough   =   0   'False
   EndProperty
   LinkTopic       =   "Form2"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   9390
   ScaleWidth      =   13455
   StartUpPosition =   2  'CenterScreen
   Begin VB.PictureBox Picture1 
      Appearance      =   0  'Flat
      ForeColor       =   &H80000008&
      Height          =   615
      Left            =   0
      ScaleHeight     =   585
      ScaleWidth      =   13545
      TabIndex        =   35
      Top             =   0
      Width           =   13575
      Begin VB.CommandButton Command2 
         Caption         =   "Horn"
         Height          =   375
         Left            =   3840
         TabIndex        =   39
         Top             =   120
         Width           =   975
      End
      Begin VB.CommandButton Command1 
         Caption         =   "EXIT"
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   9.75
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   375
         Left            =   12000
         TabIndex        =   38
         Top             =   120
         Width           =   1215
      End
      Begin VB.CommandButton StartBttn 
         Caption         =   "Start Engine"
         Enabled         =   0   'False
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   375
         Left            =   120
         TabIndex        =   37
         Top             =   120
         Width           =   1095
      End
      Begin VB.CommandButton StopBttn 
         Caption         =   "Stop Engine"
         Enabled         =   0   'False
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   375
         Left            =   1800
         TabIndex        =   36
         Top             =   120
         Width           =   1095
      End
   End
   Begin VB.Timer Timer1 
      Left            =   0
      Top             =   120
   End
   Begin VB.Frame Frame3 
      BackColor       =   &H00000000&
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   2175
      Left            =   0
      TabIndex        =   5
      Top             =   1200
      Width           =   13455
      Begin VB.CommandButton STcom 
         Caption         =   "Edit"
         Enabled         =   0   'False
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   375
         Left            =   4560
         TabIndex        =   27
         Top             =   1080
         Width           =   735
      End
      Begin VB.CommandButton stopcom 
         Caption         =   "Edit"
         Enabled         =   0   'False
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   375
         Left            =   4560
         TabIndex        =   26
         Top             =   360
         Width           =   735
      End
      Begin VB.Label Label1 
         BackStyle       =   0  'Transparent
         Caption         =   "Sample Time"
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   12
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H8000000E&
         Height          =   375
         Index           =   0
         Left            =   120
         TabIndex        =   13
         Top             =   1080
         Width           =   1695
      End
      Begin VB.Label Label1 
         BackStyle       =   0  'Transparent
         Caption         =   "Execution Time"
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   12
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H8000000E&
         Height          =   375
         Index           =   10
         Left            =   7320
         TabIndex        =   12
         Top             =   1080
         Width           =   1935
      End
      Begin VB.Label Label1 
         BackStyle       =   0  'Transparent
         Caption         =   "Stop Time"
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   12
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H8000000E&
         Height          =   495
         Index           =   4
         Left            =   120
         TabIndex        =   11
         Top             =   360
         Width           =   1575
      End
      Begin VB.Label Label1 
         BackStyle       =   0  'Transparent
         Caption         =   "Status"
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   12
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H8000000E&
         Height          =   375
         Index           =   2
         Left            =   7320
         TabIndex        =   10
         Top             =   360
         Width           =   1335
      End
      Begin VB.Label Label1 
         BackColor       =   &H80000008&
         BorderStyle     =   1  'Fixed Single
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   13.5
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H8000000E&
         Height          =   615
         Index           =   5
         Left            =   1920
         TabIndex        =   9
         Top             =   960
         Width           =   2535
      End
      Begin VB.Label Label1 
         BackColor       =   &H80000008&
         BorderStyle     =   1  'Fixed Single
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   13.5
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H8000000E&
         Height          =   615
         Index           =   3
         Left            =   1920
         TabIndex        =   8
         Top             =   240
         Width           =   2535
      End
      Begin VB.Label Label1 
         BackColor       =   &H80000008&
         BorderStyle     =   1  'Fixed Single
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   13.5
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H8000000E&
         Height          =   615
         Index           =   7
         Left            =   9600
         TabIndex        =   7
         Top             =   240
         Width           =   2775
      End
      Begin VB.Label Label1 
         BackColor       =   &H80000008&
         BorderStyle     =   1  'Fixed Single
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   13.5
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H8000000E&
         Height          =   615
         Index           =   9
         Left            =   9600
         TabIndex        =   6
         Top             =   960
         Width           =   2775
      End
   End
   Begin VB.Frame Frame1 
      BackColor       =   &H00000000&
      Caption         =   "Throttle and Brake Controls"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   12
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H8000000E&
      Height          =   2535
      Left            =   0
      TabIndex        =   2
      Top             =   3360
      Width           =   13455
      Begin VB.HScrollBar Slider2 
         Enabled         =   0   'False
         Height          =   255
         Index           =   1
         Left            =   7080
         Max             =   4000
         TabIndex        =   29
         Top             =   480
         Width           =   5655
      End
      Begin VB.HScrollBar Slider1 
         Enabled         =   0   'False
         Height          =   255
         Index           =   0
         Left            =   360
         Max             =   100
         TabIndex        =   28
         Top             =   480
         Width           =   5475
      End
      Begin VB.Label Percent1 
         BackColor       =   &H00000040&
         BorderStyle     =   1  'Fixed Single
         BeginProperty Font 
            Name            =   "Haettenschweiler"
            Size            =   26.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H000000C0&
         Height          =   615
         Left            =   4080
         TabIndex        =   34
         Top             =   960
         Width           =   1695
      End
      Begin VB.Label BrakeLED 
         BackColor       =   &H00000040&
         BorderStyle     =   1  'Fixed Single
         BeginProperty Font 
            Name            =   "Haettenschweiler"
            Size            =   26.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H000000C0&
         Height          =   615
         Left            =   11040
         TabIndex        =   25
         Top             =   960
         Width           =   1695
      End
      Begin VB.Label Label1 
         BackColor       =   &H80000008&
         Caption         =   "Tune Throttle (%)"
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   12
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H0000C000&
         Height          =   615
         Index           =   16
         Left            =   360
         TabIndex        =   4
         Top             =   1080
         Width           =   3255
      End
      Begin VB.Label Label1 
         BackColor       =   &H80000008&
         Caption         =   "Tune Brake Torque(ft-Ib)"
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   12
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H0000C000&
         Height          =   495
         Index           =   17
         Left            =   7080
         TabIndex        =   3
         Top             =   1080
         Width           =   3015
      End
   End
   Begin VB.Frame Frame2 
      BackColor       =   &H00000000&
      Caption         =   "DashBoard"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   12
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00FFFFFF&
      Height          =   3495
      Left            =   0
      TabIndex        =   0
      Top             =   5880
      Width           =   13455
      Begin VB.Frame GearFrame 
         BackColor       =   &H00000000&
         Caption         =   "Gear"
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00C0FFFF&
         Height          =   2655
         Left            =   11760
         TabIndex        =   15
         Top             =   480
         Width           =   1335
         Begin VB.Label Label5 
            BackColor       =   &H00000000&
            Caption         =   "4"
            BeginProperty Font 
               Name            =   "MS Sans Serif"
               Size            =   8.25
               Charset         =   0
               Weight          =   400
               Underline       =   0   'False
               Italic          =   0   'False
               Strikethrough   =   0   'False
            EndProperty
            ForeColor       =   &H8000000E&
            Height          =   255
            Index           =   3
            Left            =   240
            TabIndex        =   23
            Top             =   2040
            Width           =   255
         End
         Begin VB.Label Label5 
            BackColor       =   &H00000000&
            Caption         =   "3"
            BeginProperty Font 
               Name            =   "MS Sans Serif"
               Size            =   8.25
               Charset         =   0
               Weight          =   400
               Underline       =   0   'False
               Italic          =   0   'False
               Strikethrough   =   0   'False
            EndProperty
            ForeColor       =   &H8000000E&
            Height          =   255
            Index           =   2
            Left            =   240
            TabIndex        =   22
            Top             =   1440
            Width           =   135
         End
         Begin VB.Label Label5 
            BackColor       =   &H00000000&
            Caption         =   "2"
            BeginProperty Font 
               Name            =   "MS Sans Serif"
               Size            =   8.25
               Charset         =   0
               Weight          =   400
               Underline       =   0   'False
               Italic          =   0   'False
               Strikethrough   =   0   'False
            EndProperty
            ForeColor       =   &H8000000E&
            Height          =   255
            Index           =   1
            Left            =   240
            TabIndex        =   21
            Top             =   840
            Width           =   255
         End
         Begin VB.Label Label5 
            BackColor       =   &H00000000&
            Caption         =   "1"
            BeginProperty Font 
               Name            =   "MS Sans Serif"
               Size            =   8.25
               Charset         =   0
               Weight          =   400
               Underline       =   0   'False
               Italic          =   0   'False
               Strikethrough   =   0   'False
            EndProperty
            ForeColor       =   &H8000000E&
            Height          =   255
            Index           =   0
            Left            =   240
            TabIndex        =   20
            Top             =   360
            Width           =   135
         End
         Begin VB.Label Gear4 
            BackColor       =   &H00000000&
            BorderStyle     =   1  'Fixed Single
            BeginProperty Font 
               Name            =   "MS Sans Serif"
               Size            =   8.25
               Charset         =   0
               Weight          =   400
               Underline       =   0   'False
               Italic          =   0   'False
               Strikethrough   =   0   'False
            EndProperty
            Height          =   375
            Index           =   4
            Left            =   600
            TabIndex        =   19
            Top             =   2040
            Width           =   615
         End
         Begin VB.Label Gear3 
            BackColor       =   &H00000000&
            BorderStyle     =   1  'Fixed Single
            BeginProperty Font 
               Name            =   "MS Sans Serif"
               Size            =   8.25
               Charset         =   0
               Weight          =   400
               Underline       =   0   'False
               Italic          =   0   'False
               Strikethrough   =   0   'False
            EndProperty
            Height          =   375
            Index           =   3
            Left            =   600
            TabIndex        =   18
            Top             =   1440
            Width           =   615
         End
         Begin VB.Label Gear2 
            BackColor       =   &H00000000&
            BorderStyle     =   1  'Fixed Single
            BeginProperty Font 
               Name            =   "MS Sans Serif"
               Size            =   8.25
               Charset         =   0
               Weight          =   400
               Underline       =   0   'False
               Italic          =   0   'False
               Strikethrough   =   0   'False
            EndProperty
            Height          =   375
            Index           =   2
            Left            =   600
            TabIndex        =   17
            Top             =   840
            Width           =   615
         End
         Begin VB.Label Gear1 
            BackColor       =   &H00000000&
            BorderStyle     =   1  'Fixed Single
            BeginProperty Font 
               Name            =   "MS Sans Serif"
               Size            =   8.25
               Charset         =   0
               Weight          =   400
               Underline       =   0   'False
               Italic          =   0   'False
               Strikethrough   =   0   'False
            EndProperty
            ForeColor       =   &H00000000&
            Height          =   375
            Index           =   1
            Left            =   600
            TabIndex        =   16
            Top             =   240
            Width           =   615
         End
      End
      Begin VB.Label Label2 
         BackColor       =   &H80000012&
         Caption         =   "RPM"
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00C0FFFF&
         Height          =   255
         Index           =   2
         Left            =   7440
         TabIndex        =   33
         Top             =   360
         Width           =   2175
      End
      Begin VB.Label Label2 
         BackColor       =   &H80000012&
         Caption         =   "Digital Speedometer  (Miles/H)"
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00C0FFFF&
         Height          =   255
         Index           =   1
         Left            =   3480
         TabIndex        =   32
         Top             =   360
         Width           =   2175
      End
      Begin VB.Label RPM 
         BackColor       =   &H00000040&
         BorderStyle     =   1  'Fixed Single
         BeginProperty Font 
            Name            =   "Haettenschweiler"
            Size            =   26.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H000000C0&
         Height          =   615
         Left            =   7440
         TabIndex        =   31
         Top             =   720
         Width           =   1695
      End
      Begin VB.Label SpeedMPH 
         BackColor       =   &H00000040&
         BorderStyle     =   1  'Fixed Single
         BeginProperty Font 
            Name            =   "Haettenschweiler"
            Size            =   26.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H000000C0&
         Height          =   615
         Left            =   3480
         TabIndex        =   30
         Top             =   720
         Width           =   1695
      End
      Begin VB.Label Dkmhled 
         BackColor       =   &H00000040&
         BorderStyle     =   1  'Fixed Single
         BeginProperty Font 
            Name            =   "Haettenschweiler"
            Size            =   26.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H000000C0&
         Height          =   615
         Left            =   240
         TabIndex        =   14
         Top             =   720
         Width           =   1815
      End
      Begin VB.Label Label2 
         BackColor       =   &H80000012&
         Caption         =   "Digital Speedometer  (km/H)"
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00C0FFFF&
         Height          =   255
         Index           =   0
         Left            =   240
         TabIndex        =   1
         Top             =   360
         Width           =   2175
      End
   End
   Begin VB.Label Label1 
      BackColor       =   &H80000006&
      BorderStyle     =   1  'Fixed Single
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   13.5
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H8000000E&
      Height          =   615
      Index           =   12
      Left            =   0
      TabIndex        =   24
      Top             =   600
      Width           =   13455
   End
   Begin VB.Menu mnuSetup 
      Caption         =   "&Setup Comms"
      Begin VB.Menu Mnu1EstConn 
         Caption         =   "Establish a Connection"
         Begin VB.Menu Mnu2SerConn 
            Caption         =   "Serial"
         End
         Begin VB.Menu Mnu2TcpipConn 
            Caption         =   "TCP/IP"
         End
      End
      Begin VB.Menu mnu2closeCom 
         Caption         =   "Close Com Link"
         Enabled         =   0   'False
      End
   End
   Begin VB.Menu mnuApp 
      Caption         =   "&Load/Unload"
      Begin VB.Menu Mnu1LoadApp 
         Caption         =   "Load car"
         Enabled         =   0   'False
      End
      Begin VB.Menu Mnu1UnloadApp 
         Caption         =   "Unload Car"
         Enabled         =   0   'False
      End
   End
   Begin VB.Menu mnuParam 
      Caption         =   "Settings"
      Begin VB.Menu mnuSaveSet 
         Caption         =   "Save Settings"
         Enabled         =   0   'False
      End
   End
End
Attribute VB_Name = "MainWin"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Private Sub Command1_Click()
    ExitCtrlAction
End Sub


Private Sub Command2_Click()
lFlags = SND_ASYNC Or SND_NODEFAULT Or SND_FILENAME
    l = PlaySound("horn", 0, lFlags)
End Sub

Private Sub StartBttn_Click()
    StartCtrlAction
End Sub

Private Sub STcom_Click()
    frmSaTimeProperty.Show vbModal
End Sub

Private Sub StopBttn_Click()
    StopCtrlAction
End Sub

Private Sub Label3_Click()
Label3.Caption = GetFilePath("sf_car_xpc.dlm")
End Sub

Private Sub Mnu1LoadApp_Click()
    LoadAppdlg.Dirpathdlg.Enabled = True
    LoadAppdlg.Dirpathdlg.Text = GetFilePath("sf_car_xpc.dlm")
    LoadAppdlg.Dirpathdlg.Enabled = False
    LoadAppdlg.Show vbModal
    
End Sub

Private Sub Mnu1UnloadApp_Click()
    UnloadAppctrlAction
End Sub


Private Sub mnu2closeCom_Click()
    CloseComCtrlAction
End Sub

Private Sub Mnu2SerConn_Click()
     SerialSetupDlg.Show vbModal
End Sub

Private Sub Mnu2TcpipConn_Click()
   TCPSetupdlg.Show vbModal
End Sub


Private Sub mnuSaveSet_Click()
    SaveAppSetting ("sfcarset.dat")
    MainWin.mnuSaveSet.Checked = True
End Sub


Private Sub Slider1_Scroll(Index As Integer)
     SliderthrottlectrlAction
End Sub

Private Sub Slider2_Scroll(Index As Integer)
    SliderbrakectrlAction
End Sub


Private Sub stopcom_Click()
    frmStTimeProperty.Show vbModal
End Sub

Private Sub Timer1_Timer()

    'If (xPCIsAppRunning(port) = 1) Then
    If (xPCTargetobj1.IsAppRunning = 1) Then
        WhenAppIsRunAction
    ElseIf ((xPCTargetobj1.IsAppRunning = 0) Or (xPCTargetobj1.GetExecTime = xPCTargetobj1.GetStopTime)) Then
        WhenAppStopAction
    End If
    
End Sub


