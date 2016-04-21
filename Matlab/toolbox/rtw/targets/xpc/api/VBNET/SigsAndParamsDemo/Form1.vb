Public Class Form1
    Inherits System.Windows.Forms.Form

    'The XPCAPICOMLib has three objects, xPCProtocol, xPCTarget, and xPCScopes. 
    'In this form, we are only interested in xPCProtocol and xPCTarget. 
    'xPCProtocol for communication, xPCTarget to work with the target object. 

    Private com As XPCAPICOMLib.xPCProtocol
    Private tg As XPCAPICOMLib.xPCTarget



#Region " Windows Form Designer generated code "

    Public Sub New()
        MyBase.New()

        'This call is required by the Windows Form Designer.
        InitializeComponent()
        'Add any initialization after the InitializeComponent() call
    End Sub

    'Form overrides dispose to clean up the component list.
    Protected Overloads Overrides Sub Dispose(ByVal disposing As Boolean)
        If disposing Then
            If Not (components Is Nothing) Then
                components.Dispose()
            End If
        End If
        MyBase.Dispose(disposing)
    End Sub

    'Required by the Windows Form Designer
    Private components As System.ComponentModel.IContainer

    'NOTE: The following procedure is required by the Windows Form Designer
    'It can be modified using the Windows Form Designer.  
    'Do not modify it using the code editor.
    Friend WithEvents ListBox1 As System.Windows.Forms.ListBox
    Friend WithEvents Frame As System.Windows.Forms.GroupBox
    Friend WithEvents GroupBox1 As System.Windows.Forms.GroupBox
    Friend WithEvents Label1 As System.Windows.Forms.Label
    Friend WithEvents Label2 As System.Windows.Forms.Label
    Friend WithEvents Label3 As System.Windows.Forms.Label
    Friend WithEvents TextBox1 As System.Windows.Forms.TextBox
    Friend WithEvents Label5 As System.Windows.Forms.Label
    Friend WithEvents ListBox2 As System.Windows.Forms.ListBox
    Friend WithEvents rowUD As System.Windows.Forms.NumericUpDown
    Friend WithEvents GroupBox2 As System.Windows.Forms.GroupBox
    Friend WithEvents Label7 As System.Windows.Forms.Label
    Friend WithEvents Button3 As System.Windows.Forms.Button
    Friend WithEvents Label8 As System.Windows.Forms.Label
    Friend WithEvents Timer1 As System.Windows.Forms.Timer
    Friend WithEvents GroupBox4 As System.Windows.Forms.GroupBox
    Friend WithEvents GroupBox6 As System.Windows.Forms.GroupBox
    Friend WithEvents GroupBox5 As System.Windows.Forms.GroupBox
    Friend WithEvents GroupBox7 As System.Windows.Forms.GroupBox
    Friend WithEvents Label9 As System.Windows.Forms.Label
    Friend WithEvents Label10 As System.Windows.Forms.Label
    Friend WithEvents GroupBox8 As System.Windows.Forms.GroupBox
    Friend WithEvents tcpipRB As System.Windows.Forms.RadioButton
    Friend WithEvents rsRB As System.Windows.Forms.RadioButton
    Friend WithEvents com2RB As System.Windows.Forms.RadioButton
    Friend WithEvents com1RB As System.Windows.Forms.RadioButton
    Friend WithEvents ipaddressTB As System.Windows.Forms.TextBox
    Friend WithEvents ipportTB As System.Windows.Forms.TextBox
    Friend WithEvents startBTN As System.Windows.Forms.Button
    Friend WithEvents stopBTN As System.Windows.Forms.Button
    Friend WithEvents connectBTN As System.Windows.Forms.Button
    Friend WithEvents dcBTN As System.Windows.Forms.Button
    <System.Diagnostics.DebuggerStepThrough()> Private Sub InitializeComponent()
        Me.components = New System.ComponentModel.Container
        Dim resources As System.Resources.ResourceManager = New System.Resources.ResourceManager(GetType(Form1))
        Me.ListBox1 = New System.Windows.Forms.ListBox
        Me.connectBTN = New System.Windows.Forms.Button
        Me.Frame = New System.Windows.Forms.GroupBox
        Me.GroupBox2 = New System.Windows.Forms.GroupBox
        Me.rowUD = New System.Windows.Forms.NumericUpDown
        Me.Label5 = New System.Windows.Forms.Label
        Me.Label7 = New System.Windows.Forms.Label
        Me.TextBox1 = New System.Windows.Forms.TextBox
        Me.Button3 = New System.Windows.Forms.Button
        Me.GroupBox1 = New System.Windows.Forms.GroupBox
        Me.Label8 = New System.Windows.Forms.Label
        Me.ListBox2 = New System.Windows.Forms.ListBox
        Me.Label1 = New System.Windows.Forms.Label
        Me.Label2 = New System.Windows.Forms.Label
        Me.Label3 = New System.Windows.Forms.Label
        Me.startBTN = New System.Windows.Forms.Button
        Me.stopBTN = New System.Windows.Forms.Button
        Me.Timer1 = New System.Windows.Forms.Timer(Me.components)
        Me.GroupBox4 = New System.Windows.Forms.GroupBox
        Me.dcBTN = New System.Windows.Forms.Button
        Me.GroupBox8 = New System.Windows.Forms.GroupBox
        Me.com1RB = New System.Windows.Forms.RadioButton
        Me.com2RB = New System.Windows.Forms.RadioButton
        Me.GroupBox7 = New System.Windows.Forms.GroupBox
        Me.ipportTB = New System.Windows.Forms.TextBox
        Me.Label10 = New System.Windows.Forms.Label
        Me.Label9 = New System.Windows.Forms.Label
        Me.ipaddressTB = New System.Windows.Forms.TextBox
        Me.GroupBox5 = New System.Windows.Forms.GroupBox
        Me.tcpipRB = New System.Windows.Forms.RadioButton
        Me.rsRB = New System.Windows.Forms.RadioButton
        Me.GroupBox6 = New System.Windows.Forms.GroupBox
        Me.Frame.SuspendLayout()
        Me.GroupBox2.SuspendLayout()
        CType(Me.rowUD, System.ComponentModel.ISupportInitialize).BeginInit()
        Me.GroupBox1.SuspendLayout()
        Me.GroupBox4.SuspendLayout()
        Me.GroupBox8.SuspendLayout()
        Me.GroupBox7.SuspendLayout()
        Me.GroupBox5.SuspendLayout()
        Me.GroupBox6.SuspendLayout()
        Me.SuspendLayout()
        '
        'ListBox1
        '
        Me.ListBox1.AccessibleDescription = resources.GetString("ListBox1.AccessibleDescription")
        Me.ListBox1.AccessibleName = resources.GetString("ListBox1.AccessibleName")
        Me.ListBox1.Anchor = CType(resources.GetObject("ListBox1.Anchor"), System.Windows.Forms.AnchorStyles)
        Me.ListBox1.BackgroundImage = CType(resources.GetObject("ListBox1.BackgroundImage"), System.Drawing.Image)
        Me.ListBox1.ColumnWidth = CType(resources.GetObject("ListBox1.ColumnWidth"), Integer)
        Me.ListBox1.Dock = CType(resources.GetObject("ListBox1.Dock"), System.Windows.Forms.DockStyle)
        Me.ListBox1.Enabled = CType(resources.GetObject("ListBox1.Enabled"), Boolean)
        Me.ListBox1.Font = CType(resources.GetObject("ListBox1.Font"), System.Drawing.Font)
        Me.ListBox1.HorizontalExtent = CType(resources.GetObject("ListBox1.HorizontalExtent"), Integer)
        Me.ListBox1.HorizontalScrollbar = CType(resources.GetObject("ListBox1.HorizontalScrollbar"), Boolean)
        Me.ListBox1.ImeMode = CType(resources.GetObject("ListBox1.ImeMode"), System.Windows.Forms.ImeMode)
        Me.ListBox1.IntegralHeight = CType(resources.GetObject("ListBox1.IntegralHeight"), Boolean)
        Me.ListBox1.ItemHeight = CType(resources.GetObject("ListBox1.ItemHeight"), Integer)
        Me.ListBox1.Location = CType(resources.GetObject("ListBox1.Location"), System.Drawing.Point)
        Me.ListBox1.Name = "ListBox1"
        Me.ListBox1.RightToLeft = CType(resources.GetObject("ListBox1.RightToLeft"), System.Windows.Forms.RightToLeft)
        Me.ListBox1.ScrollAlwaysVisible = CType(resources.GetObject("ListBox1.ScrollAlwaysVisible"), Boolean)
        Me.ListBox1.Size = CType(resources.GetObject("ListBox1.Size"), System.Drawing.Size)
        Me.ListBox1.TabIndex = CType(resources.GetObject("ListBox1.TabIndex"), Integer)
        Me.ListBox1.Visible = CType(resources.GetObject("ListBox1.Visible"), Boolean)
        '
        'connectBTN
        '
        Me.connectBTN.AccessibleDescription = resources.GetString("connectBTN.AccessibleDescription")
        Me.connectBTN.AccessibleName = resources.GetString("connectBTN.AccessibleName")
        Me.connectBTN.Anchor = CType(resources.GetObject("connectBTN.Anchor"), System.Windows.Forms.AnchorStyles)
        Me.connectBTN.BackgroundImage = CType(resources.GetObject("connectBTN.BackgroundImage"), System.Drawing.Image)
        Me.connectBTN.Dock = CType(resources.GetObject("connectBTN.Dock"), System.Windows.Forms.DockStyle)
        Me.connectBTN.Enabled = CType(resources.GetObject("connectBTN.Enabled"), Boolean)
        Me.connectBTN.FlatStyle = CType(resources.GetObject("connectBTN.FlatStyle"), System.Windows.Forms.FlatStyle)
        Me.connectBTN.Font = CType(resources.GetObject("connectBTN.Font"), System.Drawing.Font)
        Me.connectBTN.Image = CType(resources.GetObject("connectBTN.Image"), System.Drawing.Image)
        Me.connectBTN.ImageAlign = CType(resources.GetObject("connectBTN.ImageAlign"), System.Drawing.ContentAlignment)
        Me.connectBTN.ImageIndex = CType(resources.GetObject("connectBTN.ImageIndex"), Integer)
        Me.connectBTN.ImeMode = CType(resources.GetObject("connectBTN.ImeMode"), System.Windows.Forms.ImeMode)
        Me.connectBTN.Location = CType(resources.GetObject("connectBTN.Location"), System.Drawing.Point)
        Me.connectBTN.Name = "connectBTN"
        Me.connectBTN.RightToLeft = CType(resources.GetObject("connectBTN.RightToLeft"), System.Windows.Forms.RightToLeft)
        Me.connectBTN.Size = CType(resources.GetObject("connectBTN.Size"), System.Drawing.Size)
        Me.connectBTN.TabIndex = CType(resources.GetObject("connectBTN.TabIndex"), Integer)
        Me.connectBTN.Text = resources.GetString("connectBTN.Text")
        Me.connectBTN.TextAlign = CType(resources.GetObject("connectBTN.TextAlign"), System.Drawing.ContentAlignment)
        Me.connectBTN.Visible = CType(resources.GetObject("connectBTN.Visible"), Boolean)
        '
        'Frame
        '
        Me.Frame.AccessibleDescription = resources.GetString("Frame.AccessibleDescription")
        Me.Frame.AccessibleName = resources.GetString("Frame.AccessibleName")
        Me.Frame.Anchor = CType(resources.GetObject("Frame.Anchor"), System.Windows.Forms.AnchorStyles)
        Me.Frame.BackgroundImage = CType(resources.GetObject("Frame.BackgroundImage"), System.Drawing.Image)
        Me.Frame.Controls.Add(Me.GroupBox2)
        Me.Frame.Controls.Add(Me.ListBox1)
        Me.Frame.Dock = CType(resources.GetObject("Frame.Dock"), System.Windows.Forms.DockStyle)
        Me.Frame.Enabled = CType(resources.GetObject("Frame.Enabled"), Boolean)
        Me.Frame.Font = CType(resources.GetObject("Frame.Font"), System.Drawing.Font)
        Me.Frame.ImeMode = CType(resources.GetObject("Frame.ImeMode"), System.Windows.Forms.ImeMode)
        Me.Frame.Location = CType(resources.GetObject("Frame.Location"), System.Drawing.Point)
        Me.Frame.Name = "Frame"
        Me.Frame.RightToLeft = CType(resources.GetObject("Frame.RightToLeft"), System.Windows.Forms.RightToLeft)
        Me.Frame.Size = CType(resources.GetObject("Frame.Size"), System.Drawing.Size)
        Me.Frame.TabIndex = CType(resources.GetObject("Frame.TabIndex"), Integer)
        Me.Frame.TabStop = False
        Me.Frame.Text = resources.GetString("Frame.Text")
        Me.Frame.Visible = CType(resources.GetObject("Frame.Visible"), Boolean)
        '
        'GroupBox2
        '
        Me.GroupBox2.AccessibleDescription = resources.GetString("GroupBox2.AccessibleDescription")
        Me.GroupBox2.AccessibleName = resources.GetString("GroupBox2.AccessibleName")
        Me.GroupBox2.Anchor = CType(resources.GetObject("GroupBox2.Anchor"), System.Windows.Forms.AnchorStyles)
        Me.GroupBox2.BackgroundImage = CType(resources.GetObject("GroupBox2.BackgroundImage"), System.Drawing.Image)
        Me.GroupBox2.Controls.Add(Me.rowUD)
        Me.GroupBox2.Controls.Add(Me.Label5)
        Me.GroupBox2.Controls.Add(Me.Label7)
        Me.GroupBox2.Controls.Add(Me.TextBox1)
        Me.GroupBox2.Controls.Add(Me.Button3)
        Me.GroupBox2.Dock = CType(resources.GetObject("GroupBox2.Dock"), System.Windows.Forms.DockStyle)
        Me.GroupBox2.Enabled = CType(resources.GetObject("GroupBox2.Enabled"), Boolean)
        Me.GroupBox2.Font = CType(resources.GetObject("GroupBox2.Font"), System.Drawing.Font)
        Me.GroupBox2.ImeMode = CType(resources.GetObject("GroupBox2.ImeMode"), System.Windows.Forms.ImeMode)
        Me.GroupBox2.Location = CType(resources.GetObject("GroupBox2.Location"), System.Drawing.Point)
        Me.GroupBox2.Name = "GroupBox2"
        Me.GroupBox2.RightToLeft = CType(resources.GetObject("GroupBox2.RightToLeft"), System.Windows.Forms.RightToLeft)
        Me.GroupBox2.Size = CType(resources.GetObject("GroupBox2.Size"), System.Drawing.Size)
        Me.GroupBox2.TabIndex = CType(resources.GetObject("GroupBox2.TabIndex"), Integer)
        Me.GroupBox2.TabStop = False
        Me.GroupBox2.Text = resources.GetString("GroupBox2.Text")
        Me.GroupBox2.Visible = CType(resources.GetObject("GroupBox2.Visible"), Boolean)
        '
        'rowUD
        '
        Me.rowUD.AccessibleDescription = resources.GetString("rowUD.AccessibleDescription")
        Me.rowUD.AccessibleName = resources.GetString("rowUD.AccessibleName")
        Me.rowUD.Anchor = CType(resources.GetObject("rowUD.Anchor"), System.Windows.Forms.AnchorStyles)
        Me.rowUD.Dock = CType(resources.GetObject("rowUD.Dock"), System.Windows.Forms.DockStyle)
        Me.rowUD.Enabled = CType(resources.GetObject("rowUD.Enabled"), Boolean)
        Me.rowUD.Font = CType(resources.GetObject("rowUD.Font"), System.Drawing.Font)
        Me.rowUD.ImeMode = CType(resources.GetObject("rowUD.ImeMode"), System.Windows.Forms.ImeMode)
        Me.rowUD.Location = CType(resources.GetObject("rowUD.Location"), System.Drawing.Point)
        Me.rowUD.Name = "rowUD"
        Me.rowUD.RightToLeft = CType(resources.GetObject("rowUD.RightToLeft"), System.Windows.Forms.RightToLeft)
        Me.rowUD.Size = CType(resources.GetObject("rowUD.Size"), System.Drawing.Size)
        Me.rowUD.TabIndex = CType(resources.GetObject("rowUD.TabIndex"), Integer)
        Me.rowUD.TextAlign = CType(resources.GetObject("rowUD.TextAlign"), System.Windows.Forms.HorizontalAlignment)
        Me.rowUD.ThousandsSeparator = CType(resources.GetObject("rowUD.ThousandsSeparator"), Boolean)
        Me.rowUD.UpDownAlign = CType(resources.GetObject("rowUD.UpDownAlign"), System.Windows.Forms.LeftRightAlignment)
        Me.rowUD.Value = New Decimal(New Integer() {1, 0, 0, 0})
        Me.rowUD.Visible = CType(resources.GetObject("rowUD.Visible"), Boolean)
        '
        'Label5
        '
        Me.Label5.AccessibleDescription = resources.GetString("Label5.AccessibleDescription")
        Me.Label5.AccessibleName = resources.GetString("Label5.AccessibleName")
        Me.Label5.Anchor = CType(resources.GetObject("Label5.Anchor"), System.Windows.Forms.AnchorStyles)
        Me.Label5.AutoSize = CType(resources.GetObject("Label5.AutoSize"), Boolean)
        Me.Label5.Dock = CType(resources.GetObject("Label5.Dock"), System.Windows.Forms.DockStyle)
        Me.Label5.Enabled = CType(resources.GetObject("Label5.Enabled"), Boolean)
        Me.Label5.Font = CType(resources.GetObject("Label5.Font"), System.Drawing.Font)
        Me.Label5.Image = CType(resources.GetObject("Label5.Image"), System.Drawing.Image)
        Me.Label5.ImageAlign = CType(resources.GetObject("Label5.ImageAlign"), System.Drawing.ContentAlignment)
        Me.Label5.ImageIndex = CType(resources.GetObject("Label5.ImageIndex"), Integer)
        Me.Label5.ImeMode = CType(resources.GetObject("Label5.ImeMode"), System.Windows.Forms.ImeMode)
        Me.Label5.Location = CType(resources.GetObject("Label5.Location"), System.Drawing.Point)
        Me.Label5.Name = "Label5"
        Me.Label5.RightToLeft = CType(resources.GetObject("Label5.RightToLeft"), System.Windows.Forms.RightToLeft)
        Me.Label5.Size = CType(resources.GetObject("Label5.Size"), System.Drawing.Size)
        Me.Label5.TabIndex = CType(resources.GetObject("Label5.TabIndex"), Integer)
        Me.Label5.Text = resources.GetString("Label5.Text")
        Me.Label5.TextAlign = CType(resources.GetObject("Label5.TextAlign"), System.Drawing.ContentAlignment)
        Me.Label5.Visible = CType(resources.GetObject("Label5.Visible"), Boolean)
        '
        'Label7
        '
        Me.Label7.AccessibleDescription = resources.GetString("Label7.AccessibleDescription")
        Me.Label7.AccessibleName = resources.GetString("Label7.AccessibleName")
        Me.Label7.Anchor = CType(resources.GetObject("Label7.Anchor"), System.Windows.Forms.AnchorStyles)
        Me.Label7.AutoSize = CType(resources.GetObject("Label7.AutoSize"), Boolean)
        Me.Label7.Dock = CType(resources.GetObject("Label7.Dock"), System.Windows.Forms.DockStyle)
        Me.Label7.Enabled = CType(resources.GetObject("Label7.Enabled"), Boolean)
        Me.Label7.Font = CType(resources.GetObject("Label7.Font"), System.Drawing.Font)
        Me.Label7.Image = CType(resources.GetObject("Label7.Image"), System.Drawing.Image)
        Me.Label7.ImageAlign = CType(resources.GetObject("Label7.ImageAlign"), System.Drawing.ContentAlignment)
        Me.Label7.ImageIndex = CType(resources.GetObject("Label7.ImageIndex"), Integer)
        Me.Label7.ImeMode = CType(resources.GetObject("Label7.ImeMode"), System.Windows.Forms.ImeMode)
        Me.Label7.Location = CType(resources.GetObject("Label7.Location"), System.Drawing.Point)
        Me.Label7.Name = "Label7"
        Me.Label7.RightToLeft = CType(resources.GetObject("Label7.RightToLeft"), System.Windows.Forms.RightToLeft)
        Me.Label7.Size = CType(resources.GetObject("Label7.Size"), System.Drawing.Size)
        Me.Label7.TabIndex = CType(resources.GetObject("Label7.TabIndex"), Integer)
        Me.Label7.Text = resources.GetString("Label7.Text")
        Me.Label7.TextAlign = CType(resources.GetObject("Label7.TextAlign"), System.Drawing.ContentAlignment)
        Me.Label7.Visible = CType(resources.GetObject("Label7.Visible"), Boolean)
        '
        'TextBox1
        '
        Me.TextBox1.AccessibleDescription = resources.GetString("TextBox1.AccessibleDescription")
        Me.TextBox1.AccessibleName = resources.GetString("TextBox1.AccessibleName")
        Me.TextBox1.Anchor = CType(resources.GetObject("TextBox1.Anchor"), System.Windows.Forms.AnchorStyles)
        Me.TextBox1.AutoSize = CType(resources.GetObject("TextBox1.AutoSize"), Boolean)
        Me.TextBox1.BackgroundImage = CType(resources.GetObject("TextBox1.BackgroundImage"), System.Drawing.Image)
        Me.TextBox1.Dock = CType(resources.GetObject("TextBox1.Dock"), System.Windows.Forms.DockStyle)
        Me.TextBox1.Enabled = CType(resources.GetObject("TextBox1.Enabled"), Boolean)
        Me.TextBox1.Font = CType(resources.GetObject("TextBox1.Font"), System.Drawing.Font)
        Me.TextBox1.ImeMode = CType(resources.GetObject("TextBox1.ImeMode"), System.Windows.Forms.ImeMode)
        Me.TextBox1.Location = CType(resources.GetObject("TextBox1.Location"), System.Drawing.Point)
        Me.TextBox1.MaxLength = CType(resources.GetObject("TextBox1.MaxLength"), Integer)
        Me.TextBox1.Multiline = CType(resources.GetObject("TextBox1.Multiline"), Boolean)
        Me.TextBox1.Name = "TextBox1"
        Me.TextBox1.PasswordChar = CType(resources.GetObject("TextBox1.PasswordChar"), Char)
        Me.TextBox1.RightToLeft = CType(resources.GetObject("TextBox1.RightToLeft"), System.Windows.Forms.RightToLeft)
        Me.TextBox1.ScrollBars = CType(resources.GetObject("TextBox1.ScrollBars"), System.Windows.Forms.ScrollBars)
        Me.TextBox1.Size = CType(resources.GetObject("TextBox1.Size"), System.Drawing.Size)
        Me.TextBox1.TabIndex = CType(resources.GetObject("TextBox1.TabIndex"), Integer)
        Me.TextBox1.Text = resources.GetString("TextBox1.Text")
        Me.TextBox1.TextAlign = CType(resources.GetObject("TextBox1.TextAlign"), System.Windows.Forms.HorizontalAlignment)
        Me.TextBox1.Visible = CType(resources.GetObject("TextBox1.Visible"), Boolean)
        Me.TextBox1.WordWrap = CType(resources.GetObject("TextBox1.WordWrap"), Boolean)
        '
        'Button3
        '
        Me.Button3.AccessibleDescription = resources.GetString("Button3.AccessibleDescription")
        Me.Button3.AccessibleName = resources.GetString("Button3.AccessibleName")
        Me.Button3.Anchor = CType(resources.GetObject("Button3.Anchor"), System.Windows.Forms.AnchorStyles)
        Me.Button3.BackgroundImage = CType(resources.GetObject("Button3.BackgroundImage"), System.Drawing.Image)
        Me.Button3.Dock = CType(resources.GetObject("Button3.Dock"), System.Windows.Forms.DockStyle)
        Me.Button3.Enabled = CType(resources.GetObject("Button3.Enabled"), Boolean)
        Me.Button3.FlatStyle = CType(resources.GetObject("Button3.FlatStyle"), System.Windows.Forms.FlatStyle)
        Me.Button3.Font = CType(resources.GetObject("Button3.Font"), System.Drawing.Font)
        Me.Button3.Image = CType(resources.GetObject("Button3.Image"), System.Drawing.Image)
        Me.Button3.ImageAlign = CType(resources.GetObject("Button3.ImageAlign"), System.Drawing.ContentAlignment)
        Me.Button3.ImageIndex = CType(resources.GetObject("Button3.ImageIndex"), Integer)
        Me.Button3.ImeMode = CType(resources.GetObject("Button3.ImeMode"), System.Windows.Forms.ImeMode)
        Me.Button3.Location = CType(resources.GetObject("Button3.Location"), System.Drawing.Point)
        Me.Button3.Name = "Button3"
        Me.Button3.RightToLeft = CType(resources.GetObject("Button3.RightToLeft"), System.Windows.Forms.RightToLeft)
        Me.Button3.Size = CType(resources.GetObject("Button3.Size"), System.Drawing.Size)
        Me.Button3.TabIndex = CType(resources.GetObject("Button3.TabIndex"), Integer)
        Me.Button3.Text = resources.GetString("Button3.Text")
        Me.Button3.TextAlign = CType(resources.GetObject("Button3.TextAlign"), System.Drawing.ContentAlignment)
        Me.Button3.Visible = CType(resources.GetObject("Button3.Visible"), Boolean)
        '
        'GroupBox1
        '
        Me.GroupBox1.AccessibleDescription = resources.GetString("GroupBox1.AccessibleDescription")
        Me.GroupBox1.AccessibleName = resources.GetString("GroupBox1.AccessibleName")
        Me.GroupBox1.Anchor = CType(resources.GetObject("GroupBox1.Anchor"), System.Windows.Forms.AnchorStyles)
        Me.GroupBox1.BackgroundImage = CType(resources.GetObject("GroupBox1.BackgroundImage"), System.Drawing.Image)
        Me.GroupBox1.Controls.Add(Me.Label8)
        Me.GroupBox1.Controls.Add(Me.ListBox2)
        Me.GroupBox1.Controls.Add(Me.Label1)
        Me.GroupBox1.Dock = CType(resources.GetObject("GroupBox1.Dock"), System.Windows.Forms.DockStyle)
        Me.GroupBox1.Enabled = CType(resources.GetObject("GroupBox1.Enabled"), Boolean)
        Me.GroupBox1.Font = CType(resources.GetObject("GroupBox1.Font"), System.Drawing.Font)
        Me.GroupBox1.ImeMode = CType(resources.GetObject("GroupBox1.ImeMode"), System.Windows.Forms.ImeMode)
        Me.GroupBox1.Location = CType(resources.GetObject("GroupBox1.Location"), System.Drawing.Point)
        Me.GroupBox1.Name = "GroupBox1"
        Me.GroupBox1.RightToLeft = CType(resources.GetObject("GroupBox1.RightToLeft"), System.Windows.Forms.RightToLeft)
        Me.GroupBox1.Size = CType(resources.GetObject("GroupBox1.Size"), System.Drawing.Size)
        Me.GroupBox1.TabIndex = CType(resources.GetObject("GroupBox1.TabIndex"), Integer)
        Me.GroupBox1.TabStop = False
        Me.GroupBox1.Text = resources.GetString("GroupBox1.Text")
        Me.GroupBox1.Visible = CType(resources.GetObject("GroupBox1.Visible"), Boolean)
        '
        'Label8
        '
        Me.Label8.AccessibleDescription = resources.GetString("Label8.AccessibleDescription")
        Me.Label8.AccessibleName = resources.GetString("Label8.AccessibleName")
        Me.Label8.Anchor = CType(resources.GetObject("Label8.Anchor"), System.Windows.Forms.AnchorStyles)
        Me.Label8.AutoSize = CType(resources.GetObject("Label8.AutoSize"), Boolean)
        Me.Label8.BackColor = System.Drawing.SystemColors.Control
        Me.Label8.Dock = CType(resources.GetObject("Label8.Dock"), System.Windows.Forms.DockStyle)
        Me.Label8.Enabled = CType(resources.GetObject("Label8.Enabled"), Boolean)
        Me.Label8.Font = CType(resources.GetObject("Label8.Font"), System.Drawing.Font)
        Me.Label8.ForeColor = System.Drawing.SystemColors.ControlText
        Me.Label8.Image = CType(resources.GetObject("Label8.Image"), System.Drawing.Image)
        Me.Label8.ImageAlign = CType(resources.GetObject("Label8.ImageAlign"), System.Drawing.ContentAlignment)
        Me.Label8.ImageIndex = CType(resources.GetObject("Label8.ImageIndex"), Integer)
        Me.Label8.ImeMode = CType(resources.GetObject("Label8.ImeMode"), System.Windows.Forms.ImeMode)
        Me.Label8.Location = CType(resources.GetObject("Label8.Location"), System.Drawing.Point)
        Me.Label8.Name = "Label8"
        Me.Label8.RightToLeft = CType(resources.GetObject("Label8.RightToLeft"), System.Windows.Forms.RightToLeft)
        Me.Label8.Size = CType(resources.GetObject("Label8.Size"), System.Drawing.Size)
        Me.Label8.TabIndex = CType(resources.GetObject("Label8.TabIndex"), Integer)
        Me.Label8.Text = resources.GetString("Label8.Text")
        Me.Label8.TextAlign = CType(resources.GetObject("Label8.TextAlign"), System.Drawing.ContentAlignment)
        Me.Label8.Visible = CType(resources.GetObject("Label8.Visible"), Boolean)
        '
        'ListBox2
        '
        Me.ListBox2.AccessibleDescription = resources.GetString("ListBox2.AccessibleDescription")
        Me.ListBox2.AccessibleName = resources.GetString("ListBox2.AccessibleName")
        Me.ListBox2.Anchor = CType(resources.GetObject("ListBox2.Anchor"), System.Windows.Forms.AnchorStyles)
        Me.ListBox2.BackgroundImage = CType(resources.GetObject("ListBox2.BackgroundImage"), System.Drawing.Image)
        Me.ListBox2.ColumnWidth = CType(resources.GetObject("ListBox2.ColumnWidth"), Integer)
        Me.ListBox2.Dock = CType(resources.GetObject("ListBox2.Dock"), System.Windows.Forms.DockStyle)
        Me.ListBox2.Enabled = CType(resources.GetObject("ListBox2.Enabled"), Boolean)
        Me.ListBox2.Font = CType(resources.GetObject("ListBox2.Font"), System.Drawing.Font)
        Me.ListBox2.HorizontalExtent = CType(resources.GetObject("ListBox2.HorizontalExtent"), Integer)
        Me.ListBox2.HorizontalScrollbar = CType(resources.GetObject("ListBox2.HorizontalScrollbar"), Boolean)
        Me.ListBox2.ImeMode = CType(resources.GetObject("ListBox2.ImeMode"), System.Windows.Forms.ImeMode)
        Me.ListBox2.IntegralHeight = CType(resources.GetObject("ListBox2.IntegralHeight"), Boolean)
        Me.ListBox2.ItemHeight = CType(resources.GetObject("ListBox2.ItemHeight"), Integer)
        Me.ListBox2.Location = CType(resources.GetObject("ListBox2.Location"), System.Drawing.Point)
        Me.ListBox2.Name = "ListBox2"
        Me.ListBox2.RightToLeft = CType(resources.GetObject("ListBox2.RightToLeft"), System.Windows.Forms.RightToLeft)
        Me.ListBox2.ScrollAlwaysVisible = CType(resources.GetObject("ListBox2.ScrollAlwaysVisible"), Boolean)
        Me.ListBox2.Size = CType(resources.GetObject("ListBox2.Size"), System.Drawing.Size)
        Me.ListBox2.TabIndex = CType(resources.GetObject("ListBox2.TabIndex"), Integer)
        Me.ListBox2.Visible = CType(resources.GetObject("ListBox2.Visible"), Boolean)
        '
        'Label1
        '
        Me.Label1.AccessibleDescription = resources.GetString("Label1.AccessibleDescription")
        Me.Label1.AccessibleName = resources.GetString("Label1.AccessibleName")
        Me.Label1.Anchor = CType(resources.GetObject("Label1.Anchor"), System.Windows.Forms.AnchorStyles)
        Me.Label1.AutoSize = CType(resources.GetObject("Label1.AutoSize"), Boolean)
        Me.Label1.BackColor = System.Drawing.SystemColors.Control
        Me.Label1.Dock = CType(resources.GetObject("Label1.Dock"), System.Windows.Forms.DockStyle)
        Me.Label1.Enabled = CType(resources.GetObject("Label1.Enabled"), Boolean)
        Me.Label1.Font = CType(resources.GetObject("Label1.Font"), System.Drawing.Font)
        Me.Label1.Image = CType(resources.GetObject("Label1.Image"), System.Drawing.Image)
        Me.Label1.ImageAlign = CType(resources.GetObject("Label1.ImageAlign"), System.Drawing.ContentAlignment)
        Me.Label1.ImageIndex = CType(resources.GetObject("Label1.ImageIndex"), Integer)
        Me.Label1.ImeMode = CType(resources.GetObject("Label1.ImeMode"), System.Windows.Forms.ImeMode)
        Me.Label1.Location = CType(resources.GetObject("Label1.Location"), System.Drawing.Point)
        Me.Label1.Name = "Label1"
        Me.Label1.RightToLeft = CType(resources.GetObject("Label1.RightToLeft"), System.Windows.Forms.RightToLeft)
        Me.Label1.Size = CType(resources.GetObject("Label1.Size"), System.Drawing.Size)
        Me.Label1.TabIndex = CType(resources.GetObject("Label1.TabIndex"), Integer)
        Me.Label1.Text = resources.GetString("Label1.Text")
        Me.Label1.TextAlign = CType(resources.GetObject("Label1.TextAlign"), System.Drawing.ContentAlignment)
        Me.Label1.Visible = CType(resources.GetObject("Label1.Visible"), Boolean)
        '
        'Label2
        '
        Me.Label2.AccessibleDescription = resources.GetString("Label2.AccessibleDescription")
        Me.Label2.AccessibleName = resources.GetString("Label2.AccessibleName")
        Me.Label2.Anchor = CType(resources.GetObject("Label2.Anchor"), System.Windows.Forms.AnchorStyles)
        Me.Label2.AutoSize = CType(resources.GetObject("Label2.AutoSize"), Boolean)
        Me.Label2.BackColor = System.Drawing.Color.White
        Me.Label2.Dock = CType(resources.GetObject("Label2.Dock"), System.Windows.Forms.DockStyle)
        Me.Label2.Enabled = CType(resources.GetObject("Label2.Enabled"), Boolean)
        Me.Label2.Font = CType(resources.GetObject("Label2.Font"), System.Drawing.Font)
        Me.Label2.Image = CType(resources.GetObject("Label2.Image"), System.Drawing.Image)
        Me.Label2.ImageAlign = CType(resources.GetObject("Label2.ImageAlign"), System.Drawing.ContentAlignment)
        Me.Label2.ImageIndex = CType(resources.GetObject("Label2.ImageIndex"), Integer)
        Me.Label2.ImeMode = CType(resources.GetObject("Label2.ImeMode"), System.Windows.Forms.ImeMode)
        Me.Label2.Location = CType(resources.GetObject("Label2.Location"), System.Drawing.Point)
        Me.Label2.Name = "Label2"
        Me.Label2.RightToLeft = CType(resources.GetObject("Label2.RightToLeft"), System.Windows.Forms.RightToLeft)
        Me.Label2.Size = CType(resources.GetObject("Label2.Size"), System.Drawing.Size)
        Me.Label2.TabIndex = CType(resources.GetObject("Label2.TabIndex"), Integer)
        Me.Label2.Text = resources.GetString("Label2.Text")
        Me.Label2.TextAlign = CType(resources.GetObject("Label2.TextAlign"), System.Drawing.ContentAlignment)
        Me.Label2.Visible = CType(resources.GetObject("Label2.Visible"), Boolean)
        '
        'Label3
        '
        Me.Label3.AccessibleDescription = resources.GetString("Label3.AccessibleDescription")
        Me.Label3.AccessibleName = resources.GetString("Label3.AccessibleName")
        Me.Label3.Anchor = CType(resources.GetObject("Label3.Anchor"), System.Windows.Forms.AnchorStyles)
        Me.Label3.AutoSize = CType(resources.GetObject("Label3.AutoSize"), Boolean)
        Me.Label3.Dock = CType(resources.GetObject("Label3.Dock"), System.Windows.Forms.DockStyle)
        Me.Label3.Enabled = CType(resources.GetObject("Label3.Enabled"), Boolean)
        Me.Label3.Font = CType(resources.GetObject("Label3.Font"), System.Drawing.Font)
        Me.Label3.Image = CType(resources.GetObject("Label3.Image"), System.Drawing.Image)
        Me.Label3.ImageAlign = CType(resources.GetObject("Label3.ImageAlign"), System.Drawing.ContentAlignment)
        Me.Label3.ImageIndex = CType(resources.GetObject("Label3.ImageIndex"), Integer)
        Me.Label3.ImeMode = CType(resources.GetObject("Label3.ImeMode"), System.Windows.Forms.ImeMode)
        Me.Label3.Location = CType(resources.GetObject("Label3.Location"), System.Drawing.Point)
        Me.Label3.Name = "Label3"
        Me.Label3.RightToLeft = CType(resources.GetObject("Label3.RightToLeft"), System.Windows.Forms.RightToLeft)
        Me.Label3.Size = CType(resources.GetObject("Label3.Size"), System.Drawing.Size)
        Me.Label3.TabIndex = CType(resources.GetObject("Label3.TabIndex"), Integer)
        Me.Label3.Text = resources.GetString("Label3.Text")
        Me.Label3.TextAlign = CType(resources.GetObject("Label3.TextAlign"), System.Drawing.ContentAlignment)
        Me.Label3.Visible = CType(resources.GetObject("Label3.Visible"), Boolean)
        '
        'startBTN
        '
        Me.startBTN.AccessibleDescription = resources.GetString("startBTN.AccessibleDescription")
        Me.startBTN.AccessibleName = resources.GetString("startBTN.AccessibleName")
        Me.startBTN.Anchor = CType(resources.GetObject("startBTN.Anchor"), System.Windows.Forms.AnchorStyles)
        Me.startBTN.BackgroundImage = CType(resources.GetObject("startBTN.BackgroundImage"), System.Drawing.Image)
        Me.startBTN.Dock = CType(resources.GetObject("startBTN.Dock"), System.Windows.Forms.DockStyle)
        Me.startBTN.Enabled = CType(resources.GetObject("startBTN.Enabled"), Boolean)
        Me.startBTN.FlatStyle = CType(resources.GetObject("startBTN.FlatStyle"), System.Windows.Forms.FlatStyle)
        Me.startBTN.Font = CType(resources.GetObject("startBTN.Font"), System.Drawing.Font)
        Me.startBTN.Image = CType(resources.GetObject("startBTN.Image"), System.Drawing.Image)
        Me.startBTN.ImageAlign = CType(resources.GetObject("startBTN.ImageAlign"), System.Drawing.ContentAlignment)
        Me.startBTN.ImageIndex = CType(resources.GetObject("startBTN.ImageIndex"), Integer)
        Me.startBTN.ImeMode = CType(resources.GetObject("startBTN.ImeMode"), System.Windows.Forms.ImeMode)
        Me.startBTN.Location = CType(resources.GetObject("startBTN.Location"), System.Drawing.Point)
        Me.startBTN.Name = "startBTN"
        Me.startBTN.RightToLeft = CType(resources.GetObject("startBTN.RightToLeft"), System.Windows.Forms.RightToLeft)
        Me.startBTN.Size = CType(resources.GetObject("startBTN.Size"), System.Drawing.Size)
        Me.startBTN.TabIndex = CType(resources.GetObject("startBTN.TabIndex"), Integer)
        Me.startBTN.Text = resources.GetString("startBTN.Text")
        Me.startBTN.TextAlign = CType(resources.GetObject("startBTN.TextAlign"), System.Drawing.ContentAlignment)
        Me.startBTN.Visible = CType(resources.GetObject("startBTN.Visible"), Boolean)
        '
        'stopBTN
        '
        Me.stopBTN.AccessibleDescription = resources.GetString("stopBTN.AccessibleDescription")
        Me.stopBTN.AccessibleName = resources.GetString("stopBTN.AccessibleName")
        Me.stopBTN.Anchor = CType(resources.GetObject("stopBTN.Anchor"), System.Windows.Forms.AnchorStyles)
        Me.stopBTN.BackgroundImage = CType(resources.GetObject("stopBTN.BackgroundImage"), System.Drawing.Image)
        Me.stopBTN.Dock = CType(resources.GetObject("stopBTN.Dock"), System.Windows.Forms.DockStyle)
        Me.stopBTN.Enabled = CType(resources.GetObject("stopBTN.Enabled"), Boolean)
        Me.stopBTN.FlatStyle = CType(resources.GetObject("stopBTN.FlatStyle"), System.Windows.Forms.FlatStyle)
        Me.stopBTN.Font = CType(resources.GetObject("stopBTN.Font"), System.Drawing.Font)
        Me.stopBTN.Image = CType(resources.GetObject("stopBTN.Image"), System.Drawing.Image)
        Me.stopBTN.ImageAlign = CType(resources.GetObject("stopBTN.ImageAlign"), System.Drawing.ContentAlignment)
        Me.stopBTN.ImageIndex = CType(resources.GetObject("stopBTN.ImageIndex"), Integer)
        Me.stopBTN.ImeMode = CType(resources.GetObject("stopBTN.ImeMode"), System.Windows.Forms.ImeMode)
        Me.stopBTN.Location = CType(resources.GetObject("stopBTN.Location"), System.Drawing.Point)
        Me.stopBTN.Name = "stopBTN"
        Me.stopBTN.RightToLeft = CType(resources.GetObject("stopBTN.RightToLeft"), System.Windows.Forms.RightToLeft)
        Me.stopBTN.Size = CType(resources.GetObject("stopBTN.Size"), System.Drawing.Size)
        Me.stopBTN.TabIndex = CType(resources.GetObject("stopBTN.TabIndex"), Integer)
        Me.stopBTN.Text = resources.GetString("stopBTN.Text")
        Me.stopBTN.TextAlign = CType(resources.GetObject("stopBTN.TextAlign"), System.Drawing.ContentAlignment)
        Me.stopBTN.Visible = CType(resources.GetObject("stopBTN.Visible"), Boolean)
        '
        'Timer1
        '
        '
        'GroupBox4
        '
        Me.GroupBox4.AccessibleDescription = resources.GetString("GroupBox4.AccessibleDescription")
        Me.GroupBox4.AccessibleName = resources.GetString("GroupBox4.AccessibleName")
        Me.GroupBox4.Anchor = CType(resources.GetObject("GroupBox4.Anchor"), System.Windows.Forms.AnchorStyles)
        Me.GroupBox4.BackgroundImage = CType(resources.GetObject("GroupBox4.BackgroundImage"), System.Drawing.Image)
        Me.GroupBox4.Controls.Add(Me.dcBTN)
        Me.GroupBox4.Controls.Add(Me.GroupBox8)
        Me.GroupBox4.Controls.Add(Me.GroupBox7)
        Me.GroupBox4.Controls.Add(Me.GroupBox5)
        Me.GroupBox4.Controls.Add(Me.connectBTN)
        Me.GroupBox4.Dock = CType(resources.GetObject("GroupBox4.Dock"), System.Windows.Forms.DockStyle)
        Me.GroupBox4.Enabled = CType(resources.GetObject("GroupBox4.Enabled"), Boolean)
        Me.GroupBox4.Font = CType(resources.GetObject("GroupBox4.Font"), System.Drawing.Font)
        Me.GroupBox4.ImeMode = CType(resources.GetObject("GroupBox4.ImeMode"), System.Windows.Forms.ImeMode)
        Me.GroupBox4.Location = CType(resources.GetObject("GroupBox4.Location"), System.Drawing.Point)
        Me.GroupBox4.Name = "GroupBox4"
        Me.GroupBox4.RightToLeft = CType(resources.GetObject("GroupBox4.RightToLeft"), System.Windows.Forms.RightToLeft)
        Me.GroupBox4.Size = CType(resources.GetObject("GroupBox4.Size"), System.Drawing.Size)
        Me.GroupBox4.TabIndex = CType(resources.GetObject("GroupBox4.TabIndex"), Integer)
        Me.GroupBox4.TabStop = False
        Me.GroupBox4.Text = resources.GetString("GroupBox4.Text")
        Me.GroupBox4.Visible = CType(resources.GetObject("GroupBox4.Visible"), Boolean)
        '
        'dcBTN
        '
        Me.dcBTN.AccessibleDescription = resources.GetString("dcBTN.AccessibleDescription")
        Me.dcBTN.AccessibleName = resources.GetString("dcBTN.AccessibleName")
        Me.dcBTN.Anchor = CType(resources.GetObject("dcBTN.Anchor"), System.Windows.Forms.AnchorStyles)
        Me.dcBTN.BackgroundImage = CType(resources.GetObject("dcBTN.BackgroundImage"), System.Drawing.Image)
        Me.dcBTN.Dock = CType(resources.GetObject("dcBTN.Dock"), System.Windows.Forms.DockStyle)
        Me.dcBTN.Enabled = CType(resources.GetObject("dcBTN.Enabled"), Boolean)
        Me.dcBTN.FlatStyle = CType(resources.GetObject("dcBTN.FlatStyle"), System.Windows.Forms.FlatStyle)
        Me.dcBTN.Font = CType(resources.GetObject("dcBTN.Font"), System.Drawing.Font)
        Me.dcBTN.Image = CType(resources.GetObject("dcBTN.Image"), System.Drawing.Image)
        Me.dcBTN.ImageAlign = CType(resources.GetObject("dcBTN.ImageAlign"), System.Drawing.ContentAlignment)
        Me.dcBTN.ImageIndex = CType(resources.GetObject("dcBTN.ImageIndex"), Integer)
        Me.dcBTN.ImeMode = CType(resources.GetObject("dcBTN.ImeMode"), System.Windows.Forms.ImeMode)
        Me.dcBTN.Location = CType(resources.GetObject("dcBTN.Location"), System.Drawing.Point)
        Me.dcBTN.Name = "dcBTN"
        Me.dcBTN.RightToLeft = CType(resources.GetObject("dcBTN.RightToLeft"), System.Windows.Forms.RightToLeft)
        Me.dcBTN.Size = CType(resources.GetObject("dcBTN.Size"), System.Drawing.Size)
        Me.dcBTN.TabIndex = CType(resources.GetObject("dcBTN.TabIndex"), Integer)
        Me.dcBTN.Text = resources.GetString("dcBTN.Text")
        Me.dcBTN.TextAlign = CType(resources.GetObject("dcBTN.TextAlign"), System.Drawing.ContentAlignment)
        Me.dcBTN.Visible = CType(resources.GetObject("dcBTN.Visible"), Boolean)
        '
        'GroupBox8
        '
        Me.GroupBox8.AccessibleDescription = resources.GetString("GroupBox8.AccessibleDescription")
        Me.GroupBox8.AccessibleName = resources.GetString("GroupBox8.AccessibleName")
        Me.GroupBox8.Anchor = CType(resources.GetObject("GroupBox8.Anchor"), System.Windows.Forms.AnchorStyles)
        Me.GroupBox8.BackgroundImage = CType(resources.GetObject("GroupBox8.BackgroundImage"), System.Drawing.Image)
        Me.GroupBox8.Controls.Add(Me.com1RB)
        Me.GroupBox8.Controls.Add(Me.com2RB)
        Me.GroupBox8.Dock = CType(resources.GetObject("GroupBox8.Dock"), System.Windows.Forms.DockStyle)
        Me.GroupBox8.Enabled = CType(resources.GetObject("GroupBox8.Enabled"), Boolean)
        Me.GroupBox8.Font = CType(resources.GetObject("GroupBox8.Font"), System.Drawing.Font)
        Me.GroupBox8.ImeMode = CType(resources.GetObject("GroupBox8.ImeMode"), System.Windows.Forms.ImeMode)
        Me.GroupBox8.Location = CType(resources.GetObject("GroupBox8.Location"), System.Drawing.Point)
        Me.GroupBox8.Name = "GroupBox8"
        Me.GroupBox8.RightToLeft = CType(resources.GetObject("GroupBox8.RightToLeft"), System.Windows.Forms.RightToLeft)
        Me.GroupBox8.Size = CType(resources.GetObject("GroupBox8.Size"), System.Drawing.Size)
        Me.GroupBox8.TabIndex = CType(resources.GetObject("GroupBox8.TabIndex"), Integer)
        Me.GroupBox8.TabStop = False
        Me.GroupBox8.Text = resources.GetString("GroupBox8.Text")
        Me.GroupBox8.Visible = CType(resources.GetObject("GroupBox8.Visible"), Boolean)
        '
        'com1RB
        '
        Me.com1RB.AccessibleDescription = resources.GetString("com1RB.AccessibleDescription")
        Me.com1RB.AccessibleName = resources.GetString("com1RB.AccessibleName")
        Me.com1RB.Anchor = CType(resources.GetObject("com1RB.Anchor"), System.Windows.Forms.AnchorStyles)
        Me.com1RB.Appearance = CType(resources.GetObject("com1RB.Appearance"), System.Windows.Forms.Appearance)
        Me.com1RB.BackgroundImage = CType(resources.GetObject("com1RB.BackgroundImage"), System.Drawing.Image)
        Me.com1RB.CheckAlign = CType(resources.GetObject("com1RB.CheckAlign"), System.Drawing.ContentAlignment)
        Me.com1RB.Checked = True
        Me.com1RB.Dock = CType(resources.GetObject("com1RB.Dock"), System.Windows.Forms.DockStyle)
        Me.com1RB.Enabled = CType(resources.GetObject("com1RB.Enabled"), Boolean)
        Me.com1RB.FlatStyle = CType(resources.GetObject("com1RB.FlatStyle"), System.Windows.Forms.FlatStyle)
        Me.com1RB.Font = CType(resources.GetObject("com1RB.Font"), System.Drawing.Font)
        Me.com1RB.Image = CType(resources.GetObject("com1RB.Image"), System.Drawing.Image)
        Me.com1RB.ImageAlign = CType(resources.GetObject("com1RB.ImageAlign"), System.Drawing.ContentAlignment)
        Me.com1RB.ImageIndex = CType(resources.GetObject("com1RB.ImageIndex"), Integer)
        Me.com1RB.ImeMode = CType(resources.GetObject("com1RB.ImeMode"), System.Windows.Forms.ImeMode)
        Me.com1RB.Location = CType(resources.GetObject("com1RB.Location"), System.Drawing.Point)
        Me.com1RB.Name = "com1RB"
        Me.com1RB.RightToLeft = CType(resources.GetObject("com1RB.RightToLeft"), System.Windows.Forms.RightToLeft)
        Me.com1RB.Size = CType(resources.GetObject("com1RB.Size"), System.Drawing.Size)
        Me.com1RB.TabIndex = CType(resources.GetObject("com1RB.TabIndex"), Integer)
        Me.com1RB.TabStop = True
        Me.com1RB.Text = resources.GetString("com1RB.Text")
        Me.com1RB.TextAlign = CType(resources.GetObject("com1RB.TextAlign"), System.Drawing.ContentAlignment)
        Me.com1RB.Visible = CType(resources.GetObject("com1RB.Visible"), Boolean)
        '
        'com2RB
        '
        Me.com2RB.AccessibleDescription = resources.GetString("com2RB.AccessibleDescription")
        Me.com2RB.AccessibleName = resources.GetString("com2RB.AccessibleName")
        Me.com2RB.Anchor = CType(resources.GetObject("com2RB.Anchor"), System.Windows.Forms.AnchorStyles)
        Me.com2RB.Appearance = CType(resources.GetObject("com2RB.Appearance"), System.Windows.Forms.Appearance)
        Me.com2RB.BackgroundImage = CType(resources.GetObject("com2RB.BackgroundImage"), System.Drawing.Image)
        Me.com2RB.CheckAlign = CType(resources.GetObject("com2RB.CheckAlign"), System.Drawing.ContentAlignment)
        Me.com2RB.Dock = CType(resources.GetObject("com2RB.Dock"), System.Windows.Forms.DockStyle)
        Me.com2RB.Enabled = CType(resources.GetObject("com2RB.Enabled"), Boolean)
        Me.com2RB.FlatStyle = CType(resources.GetObject("com2RB.FlatStyle"), System.Windows.Forms.FlatStyle)
        Me.com2RB.Font = CType(resources.GetObject("com2RB.Font"), System.Drawing.Font)
        Me.com2RB.Image = CType(resources.GetObject("com2RB.Image"), System.Drawing.Image)
        Me.com2RB.ImageAlign = CType(resources.GetObject("com2RB.ImageAlign"), System.Drawing.ContentAlignment)
        Me.com2RB.ImageIndex = CType(resources.GetObject("com2RB.ImageIndex"), Integer)
        Me.com2RB.ImeMode = CType(resources.GetObject("com2RB.ImeMode"), System.Windows.Forms.ImeMode)
        Me.com2RB.Location = CType(resources.GetObject("com2RB.Location"), System.Drawing.Point)
        Me.com2RB.Name = "com2RB"
        Me.com2RB.RightToLeft = CType(resources.GetObject("com2RB.RightToLeft"), System.Windows.Forms.RightToLeft)
        Me.com2RB.Size = CType(resources.GetObject("com2RB.Size"), System.Drawing.Size)
        Me.com2RB.TabIndex = CType(resources.GetObject("com2RB.TabIndex"), Integer)
        Me.com2RB.Text = resources.GetString("com2RB.Text")
        Me.com2RB.TextAlign = CType(resources.GetObject("com2RB.TextAlign"), System.Drawing.ContentAlignment)
        Me.com2RB.Visible = CType(resources.GetObject("com2RB.Visible"), Boolean)
        '
        'GroupBox7
        '
        Me.GroupBox7.AccessibleDescription = resources.GetString("GroupBox7.AccessibleDescription")
        Me.GroupBox7.AccessibleName = resources.GetString("GroupBox7.AccessibleName")
        Me.GroupBox7.Anchor = CType(resources.GetObject("GroupBox7.Anchor"), System.Windows.Forms.AnchorStyles)
        Me.GroupBox7.BackgroundImage = CType(resources.GetObject("GroupBox7.BackgroundImage"), System.Drawing.Image)
        Me.GroupBox7.Controls.Add(Me.ipportTB)
        Me.GroupBox7.Controls.Add(Me.Label10)
        Me.GroupBox7.Controls.Add(Me.Label9)
        Me.GroupBox7.Controls.Add(Me.ipaddressTB)
        Me.GroupBox7.Dock = CType(resources.GetObject("GroupBox7.Dock"), System.Windows.Forms.DockStyle)
        Me.GroupBox7.Enabled = CType(resources.GetObject("GroupBox7.Enabled"), Boolean)
        Me.GroupBox7.Font = CType(resources.GetObject("GroupBox7.Font"), System.Drawing.Font)
        Me.GroupBox7.ImeMode = CType(resources.GetObject("GroupBox7.ImeMode"), System.Windows.Forms.ImeMode)
        Me.GroupBox7.Location = CType(resources.GetObject("GroupBox7.Location"), System.Drawing.Point)
        Me.GroupBox7.Name = "GroupBox7"
        Me.GroupBox7.RightToLeft = CType(resources.GetObject("GroupBox7.RightToLeft"), System.Windows.Forms.RightToLeft)
        Me.GroupBox7.Size = CType(resources.GetObject("GroupBox7.Size"), System.Drawing.Size)
        Me.GroupBox7.TabIndex = CType(resources.GetObject("GroupBox7.TabIndex"), Integer)
        Me.GroupBox7.TabStop = False
        Me.GroupBox7.Text = resources.GetString("GroupBox7.Text")
        Me.GroupBox7.Visible = CType(resources.GetObject("GroupBox7.Visible"), Boolean)
        '
        'ipportTB
        '
        Me.ipportTB.AccessibleDescription = resources.GetString("ipportTB.AccessibleDescription")
        Me.ipportTB.AccessibleName = resources.GetString("ipportTB.AccessibleName")
        Me.ipportTB.Anchor = CType(resources.GetObject("ipportTB.Anchor"), System.Windows.Forms.AnchorStyles)
        Me.ipportTB.AutoSize = CType(resources.GetObject("ipportTB.AutoSize"), Boolean)
        Me.ipportTB.BackgroundImage = CType(resources.GetObject("ipportTB.BackgroundImage"), System.Drawing.Image)
        Me.ipportTB.Dock = CType(resources.GetObject("ipportTB.Dock"), System.Windows.Forms.DockStyle)
        Me.ipportTB.Enabled = CType(resources.GetObject("ipportTB.Enabled"), Boolean)
        Me.ipportTB.Font = CType(resources.GetObject("ipportTB.Font"), System.Drawing.Font)
        Me.ipportTB.ImeMode = CType(resources.GetObject("ipportTB.ImeMode"), System.Windows.Forms.ImeMode)
        Me.ipportTB.Location = CType(resources.GetObject("ipportTB.Location"), System.Drawing.Point)
        Me.ipportTB.MaxLength = CType(resources.GetObject("ipportTB.MaxLength"), Integer)
        Me.ipportTB.Multiline = CType(resources.GetObject("ipportTB.Multiline"), Boolean)
        Me.ipportTB.Name = "ipportTB"
        Me.ipportTB.PasswordChar = CType(resources.GetObject("ipportTB.PasswordChar"), Char)
        Me.ipportTB.RightToLeft = CType(resources.GetObject("ipportTB.RightToLeft"), System.Windows.Forms.RightToLeft)
        Me.ipportTB.ScrollBars = CType(resources.GetObject("ipportTB.ScrollBars"), System.Windows.Forms.ScrollBars)
        Me.ipportTB.Size = CType(resources.GetObject("ipportTB.Size"), System.Drawing.Size)
        Me.ipportTB.TabIndex = CType(resources.GetObject("ipportTB.TabIndex"), Integer)
        Me.ipportTB.Text = resources.GetString("ipportTB.Text")
        Me.ipportTB.TextAlign = CType(resources.GetObject("ipportTB.TextAlign"), System.Windows.Forms.HorizontalAlignment)
        Me.ipportTB.Visible = CType(resources.GetObject("ipportTB.Visible"), Boolean)
        Me.ipportTB.WordWrap = CType(resources.GetObject("ipportTB.WordWrap"), Boolean)
        '
        'Label10
        '
        Me.Label10.AccessibleDescription = resources.GetString("Label10.AccessibleDescription")
        Me.Label10.AccessibleName = resources.GetString("Label10.AccessibleName")
        Me.Label10.Anchor = CType(resources.GetObject("Label10.Anchor"), System.Windows.Forms.AnchorStyles)
        Me.Label10.AutoSize = CType(resources.GetObject("Label10.AutoSize"), Boolean)
        Me.Label10.Dock = CType(resources.GetObject("Label10.Dock"), System.Windows.Forms.DockStyle)
        Me.Label10.Enabled = CType(resources.GetObject("Label10.Enabled"), Boolean)
        Me.Label10.Font = CType(resources.GetObject("Label10.Font"), System.Drawing.Font)
        Me.Label10.Image = CType(resources.GetObject("Label10.Image"), System.Drawing.Image)
        Me.Label10.ImageAlign = CType(resources.GetObject("Label10.ImageAlign"), System.Drawing.ContentAlignment)
        Me.Label10.ImageIndex = CType(resources.GetObject("Label10.ImageIndex"), Integer)
        Me.Label10.ImeMode = CType(resources.GetObject("Label10.ImeMode"), System.Windows.Forms.ImeMode)
        Me.Label10.Location = CType(resources.GetObject("Label10.Location"), System.Drawing.Point)
        Me.Label10.Name = "Label10"
        Me.Label10.RightToLeft = CType(resources.GetObject("Label10.RightToLeft"), System.Windows.Forms.RightToLeft)
        Me.Label10.Size = CType(resources.GetObject("Label10.Size"), System.Drawing.Size)
        Me.Label10.TabIndex = CType(resources.GetObject("Label10.TabIndex"), Integer)
        Me.Label10.Text = resources.GetString("Label10.Text")
        Me.Label10.TextAlign = CType(resources.GetObject("Label10.TextAlign"), System.Drawing.ContentAlignment)
        Me.Label10.Visible = CType(resources.GetObject("Label10.Visible"), Boolean)
        '
        'Label9
        '
        Me.Label9.AccessibleDescription = resources.GetString("Label9.AccessibleDescription")
        Me.Label9.AccessibleName = resources.GetString("Label9.AccessibleName")
        Me.Label9.Anchor = CType(resources.GetObject("Label9.Anchor"), System.Windows.Forms.AnchorStyles)
        Me.Label9.AutoSize = CType(resources.GetObject("Label9.AutoSize"), Boolean)
        Me.Label9.Dock = CType(resources.GetObject("Label9.Dock"), System.Windows.Forms.DockStyle)
        Me.Label9.Enabled = CType(resources.GetObject("Label9.Enabled"), Boolean)
        Me.Label9.Font = CType(resources.GetObject("Label9.Font"), System.Drawing.Font)
        Me.Label9.Image = CType(resources.GetObject("Label9.Image"), System.Drawing.Image)
        Me.Label9.ImageAlign = CType(resources.GetObject("Label9.ImageAlign"), System.Drawing.ContentAlignment)
        Me.Label9.ImageIndex = CType(resources.GetObject("Label9.ImageIndex"), Integer)
        Me.Label9.ImeMode = CType(resources.GetObject("Label9.ImeMode"), System.Windows.Forms.ImeMode)
        Me.Label9.Location = CType(resources.GetObject("Label9.Location"), System.Drawing.Point)
        Me.Label9.Name = "Label9"
        Me.Label9.RightToLeft = CType(resources.GetObject("Label9.RightToLeft"), System.Windows.Forms.RightToLeft)
        Me.Label9.Size = CType(resources.GetObject("Label9.Size"), System.Drawing.Size)
        Me.Label9.TabIndex = CType(resources.GetObject("Label9.TabIndex"), Integer)
        Me.Label9.Text = resources.GetString("Label9.Text")
        Me.Label9.TextAlign = CType(resources.GetObject("Label9.TextAlign"), System.Drawing.ContentAlignment)
        Me.Label9.Visible = CType(resources.GetObject("Label9.Visible"), Boolean)
        '
        'ipaddressTB
        '
        Me.ipaddressTB.AccessibleDescription = resources.GetString("ipaddressTB.AccessibleDescription")
        Me.ipaddressTB.AccessibleName = resources.GetString("ipaddressTB.AccessibleName")
        Me.ipaddressTB.Anchor = CType(resources.GetObject("ipaddressTB.Anchor"), System.Windows.Forms.AnchorStyles)
        Me.ipaddressTB.AutoSize = CType(resources.GetObject("ipaddressTB.AutoSize"), Boolean)
        Me.ipaddressTB.BackgroundImage = CType(resources.GetObject("ipaddressTB.BackgroundImage"), System.Drawing.Image)
        Me.ipaddressTB.Dock = CType(resources.GetObject("ipaddressTB.Dock"), System.Windows.Forms.DockStyle)
        Me.ipaddressTB.Enabled = CType(resources.GetObject("ipaddressTB.Enabled"), Boolean)
        Me.ipaddressTB.Font = CType(resources.GetObject("ipaddressTB.Font"), System.Drawing.Font)
        Me.ipaddressTB.ImeMode = CType(resources.GetObject("ipaddressTB.ImeMode"), System.Windows.Forms.ImeMode)
        Me.ipaddressTB.Location = CType(resources.GetObject("ipaddressTB.Location"), System.Drawing.Point)
        Me.ipaddressTB.MaxLength = CType(resources.GetObject("ipaddressTB.MaxLength"), Integer)
        Me.ipaddressTB.Multiline = CType(resources.GetObject("ipaddressTB.Multiline"), Boolean)
        Me.ipaddressTB.Name = "ipaddressTB"
        Me.ipaddressTB.PasswordChar = CType(resources.GetObject("ipaddressTB.PasswordChar"), Char)
        Me.ipaddressTB.RightToLeft = CType(resources.GetObject("ipaddressTB.RightToLeft"), System.Windows.Forms.RightToLeft)
        Me.ipaddressTB.ScrollBars = CType(resources.GetObject("ipaddressTB.ScrollBars"), System.Windows.Forms.ScrollBars)
        Me.ipaddressTB.Size = CType(resources.GetObject("ipaddressTB.Size"), System.Drawing.Size)
        Me.ipaddressTB.TabIndex = CType(resources.GetObject("ipaddressTB.TabIndex"), Integer)
        Me.ipaddressTB.Text = resources.GetString("ipaddressTB.Text")
        Me.ipaddressTB.TextAlign = CType(resources.GetObject("ipaddressTB.TextAlign"), System.Windows.Forms.HorizontalAlignment)
        Me.ipaddressTB.Visible = CType(resources.GetObject("ipaddressTB.Visible"), Boolean)
        Me.ipaddressTB.WordWrap = CType(resources.GetObject("ipaddressTB.WordWrap"), Boolean)
        '
        'GroupBox5
        '
        Me.GroupBox5.AccessibleDescription = resources.GetString("GroupBox5.AccessibleDescription")
        Me.GroupBox5.AccessibleName = resources.GetString("GroupBox5.AccessibleName")
        Me.GroupBox5.Anchor = CType(resources.GetObject("GroupBox5.Anchor"), System.Windows.Forms.AnchorStyles)
        Me.GroupBox5.BackgroundImage = CType(resources.GetObject("GroupBox5.BackgroundImage"), System.Drawing.Image)
        Me.GroupBox5.Controls.Add(Me.tcpipRB)
        Me.GroupBox5.Controls.Add(Me.rsRB)
        Me.GroupBox5.Dock = CType(resources.GetObject("GroupBox5.Dock"), System.Windows.Forms.DockStyle)
        Me.GroupBox5.Enabled = CType(resources.GetObject("GroupBox5.Enabled"), Boolean)
        Me.GroupBox5.Font = CType(resources.GetObject("GroupBox5.Font"), System.Drawing.Font)
        Me.GroupBox5.ImeMode = CType(resources.GetObject("GroupBox5.ImeMode"), System.Windows.Forms.ImeMode)
        Me.GroupBox5.Location = CType(resources.GetObject("GroupBox5.Location"), System.Drawing.Point)
        Me.GroupBox5.Name = "GroupBox5"
        Me.GroupBox5.RightToLeft = CType(resources.GetObject("GroupBox5.RightToLeft"), System.Windows.Forms.RightToLeft)
        Me.GroupBox5.Size = CType(resources.GetObject("GroupBox5.Size"), System.Drawing.Size)
        Me.GroupBox5.TabIndex = CType(resources.GetObject("GroupBox5.TabIndex"), Integer)
        Me.GroupBox5.TabStop = False
        Me.GroupBox5.Text = resources.GetString("GroupBox5.Text")
        Me.GroupBox5.Visible = CType(resources.GetObject("GroupBox5.Visible"), Boolean)
        '
        'tcpipRB
        '
        Me.tcpipRB.AccessibleDescription = resources.GetString("tcpipRB.AccessibleDescription")
        Me.tcpipRB.AccessibleName = resources.GetString("tcpipRB.AccessibleName")
        Me.tcpipRB.Anchor = CType(resources.GetObject("tcpipRB.Anchor"), System.Windows.Forms.AnchorStyles)
        Me.tcpipRB.Appearance = CType(resources.GetObject("tcpipRB.Appearance"), System.Windows.Forms.Appearance)
        Me.tcpipRB.BackgroundImage = CType(resources.GetObject("tcpipRB.BackgroundImage"), System.Drawing.Image)
        Me.tcpipRB.CheckAlign = CType(resources.GetObject("tcpipRB.CheckAlign"), System.Drawing.ContentAlignment)
        Me.tcpipRB.Dock = CType(resources.GetObject("tcpipRB.Dock"), System.Windows.Forms.DockStyle)
        Me.tcpipRB.Enabled = CType(resources.GetObject("tcpipRB.Enabled"), Boolean)
        Me.tcpipRB.FlatStyle = CType(resources.GetObject("tcpipRB.FlatStyle"), System.Windows.Forms.FlatStyle)
        Me.tcpipRB.Font = CType(resources.GetObject("tcpipRB.Font"), System.Drawing.Font)
        Me.tcpipRB.Image = CType(resources.GetObject("tcpipRB.Image"), System.Drawing.Image)
        Me.tcpipRB.ImageAlign = CType(resources.GetObject("tcpipRB.ImageAlign"), System.Drawing.ContentAlignment)
        Me.tcpipRB.ImageIndex = CType(resources.GetObject("tcpipRB.ImageIndex"), Integer)
        Me.tcpipRB.ImeMode = CType(resources.GetObject("tcpipRB.ImeMode"), System.Windows.Forms.ImeMode)
        Me.tcpipRB.Location = CType(resources.GetObject("tcpipRB.Location"), System.Drawing.Point)
        Me.tcpipRB.Name = "tcpipRB"
        Me.tcpipRB.RightToLeft = CType(resources.GetObject("tcpipRB.RightToLeft"), System.Windows.Forms.RightToLeft)
        Me.tcpipRB.Size = CType(resources.GetObject("tcpipRB.Size"), System.Drawing.Size)
        Me.tcpipRB.TabIndex = CType(resources.GetObject("tcpipRB.TabIndex"), Integer)
        Me.tcpipRB.Text = resources.GetString("tcpipRB.Text")
        Me.tcpipRB.TextAlign = CType(resources.GetObject("tcpipRB.TextAlign"), System.Drawing.ContentAlignment)
        Me.tcpipRB.Visible = CType(resources.GetObject("tcpipRB.Visible"), Boolean)
        '
        'rsRB
        '
        Me.rsRB.AccessibleDescription = resources.GetString("rsRB.AccessibleDescription")
        Me.rsRB.AccessibleName = resources.GetString("rsRB.AccessibleName")
        Me.rsRB.Anchor = CType(resources.GetObject("rsRB.Anchor"), System.Windows.Forms.AnchorStyles)
        Me.rsRB.Appearance = CType(resources.GetObject("rsRB.Appearance"), System.Windows.Forms.Appearance)
        Me.rsRB.BackgroundImage = CType(resources.GetObject("rsRB.BackgroundImage"), System.Drawing.Image)
        Me.rsRB.CheckAlign = CType(resources.GetObject("rsRB.CheckAlign"), System.Drawing.ContentAlignment)
        Me.rsRB.Dock = CType(resources.GetObject("rsRB.Dock"), System.Windows.Forms.DockStyle)
        Me.rsRB.Enabled = CType(resources.GetObject("rsRB.Enabled"), Boolean)
        Me.rsRB.FlatStyle = CType(resources.GetObject("rsRB.FlatStyle"), System.Windows.Forms.FlatStyle)
        Me.rsRB.Font = CType(resources.GetObject("rsRB.Font"), System.Drawing.Font)
        Me.rsRB.Image = CType(resources.GetObject("rsRB.Image"), System.Drawing.Image)
        Me.rsRB.ImageAlign = CType(resources.GetObject("rsRB.ImageAlign"), System.Drawing.ContentAlignment)
        Me.rsRB.ImageIndex = CType(resources.GetObject("rsRB.ImageIndex"), Integer)
        Me.rsRB.ImeMode = CType(resources.GetObject("rsRB.ImeMode"), System.Windows.Forms.ImeMode)
        Me.rsRB.Location = CType(resources.GetObject("rsRB.Location"), System.Drawing.Point)
        Me.rsRB.Name = "rsRB"
        Me.rsRB.RightToLeft = CType(resources.GetObject("rsRB.RightToLeft"), System.Windows.Forms.RightToLeft)
        Me.rsRB.Size = CType(resources.GetObject("rsRB.Size"), System.Drawing.Size)
        Me.rsRB.TabIndex = CType(resources.GetObject("rsRB.TabIndex"), Integer)
        Me.rsRB.Text = resources.GetString("rsRB.Text")
        Me.rsRB.TextAlign = CType(resources.GetObject("rsRB.TextAlign"), System.Drawing.ContentAlignment)
        Me.rsRB.Visible = CType(resources.GetObject("rsRB.Visible"), Boolean)
        '
        'GroupBox6
        '
        Me.GroupBox6.AccessibleDescription = resources.GetString("GroupBox6.AccessibleDescription")
        Me.GroupBox6.AccessibleName = resources.GetString("GroupBox6.AccessibleName")
        Me.GroupBox6.Anchor = CType(resources.GetObject("GroupBox6.Anchor"), System.Windows.Forms.AnchorStyles)
        Me.GroupBox6.BackgroundImage = CType(resources.GetObject("GroupBox6.BackgroundImage"), System.Drawing.Image)
        Me.GroupBox6.Controls.Add(Me.Label2)
        Me.GroupBox6.Controls.Add(Me.Label3)
        Me.GroupBox6.Controls.Add(Me.startBTN)
        Me.GroupBox6.Controls.Add(Me.stopBTN)
        Me.GroupBox6.Dock = CType(resources.GetObject("GroupBox6.Dock"), System.Windows.Forms.DockStyle)
        Me.GroupBox6.Enabled = CType(resources.GetObject("GroupBox6.Enabled"), Boolean)
        Me.GroupBox6.Font = CType(resources.GetObject("GroupBox6.Font"), System.Drawing.Font)
        Me.GroupBox6.ImeMode = CType(resources.GetObject("GroupBox6.ImeMode"), System.Windows.Forms.ImeMode)
        Me.GroupBox6.Location = CType(resources.GetObject("GroupBox6.Location"), System.Drawing.Point)
        Me.GroupBox6.Name = "GroupBox6"
        Me.GroupBox6.RightToLeft = CType(resources.GetObject("GroupBox6.RightToLeft"), System.Windows.Forms.RightToLeft)
        Me.GroupBox6.Size = CType(resources.GetObject("GroupBox6.Size"), System.Drawing.Size)
        Me.GroupBox6.TabIndex = CType(resources.GetObject("GroupBox6.TabIndex"), Integer)
        Me.GroupBox6.TabStop = False
        Me.GroupBox6.Text = resources.GetString("GroupBox6.Text")
        Me.GroupBox6.Visible = CType(resources.GetObject("GroupBox6.Visible"), Boolean)
        '
        'Form1
        '
        Me.AccessibleDescription = resources.GetString("$this.AccessibleDescription")
        Me.AccessibleName = resources.GetString("$this.AccessibleName")
        Me.AutoScaleBaseSize = CType(resources.GetObject("$this.AutoScaleBaseSize"), System.Drawing.Size)
        Me.AutoScroll = CType(resources.GetObject("$this.AutoScroll"), Boolean)
        Me.AutoScrollMargin = CType(resources.GetObject("$this.AutoScrollMargin"), System.Drawing.Size)
        Me.AutoScrollMinSize = CType(resources.GetObject("$this.AutoScrollMinSize"), System.Drawing.Size)
        Me.BackgroundImage = CType(resources.GetObject("$this.BackgroundImage"), System.Drawing.Image)
        Me.ClientSize = CType(resources.GetObject("$this.ClientSize"), System.Drawing.Size)
        Me.Controls.Add(Me.GroupBox4)
        Me.Controls.Add(Me.GroupBox1)
        Me.Controls.Add(Me.Frame)
        Me.Controls.Add(Me.GroupBox6)
        Me.Enabled = CType(resources.GetObject("$this.Enabled"), Boolean)
        Me.Font = CType(resources.GetObject("$this.Font"), System.Drawing.Font)
        Me.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedSingle
        Me.Icon = CType(resources.GetObject("$this.Icon"), System.Drawing.Icon)
        Me.ImeMode = CType(resources.GetObject("$this.ImeMode"), System.Windows.Forms.ImeMode)
        Me.Location = CType(resources.GetObject("$this.Location"), System.Drawing.Point)
        Me.MaximumSize = CType(resources.GetObject("$this.MaximumSize"), System.Drawing.Size)
        Me.MinimumSize = CType(resources.GetObject("$this.MinimumSize"), System.Drawing.Size)
        Me.Name = "Form1"
        Me.RightToLeft = CType(resources.GetObject("$this.RightToLeft"), System.Windows.Forms.RightToLeft)
        Me.StartPosition = CType(resources.GetObject("$this.StartPosition"), System.Windows.Forms.FormStartPosition)
        Me.Text = resources.GetString("$this.Text")
        Me.Frame.ResumeLayout(False)
        Me.GroupBox2.ResumeLayout(False)
        CType(Me.rowUD, System.ComponentModel.ISupportInitialize).EndInit()
        Me.GroupBox1.ResumeLayout(False)
        Me.GroupBox4.ResumeLayout(False)
        Me.GroupBox8.ResumeLayout(False)
        Me.GroupBox7.ResumeLayout(False)
        Me.GroupBox5.ResumeLayout(False)
        Me.GroupBox6.ResumeLayout(False)
        Me.ResumeLayout(False)

    End Sub

