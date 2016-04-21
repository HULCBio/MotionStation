function bf = reshape(bf,siz)
%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2003/11/30 23:06:39 $

error(nargchk(2,2,nargin));
if ~ishandle(bf),
    error('First Parameter must be a valid BITFIELD handle ');
end
set(bf,'size',siz);

% [EOF] reshape.m