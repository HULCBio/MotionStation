function newaddr = suoffset(mm,offset)
% Private. Add an offset to the location (address or register)
% Note: Does not apply to registers.
% Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.2.2.1 $  $Date: 2003/11/30 23:10:49 $

if ~isnumeric(offset),
    error('Address offset must be a numeric value');
end

% offsets = round(double(reshape(offset,[prod(size(offset)) 1])));
% newaddr = [mm.address(1)+double(offsets) ones(prod(size(offset)),1)*mm.address(2)];
% 
% if any(any((newaddr < 0 | newaddr > mm.maxaddress))),
%     error('Exceeded absolute limits of address space');
% end

%[EOF] suoffset.m