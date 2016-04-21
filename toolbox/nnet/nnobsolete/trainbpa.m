function [a,b,c,d,e,f,g,h] = trainbpa(i,j,k,l,m,n,o,p,q,r,s,t)
%TRAINBPA Train feed-forward network with bp + adaptive learning.
%  
%  This function is obselete.
%  Use NNT2FF and TRAIN to update and train your network.

nntobsf('trainbpa','Use NNT2FF and TRAIN to update and train your network.')

%  TRAINBPA can be called with 1, 2, or 3 sets of weights
%  and biases to train up to 3 layer feed-forward networks.
%          
%  [W1,B1,W2,B2,...,TE,TR] = TRAINBPA(W1,B1,F1,W2,B2,F2,...,P,T,TP)
%    Wi - SixR weight matrix for the ith layer.
%    Bi - S1x1 bias vector for the ith layer.
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
%    TP(7) - Maximum error ratio, default = 1.04.
%  Missing parameters and NaN's are replaced with defaults.
%  
% See also NNTRAIN, BACKPROP, INITFF, SIMFF, TRAINBPX, TRAINLM.

% Mark Beale, 1-31-92
% Revised 12-15-93, MB.
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.11 $  $Date: 2002/04/14 21:13:14 $

if all([5 6 8 9 11 12] ~= nargin),error('Wrong number of input arguments'),end

if nargin == 5
  [a,b,c,d] = tbpx1(i,j,k,l,m,[NaN NaN NaN NaN NaN NaN 0 NaN]);

elseif nargin == 6
  n = [n NaN+zeros(1,8) 0];
  len = length(n);
  n = n([1 2 3 4 5 6 len 7]);
  [a,b,c,d] = tbpx1(i,j,k,l,m,n);

elseif nargin == 8
  [a,b,c,d,e,f] = tbpx2(i,j,k,l,m,n,o,p,...
    [NaN NaN NaN NaN NaN NaN 0 NaN]);

elseif nargin == 9
  q = [q NaN+zeros(1,8) 0];
  len = length(q);
  q = q([1 2 3 4 5 6 len 7]);
  [a,b,c,d,e,f] = tbpx2(i,j,k,l,m,n,o,p,q);

elseif nargin == 11
  [a,b,c,d,e,f,g,h] = tbpx3(i,j,k,l,m,n,o,p,q,r,s, ...
    [NaN NaN NaN NaN NaN NaN 0 NaN]);

elseif nargin == 12
  t = [t NaN+zeros(1,8) 0];
  len = length(t);
  t = t([1 2 3 4 5 6 len 7]);
  [a,b,c,d,e,f,g,h] = tbpx3(i,j,k,l,m,n,o,p,q,r,s,t);
end
