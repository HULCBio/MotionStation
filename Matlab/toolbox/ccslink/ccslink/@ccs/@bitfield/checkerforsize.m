function sv = checkerforsize(nn,usersSV)
%CHECKERFORsize - private function to verify operations on property STORAGEUNITSPERVALUE
% Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.4.4.1 $  $Date: 2003/11/30 23:06:22 $

if ~isnumeric(usersSV),
    error('size property must be a numeric vector.');
end
totalSize = prod(usersSV);
if isempty(usersSV),
    usersSV = nn.size;
elseif any(usersSV<=0) | any(mod(usersSV,1)~=0),
    error('SIZE limited to positive integer values. ');
elseif any(size(totalSize)~=[1 1]),
    error('SIZE limited to 1-D vectors. ');
elseif totalSize > 1,
    error('Bitfield SIZE is limited to 1. ');
end
arrSize = size(usersSV);

if arrSize(1) ~= 1,
    sv = round(usersSV');  % Convert to a row vector 
else
    sv = round(usersSV);
end

% recompute some other property values
nn.numberofstorageunits=nn.storageunitspervalue*prod(sv);