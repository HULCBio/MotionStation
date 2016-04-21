function [w,b] = solvehop(t)
%SOLVEHOP Design Hopfield network.
%  
%  This function is obselete.
%  Use NEWHOP to design your network.

nntobsf('solvehop','Use NEWHOP to design your network.')

%  [W,B] = SOLVEHOP(T)
%    T - SxQ matrix of target output vectors.
%  Returns:
%    W - SxS weight matrix.
%    B - Sx1 bias vector.
%  
%  See also NNSOLVE, HOPFIELD, SIMHOP.

% Howard Demuth, 1-31-92
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.11 $  $Date: 2002/04/14 21:12:38 $

% Jian-Hua Li, Anthony N. Michel, "Analysis and synthesis
%   of a class of neural networks: linear systems
%   operating on a closed hypercube," IEEE Trans. on
%   Circuits and Systems vol 36, no. 11, pp. 1405-22,
%   November 1989.

if nargin < 1,error('Not enough input arguments.'); end
if nargout < 2, error('Not enough output arguments.'); end

[S,Q] = size(t);
Y = t(:,1:Q-1)-t(:,Q)*ones(1,Q-1);
[U,SS,V] = svd(Y);
K = rank(SS);

TP = zeros(S,S);
for k=1:K
  TP = TP + U(:,k)*U(:,k)';
  end

TM = zeros(S,S);
for k=K+1:S
  TM = TM + U(:,k)*U(:,k)';
  end

tau = 10;
Ttau = TP - tau*TM;
Itau = t(:,Q) - Ttau*t(:,Q);

h = 0.15;
C1 = exp(h)-1;
C2 = -(exp(-tau*h)-1)/tau;

w = expm(h*Ttau);
b = U * [  C1*eye(K)         zeros(K,S-K);
         zeros(S-K,K)  C2*eye(S-K)] * U' * Itau;

