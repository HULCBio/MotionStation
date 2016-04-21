function [a,b,c,d,e,f,g,h] = trainbpx(i,j,k,l,m,n,o,p,q,r,s,t)
%TRAINBPX Train feed-forward network with fast backpropagation.
%  
%  This function is obselete.
%  Use NNT2FF and TRAIN to update and train your network.

nntobsf('trainbpx','Use NNT2FF and TRAIN to update and train your network.')

%  TRAINBPX can be called with 1, 2, or 3 sets of weights
%  and biases to train up to 3 layer feed-forward networks.
%  
%  [W1,B1,W2,B2,...,TE,TR] = TRAINBPX(W1,B1,F1,W2,B2,F2,...,P,T,TP)
%    Wi - Weight matrix for the ith layer.
%    Bi - Bias vector for the ith layer.
%    Fi - Transfer function (string) for the ith layer.
%    P  - RxQ matrix of input vectors.
%    T  - SxQ matrix of target vectors.
%    TP - Training parameters (optional).
%  Returns new weights and biases and
%    Wi - new weights.
%    Bi - new biases.
%    TE - the actual number of epochs trained.
%    TR - training record: [row of errors]
%  
%  Training parameters are:
%    TP(1) - Epochs between updating display, default = 25.
%    TP(2) - Maximum number of epochs to train, default = 1000.
%    TP(3) - Sum-squared error goal, default = 0.02.
%    TP(4) - Learning rate, 0.01.
%    TP(5) - Learning rate increase, default = 1.05.
%    TP(6) - Learning rate decrease, default = 0.7.
%    TP(7) - Momentum constant, default = 0.9.
%    TP(8) - Maximum error ratio, default = 1.04.
%  Missing parameters and NaN's are replaced with defaults.
%  
%  See also NNTRAIN, BACKPROP, INITFF, SIMFF, TRAINBP, TRAINLM.

% Mark Beale, 9-2-92
% Revised 12-15-93, MB.
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.11 $  $Date: 2002/04/14 21:13:20 $

if all([5 6 8 9 11 12] ~= nargin),error('Wrong number of input arguments'),end

if nargin == 5
  [a,b,c,d] = tbpx1(i,j,k,l,m);
elseif nargin == 6
  [a,b,c,d] = tbpx1(i,j,k,l,m,n);
elseif nargin == 8
  [a,b,c,d,e,f] = tbpx2(i,j,k,l,m,n,o,p);
elseif nargin == 9
  [a,b,c,d,e,f] = tbpx2(i,j,k,l,m,n,o,p,q);
elseif nargin == 11
  [a,b,c,d,e,f,g,h] = tbpx3(i,j,k,l,m,n,o,p,q,r,s);
elseif nargin == 12
  [a,b,c,d,e,f,g,h] = tbpx3(i,j,k,l,m,n,o,p,q,r,s,t);
end
