function pos=randtop(varargin)
%RANDTOP Random layer topology function.
%
%  Syntax
%
%    pos = randtop(dim1,dim2,...,dimN)
%
%  Description
%
%    RANDTOP calculates the neuron positions for layers whose
%    neurons are arranged in an N dimensional random pattern.
%
%    RANDTOP(DIM1,DIM2,...,DIMN) takes N arguments,
%      DIMi - Length of layer in dimension i.
%    and returns an NxS matrix of N coordinate vectors
%    where S is the product of DIM1*DIM2*...*DIMN.
%
%  Examples
%
%    This code creates and displays a two-dimensional layer
%    with 192 neurons arranged in a 16x12 random pattern.
%
%      pos = randtop(16,12); plotsom(pos)
%
%    This code plots the connections between the same neurons,
%    but shows each neuron at the location of its weight vector.
%    The weights are generated randomly so that the layer is
%    very unorganized, as is evident in the plot.
%
%      W = rands(192,2); plotsom(W,dist(pos))
%
%  See also GRIDTOP, HEXTOP.

% Mark Beale, 11-31-97
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.7 $

dim = [varargin{:}];
dims = length(dim);
pos = zeros(dims,prod(dim));

noiseLen = 0.8;
noiseElement = (noiseLen^2)/dims;
noise = rands(dims,prod(dim)) * noiseElement;
hexpos = hextop(varargin{:});
pos =  (hexpos + noise) * 0.6/noiseLen;
posmin = min(pos,[],2);
pos = pos - posmin(:,ones(1,prod(dim)));
