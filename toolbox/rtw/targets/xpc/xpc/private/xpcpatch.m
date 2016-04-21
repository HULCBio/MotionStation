function xpcpatch(filename, propval)

% XPCPATCH - xPC Target private function

% Copyright 1996-2004 The MathWorks, Inc.
% $Revision: 1.7.2.1 $ $Date: 2004/03/04 20:09:58 $

% patch kernel
xpcpatchkernel(filename, propval);

%patch tcpip related images
clear mex
if strcmpi(propval{11}, 'RS232') % HostTargetComm
  return
end
xpcpatchtcpip(filename, propval);
