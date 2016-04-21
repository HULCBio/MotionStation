function resp = copy(ss)
% COPY Creates a copy of a STRING object.
%   O = COPY(SS) returns a copy of the STRING object SS.
%
%   See also STRING.
%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.2.2.1 $  $Date: 2003/11/30 23:12:48 $

nargchk(1,1,nargin);
if ~ishandle(ss),
    error('First Parameter must be a STRING Handle.');
end

resp = ccs.string;
copy_memoryobj(ss,resp);
copy_numeric(  ss,resp);
copy_string(   ss,resp);

% [EOF] copy.m
