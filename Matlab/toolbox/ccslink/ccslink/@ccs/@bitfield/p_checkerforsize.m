function siz = p_checkerforsize(obj,siz,opt)
%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.1.4.2 $  $Date: 2003/11/30 23:06:34 $

error(nargchk(2,3,nargin));
errid = generateccsmsgid('InvalidSizeInput');
if nargin==2,
    opt = '';
else
    opt = [opt ' '];
end
if ~isnumeric(siz),
    error(errid,[opt 'SIZE must be a numeric vector.']);
end

totalSize = prod(siz);
if isempty(siz),
    siz = obj.size;
elseif any((siz<=0)) | any(mod(siz,1)~=0),
    error(errid,[opt 'SIZE is limited to positive integer values. ']);
elseif any(size(totalSize)~=[1 1]),
    error(errid,[opt 'SIZE is limited to 1-D vectors. ']);
elseif prod(siz)>1,
    error(errid,['Bitfield SIZE must always be equivalent to 1. ']);
end

arrSize = size(siz);
if arrSize(1) ~= 1,
    siz = round(siz');  % Convert to a row vector 
else
    siz = round(siz);
end

% [EOF] p_checkerforsize.m