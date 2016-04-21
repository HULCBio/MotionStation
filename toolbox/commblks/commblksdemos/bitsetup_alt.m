% BITSETUP_ALT Set up the bit allocation for the faster version of the
%    DMT demo. (dmt_sim_alt.mdl)

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.4 $  $Date: 2002/03/24 02:04:09 $

load bit_allocation

% binloc : ith item contains all locations with i bits
for numbits=1:max(b),
   binloc{numbits}=find(b==numbits);
end

% bitalloc : ith entry is the number of bins with i bits
bitalloc = []; 
for idx=1:length(binloc), 
   bitalloc = [bitalloc length(binloc{idx})];
end

% scrambled : binloc concatenated
scrambled=[]; 
for idx=1:length(binloc),
   scrambled=[scrambled;binloc{idx}];
end

[Y,I]=sort(scrambled);

c = cumsum(b);
cscram = c(scrambled);
cum_bitalloc = cumsum(bitalloc);

initorder = [1 1];
for idx = 2:length(bitalloc)
   currnum = cscram(cum_bitalloc(idx-1)+1:cum_bitalloc(idx));
   initorder = [initorder; [currnum-idx+1 currnum]];
end

initscram = [];
for idx = 1:size(initorder,1)
   initscram = [initscram, initorder(idx,1):initorder(idx,2)];
end
   
[X,J]=sort(initscram);
