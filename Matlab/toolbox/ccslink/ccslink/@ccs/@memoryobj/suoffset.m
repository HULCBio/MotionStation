function newaddr = suoffset(mm,offset)
%AUOFF - Add an offset to the address and return the new address value
%

% Copyright 2001-2003 The MathWorks, Inc.
% $Revision: 1.4.2.2 $ $Date: 2004/04/08 20:46:29 $
if ~isnumeric(offset),
    error('Address offset must be a numeric value');
end
offsets = round(double(reshape(offset,[prod(size(offset)) 1])));
newaddr = [mm.address(1)+double(offsets) ones(prod(size(offset)),1)*mm.address(2)];

if any(any((newaddr < 0 | newaddr > mm.maxaddress))),
    error('Exceeded absolute limits of address space');
end

%[EOF] suoffset.m