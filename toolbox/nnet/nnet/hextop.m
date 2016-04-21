function pos=hextop(varargin)
%HEXTOP Hexagonal layer topology function.
%
%  Syntax
%
%    pos = hextop(dim1,dim2,...,dimN)
%
%  Description
%
%    HEXTOP calculates the neuron positions for layers whose
%    neurons are arranged in a N dimensional hexagonal pattern.
%
%    HEXTOP(DIM1,DIM2,...,DIMN) takes N arguments,
%      DIMi - Length of layer in dimension i.
%    and returns an NxS matrix of N coordinate vectors
%    where S is the product of DIM1*DIM2*...*DIMN.
%
%  Examples
%
%    This code creates and displays a two-dimensional layer
%    with 40 neurons arranged in a 8x5 hexagonal pattern.
%
%      pos = hextop(8,5); plotsom(pos)
%
%    This code plots the connections between the same neurons,
%    but shows each neuron at the location of its weight vector.
%    The weights are generated randomly so that the layer is
%    very disorganized, as is evident in the following plot.
%
%      W = rands(40,2); plotsom(W,dist(pos))
%
%  See also GRIDTOP, RANDTOP.

% Mark Beale, 11-31-97
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.7 $

dim = [varargin{:}];
dims = length(dim);
pos = zeros(dims,prod(dim));

len = 1;
pos(1,1) = 0;
center = [];
squishes = [];
for i=1:length(dim)
  dimi = dim(i);
  newlen = len*dimi;
  offset = sqrt(1-sumsqr(center));
  
  if (i>1)
    for j=2:dimi
      iShift = center * rem(j+1,2);
    doShift = iShift(:,ones(1,len));
      pos(1:(i-1),[1:len]+len*(j-1)) = pos(1:(i-1),1:len) + doShift;
    end
  end
  
  posi = [0:(dimi-1)]*offset;
  pos(i,1:newlen) = posi(floor((0:(newlen-1))/len)+1);
  
  len = newlen;
  center = ([center; 0]*i + [center; offset])/(i+1);
end
