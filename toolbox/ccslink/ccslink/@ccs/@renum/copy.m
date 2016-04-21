function resp = copy(nn)
% COPY Creates a copy of an ENUM object.
%   O = COPY(RE) returns a copy of the RENUM object RE.
%
%   See also RENUM.
%   Copyright 2002-2003 The MathWorks, Inc.

%   $Revision: 1.2.2.1 $  $Date: 2003/11/30 23:10:56 $

nargchk(1,1,nargin);
if ~ishandle(nn),
    error('First Parameter must be a RENUM Handle.');
end

resp = ccs.renum;
copy_registerobj(nn,resp);
copy_rnumeric(   nn,resp);
copy_renum(      nn,resp);

% [EOF] copy.m
