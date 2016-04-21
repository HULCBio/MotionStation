function resp = copy(nn)
% COPY Creates a copy of a MEMORYOBJ object.
%   O = COPY(MM) returns a copy of the MEMORYOBJ object MM.
%
%   See also MEMORYOBJ.
%   Copyright 2002-2003 The MathWorks, Inc.

%   $Revision: 1.3.2.1 $  $Date: 2003/11/30 23:09:17 $

nargchk(1,1,nargin);
if ~ishandle(nn),
    error('First Parameter must be a MEMORYOBJ Handle.');
end
resp = ccs.memoryobj;
copy_memoryobj(nn,resp);

% [EOF] copy.m


