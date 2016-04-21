function [w1,b1,w2,b2] = initelm(p,s1,s2)
%INITELM Initialize Elman recurrent network.
%  
%  This function is obselete.
%  Use NNT2ELM and INIT to update and initialize your network.

nntobsf('initelm','Use NNT2ELM and INIT to update and initialize your network.')

%  [W1,B1,W2,B2] = INITELM(P,S1,S2)
%    P  - RxQ matrix of input vectors.
%    S1 - Number of hidden TANSIG neurons.
%    S2 - Number of output PURELIN neurons.
%  Returns:
%    W1 - Weight matrix for recurrent layer.
%    B1 - Bias (column) vector for recurrent layer.
%    W2  - Weight matrix for output layer (from first layer).
%    B2  - Bias (column) vector for output layer.
%  
%  [W1,B1,W2,B2] = INITELM(P,S1,T)
%    T - SxQ matrix of target outputs.
%  Returns weights and biases.
%  
%  IMPORTANT: Each ith row of P must contain expected
%    min and max values for the ith input.
%  
%  EXAMPLE: P = [sin(0:100); cos([0:100]*2)];
%           t = 2*P(1,:) - 3*P(2,:);
%           [W1,b1,W2,b2] = initelm(P,2,t);
%  
%  See also ELMAN, SIMELM, TRAINELM

% Mark Beale, 12-15-93
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.11 $  $Date: 2002/04/14 21:13:59 $

if nargin < 3, error('Not enough input arguments'); end

% INPUTS
[r,q] = size(p);
if q < 2,error('First argument has less than 2 columns.'),end
p = [nnminr(p) nnmaxr(p)];

% OUTPUTS
[s,q] = size(s2);
if max(s,q) > 1
  s2 = s;
end

% INIALIZIZE RECURRENT LAYER
[w1,b1] = nwtan(s1,[p; ones(s1,1)*[-1 1]] );

% INITIALIZE OUTPUT LAYER

[w2,b2] = rands(s2,s1);
