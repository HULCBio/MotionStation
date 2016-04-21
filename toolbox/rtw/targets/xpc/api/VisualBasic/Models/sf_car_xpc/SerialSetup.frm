VERSION 5.00
Begin VB.Form SerialSetupDlg 
   BorderStyle     =   1  'Fixed Single
   Caption         =   "Serial Connection Setup"
   ClientHeight    =   2160
   ClientLeft      =   2760
   ClientTop       =   3750
   ClientWidth     =   4380
   ControlBox      =   0   'False
   ForeColor       =   &H0000C000&
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   2160
   ScaleWidth      =   4380
   StartUpPosition =   2  'CenterScreen
   Begin VB.Frame frmCOMport 
      Caption         =   "Select &COM Port"
      Height          =   1695
      Left            =   240
      TabIndex        =   2
      Top             =   120
      Width           =   1695
      Begin VB.OptionButton optCOMport2 
         Caption         =   "COM &2"
         Height          =   495
         Left            =   240
         TabIndex        =   4
         Top             =   960
         Width           =   1335
      End
      Begin VB.OptionButton optCOMport1 
         Caption         =   "COM &1"
         Height          =   495
         Left            =   240
         TabIndex        =   3
         Top             =   360
         Value           =   -1  'True
         Width           =   1335
      End
   End
   Begin VB.CommandButton CancelButton 
      Cancel          =   -1  'True
      Caption         =   "Cancel"
      Height          =   375
      Left            =   2400
      TabIndex        =   1
      Top             =   1320
      Width           =   1215
   End
   Begin VB.CommandButton OKButton 
      Caption         =   "OK"
      Height          =   375
      Left            =   2400
      TabIndex        =   0
      Top             =   360
      Width           =   1215
   End
End
Attribute VB_Name = "SerialSetupDlg"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub CancelButton_Click()
    Unload Me
    Set SerialSetupDlg = Nothing
End Sub

Private Sub OKButton_Click()
    SerialComctrlAction
End Sub

