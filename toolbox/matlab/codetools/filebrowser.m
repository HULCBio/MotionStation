function filebrowser
%FILEBROWSER Open the Current Directory browser or bring it to the front.
%
%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 1.1.6.6 $

err = javachk('mwt', 'The Current Directory Browser');
if ~isempty(err)
    error(err);
end

try
    % Launch the Current Directory Browser
    com.mathworks.mde.filebrowser.FileBrowser.invoke;    
catch
    % Failed. Bail
    error('Failed to open the Current Directory Browser');
end
