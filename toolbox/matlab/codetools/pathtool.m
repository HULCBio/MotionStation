function pathtool
%PATHTOOL View, modify, and save the MATLAB search path.
%   PATHTOOL opens the MATLAB Set Path tool, which allows you to view,
%   manipulate, and save the MATLAB search path.
%
%   See also PATH, ADDPATH, RMPATH, SAVEPATH.

%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 1.1.6.5 $

% Make sure that we can support the Path tool on this platform.
errormsg = javachk('mwt', 'The Path tool');
if ~isempty(errormsg)
	error('MATLAB:pathtool:UnsupportedPlatform', errormsg);
end

try
    % Launch Java Path Browser
    com.mathworks.mlservices.MLPathBrowserServices.invoke;
catch
    error('MATLAB:pathtool:PathtoolFailed', 'Failed to open Path tool');
end
