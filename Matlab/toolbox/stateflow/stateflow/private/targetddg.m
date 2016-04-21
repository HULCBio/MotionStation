function dlgstruct = targetddg(h, name)
  % See if this dialog is already open 

% Copyright 2002-2003 The MathWorks, Inc.

    t = DAStudio.ToolRoot;
    openD = t.getOpenDialogs;
    thisDialog = [];
    thisDialogTag = create_unique_dialog_tag_l(h);
    
    for i=1:size(openD)
      tag = openD(i).dialogTag;
      if strcmp(tag, thisDialogTag)
        % We have a match
        thisDialog = openD(i);
        break;
      end
    end
	
    isRTW = false;
    if strcmp(h.Name, 'rtw')
      isRTW = true;
    end
    
  %------------------------------------------------------------------
  % First row
  %------------------------------------------------------------------
  % Name field
  txtName.Name             = 'Target Name:';
  txtName.Type             = 'edit';
  txtName.RowSpan          = [1 1];
  txtName.ColSpan          = [1 4];
  txtName.ObjectProperty   = 'Name';
  txtName.Tag              = strcat('sfTargetdlg_', txtName.Name);
  if isRTW txtName.Enabled = false; end
  
  %------------------------------------------------------------------
  % Second row
  %------------------------------------------------------------------
  % Parent label
  lblParent.Name         = 'Parent:';   
  lblParent.Type         = 'text';  
  lblParent.RowSpan      = [2 2];
  lblParent.ColSpan      = [1 1];
  lblParent.Tag          = strcat('sfTargetdlg_', lblParent.Name);
  
  % Parent hyperlink
  hypParent.Name         = ddg_get_parent_name(h.getParent);
  hypParent.Type         = 'hyperlink';
  hypParent.RowSpan      = [2 2];
  hypParent.ColSpan      = [2 4];
  hypParent.MatlabMethod = 'sf';
  hypParent.Tag          = 'hypParentTag';
  hypParent.MatlabArgs   = {'Private', 'dlg_goto_parent', h.Id};
  
  %------------------------------------------------------------------
  % Third row
  %------------------------------------------------------------------ 
  % Target Language label
  lblTL.Name      = 'Target Language:';
  lblTL.Type      = 'text';
  lblTL.RowSpan   = [3 3];
  lblTL.ColSpan   = [1 1];
  lblTL.Tag       = strcat('sfTargetdlg_', lblTL.Name);
  
  lblTLv.Name     = 'ANSI-C';
  lblTLv.Type     = 'text';
  lblTLv.RowSpan  = [3 3];
  lblTLv.ColSpan  = [2 4];
  lblTLv.Tag      = strcat('sfTargetdlg_', lblTLv.Name);

  %------------------------------------------------------------------
  % Fourth row
  %------------------------------------------------------------------
  % Target combobox
  cmbTarget.Type          = 'combobox';
  cmbTarget.RowSpan       = [4 4];
  cmbTarget.ColSpan       = [1 4];
  cmbTarget.DialogRefresh = 1;
  cmbTarget.Tag           = 'cmbTarget';
  %populate the entries based on the targetmethods buildCommand
  cmbTarget.Entries       = get_build_combo_string_l(h.Id); 
  % figure out the current selection of the combobox	 				 
  if ~isempty(thisDialog)
    cmbTarget.Value = thisDialog.getWidgetValue('cmbTarget');
  else
	cmbTarget.Value = 0;
  end
  
  %------------------------------------------------------------------
  % Fifth row
  %------------------------------------------------------------------
  btnTarget.Name         = 'Target Options';
  btnTarget.Type         = 'pushbutton';
  btnTarget.RowSpan      = [5 5];
  btnTarget.ColSpan      = [1 1];
  btnTarget.MatlabMethod = 'sf';
  btnTarget.Tag          = 'btnTargetTag';
  btnTarget.MatlabArgs   = {'Private', 'targetddg_btn_target_cb', h, 'Target Options'};
  
  btnCoder.Name          = 'Coder Options';
  btnCoder.Type          = 'pushbutton';
  btnCoder.RowSpan       = [5 5];
  btnCoder.ColSpan       = [2 2];
  btnCoder.MatlabMethod  = 'sf';
  btnCoder.Tag           = 'btnCoderTag';
  btnCoder.MatlabArgs    = {'Private', 'targetddg_btn_coder_cb', h, 'Coder Options'};
  
  btnBuild.Name          = get_build_button_string_l(h.Id, cmbTarget.Value+1);
  btnBuild.Type          = 'pushbutton';
  btnBuild.RowSpan       = [5 5];
  btnBuild.ColSpan       = [4 4];
  btnBuild.Tag           = 'btnBuildTag';
  
  % this is what happens when user clicks the build button
  val                    = cmbTarget.Value+1;
  buildCommands          = target_methods('buildcommands',h.Id);
  btnBuild.MatlabMethod  = 'sf';
  btnBuild.MatlabArgs    = {'Private','target_methods','build', h.Id, buildCommands{val,3}};
  
  
  %------------------------------------------------------------------
  % Sixth row
  %------------------------------------------------------------------
  chkLibSet.Name           = 'Use settings for all libraries';
  chkLibSet.Type           = 'checkbox';
  chkLibSet.RowSpan        = [6 6];
  chkLibSet.ColSpan        = [1 1];  
  chkLibSet.ObjectProperty = 'ApplyToAllLibs';
  chkLibSet.Tag            = strcat('sfTargetdlg_', chkLibSet.Name);
  
  %------------------------------------------------------------------
  % Seventh row
  %------------------------------------------------------------------
  % Description editarea
  desc.Name           = 'Description';
  desc.Type           = 'editarea';
  desc.RowSpan        = [7 7];
  desc.ColSpan        = [1 4];
  desc.ObjectProperty = 'Description';
  desc.Tag            = strcat('sfTargetdlg_', desc.Name);
    
  %------------------------------------------------------------------
  % Eigth row
  %------------------------------------------------------------------
  %Document hyperlink
  doclinkName.Name           = 'Document Link:';
  doclinkName.RowSpan        = [8 8];
  doclinkName.ColSpan        = [1 1];
  doclinkName.Type           = 'hyperlink';
  doclinkName.Tag            = 'doclinkNameTag';
  doclinkName.MatlabMethod   = 'sf';
  doclinkName.MatlabArgs     = {'Private', 'dlg_goto_document', h.Id};
  
  %Document link edit area
  doclinkEdit.Name           = '';
  doclinkEdit.RowSpan        = [8 8];
  doclinkEdit.ColSpan        = [2 4];
  doclinkEdit.Type           = 'edit';
  doclinkEdit.ObjectProperty = 'Document';
  doclinkEdit.Tag            = 'sfTargetdlg_doclinkEdit';
  
  % main panel
  pnlMain.Type       = 'panel';
  pnlMain.LayoutGrid = [8 4];
  pnlMain.RowStretch = [0 0 0 0 0 0 1 0];
  pnlMain.ColStretch = [0 0 1 0];
  pnlMain.Items      = {txtName, ...
                        lblParent, hypParent, ...
                        lblTL, lblTLv, ...
                        cmbTarget, ...
                        btnTarget, btnCoder, btnBuild, ...
                        chkLibSet, ...
                        desc, ...
                        doclinkName, doclinkEdit};
  pnlMain.Tag        = 'sfTargetdlg_pnlMain';
   
  %------------------------------------------------------------------
  % Main dialog
  %------------------------------------------------------------------
  if strcmp(name, 'tab')
    dlgstruct.Name  = h.Name;
    dlgstruct.Items = {pnlMain};
  else
    if isRTW
      title = 'Stateflow RTW Target Builder';
    else
      title = 'Stateflow Target Builder';
    end
    % if the developer feature is on append the id to the title
    if sf('Feature','Developer')
      id = strcat('#', sf_scalar2str(h.Id));
      dlgstruct.DialogTitle = strcat(title, id);
    else
      dlgstruct.DialogTitle = title;
    end
    dlgstruct.SmartApply       = 0;
    dlgstruct.Items            = {pnlMain};
    dlgstruct.DialogTag        = create_unique_dialog_tag_l(h);
    dlgstruct.CloseCallback    = 'sf';
    dlgstruct.CloseArgs        = {'Private', 'targetddg_preclose_callback', '%dialog'};
    dlgstruct.PreApplyCallback = 'sf';
    dlgstruct.PreApplyArgs     = {'Private', 'targetddg_preapply_callback', '%dialog'};
  end
  
  dlgstruct.HelpMethod = 'sfhelp';
  if strcmp(h.Name, 'sfun')
    dlgstruct.HelpArgs = {'simulation_target_dialog'};
  elseif strcmp(h.Name, 'rtw')
    dlgstruct.HelpArgs = {'rtw_target_dialog'};
  else
    dlgstruct.HelpArgs = {'custom_target_dialog'};
  end
  dlgstruct.DisableDialog = ~is_object_editable(h);

  %------------------------------------------------------------------
  % Gets the build button string based on the selected item in the
  % combobox
  %------------------------------------------------------------------
  function name = get_build_button_string_l(targetId, cmbSelected) 
    buildCommands = target_methods('buildcommands',targetId);
    name          = buildCommands{cmbSelected,2};

  %------------------------------------------------------------------
  % Gets the combobox entry from target_methods('buildCommands', id)
  %------------------------------------------------------------------
  function entries = get_build_combo_string_l(targetId)
    buildCommands = target_methods('buildCommands', targetId);
    entries       = {buildCommands{:,1}};
    
  %------------------------------------------------------------------
  % Generate a unique tag 
  %------------------------------------------------------------------
  function unique_tag = create_unique_dialog_tag_l(h)
    unique_tag = ['_DDG_Target_Dialog_Tag_', sf_scalar2str(h.Id)];
    