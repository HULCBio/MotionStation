function inda = index2addr(nn,indn)
%INDEX2ADDR - Converts table of indices into a table of memory addresses
%  A=INDEX2ADDR(NN,INX) converts a vector of indices (INX) into a 
%  an array of address values.  Each row of INX must be an index into
%  an array of size NN.SIZE.  The rows of A 
%
%  Example:
%   nn.storageunitspervalue = 4
%   nn.size = [2 3]
%   nn.arrayorder = 'col-major'
%
%   > nn.index2addr([1 1; 2 1; 2 3])
%   ans =  
%       1  2  3  4 % Index required for [1 1]
%       5  6  7  8 % Index required for [2 1]
%      21 22 23 24 % Index required for [2 3]
%
%   > nn.arrayorder = 'row-major'   % 
%   > nn.index2addr([1 1; 2 1; 2 3])
%   ans =  
%       1  2  3  4 % Index required for [1 1]
%      13 14 15 16 % Index required for [2 1]
%      21 22 23 24 % Index required for [2 3]
%    
% 
% Takes a vector of indices and collapses it into a seqeuence of consecutive block reads
% This step is taken to improve read efficiency

%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.5.4.1 $  $Date: 2003/11/30 23:09:55 $

try
    indn = reshape(indn,[],length(nn.size));
catch
    disp(lasterr)
    error('Indices must include one entry for each dimension of numeric array (SIZE)');
end
% if strcmp(nn.arrayorder,'row-major') & length(nn.size) >1,
%     nndims = [nn.size(2) nn.size(1) nn.size(3:end)];
%     adjv = cumprod(nndims);
%     adjv = [adjv(1) 1 adjv(2:end-1)];
% else
%     adjv = [1 cumprod(nn.size)];
%     adjv = adjv(1:end-1);
% end

idx = p_sub2ind(nn,nn.size,indn,nn.arrayorder);
if strcmp(nn.arrayorder,'row-major') & length(nn.size) >1,
    adjv = [fliplr(cumprod(fliplr(nn.size(2:end)))) 1];     
else
    adjv = [1 cumprod(nn.size(1:end-1))];
end

inda = [];
for elem = indn',
    findx = (nn.storageunitspervalue*adjv*(elem-1))+1;
    inda = vertcat(inda,(findx:findx+nn.storageunitspervalue-1));
end


% [EOF] index2addr.m