function resp = copy(nn)
% COPY Creates a copy of a POINTER object.
%   O = COPY(PP) returns a copy of the POINTER object PP.
%
%   See also POINTER.
%   Copyright 2002-2003 The MathWorks, Inc.

%   $Revision: 1.2.2.1 $  $Date: 2003/11/30 23:10:20 $

nargchk(1,1,nargin);
if ~ishandle(nn),
    error('First Parameter must be a POINTER Handle.');
end

resp = ccs.pointer;
copy_memoryobj(nn,resp);
copy_numeric(nn,resp);
copy_pointer(nn,resp);

% [EOF] copy.m
