function [w1,b1,w2,b2,w3,b3] = initff(p,s1,f1,s2,f2,s3,f3)
%INITFF Inititialize feed-forward network up to 3 layers.
%  
%  This function is obselete.
%  Use NNT2FF and INIT to update and initialize your network.

nntobsf('initff','Use NNT2FF and INIT to update and initialize your network.')

%  [W1,B1,...] = INITFF(P,S1,'F1',...,Sn,'Fn')
%    P  - Rx2 matrix of input vectors.
%    Si - Size of ith layer.
%    Fi - Transfer function of the ith layer (string).
%  Returns:
%    Wi - Weight matrix of the ith layer.
%    Bi - Bias (column) vector of the ith layer.
%  
%  [W1,B1,...] = INITFF(P,S1,'F1',...,T,'Fn')
%    T - SnxQ matrix of target vectors.
%  Returns weights and biases.
%  
%  IMPORTANT: Each ith row of P must contain expected
%    min and max values for the ith input.
%  
%  EXAMPLE: [W1,b1,W2,b2] = initff([0 10; -5 5],5,'tansig',3,'purelin');
%           p = [4; -1];
%           a = simuff(p,W1,b1,'tansig',W2,b2,'purelin')
%  
%  See also NNINIT, BACKPROP, SIMUFF, TRAINBPX, TRAINLM

% Mark Beale, 12-15-93
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.11 $  $Date: 2002/04/14 21:14:02 $

if all([3 5 7] ~= nargin),error('Wrong number of input arguments'),end

[R,Q] = size(p);
if (Q < 2), error('P must contain at least two elements in each row.'),end

if nargin == 3
  [S,Q] = size(s1);
  if max(S,Q) > 1, s1 = S; end
  [w1,b1] = feval(feval(f1,'init'),s1,p);

elseif nargin == 5
  [w1,b1] = feval(feval(f1,'init'),s1,p);
  x = ones(s1,1) * feval(f1,'output');
  [S,Q] = size(s2);
  if max(S,Q) > 1, s2 = S; end
  [w2,b2] = feval(feval(f2,'init'),s2,x);
   
elseif nargin == 7
  [w1,b1] = feval(feval(f1,'init'),s1,p);
  x = ones(s1,1) * feval(f1,'output');
  [w2,b2] = feval(feval(f2,'init'),s2,x);
  x = ones(s2,1) * feval(f2,'output');
  [S,Q] = size(s3);
  if max(S,Q) > 1, s3 = S; end
  [w3,b3] = feval(feval(f3,'init'),s3,x);
end
