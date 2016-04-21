function removeprop(hLink,prop)
%REMOVEPROP Remove property for linking

% Copyright 2003 The MathWorks, Inc.

if ~isstr(prop)
  error('MATLAB:graphics:linkprop','string input required');
end

propnames = get(hLink,'PropertyNames');

% If non-empty cell string 
if ~isempty(propnames) && iscellstr(propnames)

    % If we found a match
    ind = find(strcmp(propnames,prop)==1);
        
    % Annoying cell string management, isn't there a simpler 
    % way to remove an item from a cell string?
    if ~isempty(ind)
    
       % Force one element, we should never have duplicate
       % property entries anyway 
       ind = ind(1);

       if ind==1 
           propnames = {propnames{2:end}};
       elseif ind==length(propnames)
           propnames = {propnames{1:end-1}};
       else
           propnames = {propnames{1:ind-1},propnames{ind+1:end}}; 
       end
    end
    
    set(hLink,'PropertyNames',propnames);

    % Update listeners, call to pseudo-private method
    feval(get(hLink,'UpdateFcn'),hLink); 
end

 
