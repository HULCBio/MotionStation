function loadconstr(Editor,SavedData)
%LOADCONSTR  Reloads saved constraint data.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.9 $  $Date: 2002/04/10 05:01:57 $

% Clear existing constraints
delete(Editor.findconstr);

% Create and initialize new constraints
for ct=1:length(SavedData),
    % Recreate constraint
    C = Editor.newconstr(SavedData(ct).Type);
    C.load(SavedData(ct).Data);
	% Add to constraint list (includes rendering)
	Editor.addconstr(C);
    % Unselect
    C.Selected = 'off';
end

% Update limits
updateview(Editor)
