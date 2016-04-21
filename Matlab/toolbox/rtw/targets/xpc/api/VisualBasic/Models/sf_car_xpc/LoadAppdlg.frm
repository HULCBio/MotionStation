VERSION 5.00
Begin VB.Form LoadAppdlg 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Load"
   ClientHeight    =   2760
   ClientLeft      =   2760
   ClientTop       =   3750
   ClientWidth     =   8685
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   2760
   ScaleWidth      =   8685
   ShowInTaskbar   =   0   'False
   StartUpPosition =   2  'CenterScreen
   Begin VB.Frame Frame1 
      Caption         =   "Load Application"
      Height          =   2415
      Left            =   0
      TabIndex        =   2
      Top             =   120
      Width           =   7095
      Begin VB.TextBox StrAppNmaedlg 
         Enabled         =   0   'False
         Height          =   495
         Left            =   120
         TabIndex        =   6
         Text            =   "sf_car_xpc"
         Top             =   1560
         Width           =   6855
      End
      Begin VB.TextBox Dirpathdlg 
         Height          =   495
         Left            =   120
         TabIndex        =   5
         Top             =   600
         Width           =   6855
      End
      Begin VB.Label Label1 
         Caption         =   "Enter path of Target Direcotry"
         Height          =   255
         Index           =   0
         Left            =   120
         TabIndex        =   4
         Top             =   360
         Width           =   2295
      End
      Begin VB.Label Label1 
         Caption         =   "Enter Target App Name"
         Height          =   255
         Index           =   1
         Left            =   120
         TabIndex        =   3
         Top             =   1320
         Width           =   1935
      End
   End
   Begin VB.CommandButton CancelButton 
      Caption         =   "Cancel"
      Height          =   375
      Left            =   7200
      TabIndex        =   1
      Top             =   960
      Width           =   1215
   End
   Begin VB.CommandButton OKButton 
      Caption         =   "OK"
      Height          =   375
      Left            =   7200
      TabIndex        =   0
      Top             =   240
      Width           =   1215
   End
End
Attribute VB_Name = "LoadAppdlg"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Option Explicit

Private Sub CancelButton_Click()
    Unload Me
End Sub

Private Sub OKButton_Click()
   Call LoadAppctrlAction(LoadAppdlg.Dirpathdlg.Text, LoadAppdlg.StrAppNmaedlg.Text)
End Sub



