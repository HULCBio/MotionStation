function c = ndops(opname,a,b)
%NDOPS  Operations on ND arrays (page-wise along dimensions >2).
%
%   C = NDOPS('operation',A,B) where 'operation' is one of the 
%   following:
%      'add'        matrix addition
%      'mult'       matrix multiplication
%      'trans'      matrix transposition
%      'hcat'       horizontal concatenation
%      'vcat'       vertical concatenation
%      'min'        min of two matrices
%      'max'        max of two matrices
%
%   LOW-LEVEL UTILITY. Used for delay management.

%	Pascal Gahinet  
%	Copyright 1986-2002 The MathWorks, Inc. 
%	$Revision: 1.4 $  $Date: 2002/04/10 05:54:02 $

sa = size(a);
if nargin>2,
   sb = size(b);
else
   sb = sa;
end

% Make SA and SB of identical length
sa = [sa ones(1,length(sb)-length(sa))];
sb = [sb ones(1,length(sa)-length(sb))];

% Determine "array" sizes (for dimensions>2)
ArraySizes = max(sa(3:end),sb(3:end));
nma = prod(sa(3:end));
nmb = prod(sb(3:end));
nmats = max(nma,nmb);

switch opname(1:3)
case 'add'
   c = zeros([sa(1:2) ArraySizes]);
   for k=1:nmats,
      c(:,:,k) = a(:,:,min(k,nma)) + b(:,:,min(k,nmb));
   end
   
case 'mul'
   c = zeros([sa(1) sb(2) ArraySizes]);
   for k=1:nmats,
      c(:,:,k) = a(:,:,min(k,nma)) * b(:,:,min(k,nmb));
   end
   
case 'tra'
   c = permute(a,[2 1 3:length(sa)]);
   
case 'hca'
   c = zeros([sa(1) sa(2)+sb(2) ArraySizes]);
   for k=1:nmats,
      c(:,:,k) = [a(:,:,min(k,nma)) , b(:,:,min(k,nmb))];
   end
   
case 'vca'
   c = zeros([sa(1)+sb(1) sa(2) ArraySizes]);
   for k=1:nmats,
      c(:,:,k) = [a(:,:,min(k,nma)) ; b(:,:,min(k,nmb))];
   end
   
case 'min'
   c = zeros([max(sa(1:2),sb(1:2)) ArraySizes]);
   for k=1:nmats,
      c(:,:,k) = min(a(:,:,min(k,nma)) , b(:,:,min(k,nmb)));
   end
   
case 'max'
   c = zeros([max(sa(1:2),sb(1:2)) ArraySizes]);
   for k=1:nmats,
      c(:,:,k) = max(a(:,:,min(k,nma)) , b(:,:,min(k,nmb)));
   end
   
end
