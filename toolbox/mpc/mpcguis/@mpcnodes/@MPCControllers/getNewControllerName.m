function Name = getNewControllerName(this, DefaultName)

% Name = getNewControllerName(this, DefaultName)
%
% Ask the user for a new controller name.  Name must be unique.

%  Author:  Larry Ricker
%  Copyright 1986-2003 The MathWorks, Inc.
%  $Revision: 1.1.8.3 $ $Date: 2004/04/10 23:36:01 $

isValid = false;
while ~isValid
    DefaultName = inputdlg({['Name the new controller:']},'MPC input',1,DefaultName);
    if isempty(DefaultName) || length(DefaultName) <= 0
        % User cancelled, so return
        Name = '';
        return
    end
    % Check for uniqueness.
    MPCControllerNode = this.getChildren.find('Label',DefaultName{1});
    if isempty(MPCControllerNode)
        % If none was found, desired label is unique.
        Name = DefaultName{1};
        return
    end
end
