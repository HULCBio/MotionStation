function deleteconfirm(fileName,refreshFlag)
%DELETECONFIRM Confirm the deletion of a file with a dialog box
%   See also VISDIR.

% Copyright 1984-2003 The MathWorks, Inc. 

if nargin<2
    refreshFlag = 0;
end

confirmMsg = 'Delete now';
cancelMsg = 'Cancel';

buttonName=questdlg(['Delete file ' fileName '?'], 'Confirm Delete', ...
	confirmMsg, cancelMsg, cancelMsg);

switch buttonName,
case confirmMsg, 
	delete(fileName)
    if refreshFlag
        com.mathworks.mde.filebrowser.FileBrowser.refresh;
    end
case cancelMsg,
    % No action
end 
