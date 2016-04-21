function addprop(hLink,prop)
%ADDPROP Add property for linking

% Copyright 2003 The MathWorks, Inc.

if ~isstr(prop)
  error('MATLAB:graphics:linkprop','string input required');
end

propnames = get(hLink,'PropertyNames');

if ~isempty(propnames) && iscellstr(propnames)

    % Only update if not already in list
    if ~any(strcmp(propnames,prop))
 
       % Add new property  
       set(hLink,'PropertyNames',{propnames{:},prop}); 
    end
else
    set(hLink,'PropertyNames',{prop});
end

% Update listeners, call to pseudo-private method
feval(get(hLink,'UpdateFcn'),hLink); 
 
