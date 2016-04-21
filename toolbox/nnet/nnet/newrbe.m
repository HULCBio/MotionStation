function net=newrbe(p,t,spread)
%NEWRBE Design an exact radial basis network.
%
%  Synopsis
%
%    net = newrbe
%    net = newrbe(P,T,SPREAD)
%
%  Description
%
%    Radial basis networks can be used to approximate functions.
%    NEWRBE very quickly designs a radial basis network with
%    zero error on the design vectors.
%
%   NET = NEWRBE creates a new network with a dialog box.
%
%    NEWRBE(P,T,SPREAD) takes two or three arguments,
%    P      - RxQ matrix of Q input vectors.
%    T      - SxQ matrix of Q target class vectors.
%    SPREAD - of radial basis functions, default = 1.0.
%    and returns a new exact radial basis network.
%
%    The larger that SPREAD, is the smoother the function approximation
%    will be. Too large a spread can cause numerical problems.
%
%  Examples
%
%    Here we design a radial basis network, given inputs P
%    and targets T.
%
%      P = [1 2 3];
%      T = [2.0 4.1 5.9];
%      net = newrbe(P,T);
%
%    Here the network is simulated for a new input.
%
%      P = 1.5;
%      Y = sim(net,P)
%
%  Algorithm
%
%    NEWRBE creates a two layer network. The first layer has RADBAS
%    neurons, and calculates its weighted inputs with DIST, and its
%    net input with NETPROD.  The second layer has PURELIN neurons,
%    and calculates its weighted input with DOTPROD and its net inputs
%    with NETSUM. Both layer's have biases.
%
%    NEWRBE sets the first layer weights to P', and the first
%    layer biases are all set to 0.8326/SPREAD, resulting in
%    radial basis functions that cross 0.5 at weighted inputs
%    of +/- SPREAD.
%
%    The second layer weights IW{2,1} and biases b{2} are found by
%    simulating the first layer outputs A{1}, and then solving the
%    following linear expression:
%
%        [W{2,1} b{2}] * [A{1}; ones] = T
%
%  See also SIM, NEWRB, NEWGRNN, NEWPNN.

% Mark Beale, 11-31-97
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.9 $ $Date: 2002/04/14 21:34:50 $

if nargin < 2
  net = newnet('newrbe');
  return
end

% Defaults
if nargin < 3, spread = 1; end

% Error checks
if (~isa(p,'double')) | (~isreal(p)) | (length(p) == 0)
  error('Inputs are not a non-empty real matrix.')
end
if (~isa(t,'double')) | (~isreal(t)) | (length(t) == 0)
  error('Targets are not a non-empty real matrix.')
end
if (size(p,2) ~= size(t,2))
  error('Inputs and Targets have different numbers of columns.')
end
if (~isa(spread,'double')) | ~isreal(spread) | any(size(spread) ~= 1) | (spread < 0)
  error('Spread is not a positive or zero real value.')
end

% Dimensions
[R,Q] = size(p);
[S,Q] = size(t);

% Architecture
net = network(1,2,[1;1],[1;0],[0 0;1 0],[0 1]);

% Simulation
net.inputs{1}.size = R;
net.layers{1}.size = Q;
net.inputWeights{1,1}.weightFcn = 'dist';
net.layers{1}.netInputFcn = 'netprod';
net.layers{1}.transferFcn = 'radbas';
net.layers{2}.size = S;

% Weight and Bias Values
[w1,b1,w2,b2] = designrbe(p,t,spread);

net.b{1} = b1;
net.iw{1,1} = w1;
net.b{2} = b2;
net.lw{2,1} = w2;

%======================================================
function [w1,b1,w2,b2] = designrbe(p,t,spread)

[r,q] = size(p);
[s2,q] = size(t);

w1 = p';
b1 = ones(q,1)*sqrt(-log(.5))/spread;
a1 = radbas(dist(w1,p).*(b1*ones(1,q)));

x = t/[a1; ones(1,q)];
w2 = x(:,1:q);
b2 = x(:,q+1);

%======================================================
