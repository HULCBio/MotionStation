function siz = p_checkerforsize(obj,siz,opt)
%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.2.4.1 $  $Date: 2003/11/30 23:11:38 $

error(nargchk(2,3,nargin));
if nargin==2,
    opt = '';
else
    opt = [opt ' '];
end
if ~isnumeric(siz),
    error([opt 'SIZE must be a numeric vector.']);
end

totalSize = prod(siz);
if isempty(siz),
    siz = obj.size;
elseif any((siz<=0)) | any(mod(siz,1)~=0),
    error([opt 'SIZE is limited to positive integer values. ']);
elseif any(size(totalSize)~=[1 1]),
    error([opt 'SIZE is limited to 1-D vectors. ']);
elseif prod(siz)>1,
    error(['Register SIZE must always be equivalent to 1. ']);
end

arrSize = size(siz);
if arrSize(1) ~= 1,
    siz = round(siz');  % Convert to a row vector 
else
    siz = round(siz);
end

% [EOF] p_checkerforsize.m