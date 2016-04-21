function resp = readnumeric(nn,index,timeout)

% Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.3.4.2 $  $Date: 2003/11/30 23:12:18 $

error(nargchk(1,3,nargin));
if ~ishandle(nn),
    error(generateccsmsgid('InvalidHandle'),'First Parameter must be a RSTRING Handle.');
end

if nargin == 1,
    resp = read_rnumeric(nn);
elseif nargin == 2,
    resp = read_rnumeric(nn,index);     
else
    resp = read_rnumeric(nn,index,timeout);
end

%  [EOF] readnumeric.m
