function Name = getNewSimName(this, DefaultName)

% Copyright 2003 The MathWorks, Inc.

% Ask the user for a new scenario name.  Name must be unique.
% 'this' is MPCSims node.

while true
    DefaultName = inputdlg({['Name the new scenario:']}, ...
        'MPC input', 1, DefaultName);
    if isempty(DefaultName) || length(DefaultName) <= 0
        % User cancelled, so return
        Name = '';
        return
    end
    % Check for uniqueness.
    MPCSimNode = this.getChildren.find('Label',DefaultName{1});
    if isempty(MPCSimNode)
        % If none was found, desired label is unique.
        Name = DefaultName{1};
        return
    end
end
