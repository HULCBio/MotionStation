function resp = read(ss,index,timeout)
%READ 
%   DN = READ(SS)
%   DN = READ(SS,[],TIMEOUT)
%   DN = READ(SS,INDEX)
%   DN = READ(SS,INDEX,TIMEOUT)
%
% Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.3.2.2 $  $Date: 2003/11/30 23:12:55 $

error(nargchk(1,3,nargin));
if ~ishandle(ss),
    error(generateccsmsgid('InvalidHandle'),'First Parameter must be a STRING Handle.');
end

if nargin == 1,
    resp = read_string(ss);
elseif nargin == 2,
    resp = read_string(ss,index);     
else
    resp = read_string(ss,index,timeout);
end


% [EOF] read.m
