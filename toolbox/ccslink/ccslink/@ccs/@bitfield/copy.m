function resp = copy(nn)
% COPY Creates a copy of a BITFIELD object.
%   O = COPY(BB) returns a copy of the BITFIELD object BB.
%
%   See also BITFIELD.
%   Copyright 2002-2003 The MathWorks, Inc.

%   $Revision: 1.2.2.1 $  $Date: 2003/11/30 23:06:26 $

nargchk(1,1,nargin);
if ~ishandle(nn),
    error('First Parameter must be a BITFIELD Handle.');
end

resp = ccs.bitfield;
copy_memoryobj(nn,resp);
copy_bitfield(nn,resp);

% [EOF] copy.m
