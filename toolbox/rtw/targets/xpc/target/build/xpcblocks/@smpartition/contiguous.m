function S = contiguous(S)
% CONTIGUOUS  Create partition object with contiguous memory partitions
%   SA=CONTIGUOUS(S)  - returns a new partition object SA which forces all
%   partitions to reside in contiguous memory locations.  This ensures
%   maximum data packing and no overlap.  The paritions are always stacked
%   by thier index in S.
%
%   Note - IF S is a singular paritions, this simply returns a copy of the
%   original partition object.   
%
%
% See also SMPARTITION

%   Copyright 2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2004/01/22 18:34:38 $
if nargin ~= 1,
   error('unexpected parameter - contiguous does not have arguments');
end
for inxS=2:numel(S),
    newaddr = base(S(inxS-1)) + sizeof(S(inxS-1));
    S(inxS).Address(1) = newaddr;
    tmp = warning('query','XPC:SMPartition:BaseChange');
    warning('off','XPC:SMPartition:BaseChange');  % Sort of expected
    S(inxS) = adjustaddress(S(inxS));
    warning(tmp.state,'XPC:SMPartition:BaseChange'); 
end
