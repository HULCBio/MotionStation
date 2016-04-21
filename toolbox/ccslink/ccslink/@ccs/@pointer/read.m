function resp = read(rr,index,timeout)
%READ 
%   DN = READ(NN)
%   DN = READ(NN,[],TIMEOUT)
%   DN = READ(NN,INDEX)
%   DN = READ(NN,INDEX,TIMEOUT)
%
%   See also 

%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.5.4.2 $  $Date: 2003/11/30 23:10:28 $

error(nargchk(1,3,nargin));
if ~ishandle(rr),
    error(generateccsmsgid('InvalidHandle'),'First Parameter must be a POINTER Handle.');
end

if nargin == 1,
    resp = read_numeric(rr);
elseif nargin == 2,
    resp = read_numeric(rr,index);     
else
    resp = read_numeric(rr,index,timeout);
end
% [EOF] read.m