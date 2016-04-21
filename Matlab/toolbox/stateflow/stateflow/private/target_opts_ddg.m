function dlgstruct = target_opts_ddg(h, name)

% Copyright 2002-2003 The MathWorks, Inc.

   isSfunOrRTW = false;
   if strcmp(h.Name, 'sfun') || strcmp(h.Name, 'rtw')
       isSfunOrRTW = true;
   end

  %------------------------------------------------------------------
  % First row
  %------------------------------------------------------------------
  % Name label
  lblName.Name    = 'Target Name:';
  lblName.Type    = 'text';
  lblName.RowSpan = [1 1];
  lblName.ColSpan = [1 3];
  lblName.Tag = strcat('sfTargetoptsdlg_', lblName.Name);
  
  % Name text
  txtName.Name    = h.Name;
  txtName.Type    = 'text';
  txtName.RowSpan = [1 1];
  txtName.ColSpan = [4 10];
  txtName.Tag = strcat('sfTargetoptsdlg_', txtName.Name);
  
  %------------------------------------------------------------------
  % Second row
  %------------------------------------------------------------------
  
  %-------------------------
  % Tab items
  %-------------------------
  item1.Name           = 'Custom code included at the top of generated code (e.g. #include''s)';
  item1.Type           = 'editarea';  
  item1.ObjectProperty = 'CustomCode';
  item1.Tag = strcat('sfTargetoptsdlg_', item1.Name);
  
  item2.Name           = 'Space-separated list of custom include directories';
  item2.Type           = 'editarea';
  item2.ObjectProperty = 'UserIncludeDirs';
  item2.Tag = strcat('sfTargetoptsdlg_', item2.Name);
  
  item3.Name           = 'Custom source files';
  item3.Type           = 'editarea';  
  item3.ObjectProperty = 'UserSources';
  item3.Tag = strcat('sfTargetoptsdlg_', item3.Name);
  
  item4.Name           = 'Custom libraries';
  item4.Type           = 'editarea';
  item4.ObjectProperty = 'UserLibraries';
  item4.Tag = strcat('sfTargetoptsdlg_', item4.Name);
  
  item5.Name           = 'Code generation directory';
  item5.Type           = 'editarea';
  item5.ObjectProperty = 'CodegenDirectory';
  item5.Tag = strcat('sfTargetoptsdlg_', item5.Name);
  
  item6.Name           = 'Custom initialization code (called from mdlInitialize)';
  item6.Type           = 'editarea';
  item6.ObjectProperty = 'CustomInitializer';
  item6.Tag            = strcat('sfTargetoptsdlg_', item6.Name);
   
  item7.Name           = 'Custom termination code (called from mdlTerminate)';
  item7.Type           = 'editarea';
  item7.ObjectProperty = 'CustomTerminator';
  item7.Tag            = strcat('sfTargetoptsdlg_', item6.Name);
  
  item8.Name           = 'Reserved names';
  item8.Type           = 'editarea';
  item8.ObjectProperty = 'ReservedNames';
  item8.Tag            = strcat('sfTargetoptsdlg_', item8.Name);



  %-------------------------
  % Tab panels
  %-------------------------
  tab1.Name = 'Include Code';
  tab1.Items = {item1};
  %tab1.Tag = 'real';
  
  tab2.Name = 'Include Paths';
  tab2.Items = {item2};
  %tab2.Tag = strcat('sfTargetoptsdlg_', tab2.Name);
  
  tab3.Name = 'Source Files';
  tab3.Items = {item3};
  %tab3.Tag = strcat('sfTargetoptsdlg_', tab3.Name);
  
  tab4.Name = 'Libraries';
  tab4.Items = {item4};
  %tab4.Tag = strcat('sfTargetoptsdlg_', tab4.Name);
  
  tab5.Name = 'Generated Code Directory';
  tab5.Items = {item5};
  %tab5.Tag = strcat('sfTargetoptsdlg_', tab5.Name);
  
  tab6.Name  = 'Initialization Code';
  tab6.Items = {item6};
  
  tab7.Name  = 'Termination Code';
  tab7.Items = {item7};

  tab8.Name  = 'Reserved Names';
  tab8.Items = {item8};

  %-------------------------
  % Tab
  %-------------------------
  tabMain.Name = 'tabContainer';
  tabMain.Type = 'tab';
  tabMain.RowSpan = [2 2];
  tabMain.ColSpan = [1 10];
  if isSfunOrRTW
    tabMain.Tabs    = {tab1, tab2, tab3, tab4, tab5, tab6, tab7, tab8}; 
  else
    tabMain.Tabs = {tab1, tab2, tab3, tab4, tab5, tab8};
  end
  tabMain.Tag = strcat('sfTargetoptsdlg_', tabMain.Name);

  %------------------------------------------------------------------
  % main panel
  %------------------------------------------------------------------
  pnlMain.Type       = 'panel';
  pnlMain.LayoutGrid = [2 10];
  pnlMain.Items      = {lblName, txtName, tabMain};
  %pnlMain.Tag       =  'sfTargetoptsdlg_pnlMain';
                
  %------------------------------------------------------------------
  % Main dialog
  %------------------------------------------------------------------
  dlgstruct.DialogTitle = ['Stateflow ', h.Name, ' Target Options'];
  dlgstruct.Items       = {pnlMain};  
  dlgstruct.DialogTag   = create_unique_dialog_tag_l(h);
  dlgstruct.HelpMethod  = 'sfhelp';
  dlgstruct.HelpArgs    = {'TARGET_OPTIONS_DIALOG'}; 
  dlgstruct.DisableDialog = ~is_object_editable(h);

  %------------------------------------------------------------------
  % Generate a unique tag.  Note: the tag MUST be the same as the one
  % in targetddg_btn_target_cb
  %------------------------------------------------------------------
  function unique_tag = create_unique_dialog_tag_l(h)
    unique_tag = ['_DDG_Target_Options_Dialog_Tag_', sf_scalar2str(h.Id)];
  