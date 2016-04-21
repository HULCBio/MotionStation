function resp = read(mm,index,timeout)
%READ 
%   DN = READ(MM)
%   DN = READ(MM,[],TIMEOUT)
%   DN = READ(MM,INDEX)
%   DN = READ(MM,INDEX,TIMEOUT)
%
%   See also 

%   Copyright 2001-2003 The MathWorks, Inc.
%   $Revision: 1.5.2.2 $ $Date: 2004/04/08 20:46:24 $

error(nargchk(1,3,nargin));
if ~ishandle(mm),
    error('First Parameter must be a MEMORYOBJ Handle.');
end

if nargin == 1,
    resp = read_memoryobj(mm);
elseif nargin == 2,
    resp = read_memoryobj(mm,index);     
else
    resp = read_memoryobj(mm,index,timeout);
end

% [EOF] read.m