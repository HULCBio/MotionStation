function resp = copy(nn)
% COPY Creates a copy of a NUMERIC object.
%   O = COPY(NN) returns a copy of the NUMERIC object NN.
%
%   See also NUMERIC.
%   Copyright 2002-2003 The MathWorks, Inc.

%   $Revision: 1.3.2.1 $  $Date: 2003/11/30 23:09:49 $

nargchk(1,1,nargin);
if ~ishandle(nn),
    error('First Parameter must be a NUMERIC Handle.');
end

resp = ccs.numeric;
copy_memoryobj(nn,resp);
copy_numeric(nn,resp);

% [EOF] copy.m
