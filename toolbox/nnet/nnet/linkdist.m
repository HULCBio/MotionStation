function d = linkdist(pos)
%LINKDIST Link distance function.
%
%  Syntax
%
%    d = linkdist(pos);
%
%  Description
%
%    LINKDIST is a layer distance function used to find
%    the distances between the layer's neurons given their
%    positions.
%
%    LINKDIST(pos) takes one argument,
%      POS - NxS matrix of neuron positions.
%     and returns the SxS matrix of distances.
%
%  Examples
%
%    Here we define a random matrix of positions for 10 neurons
%    arranged in three dimensional space and find their distances.
%
%      pos = rand(3,10);
%      D = linkdist(pos)
%
%  Network Use
%
%    You can create a standard network that uses LINKDIST
%    as a distance function by calling NEWSOM.
%
%    To change a network so a layer's topology uses LINKDIST set
%    NET.layers{i}.distanceFcn to 'linkdist'.
%
%    In either case, call SIM to simulate the network with DIST.
%    See NEWSOM for training and adaption examples.
%
%  Algorithm
%
%    The link distance D between two position vectors Pi and Pj
%    from a set of S vectors is:
%  
%      Dij = 0, if i==j
%          = 1, if sum((Pi-Pj).^2).^0.5 is <= 1
%          = 2, if k exists, Dik = Dkj = 1
%          = 3, if k1, k2 exist, Dik1 = Dk1k2 = Dk2j = 1.
%          = N, if k1..kN exist, Dik1 = Dk1k2 = ...= DkNj = 1
%           = S, if none of the above conditions apply.
%
%  See also SIM, DIST, MANDIST.

% Mark Beale, 11-31-97
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.8 $

[dims,s] = size(pos);
found = eye(s,s);
links = double((dist(pos) <= 1.00001) & ~found);

d = s*(1-eye(s,s));
for i=1:s
  nextfound = (found*links) | found;
  newfound = nextfound & ~found;
  ind = find(newfound);
  if length(ind) == 0
    break;
  end
  d(ind) = i;
  found = nextfound;
end
