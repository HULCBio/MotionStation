function resp = read(en,index,timeout)
%READ 
%   DN = READ(EN)
%   DN = READ(EN,[],TIMEOUT)
%   DN = READ(EN,INDEX)
%   DN = READ(EN,INDEX,TIMEOUT)
%
%   See also 

%   Copyright 2001-2003 The MathWorks, Inc.
%   $Revision: 1.3.4.2 $ $Date: 2003/11/30 23:11:03 $

error(nargchk(1,3,nargin));
if ~ishandle(en),
    error(generateccsmsgid('InvalidHandle'),'First Parameter must be a RENUM Handle.');
end

if nargin == 1,
    resp = read_renum(en);
elseif nargin == 2,
    resp = read_renum(en,index);     
else
    resp = read_renum(en,index,timeout);
end

% [EOF] read.m