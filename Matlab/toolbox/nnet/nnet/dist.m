function z = dist(w,p)
%DIST Euclidean distance weight function.
%
%  Syntax
%
%    Z = dist(W,P)
%    df = dist('deriv')
%    D = dist(pos)
%
%  Description
%
%    DIST is the Euclidean distance weight function. Weight
%    functions apply weights to an input to get weighted inputs.
%
%    DIST(W,P) takes these inputs,
%      W - SxR weight matrix.
%      P - RxQ matrix of Q input (column) vectors.
%    and returns the SxQ matrix of vector distances.
%
%    DIST('deriv') returns '' because DIST does not have
%    a derivative function.
%
%    DIST is also a layer distance function which can be used
%    to find the distances between neurons in a layer.
%
%    DIST(POS) takes one argument,
%      POS - NxS matrix of neuron positions.
%     and returns the SxS matrix of distances.
%
%  Examples
%
%    Here we define a random weight matrix W and input vector P
%    and calculate the corresponding weighted input Z.
%
%      W = rand(4,3);
%      P = rand(3,1);
%      Z = dist(W,P)
%
%    Here we define a random matrix of positions for 10 neurons
%    arranged in three dimensional space and find their distances.
%
%      pos = rand(3,10);
%      D = dist(pos)
%
%  Network Use
%
%    You can create a standard network that uses DIST
%    by calling NEWPNN or NEWGRNN.
%
%    To change a network so an input weight uses DIST set
%    NET.inputWeight{i,j}.weightFcn to 'dist.  For a layer weight
%    set NET.inputWeight{i,j}.weightFcn to 'dist'.
%
%    To change a network so that a layer's topology uses DIST set
%    NET.layers{i}.distanceFcn to 'dist'.
%
%    In either case, call SIM to simulate the network with DIST.
%    See NEWPNN or NEWGRNN for simulation examples.
%
%  Algorithm
%
%    The Euclidean distance D between two vectors X and Y is:
%  
%      D = sqrt(sum((x-y).^2))
%
%  See also SIM, DOTPROD, NEGDIST, NORMPROD, MANDIST, LINKDIST.

% Mark Beale, 12-15-93
% Revised 11-31-97, MB
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.12 $  $Date: 2002/04/14 21:31:49 $

% FUNCTION INFO
if isstr(w)
  switch (w)
    case 'deriv',
      z = '';
    otherwise
      error('Unrecognized code.')
  end
  return
end

% CALCULATION
if nargin == 1
  p = w;
  w = w';
end

[S,R] = size(w);
[R2,Q] = size(p);
if (R ~= R2), error('Inner matrix dimensions do not match.'),end

z = zeros(S,Q);
if (Q<S)
  p = p';
  copies = zeros(1,S);
  for q=1:Q
    z(:,q) = sum((w-p(q+copies,:)).^2,2);
  end
else
  w = w';
  copies = zeros(1,Q);
  for i=1:S
    z(i,:) = sum((w(:,i+copies)-p).^2,1);
  end
end
z = sqrt(z);
