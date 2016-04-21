function [dw,db] = learnbp(p,d,lr)
%LEARNBP Backpropagation learning rule.
%  
%  This function is obselete.
%  Use LEARNGD to calculate new weights and biases.

nntobsf('learnbp','Use LEARNGD to calculate new weights and biases.')

%  [dW,dB] = LEARNBP(P,D,LR)
%    P  - RxQ matrix of input vectors.
%    E  - SxQ matrix of error vectors.
%    LR - the learning rate (default = 1).
%  Returns:
%    dW - a weight change matrix.
%    dB - a bias change vector (optional).
%  
%  See also NNLEARN, BACKPROP, SIMFF, INITFF, TRAINBP.

% Mark Beale, 1-31-92
% Revised 12-15-93, MB
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.11 $  $Date: 2002/04/14 21:14:17 $

if nargin < 2, error('Not enough arguments.'); end
if nargin == 3, d = lr*d; end

dw = d*p';
if nargout == 2
  [R,Q] = size(p);
  db = d*ones(Q,1);
end
