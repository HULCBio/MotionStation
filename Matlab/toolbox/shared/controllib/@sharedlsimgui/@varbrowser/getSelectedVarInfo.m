function varStruc = getSelectedVarInfo(h)

% GETSELECTEDVARINFO  Retrieves the selected variable structure 

% Author(s): 
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:25:10 $


thisSelection = h.javahandle.getSelectedRows;
varStruc = [];
if ~isempty(thisSelection)
    varStruc = h.variables(double(thisSelection(1))+1);
end

