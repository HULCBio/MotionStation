function z = mandist(w,p)
%MANDIST Manhattan distance weight function.
%
%  Syntax
%
%    Z = mandist(W,P)
%    df = mandist('deriv')
%    D = mandist(pos);
%
%  Description
%
%    MANDIST is the Manhattan distance weight function. Weight
%    functions apply weights to an input to get weighted inputs.
%
%    MANDIST(W,P) takes these inputs,
%      W - SxR weight matrix.
%      P - RxQ matrix of Q input (column) vectors.
%    and returns the SxQ matrix of vector distances.
%
%    MANDIST('deriv') returns '' because MANDIST does not have
%    a derivative function.
%
%    MANDIST is also a layer distance function which can be used
%    to find distances between neurons in a layer.
%
%    MANDIST(POS) takes one argument,
%      POS - S row matrix of neuron positions.
%     and returns the SxS matrix of distances.
%
%  Examples
%
%    Here we define a random weight matrix W and input vector P
%    and calculate the corresponding weighted input Z.
%
%      W = rand(4,3);
%      P = rand(3,1);
%      Z = mandist(W,P)
%
%    Here we define a random matrix of positions for 10 neurons
%    arranged in three dimensional space and then find their distances.
%
%      pos = rand(3,10);
%      D = mandist(pos)
%
%  Network Use
%
%    You can create a standard network that uses MANDIST
%    as a distance function by calling NEWSOM.
%
%    To change a network so an input weight uses MANDIST set
%    NET.inputWeight{i,j}.weightFcn to 'mandist.  For a layer weight
%    set NET.inputWeight{i,j}.weightFcn to 'mandist'.
%
%    To change a network so a layer's topology uses MANDIST set
%    NET.layers{i}.distanceFcn to 'mandist'.
%
%    In either case, call SIM to simulate the network with DIST.
%    See NEWPNN or NEWGRNN for simulation examples.
%
%  Algorithm
%
%    The Manhattan distance D between two vectors X and Y is:
%  
%      D = sum(abs(x-y))
%
%  See also SIM, DIST, LINKDIST.

% Mark Beale, 12-15-93
% Revised 11-31-97, MB
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.7 $  $Date: 2002/04/14 21:30:35 $

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
    z(:,q) = sum(abs(w-p(q+copies,:)),2);
  end
else
  w = w';
  copies = zeros(1,Q);
  for i=1:S
    z(i,:) = sum(abs(w(:,i+copies)-p),1);
  end
end
