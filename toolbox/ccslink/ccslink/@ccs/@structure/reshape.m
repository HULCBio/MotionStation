function st = reshape(st,siz)
%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2003/11/30 23:13:46 $

error(nargchk(2,2,nargin));
if ~ishandle(st),
    error('First Parameter must be a valid STRUCTURE handle ');
end
set(st,'size',siz);

% [EOF] reshape.m