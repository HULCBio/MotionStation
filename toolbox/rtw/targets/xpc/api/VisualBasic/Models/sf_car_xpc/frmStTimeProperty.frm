VERSION 5.00
Begin VB.Form frmStTimeProperty 
   BorderStyle     =   4  'Fixed ToolWindow
   Caption         =   "Stop Time Property Value"
   ClientHeight    =   1215
   ClientLeft      =   2655
   ClientTop       =   3135
   ClientWidth     =   5400
   LinkTopic       =   "Form1"
   LockControls    =   -1  'True
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   1215
   ScaleWidth      =   5400
   ShowInTaskbar   =   0   'False
   StartUpPosition =   2  'CenterScreen
   Begin VB.TextBox txtPropValue 
      Height          =   300
      Left            =   135
      TabIndex        =   1
      Top             =   315
      Width           =   5070
   End
   Begin VB.CommandButton cmdCancel 
      Cancel          =   -1  'True
      Caption         =   "&Cancel"
      Height          =   360
      Left            =   3735
      TabIndex        =   3
      Top             =   720
      Width           =   1335
   End
   Begin VB.CommandButton cmdOK 
      Caption         =   "&OK"
      Default         =   -1  'True
      Height          =   360
      Left            =   2190
      TabIndex        =   2
      Top             =   720
      Width           =   1335
   End
   Begin VB.CheckBox chkPropValue 
      Caption         =   "Check1"
      Height          =   300
      Left            =   135
      TabIndex        =   4
      Top             =   315
      Width           =   5070
   End
   Begin VB.Label lblLabel 
      Caption         =   "&Enter Stop Time:"
      Height          =   225
      Left            =   135
      TabIndex        =   0
      Top             =   60
      Width           =   4365
   End
End
Attribute VB_Name = "frmStTimeProperty"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Private Sub cmdCancel_Click()
  OK = False
  Me.Hide
End Sub

Private Sub cmdOK_Click()
  Call xPCTargetobj1.SetStopTime(CDbl(frmStTimeProperty.txtPropValue.Text))
  MainWin.Label1(3).Caption = CStr(xPCTargetobj1.GetStopTime)
  Unload Me
End Sub

Private Sub Form_Load()
    frmStTimeProperty.txtPropValue.Text = CStr(xPCTargetobj1.GetStopTime)
End Sub
