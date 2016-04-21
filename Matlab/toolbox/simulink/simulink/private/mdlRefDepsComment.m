function oStr = mdlRefDepsComment(h, callback, tag, hDlg)
%
% Abstract
%  This is used to generate the comment in the ModelDependencies field
%  on the model reference page.  By default, the following comment will
%  show up in the field to help the user.  If the user makes any changes
%  we will save those changes to the ModelDependencies parameter, and 
%  display them the next time the dialog is open.  
%
%  This can be called from 2 places, either the Apply callback (callback
%  is true), or when the dialog is created (callback is false).
%

% Copyright 2003 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $
  
  hSrc = h.getSourceObject;
  
  cr = sprintf('\n');
  comment = ['% Specify the model dependencies as a cell array of file names.  The dependencies', cr, ...
             '% automatically include the model.mdl and linked library .mdl files.  For files', cr, ... 
             '% not on the MATLAB path, use absolute paths; prefix $MDL to a file path if the', cr, ...
             '% path is relative to the location of the .mdl file; wildcards are allowed; use a ''%''', cr, ... 
             '% to comment out a line; use ''...'' to continue lines.  For example,', cr, ...
             '%', cr, ...
             '% {''D:\Work\parameters.mat'', ''$MDL\mdlvars.mat'', ...', cr, ...
             '% ''D:\Work\masks\*.m''}'];
  
  % We are being called from the preApply callback of the dialog.
  if callback
    val = hDlg.getWidgetValue(tag);
    if ~strcmp(val, comment)
      oStr = val;
    else
      oStr = '';
    end
  else
    currPrm = get_param(hSrc,'ModelDependencies');
    if ~isempty(currPrm) && ~strcmp(currPrm, comment)
      oStr = currPrm;
    else
      oStr = comment;
    end
  end
  
%endfunction