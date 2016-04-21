function pos=mytopf(varargin)
%MYTOPF Example custom topology function.
%
%  Use this function as a template to write your own function.
%  
%  Syntax
%
%    pos = mytopf(dim1,dim2,...,dimN)
%      dimi - number of neurons along the ith layer dimension
%      pos  - NxS matrix of S position vectors, where S is the
%             total number of neurons which is defined by the
%              product dim1*dim1*...*dimN.
%
%  Example
%
%    pos = mytopf(20,20);
%    plotsom(pos)

% Copyright 1997 The MathWorks, Inc.
% $Revision: 1.2.2.1 $

% ** Replace the code below with your own calculation
% ** for the neuron positions.

dim = [varargin{:}];    % The dimensions as a row vector
size = prod(dim);       % Total number of neurons
dims = length(dim);     % Number of dimensions
pos = zeros(dims,size); % The size that POS will need to be

len = 1;
pos(1,1) = 0;
for i=1:length(dim)
  dimi = dim(i);
  newlen = len*dimi;
  pos(1:(i-1),1:newlen) = pos(1:(i-1),rem(0:(newlen-1),len)+1);
  posi = 0:(dimi-1);
  pos(i,1:newlen) = posi(floor((0:(newlen-1))/len)+1);
  len = newlen;
end

for i=1:2
  pos(i,:)=pos(i,:)*0.7+sin([1:size]*exp(1)/5*i)*0.2;
end
