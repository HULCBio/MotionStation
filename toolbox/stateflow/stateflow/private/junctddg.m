function dlgstruct = junctddg(h, name)

% Copyright 2002-2003 The MathWorks, Inc.

  % Parent label
  lblParent.Name    = 'Parent:';   
  lblParent.Type    = 'text';  
  lblParent.RowSpan = [1 1];
  lblParent.ColSpan = [1 1];
  lblParent.Tag     = strcat('sfJunctdlg_', lblParent.Name);
  
  hypParent.Name         = ddg_get_parent_name(h.getParent);
  hypParent.Type         = 'hyperlink';
  hypParent.RowSpan      = [1 1];
  hypParent.ColSpan      = [2 2];
  hypParent.Tag          = 'hypParentTag';
  hypParent.MatlabMethod = 'sf';
  hypParent.MatlabArgs = {'Private', 'dlg_goto_parent', h.Id};
 
  % Description editarea
  desc.Name    = 'Description';
  desc.Type    = 'editarea';
  desc.RowSpan = [2 2];
  desc.ColSpan = [1 2];
  desc.ObjectProperty = 'Description';
  desc.Tag = strcat('sfJunctdlg_', desc.Name);
  
  %Document hyperlink
  doclinkName.Name = 'Document Link:';
  doclinkName.RowSpan = [3 3];
  doclinkName.ColSpan = [1 1];
  doclinkName.Type = 'hyperlink';
  doclinkName.Tag = 'doclinkNameTag';
  doclinkName.MatlabMethod = 'sf';
  doclinkName.MatlabArgs = {'Private', 'dlg_goto_document', h.Id};
  
  %Document link edit area
  doclinkEdit.Name = '';
  doclinkEdit.RowSpan = [3 3];
  doclinkEdit.ColSpan = [2 2];
  doclinkEdit.Type = 'edit';
  doclinkEdit.ObjectProperty = 'Document';
  doclinkEdit.Tag = 'sfJunctdlg_doclinkEdit';
  
  % main panel
  pnlMain.Type       = 'panel';
  pnlMain.LayoutGrid = [3 2];
  pnlMain.ColStretch = [0 1];
  pnlMain.RowStretch = [0 1 0];
  pnlMain.Items      = {lblParent, hypParent, ...
                        desc, ...
                        doclinkName, doclinkEdit};
  pnlMain.Tag        = 'sfJunctddg_pnlMain';
   
  %------------------------------------------------------------------
  % Main dialog
  %------------------------------------------------------------------
  
  if (strcmp(h.Type,'HISTORY') == 1)
    title = 'History Junction';
    dlgstruct.HelpArgs = {'history_junction_dialog'};
  else
    title = 'Connective Junction';
    dlgstruct.HelpArgs = {'connective_junction_dialog'};
  end
  % if the developer feature is on append the id to the title
  if sf('Feature','Developer')
    id = strcat('#', sf_scalar2str(h.Id));
    dlgstruct.DialogTitle = strcat(title, id);
  else
    dlgstruct.DialogTitle = title;
  end
  dlgstruct.Items         = {pnlMain};
  dlgstruct.CloseCallback = 'sf';
  dlgstruct.CloseArgs     = {'SetDynamicDialog', h.Id, []};
  dlgstruct.HelpMethod = 'sfhelp';
  dlgstruct.DisableDialog = ~is_object_editable(h);
