function S = offset(S,off)
% OFFSET  shift memory location of entire partition 
%  SO = OFFSET(S,ADDR) - Returns a new partition object which is offset 
%      from S by the value of ADDR.  The offset parameter ADDR
%      can be a positive or negative integer or positive hexidecimcal
%      string in C format: '0xHHH'.  Partitions always start no 32-bit
%      boundaries, therefore ADDR must always be a multiple of 4.
%
% See also SMPARTITION

%   Copyright 2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2004/01/22 18:34:44 $

if nargin ~= 2, % We only delete specified locations
    error('OFFSET requires an parameter that defines the address offset');
end
off = addressconvert(S,off);
if mod(off,4) ~= 0,
    error(['Partitions always start on word boundaries.',...
   char(10),'Offsets are limited to multiples of 4']);
end
baseaddress = base(S) + off;
if any(baseaddress < 0),
    error('Negative offset are OK, but this value produces a memory location below shared-memory');
end
for inxS = 1:numel(S),
   S(inxS).Address(1) = baseaddress(inxS); 
end
S = adjustaddress(S);
