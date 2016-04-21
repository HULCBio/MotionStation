function out = ischannel(obj)
%ISCHANNEL True for channels.
%
%    ISCHANNEL(OBJ) returns a logical 1 if OBJ is a channel or channel array
%    and returns a logical 0 otherwise.
%
%    See also ISVALID.
%

%    MP 4-16-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.10.2.4 $  $Date: 2003/08/29 04:41:16 $

ArgChkMsg = nargchk(0,1,nargin);
if ~isempty(ArgChkMsg)
    error('daq:ischannel:argcheck', ArgChkMsg);
end

if nargout > 1
   error('daq:ischannel:argcheck', 'Too many output arguments.')
end

% A daqdevice object (Analog Input, Analog Output or Digital IO) 
% can never be a channel object.
out = logical(0);


