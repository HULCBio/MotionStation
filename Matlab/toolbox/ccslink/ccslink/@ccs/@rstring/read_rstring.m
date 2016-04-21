function resp = read_rstring(rs,index,timeout)
% Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.4.4.1 $  $Date: 2003/11/30 23:12:17 $

error(nargchk(1,3,nargin));
if ~ishandle(rs),
    error('First Parameter must be a STRING Handle.');
end

if nargin == 1,
    resp = read_rnumeric(rs);
elseif nargin == 2,
    resp = read_rnumeric(rs,index);     
else
    resp = read_rnumeric(rs,index,timeout);
end

nullfound = find(resp==0);
if ~isempty(nullfound)
    resp = resp(1:nullfound(1));
else
    warning('Character array does not end with a NULL character');
end

resp = checkforNonASCII(resp);
resp = equivalent(rs,resp);

%-----------------------------------
function resp = checkforNonASCII(resp)
if resp<0 | resp>127
    warning('Non-ASCII characters in the result are saturated. Use READNUMERIC to get the exact numeric values ');
    % Saturate
    if resp<0,          resp = 0;
    elseif resp>127,    resp = 127;
    end
end

% [EOF] read_string.m
