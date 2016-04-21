function index = p_checkerforindex(obj,index,opt)

%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.2.4.2 $  $Date: 2003/11/30 23:11:37 $

error(nargchk(2,3,nargin));
if nargin==2,
    opt = '';
else
    opt = [opt ' '];
end
if ~isnumeric(index),
    error(generateccsmsgid('InvalidIndexFormat'),[opt 'INDEX must be a numeric vector.']);
end

if isempty(index),
    index = ones(1,length(obj.size));
elseif any( any(index<=0) | any(mod(index,1)~=0) ),
    error(generateccsmsgid('InvalidIndexValue'),[opt 'INDEX is limited to positive integer values. ']);
elseif any(prod(reshape(index,length(obj.size),[])',2)>1),
    error(generateccsmsgid('InvalidIndexValue'),['Register index must always be equivalent to 1. ']);
end

% [EOF] p_checkerforindex.m                         