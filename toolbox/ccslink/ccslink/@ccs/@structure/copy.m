function resp = copy(st)
% COPY Creates a copy of a STRUCTURE object.
%   O = COPY(ST) returns a copy of the STRUCTURE object ST.
%
%   See also STRUCTURE.
%   Copyright 2002-2003 The MathWorks, Inc.

nargchk(1,1,nargin);
if ~ishandle(st),
    error('First Parameter must be a STRUCTURE Handle.');
end

resp = ccs.structure;
copy_structure(st,resp);

% [EOF] copy.m
