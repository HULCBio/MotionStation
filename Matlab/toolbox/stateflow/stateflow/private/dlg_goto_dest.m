function dlg_goto_dest(objectId)

% Copyright 2003 The MathWorks, Inc.
  
  if ~sf('ishandle',objectId)
    return;
  end
  
  [chart,dst] = sf('get',objectId,'.chart','.dst.id');
  if dst==0,
    dst=[];
  else
    sf('Open',dst); % this opens the appropriate subviewer
    sf('Explr', 'VIEW', dst);
  end  
  sf('FitToView',chart, [objectId, dst]);