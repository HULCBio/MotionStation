function OK = renameController(this, OldName, NewName)

% OK = renameController(this, OldName, NewName)

%	Copyright 1986-2003 The MathWorks, Inc. 
%	$Revision: 1.1.8.3 $  $Date: 2004/01/16 20:05:23 $
%   Author:  Larry Ricker

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
    waitfor(errordlg(sprintf(['Name "%s" is already in use.  ', ...
        'Reverting to "%s".'], ...
        NewName, OldName), 'MPC Error', 'modal'));
    OK = false;
end
