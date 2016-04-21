function dlg_goto_source(objectId)

% Copyright 2003 The MathWorks, Inc.
  
  if ~sf('ishandle',objectId)
    return;
  end
  
  [chart,src] = sf('get',objectId,'.chart','.src.id');
  if src==0,
    src=[];
  else
    sf('Open',src); % this opens the appropriate subviewer
    sf('Explr', 'VIEW', src);
  end
  sf('FitToView',chart, [objectId, src]);