function resp = read(rs,index,timeout)
%READ 
%   DN = READ(RS)
%   DN = READ(RS,[],TIMEOUT)
%   DN = READ(RS,INDEX)
%   DN = READ(RS,INDEX,TIMEOUT)

% Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.3.2.2 $  $Date: 2003/11/30 23:12:16 $

error(nargchk(1,3,nargin));
if ~ishandle(rs),
    error(generateccsmsgid('InvalidHandle'),'First Parameter must be a RSTRING Handle.');
end

if nargin == 1,
    resp = read_rstring(rs);
elseif nargin == 2,
    resp = read_rstring(rs,index);     
else
    resp = read_rstring(rs,index,timeout);
end

% [EOF] read.m