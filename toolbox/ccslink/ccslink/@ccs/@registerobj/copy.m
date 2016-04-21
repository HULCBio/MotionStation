function resp = copy(nn)
% COPY Creates a copy of a REGISTEROBJ object.
%   O = COPY(RR) returns a copy of the REGISTEROBJ object RR.
%
%   See also REGISTEROBJ.
%   Copyright 2002-2003 The MathWorks, Inc.

%   $Revision: 1.3.2.1 $  $Date: 2003/11/30 23:10:35 $

nargchk(1,1,nargin);
if ~ishandle(nn),
    error('First Parameter must be a REGISTEROBJ Handle.');
end

resp = ccs.registerobj;
copy_registerobj(nn,resp);

% [EOF] copy.m


