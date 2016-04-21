function dw = learnlvq2(w,p,a,t,lr)
%LEARNLVQ Learning vector quantization rule.
%  
%  This function is obselete.
%  Use NNT2LVQ and TRAIN to update and train your network.

nntobsf('learnlvq','Use NNT2LVQ and TRAIN to update and train your network.')

%  LEARNLVQ(W,P,A,T,LR)
%    W  - SxR weight matrix.
%    P  - Rx1 input vector.
%    A  - Sx1 0/1 output vector.
%    T  - Sx1 0/1 target vector
%    LR - Learning rate.
%  Returns a weight change matrix.
%  
%  See also NNLEARN, LVQ, SIMLVQ, INITLVQ, TRAINLVQ.

% Mark Beale, 12-15-93
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.11 $  $Date: 2002/04/14 21:14:26 $

if nargin < 4,error('Not enough arguments.'); end

i = find(a ~= 0);
len = length(i);

[S,R] = size(w);
if len == 1
  x = t(i).*2 - 1;
  dw = sparse(i,1:R,lr*(p'-w(i,:))*x,S,R,R);
else
  dw = zeros(size(w));
  x = t(i).*2 - 1;
  dw(i,:) = lr*(ones(len,1)*p'-w(i,:)).*(x * ones(1,R));
end
