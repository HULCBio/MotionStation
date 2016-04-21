function resp = readnumeric(nn,index,timeout)
% Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.2.2.2 $  $Date: 2003/11/30 23:12:57 $

error(nargchk(1,3,nargin));
if ~ishandle(nn),
    error(generateccsmsgid('InvalidHandle'),'First Parameter must be a STRING Handle.');
end

if nargin == 1,
    resp = read_numeric(nn);
elseif nargin == 2,
    resp = read_numeric(nn,index);     
else
    resp = read_numeric(nn,index,timeout);
end

%  [EOF] readnumeric.m
