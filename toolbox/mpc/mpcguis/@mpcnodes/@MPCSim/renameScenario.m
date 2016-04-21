function OK = renameScenario(this, OldName, NewName)

%OK = renameScenario(this, OldName, NewName)

% Author(s): Larry Ricker
% Revised: 
% Copyright 1986-2003 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2003/12/04 01:35:04 $

if strcmp(OldName, NewName)
    % Name hasn't changed
    OK = true;
    return
end
if isempty(this.up.getChildren.find('Label', NewName));
    % Proposed NewName is unique, so rename
    this.Label = NewName;
    OK = true;
else
    % Not unique, so post error message
    waitfor(errordlg(sprintf(['Name "%s" is already in use.', ...
            '  Reverting to "%s".'], ...
        NewName, OldName), 'MPC Error', 'modal'));
    OK = false;
end
