function var = getSelectedVar(h)

% GETSELECTEDVAR  Retrieves the selected variable 

% Author(s): 
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2004/04/10 23:37:43 $


thisSelection = h.javahandle.getSelectedRows;
var = [];
if ~isempty(thisSelection)
    varStruc = h.variables(double(thisSelection(1))+1);
    if isempty(h.filename)
        var=evalin('base',varStruc.name);
    else
        S=load(h.filename);
        var=S.(varStruc.name);
    end        
end

