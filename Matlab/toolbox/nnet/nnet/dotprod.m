function z=dotprod(w,p)
%DOTPROD Dot product weight function.
%
%  Syntax
%
%    Z = dotprod(W,P)
%    df = dotprod('deriv')
%
%  Description
%
%    DOTPROD is the dot product weight function.  Weight functions
%    apply weights to an input to get weighted inputs.
%
%    DOTPROD(W,P) takes these inputs,
%      W - SxR weight matrix.
%      P - RxQ matrix of Q input (column) vectors.
%    and returns the SxQ dot product of W and P.
%
%  Examples
%
%    Here we define a random weight matrix W and input vector P
%    and calculate the corresponding weighted input Z.
%
%      W = rand(4,3);
%      P = rand(3,1);
%      Z = dotprod(W,P)
%
%  Network Use
%
%    You can create a standard network that uses DOTPROD
%    by calling NEWP or NEWLIN.
%
%    To change a network so an input weight uses DOTPROD set
%    NET.inputWeight{i,j}.weightFcn to 'dotprod.  For a layer weight
%    set NET.inputWeight{i,j}.weightFcn to 'dotprod.
%
%    In either case, call SIM to simulate the network with DOTPROD.
%    See NEWP and NEWLIN for simulation examples.
%
%  See also SIM, DDOTPROD, DIST, NEGDIST, NORMPROD.

% Mark Beale, 11-31-97
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.7 $

% FUNCTION INFO
if isstr(w)
  switch (w)
    case 'deriv',
      z = 'ddotprod';
    otherwise
      error('Unrecognized code.')
  end
  return
end

% CALCULATION
z = w*p;

