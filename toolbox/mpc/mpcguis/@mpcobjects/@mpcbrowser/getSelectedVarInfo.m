function varStruc = getSelectedVarInfo(h)

% GETSELECTEDVARINFO  Retrieves the selected variable structure 

% Author(s): 
% Revised:
% Copyright 1986-2003 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2004/04/10 23:37:44 $


thisSelection = h.javahandle.getSelectedRows;
varStruc = [];
if ~isempty(thisSelection)
    varStruc = h.variables(double(thisSelection(1))+1);
end

