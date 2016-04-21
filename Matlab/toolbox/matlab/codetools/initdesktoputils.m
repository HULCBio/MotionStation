function initdesktoputils
%INITDESKTOPUTILS Initialize the MATLAB path for the desktop and desktop tools.
%   INITDESKTOPUTILS initializes the MATLAB path for the desktop and desktop
%   tools.  This function is only intended to be called from matlabrc.m and 
%   will not have any effect if called after MATLAB is initialized.

%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $

if usejava('mwt')
    com.mathworks.jmi.MatlabPath.setInitialPath(path);
end
