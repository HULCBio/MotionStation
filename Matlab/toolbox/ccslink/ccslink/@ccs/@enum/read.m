function resp = read(en,index,timeout)
%READ 
%   DN = READ(EN)
%   DN = READ(EN,[],TIMEOUT)
%   DN = READ(EN,INDEX)
%   DN = READ(EN,INDEX,TIMEOUT)

%   Copyright 2001-2003 The MathWorks, Inc.
%   $Revision: 1.7.2.3 $ $Date: 2004/04/08 20:46:01 $

error(nargchk(1,3,nargin));
if ~ishandle(en),
    error(generateccsmsgid('InvalidHandle'),'First Parameter must be an ENUM Handle.');
end

if nargin == 1,
    resp = read_enum(en);
elseif nargin == 2,
    resp = read_enum(en,index);     
else
    resp = read_enum(en,index,timeout);
end

% [EOF] read.m