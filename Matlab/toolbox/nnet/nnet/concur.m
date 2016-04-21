function b2=concur(b,q)
%CONCUR Create concurrent bias vectors.
%
%  Syntax
%
%    concur(b,q)
%
%  Description
%
%    CONCUR(B,Q)
%      B - Nlx1 cell array of bias vectors.
%      Q - Concurrent size.
%    Returns an SxB matrix of copies of B (or Nlx1 cell array of matrices).
%
%  Examples
%  
%    Here CONCUR creates three copies of a bias vector.
%
%      b = [1; 3; 2; -1];
%      concur(b,3)
%
%  Network Use
%
%    To calculate a layer's net input, the layer's weighted
%    inputs must be combined with its biases.  The following
%    expression calculates the net input for a layer with
%    the NETSUM net input function, two input weights, and
%    a bias:
%
%      n = netsum(z1,z2,b)
%
%    The above expression works if Z1, Z2, and B are all Sx1
%    vectors.  However, if the network is being simulated by SIM
%    (or ADAPT or TRAIN) in response to Q concurrent vectors,
%    then Z1 and Z2 will be SxQ matrices.  Before B can be
%    combined with Z1 and Z2 we must make Q copies of it.
%
%      n = netsum(z1,z2,concur(b,q))
%    
%  See also NETSUM, NETPROD, SIM, SEQ2CON, CON2SEQ.

% Mark Beale, 11-31-97
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.7 $

if nargin < 2, error('Not enough input arguments.'), end

if isa(b,'double')
  b2 = b(:,ones(1,q));
  return
end

b2 = cell(size(b));
ones1xQ = ones(1,q);
for i=1:size(b,1)
   bi = b{i};
  if length(bi)
    b2{i} = bi(:,ones1xQ);
  end
end
