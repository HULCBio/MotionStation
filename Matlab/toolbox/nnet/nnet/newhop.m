function net=newhop(t)
% NEWHOP Create a Hopfield recurrent network.
%
%  Syntax
%
%    net = newhop
%    net = newhop(T)
%
%  Description
%
%    Hopfield networks are used for pattern recall.
%
%   NET = NEWHOP creates a new network with a dialog box.
%
%    NEWHOP(T) takes one input argument,
%      T - RxQ matrix of Q target vectors. (Values must be +1 or -1.)
%    and returns a new Hopfield recurrent neural network with
%    stable points at the vectors in T.
%
%  Examples
%
%    Here we create a Hopfield network with two three-element
%    stable points T.
%
%      T = [-1 -1 1; 1 -1 1]';
%      net = newhop(T);
%
%    Below we check that the network is stable at these points by
%    using them as initial layer delay conditions.  If the network is
%    stable we would expect that the outputs Y will be the same.
%    (Since Hopfield networks have no inputs, the second argument
%    to SIM is Q = 2 when using matrix notation).
%
%      Ai = T;
%      [Y,Pf,Af] = sim(net,2,[],Ai);
%      Y
%
%    To see if the network can correct a corrupted vector, run
%    the following code which simulates the Hopfield network for
%    five timesteps.  (Since Hopfield networks have no inputs,
%    the second argument to SIM is {Q TS} = [1 5] when using cell
%    array notation.)
%
%      Ai = {[-0.9; -0.8; 0.7]};
%      [Y,Pf,Af] = sim(net,{1 5},{},Ai);
%      Y{1}
%
%    If you run the above code Y{1} will equal T(:,1) if the
%    network has managed to convert the corrupted vector Ai to
%    the nearest target vector.
%
%  Algorithm
%
%    Hopfield networks are designed to have stable layer outputs
%    as defined by user supplied targets.  The algorithm
%    minimizes the number of unwanted stable points.
%
%  Properties
%
%    Hopfield networks consist of a single layer with the DOTPROD
%    weight function, NETSUM net input function, and the SATLINS
%    transfer function.
%
%    The layer has a recurrent weight from itself and a bias.
%
%  Reference
%
%    J. Li, A. N. Michel, W. Porod, "Analysis and synthesis of a
%    class of neural networks: linear systems operating on a
%    closed hypercube," IEEE Transactions on Circuits and Systems,
%    vol. 36, no. 11, pp. 1405-1422, November 1989.
%
%  See also SIM, SATLINS.

% Mark Beale, 11-31-97
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.8 $ $Date: 2002/04/14 21:31:17 $

% ARGUMENTS
if nargin < 1
  net = newnet('newhop');
  return
end

% CHECKING
if (~isa(t,'double')) | ~isreal(t) | (length(t) == 0)
  error('Targets is not a real non-empty matrix.');
end

% DIMENSIONS
[S,Q] = size(t);

% NETWORK PARAMETERS
[w,b] = solvehop2(t);

% NETWORK ARCHITECTURE
net = network(0,1,[1],[],[1],[1]);

% RECURRENT LAYER
net.layers{1}.size = S;
net.layers{1}.transferFcn = 'satlins';
net.b{1} = b;
net.lw{1,1} = w;
net.layerWeights{1,1}.delays = 1;

%==========================================================
function [w,b] = solvehop2(t)

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

%==========================================================