#End Region
    Private Sub Form1_Load(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Load
        'Initialize our componets Controls when we first load the form
        'Any Control that is not applicable when we start the application
        'is disabled. 

        ipaddressTB.Enabled = False
        ipportTB.Enabled = False
        com1RB.Enabled = False
        com2RB.Enabled = False
        connectBTN.Enabled = False
        dcBTN.Enabled = False
        startBTN.Enabled = False
        stopBTN.Enabled = False


        'Create the instances of the xPC Target COM objects necessary 
        'to interface with the target. Declare stat to later 
        'initialize the COM object.

        com = New XPCAPICOMLib.xPCProtocol
        tg = New XPCAPICOMLib.xPCTarget
        Dim stat As Integer

        'Initialize the COM object
        stat = com.Init()

        'Check to see that the xPC Target API loaded and initialized 
        'successfully by checking the value of stat.
        'This checks if the intialization of the xPC Target API is successful. 
        'If the initialization fails, exit cleanly from the application. 
        'Otherwise, an exception will occur.

        'stat=0,loaded susscessfully,-1 failed.
        If stat < 0 Then
            MsgBox("Could not load api") 'We can no longer continue.
            End
        End If

    End Sub

    'The following procedure connects the application to the target PC. 
    'This subprocedure will  call the subprocedures connect2Target() 
    'and initFormControls().
    Private Sub connectBTN_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles connectBTN.Click
        Dim stat As Integer
        'Call the sub procedure connect2Target to handle the connection. 
        'To jump to the sub procedure for connect2Target(), right-click
        'on connect2Target and select Go to definition.
        stat = connect2Target()
        'Check the status of the connection.
        'Returns –1 for success, otherwise connection has failed.
        If Not (stat = -1) Then
            'Use the COM API error handler function, 
            'GetxPCErrorMsg, to capture the error. 
            'Use MsgBox to display the error message.
            MsgBox(com.GetxPCErrorMsg)
            'If connection failed, exit here since we can no longer communicate
            Exit Sub
        End If

        connectBTN.Enabled = False

        'Otherwise, connection has been established. 
        'Use the xPC Target Init method to initialize 
        'the target object tg. The Init command directs
        'the tg object to communicate with the target 
        'PC defined by the object, com.
        tg.Init(com)
        'You can now use the tg object to communicate with the target PC

        'Call the sub initFormControls() to handle the connection. 
        'To jump to the sub procedure for connect2Target(), right-click
        'on initFormControls() and select Go to definition.
        initFormControls()

    End Sub
    'This is a generic demo that allows connection to any target PC via RS-232 or TCP/IP
    'The following function analyzes the input from the Form communication components 
    'Based on the input, the sub procedure uses the correct connection method to connect
    'the com object to the target PC. The sub procedure also returns a status value in 
    'stat for the return from TcpIpConnect(). If the return value is -1, 
    'the connection is successful. Otherwise, the connection attempt has failed.
    Function connect2Target() As Integer
        'If the TCP/IP radio button is selected 
        'then the connection is TCP/IP
        Dim stat As Integer
        If tcpipRB.Checked = True Then
            stat = com.TcpIpConnect(ipaddressTB.Text, ipportTB.Text) 'stat=-1 is successful, otherwise communication failed
        Else
            'Otherwise rs-232 must be the choice selected.
            Dim comport As Integer 'need to hold comport
            'Since the connection is an RS-232 one, use the comport variable to 
            'contain the communication port value, 1 or 0
            If com1RB.Checked Then
                comport = 0
            Else
                comport = 1
            End If
            stat = com.RS232Connect(comport, 115200)
        End If
        Return (stat)
    End Function
    'Upon connection, this procedure will collect target application information, such as:
    '•	target application name
    '•	target application parameters Names
    '•  target application signals Names
    Sub initFormControls()
        'Because the connection has been established, disable all the communication components
        'to prevent users from continuing to interact with these components.
        tcpipRB.Enabled = False
        rsRB.Enabled = False
        com1RB.Enabled = False
        com2RB.Enabled = False

        'Here we enable all the components we want to be active when we are connected.
        startBTN.Enabled = True
        stopBTN.Enabled = True
        Timer1.Enabled = True
        ListBox1.Enabled = True
        ListBox2.Enabled = True
        dcBTN.Enabled = True

        'Enable all the components we want to be active when we are connected. 
        'This includes the disconnect button, start and stop buttons for
        'the target application, and the list boxes to display both the signal and
        'parameter names. In addition, a timer component is enabled that allows the
        'application to poll data from the target PC periodiclly and refresh the form.

        Label2.Text = tg.GetAppName 'The following gets the name of the application loaded on the target PC.
        'The Form calls the populatesignalListBox and populateparamListBox to collect the 
        'signal and parameter names and values form the target application.
        'These parameters enter the information as flat lists into their respective list boxes.
        populateparamListBox()
        'The following procedure gets all the target application parameters and adds them individually to a list box.
        populatesignalListBox()
    End Sub
    'The following procedure gets all the target application parameters and adds them
    'individually to a list box.
    Sub populateparamListBox()
        'Declare I for a loop counter. This variable will be used as the paramIdx 
        'argument to the GetParamName function.
        Dim I As Integer

        'Declare an object, paramstringobj, to hold the return values required to
        'get the parameter names.
        Dim paramstringobj As Object

        'The GetParamName function returns an array of type object with two elements. 
        'The first element (index 0) contains the blockpath string, the second element 
        '(index 1) contains the parameter name string. The GetParamName function expects an 
        'input argument paramIdx. This is the xPC Target index of the parameter you want to
        'get the name of. In this case, I becomes the paramIdx that will be used for the 
        'input argument to get each parameter name. To add all the parameters in the model 
        'to the list box, we need a ‘for’ loop. The loop control will be terminated by the 
        'total number of parameters in the model. The parameter index, paramIdx, starts 
        'from zero and extends to the ‘total number of parameters–1’. This list box becomes 
        'active if the parameter is a vector.

        For I = 0 To tg.GetNumParams() - 1
            paramstringobj = tg.GetParamName(I)
            ListBox1.Items.Add(paramstringobj(0) + "\" + paramstringobj(1))
        Next I
    End Sub
    'The following procedure gets all the target application signals and adds them 
    'individually to a list box.
    Sub populatesignalListBox()
        'Declare I for a loop counter. This variable will be used as the signalIdx 
        'argument to the GetSignalName function.
        Dim I As Integer

        'The GetSignalName function returns a string containing the blockpath of the signal. 
        'To acquire a flat list of all the signals from the target application, use the 
        'GetNumSignals function to control a loop counter. In this case, 
        'I becomes the signal index (sigIdx) argument required by the GetSignalName function. 
        'In the last line of the ‘for loop’, we add the signal blockpath string to the signal
        'list box.
        For I = 0 To tg.GetNumSignals() - 1
            ListBox2.Items.Add(tg.GetSignalName(I))
        Next I
    End Sub
    'The following procedure closes the communication.
    Private Sub Form1_Closed(ByVal sender As Object, ByVal e As System.EventArgs) Handles MyBase.Closed
        'Here we make sure we close the communication
        com.Close()
    End Sub
    'The following procedure uses the list box of target parameters to allow the selection of a parameter in the list box of parameters, 
    'display the value of that parameter, and change the value of that parameter using an edit box component. 
    Private Sub ListBox1_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles ListBox1.Click
        'Note that this Form has a NumericUpDown component (labeled in the Demo as Select Index). 
        'This component is enabled when a selected parameter values ia a vector or matrix. 
        'This component is used to query each element of the parameter values for a selected parameter. 
        'Configure the NumericUpDown component with the proper maximum and minimum constraints depending 
        'on the size of the selected parameter. The NumericUpDown component will have dynamic values 
        'that change as the position of the selected parameter changes. 

        Dim paramIdx As Integer
        Dim paramDim As Object
        Dim rows As Integer
        Dim paramVal As Object

        'The selected Index maps exactly to the parameter Index of selected parameter on the target.
        paramIdx = ListBox1.SelectedIndex 'Contains the paramIdx of the selected parameter.
        'Get the dimensions of the parameter so that the upper and lower bounds of the
        'NumericUpDown component can be configured.
        paramDim = tg.GetParamDims(paramIdx) 

        'Determine parameter dimensions to set the maximum and minimum bounds on the row index controls.
        rows = paramDim(0)
        rowUD.Maximum = rows
        rowUD.Minimum = 1

        If rows = 1 Then
            rowUD.Enabled = False
        Else
            rowUD.Enabled = True
        End If

        paramVal = tg.GetParam(paramIdx)

        'The xPC Target COM API GetParam() function retrieves the value of the selected parameter. 
        'This function accepts as input the parameter index, paramIdx, obtained from the 
        'ListBox1.SelectedIndex property. The GetParam() function returns an array of type object. 
        'The conversion is done in column-major format. 
        'Determine the size of the parameter with the GetParamDims() function. 
        'This function returns an array of objects with two elements. 
        'The first element is the number of rows in the parameter, 
        'the second element is the number of columns in the parameter.

        'By default, display the first element, paramVal(0). Use the NumericUpDown component as
        'the index to access the parameter values for non-scalar parameters.
        TextBox1.Text = paramVal(0)

    End Sub
    'The following procedure applies the change from the Apply Parameter change text box to the specified parameter.
    Private Sub Button3_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles Button3.Click

        Dim paramIdx As Integer
        Dim paramDim As Object
        Dim paramVal As Object

        paramIdx = ListBox1.SelectedIndex
        paramDim = tg.GetParamDims(paramIdx)
        paramVal = tg.GetParam(paramIdx)

        'Create an array of doubles with the correct size.
        Dim newVal(paramDim(0) * paramDim(1)) As Double

        newVal = paramVal
        'Set the proper parameter using the NumericUpDown value to index into the correct 
        'element of parameter values.
        newVal(rowUD.Value - 1) = CDbl(TextBox1.Text)
        tg.SetParam(paramIdx, newVal)

    End Sub
    'The following procedure updates the Form periodically by polling data from the target PC.
    Private Sub Timer1_Tick(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles Timer1.Tick
        'Check the value of the selected signal and update the component on the form.
        If ListBox2.SelectedIndex Then
            Label8.Text = tg.GetSignal(ListBox2.SelectedIndex)
        Else
            Label8.Text = " "
        End If
    End Sub
    'The following procedure updates the display of the parameter values. 
    'Depending on the order of the new selected item in the parameter list box, 
    'reset the constraints of the NumericUpDown component.
    Private Sub ListBox1_SelectedIndexChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles ListBox1.SelectedIndexChanged
        'Here we need to update the display of the parameter Values and reset the constraints
        'of the numericupdown control depending on the new selected item from the parameter listbox
        Dim paramIdx As Integer
        Dim paramDim As Object
        Dim dims As Integer
        Dim rows, cols As Integer
        Dim paramVal As Object

        paramIdx = ListBox1.SelectedIndex
        paramDim = tg.GetParamDims(paramIdx)
        'Determine new parameter dimensions to set maximum/minimum constraints on the row index controls.
        rows = paramDim(0)
        cols = paramDim(1)

        dims = rows * cols

        rowUD.Maximum = dims
        rowUD.Minimum = 1

        If dims > 1 Then
            rowUD.Enabled = True
        Else
            rowUD.Enabled = False
        End If
        paramVal = tg.GetParam(paramIdx) 'Here, paramVal is an array with element equal to dims.
        TextBox1.Text = paramVal(0)

    End Sub
    'The following procedure checks the selected communication method
    Private Sub tcpipRB_CheckedChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles tcpipRB.CheckedChanged
        connectBTN.Enabled = True
        If tcpipRB.Checked = True Then
            'Disable all RS-232 components.
            rsRB.Checked = False
            com1RB.Enabled = False
            com2RB.Enabled = False
            'Enable all TCP/IP parameter components.
            ipaddressTB.Enabled = True
            ipportTB.Enabled = True
        Else 'enable all rs232 componets
            rsRB.Checked = True
            com1RB.Enabled = True
            com2RB.Enabled = True
            'Disable all TCP/IP components.
            ipaddressTB.Enabled = False
            ipportTB.Enabled = False
        End If

    End Sub
    'Depending on the connection method, enables or disables the COM1/COM2 port radio buttons.
    Private Sub rsRB_CheckedChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles rsRB.CheckedChanged
        connectBTN.Enabled = True
        If rsRB.Checked = True Then
            'disable all tcpip components
            tcpipRB.Checked = False
            ipaddressTB.Enabled = False
            ipportTB.Enabled = False
            'enable all rs232 components
            com1RB.Enabled = True
            com2RB.Enabled = True
        Else 'enable all tcpip components
            tcpipRB.Checked = True
            com1RB.Enabled = False
            com2RB.Enabled = False
        End If
    End Sub
    'The following procedure stops the application.
    Private Sub stopBTN_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles stopBTN.Click
        tg.StopApp()
        'Since the application has started, disable the Start button and enable the Stop button
        startBTN.Enabled = True
        stopBTN.Enabled = False
    End Sub
    'The following procedure starts the application.
    Private Sub startBTN_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles startBTN.Click
        'Here we start the application. 
        tg.StartApp()
        'Since we start the application we disable the start button, enable stop.
        startBTN.Enabled = False
        stopBTN.Enabled = True
    End Sub
    'The following procedure enables the components required to reconnect to the target PC.
    Private Sub dcBTN_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles dcBTN.Click
        com.Close()
        'Enable components required to Reconnect to Target
        connectBTN.Enabled = True
        tcpipRB.Enabled = True
        rsRB.Enabled = True
        'Disable all the components required when not connected to the target PC.
        Timer1.Enabled = False
        ListBox1.Items.Clear()
        ListBox2.Items.Clear()
        ListBox1.Enabled = False
        ListBox2.Enabled = False
        dcBTN.Enabled = False
        rsRB.Checked = False
        tcpipRB.Checked = False
        startBTN.Enabled = False
        stopBTN.Enabled = False
    End Sub
    'The following procedure updates the NumericUpDown component display if the parameter is a vector or matrix. 
    'In this case, select the index from the NumericUpDown component and update the display of the new parameter value.
    Private Sub rowUD_ValueChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles rowUD.ValueChanged
        'Here we need to update the display of the parameter value when the paramter is a non-scalar(i.e vector)
        'We select the index from the numericupdown componenet and update the display of the new parameter value.
        If rowUD.Enabled = True Then
            Dim paramVal As Object
            Dim ptDim As Object
            Dim paramIdx As Integer
            Dim dims As Integer

            paramIdx = ListBox1.SelectedIndex
            ptDim = tg.GetParamDims(paramIdx)
            dims = ptDim(0) * ptDim(1) 'rows*cols
            paramVal = tg.GetParam(paramIdx) 'paramVal is an array with elements equal to the size of dims.
            TextBox1.Text = paramVal(rowUD.Value - 1) 'Only display the value selected by the NumericUpDown component.
        End If

    End Sub
End Class
