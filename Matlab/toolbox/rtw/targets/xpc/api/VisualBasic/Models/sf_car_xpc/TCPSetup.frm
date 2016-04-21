VERSION 5.00
Begin VB.Form TCPSetupdlg 
   BorderStyle     =   1  'Fixed Single
   Caption         =   "TCP/IP Communication Setup"
   ClientHeight    =   2415
   ClientLeft      =   45
   ClientTop       =   330
   ClientWidth     =   6555
   ControlBox      =   0   'False
   LinkTopic       =   "Form2"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   2415
   ScaleWidth      =   6555
   StartUpPosition =   2  'CenterScreen
   Begin VB.CommandButton CancelButton 
      Caption         =   "Cancel"
      Height          =   375
      Left            =   5160
      TabIndex        =   6
      Top             =   1320
      Width           =   1215
   End
   Begin VB.CommandButton OKButton 
      Caption         =   "OK"
      Default         =   -1  'True
      Height          =   375
      Left            =   5160
      TabIndex        =   5
      Top             =   720
      Width           =   1215
   End
   Begin VB.Frame Frame1 
      Caption         =   "Enter Target IP Address And Port Number"
      Height          =   1815
      Left            =   120
      TabIndex        =   0
      Top             =   360
      Width           =   4815
      Begin VB.TextBox PortTextfld 
         Height          =   405
         Index           =   1
         Left            =   1080
         TabIndex        =   4
         Top             =   960
         Width           =   3015
      End
      Begin VB.TextBox IPTextfld 
         Height          =   405
         Index           =   0
         Left            =   1080
         TabIndex        =   2
         Top             =   360
         Width           =   3015
      End
      Begin VB.Label Label1 
         Caption         =   "Port Number"
         Height          =   255
         Index           =   1
         Left            =   120
         TabIndex        =   3
         Top             =   1080
         Width           =   975
      End
      Begin VB.Label Label1 
         Caption         =   "IP Address"
         Height          =   255
         Index           =   0
         Left            =   120
         TabIndex        =   1
         Top             =   480
         Width           =   855
      End
   End
End
Attribute VB_Name = "TCPSetupdlg"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub CancelButton_Click()
    Unload Me
    Set TCPSetupdlg = Nothing
End Sub
Private Sub OKButton_Click()
    If TCPSetupdlg.IPTextfld(0).Text = "" Or TCPSetupdlg.PortTextfld(1).Text = "" Then
        MsgBox ("Please Fill Form")
       
    Else
        Call TcpConnctrlAction(TCPSetupdlg.IPTextfld(0).Text, TCPSetupdlg.PortTextfld(1).Text)
    End If
End Sub


