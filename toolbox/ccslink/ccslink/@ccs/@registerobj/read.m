function resp = read(mm,index,timeout)
%READ 
%   DN = READ(MM)
%   DN = READ(MM,[],TIMEOUT)
%   DN = READ(MM,INDEX)
%   DN = READ(MM,INDEX,TIMEOUT)
%
%   See also 

%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.2.2.1 $ $Date: 2003/11/30 23:10:42 $

error(nargchk(1,3,nargin));
if ~ishandle(mm),
    error('First Parameter must be a REGISTEROBJ Handle.');
end

if nargin == 1,
    resp = read_memoryobj(mm);
elseif nargin == 2,
    resp = read_memoryobj(mm,index);     
else
    resp = read_memoryobj(mm,index,timeout);
end

% [EOF] read.m