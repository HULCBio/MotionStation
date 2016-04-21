function dlg_goto_object(objectId)

% Copyright 2002 The MathWorks, Inc.
  
  if ~sf('ishandle',objectId)
    return;
  end
        
  sf('Open',objectId);
  
  if ~isempty(sf('get',objectId,'chart.isa'))
    sf('Select',objectId,[]);
  end
  
  sf('Explr', 'VIEW', objectId);
  