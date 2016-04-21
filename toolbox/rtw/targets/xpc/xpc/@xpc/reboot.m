function reboot(xpcObj)
% REBOOT Reboot the target system pointed to by XPCOBJ.
%   REBOOT(XPCOBJ) will reboot the target system.
%
%   See also UNLOAD.
%

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.6 $ $Date: 2002/03/25 04:17:18 $


if (prod(size(xpcObj)) > 1)
  error(sprintf('%s: Not a scalar', inputname(1)));
end

try
  xpcObj = set(xpcObj, 'Command', 'Boot');
catch
  error(xpcgate('xpcerrorhandler'));
end

%% EOF reboot.m
