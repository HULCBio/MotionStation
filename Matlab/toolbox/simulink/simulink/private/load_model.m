function oMdlsLoaded = load_model(iMdl)
%LOAD_MODEL Load a model if it not loaed and returns a cell array of model (and
%           library) that have been loaded as a result of loading this model.

% Copyright 2003 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $
%  By: Murali Yeddanapudi, 14-May-2003
  
  oMdlsLoaded = {};
  openMdls = find_system('SearchDepth',0, 'type','block_diagram');

  if isempty(strmatch(iMdl, openMdls, 'exact'))
    load_system(iMdl);
    openMdlsAfterLoad = find_system('SearchDepth',0, 'type','block_diagram');
    oMdlsLoaded = setdiff(openMdlsAfterLoad, openMdls);
  end
  
%endfunction