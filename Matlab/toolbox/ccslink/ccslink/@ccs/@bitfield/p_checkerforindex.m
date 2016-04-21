function index = p_checkerforindex(obj,index,opt)
%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.1.4.2 $  $Date: 2003/11/30 23:06:33 $

error(nargchk(2,3,nargin));
errid = generateccsmsgid('InvalidIndexInput');
if nargin==2,
    opt = '';
else
    opt = [opt ' '];
end
if ~isnumeric(index),
    error(errid,[opt 'INDEX must be a numeric vector.']);
end

if isempty(index),
    index = ones(1,length(obj.size));
elseif any( any(index<=0) | any(mod(index,1)~=0) ),
    error(errid,[opt 'INDEX is limited to positive integer values. ']);
elseif any(prod(reshape(index,length(obj.size),[])',2)>1),
    error(errid,['Bitfield INDEX must always be equivalent to 1. ']);
end

% [EOF] p_checkerforindex.m                         