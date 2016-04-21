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
%    $Revision: 1.10.2.4 $  $Date: 2003/08/29 04:40:23 $

ArgChkMsg = nargchk(1,1,nargin);
if ~isempty(ArgChkMsg)
    error('daq:ischannel:argcheck', ArgChkMsg);
end

if nargout > 1,
   error('daq:ischannel:argcheck', 'Too many output arguments.')
end

% Return true if the object is of class aichannel or aochannel.
out = logical(sum(strcmp(class(obj), {'aichannel', 'aochannel'})));


