function z=normprod(w,p)
%NORMPROD Normalized dot product weight function.
%
%  Syntax
%
%    Z = normprod(W,P)
%    df = normprod('deriv')
%
%  Description
%
%    NORMPROD is a weight function.  Weight functions apply
%    weights to an input to get weighted inputs.
%
%    NORMPROD(W,P) takes these inputs,
%      W - SxR weight matrix.
%      P - RxQ matrix of Q input (column) vectors.
%    and returns the SxQ matrix of normalized dot products.
%
%    NORMPROD('deriv') returns '' because NORMPROD does not have
%    a derivative function.
%
%  Examples
%
%    Here we define a random weight matrix W and input vector P
%    and calculate the corresponding weighted input Z.
%
%      W = rand(4,3);
%      P = rand(3,1);
%      Z = normprod(W,P)
%
%  Network Use
%
%    You can create a standard network that uses NORMPROD
%    by calling NEWGRNN.
%
%    To change a network so an input weight uses NORMPROD, set
%    NET.inputWeight{i,j}.weightFcn to 'normprod.  For a layer weight
%    set NET.inputWeight{i,j}.weightFcn to 'normprod.
%
%    In either case, call SIM to simulate the network with NORMPROD.
%    See NEWGRNN for simulation examples.
%
%  Algorithm
%
%    NORMPROD returns the dot product normalized by the sum
%    of the input vector elements.
%
%      z = w*p/sum(p)
%
%  See also SIM, DOTPROD, NEGDIST, DIST.

% Mark Beale, 11-31-97
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.7 $

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
[S,R] = size(w);
[R2,Q] = size(p);
if (R ~= R2), error('Inner matrix dimensions do not match.'), end

sump = sum(p,1);
z = w * (p ./ sump(ones(1,R),:));
  
