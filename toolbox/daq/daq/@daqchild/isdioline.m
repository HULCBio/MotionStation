function out = isdioline(obj)
%ISDIOLINE True for lines.
%
%    ISDIOLINE(OBJ) returns a logical 1 if OBJ is a line or line 
%    array and returns a logical 0 otherwise.
%
%    See also ISVALID.
%

%    MP 4-16-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.4.2.4 $  $Date: 2003/08/29 04:40:24 $

ArgChkMsg = nargchk(1,1,nargin);
if ~isempty(ArgChkMsg)
    error('daq:isdioline:argcheck', ArgChkMsg);
end

if nargout > 1,
   error('daq:isdioline:argcheck', 'Too many output arguments.')
end

% Return true if the object is of type 'dioline'.
out = logical(strcmp(class(obj), {'dioline'}));
