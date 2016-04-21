function pos=gridtop(varargin)
%GRIDTOP Grid layer topology function.
%
%  Syntax
%
%    pos = gridtop(dim1,dim2,...,dimN)
%
%  Description
%
%    GRIDTOP calculates neuron positions for layers whose
%    neurons are arranged in an N dimensional grid.
%
%    GRIDTOP(DIM1,DIM2,...,DIMN) takes N arguments,
%      DIMi - Length of layer in dimension i.
%    and returns an NxS matrix of N coordinate vectors
%    where S is the product of DIM1*DIM2*...*DIMN.
%
%  Examples
%
%    This code creates and displays a two-dimensional layer
%    with 40 neurons arranged in a 8x5 grid.
%
%      pos = gridtop(8,5); plotsom(pos)
%
%    This code plots the connections between the same neurons,
%    but shows each neuron at the location of its weight vector.
%    The weights are generated randomly so the layer is
%    very unorganized as is evident in the following plot.
%
%      W = rands(40,2); plotsom(W,dist(pos))
%
%  See also HEXTOP, RANDTOP.

% Mark Beale, 11-31-97
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.7 $

dim = [varargin{:}];

size = prod(dim);
dims = length(dim);
pos = zeros(dims,size);

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
