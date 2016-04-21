function p = privateGetIviPath
%PRIVATEGETIVICPATH Find the IVI-C driver installation directory.
%
%   D = PRIVATEGETIVICPATH returns the IVI-C driver installation directory
%   to allow access to the drivers and function panels.
%
%   If the IVI shared components have not been properly installed, D will
%   be an empty string.
%
%   This is a helper function used by functions in the Instrument
%   Control Toolbox. This function should not be called directly
%   by users.

%   PE 10-09-03
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.3 $  $Date: 2004/02/01 21:55:23 $

persistent ivicpath

if isempty(ivicpath)
    try
        ivicpath = winqueryreg('HKEY_LOCAL_MACHINE', 'SOFTWARE\IVI\', 'IVIStandardRootDir');
    catch
        ivicpath = '';
    end
end

p = ivicpath;

