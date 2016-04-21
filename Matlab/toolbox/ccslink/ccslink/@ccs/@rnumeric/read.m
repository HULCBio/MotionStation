function resp = read(nn,index,timeout)
%READ 
%   DN = READ(NN)
%   DN = READ(NN,[],TIMEOUT)
%   DN = READ(NN,INDEX)
%   DN = READ(NN,INDEX,TIMEOUT)
%
%   See also 

%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.2.2.2 $ $Date: 2003/11/30 23:11:41 $

error(nargchk(1,3,nargin));
if ~ishandle(nn),
    error(generateccsmsgid('InvalidHandle'),'First Parameter must be a NUMERIC Handle.');
end

if nargin == 1,
    resp = read_rnumeric(nn);
elseif nargin == 2,
    resp = read_rnumeric(nn,index);     
else
    resp = read_rnumeric(nn,index,timeout);
end

% [EOF] read.m