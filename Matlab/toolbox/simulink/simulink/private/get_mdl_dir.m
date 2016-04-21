function oDir = get_mdl_dir(iMdl)
%GET_MDL_DIR Returns the directory where a model has is located

% $Revision: 1.1.6.2 $
% By: Murali Yeddanapudi, 14-May-2003
% Copyright 1990-2003 The MathWorks, Inc.
    
  oDir = ''; % assume

  iMdlIsWithOutExt = isempty(regexp(lower(iMdl), '.+\.mdl$'));

  % CASE 1.

  % add the extension .mdl if it is missing and see if it is
  % visible from the current dir, with out relying on the matlab path
  mdl = '';
  try
    if iMdlIsWithOutExt
      mdl = ls([iMdl, '.mdl']);
      if isempty(mdl),
        mdl = ls([iMdl, '.MDL']);
      end
    else
      mdl = ls(iMdl);
    end
  catch
    mdl = '';    
  end

  if ~isempty(mdl)
    [oDir,n,e,v] = fileparts(mdl);
    return;
  end

  % CASE 2.

  % if we are here then we need to look for iMdl using which command

  % first try with lower case extension
  mdlWithExt = iMdl;
  if iMdlIsWithOutExt, mdlWithExt = [iMdl, '.mdl']; end
  mdl = which(mdlWithExt);
  if ~isempty(mdl),
    [oDir, name, ext, versn] = fileparts(mdl);
    return;
  end

  % try again with upper case extension
  mdlWithExt = iMdl;
  if iMdlIsWithOutExt, mdlWithExt = [iMdl, '.MDL']; end
  mdl = which(mdlWithExt);
  if ~isempty(mdl),
    [oDir, name, ext, versn] = fileparts(mdl);
    return;
  end

  % CASE 3.

  % if we are here the model is either in memory we play some games
  % with the which command to figure out where it came from.

  [tmp1, mdl, tmp2, tmp3] = fileparts(iMdl);
  mdl = which(mdl);
  if isequal(mdl, deblank(ls(mdl)))
    [oDir, tmp1, tmp2, tmp3] = fileparts(mdl);
    return;
  end

%endfunction
