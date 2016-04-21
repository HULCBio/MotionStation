
% Copyright 2003 The MathWorks, Inc.

function result = is_simulink_handle(h)
  result = false;
  type = get(h, 'type');
  switch(type)
   case {'block', 'block_diagram', 'line', 'annotation', 'port'}
    result = true;  
  end

