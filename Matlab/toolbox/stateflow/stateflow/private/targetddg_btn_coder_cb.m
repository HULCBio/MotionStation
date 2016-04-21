function [res, err] = targetddg_btn_coder_cb(h, subDialogName)

% Copyright 2003 The MathWorks, Inc.

  % See if this dialog is already open 
  t            = DAStudio.ToolRoot;
  openD        = t.getOpenDialogs;
  hSubDialog   = [];
  subDialogTag = create_unique_dialog_tag_l(h);
    
  for i=1:size(openD)
    tag = openD(i).dialogTag;
    if strcmp(tag, subDialogTag)
      hSubDialog = openD(i);
      break;
    end
  end

  if ishandle(hSubDialog)
    hSubDialog.show;
  else  
    DAStudio.Dialog(h, 'Coder Options', 'DLG_STANDALONE');
  end

  err = [];
  res = 1;
  
  %------------------------------------------------------------------
  % Generate a unique tag.  Note: the tag MUST be the same as the one
  % in coder_opts_ddg
  %------------------------------------------------------------------
  function unique_tag = create_unique_dialog_tag_l(h)
    unique_tag = ['_DDG_Coder_Options_Dialog_Tag_', sf_scalar2str(h.Id)];