function resp = copy(ss)
% COPY Creates a copy of a RSTRING object.
%   O = COPY(RS) returns a copy of the RSTRING object RS.
%
%   See also RSTRING.
%   Copyright 2002-2003 The MathWorks, Inc.

%   $Revision: 1.2.2.1 $  $Date: 2003/11/30 23:12:09 $

nargchk(1,1,nargin);
if ~ishandle(ss),
    error('First Parameter must be a RSTRING Handle.');
end

resp = ccs.rstring;
copy_registerobj(ss,resp);
copy_rnumeric(   ss,resp);
copy_rstring(    ss,resp);

% [EOF] copy.m

