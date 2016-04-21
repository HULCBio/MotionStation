function resp = copy(nn)
% COPY Creates a copy of an RNUMERIC object.
%   O = COPY(RN) returns a copy of the RNUMERIC object RN.
%
%   See also RNUMERIC.
%   Copyright 2002-2003 The MathWorks, Inc.

%   $Revision: 1.3.4.1 $  $Date: 2003/11/30 23:11:27 $

nargchk(1,1,nargin);
if ~ishandle(nn),
    error('First Parameter must be a RNUMERIC Handle.');
end

resp = ccs.rnumeric;
copy_registerobj(nn,resp);
copy_rnumeric(nn,resp);

% [EOF] copy.m
