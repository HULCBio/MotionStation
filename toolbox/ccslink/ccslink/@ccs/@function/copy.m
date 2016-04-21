function resp = copy(ff)
% COPY Creates a copy of a FUNCTION object.
%   O = COPY(FF) returns a copy of the FUNCTION object FF.

%   See also FUNCTION.
%   Copyright 2002-2003 The MathWorks, Inc.


nargchk(1,1,nargin);
if ~ishandle(ff),
    error(generateccsmsgid('InvalidHandle'),'First Parameter must be a FUNCTION Handle.');
end

resp = ccs.function;
copy_function(ff,resp);

% [EOF] copy.m
