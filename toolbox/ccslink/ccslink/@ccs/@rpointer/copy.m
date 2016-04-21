function resp = copy(nn)
% COPY Creates a copy of a RPOINTER object.
%   O = COPY(RP) returns a copy of the RPOINTER object RP.
%
%   See also RPOINTER.
%   Copyright 2002-2003 The MathWorks, Inc.

%   $Revision: 1.2.2.1 $  $Date: 2003/11/30 23:11:56 $

nargchk(1,1,nargin);
if ~ishandle(nn),
    error('First Parameter must be a RPOINTER Handle.');
end

resp = ccs.rpointer;
copy_registerobj(nn,resp);
copy_rnumeric(nn,resp);
copy_rpointer(nn,resp);

% [EOF] copy.m
