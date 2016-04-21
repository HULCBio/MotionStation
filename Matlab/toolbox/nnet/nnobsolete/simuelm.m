function [a1,a2] = simuelm(p,w1,b1,w2,b2,init_a1)
%SIMUELM Simulates an Elman recurrent network.
%  
%  This function is obselete.
%  Use NNT2ELM and SIM to update and simulate your network.

nntobsf('simuelm','Use NNT2ELM and SIM to update and simulate your network.')

%  [A1,A2] = SIMUELM(P,W1,B1,W2,B2,A1)
%    P  - Input (column) vectors to network arranged in time.
%    W1 - Weight matrix for recurrent layer.
%    B1 - Bias (column) vector for recurrent layer.
%    W2 - Weight matrix for output layer.
%    B2 - Bias (column) vector for output layer.
%    A1 - Initial output vector of recurrent layer (optional).
%  Returns:
%    A1 - Output (column) vectors of recurrent layer in time.
%    A2 - Output (column) vectors of output layer in time.
%  
%  A2 = SIMUELM(P,W1,B1,W2,B2,A1)
%  Returns only the output vectors.
%  
%  EXAMPLE: [W1,b1,W2,b2] = initelm([-5 5; 0 2],4,1);
%           p = [3; 1.5];
%           a = simuelm(p,W1,b1,W2,b2)
%  
%  See also NNSIM, ELMAN, INITELM, TRAINELM.

% Mark Beale, 12-15-93
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.11 $  $Date: 2002/04/14 21:15:45 $

[r,q] = size(p);
s1 = length(b1);
s2 = length(b2);
a2 = zeros(s2,q);

if nargin == 5, init_a1 = zeros(s1,1); end

if nargout == 1
  a1 = tansig(w1*[p(:,1); init_a1],b1);
  a2(:,1) = purelin(w2*a1,b2);
  for i=2:q
    a1 = tansig(w1*[p(:,i); a1],b1);
    a2(:,i) = purelin(w2*a1,b2);
  end
  a1 = a2;

elseif nargout == 2
  a1 = zeros(s1,q);
  a1(:,1) = tansig(w1*[p(:,1); init_a1],b1);
  a2(:,1) = purelin(w2*a1(:,1),b2);
  for i=2:q
    a1(:,i) = tansig(w1*[p(:,i); a1(:,i-1)],b1);
    a2(:,i) = purelin(w2*a1(:,i),b2);
  end
end
