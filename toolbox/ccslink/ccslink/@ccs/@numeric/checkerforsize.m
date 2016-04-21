function sv = checkerforsize(nn,usersSV)
%CHECKERFORSIZE - private function to verify operations on property STORAGEUNITSPERVALUE

%   Copyright 2001-2003 The MathWorks, Inc.
%   $Revision: 1.6.4.2 $ $Date: 2004/04/08 20:46:35 $

if ~isnumeric(usersSV),
    error('Property ''size'' must be a numeric vector.');
end
totalSize = prod(usersSV);
if isempty(usersSV),
    usersSV = nn.size;
elseif any(usersSV<=0) | any(mod(usersSV,1)~=0),
    error('SIZE limited to positive integer values. ');
elseif any(size(totalSize)~=[1 1]),
    error('SIZE limited to 1-D vectors. ');
end
arrSize = size(usersSV);

if arrSize(1) ~= 1,
    sv = round(usersSV');  % Convert to a row vector 
else
    sv = round(usersSV);
end
% recompute some other property values
nn.numberofstorageunits = nn.storageunitspervalue*prod(sv);

% [EOF] checkerforsize.m