function resp = copy(nn)
% COPY Creates a copy of an RENUM object.
%   O = COPY(EN) returns a copy of the ENUM object EN.
%
%   See also ENUM.
%   Copyright 2002-2003 The MathWorks, Inc.

%   $Revision: 1.2.2.1 $  $Date: 2003/11/30 23:07:56 $

nargchk(1,1,nargin);
if ~ishandle(nn),
    error('First Parameter must be an ENUM Handle.');
end

resp = ccs.enum;
copy_memoryobj(nn,resp);
copy_numeric(nn,resp);
copy_enum(nn,resp);

% [EOF] copy.m
