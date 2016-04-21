function net=newlvq(pr,s1,pc,lr,lf)
%NEWLVQ Create a learning vector quantization network.
%
%  Syntax
%
%    net = newlvq
%    net = newlvq(PR,S1,PC,LR,LF)
%
%  Description
%
%    LVQ networks are used to solve classification
%    problems.
%
%   NET = NEWLVQ creates a new network with a dialog box.
%
%    NET = NEWLVQ(PR,S1,PC,LR,LF) takes these inputs,
%      PR - Rx2 matrix of min and max values for R input elements.
%      S1 - Number of hidden neurons.
%      PC - S2 element vector of typical class percentages.
%      LR - Learning rate, default = 0.01.
%      LF - Learning function, default = 'learnlv1'.
%    Returns a new LVQ network.
%
%    The learning function LF can be LEARNLV1 or LEARNLV2.
%    LEARNLV2 should only be used to finish training of networks
%    already trained with LEARNLV1.
%
%  Examples
%
%    The input vectors P and target classes Tc below define
%    a classification problem to be solved by an LVQ network.
%
%      P = [-3 -2 -2  0  0  0  0 +2 +2 +3; ...
%           0 +1 -1 +2 +1 -1 -2 +1 -1  0];
%      Tc = [1 1 1 2 2 2 2 1 1 1];
%
%    Target classes Tc are converted to target vectors T. Then an
%    LVQ network is created (with inputs ranges obtained from P,
%    4 hidden neurons, and class percentages of 0.6 and 0.4)
%    and is trained.
%
%      T = ind2vec(Tc);
%      net = newlvq(minmax(P),4,[.6 .4]);
%      net = train(net,P,T);
%
%    The resulting network can be tested.
%
%      Y = sim(net,P)
%      Yc = vec2ind(Y)
%
%  Properties
%
%    NEWLVQ creates a two layer network. The first layer uses the
%    COMPET transfer function, calculates weighted inputs with NEGDIST, and
%    net input with NETSUM.  The second layer has PURELIN neurons,
%    calculates weighted input with DOTPROD and net inputs with NETSUM.
%    Neither layer has biases.
%
%    First layer weights are initialized with MIDPOINT.  The
%    second layer weights are set so that each output neuron i
%    has unit weights coming to it from PC(i) percent of the
%    hidden neurons.
%
%    Adaption and training are done with TRAINS and TRAINR,
%    which both update the first layer weights with the specified
%    learning functions.
%
%  See also SIM, INIT, ADAPT, TRAIN, TRAINS, TRAINR, LEARLV1, LEARNLV2.

% Mark Beale, 11-31-97
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.9 $ $Date: 2002/04/14 21:33:17 $

if nargin < 3
  net = newnet('newlvq')
  return
end

% Defaults
if nargin < 4, lr = 0.01; end
if nargin < 5, lf = 'learnlv1'; end

% Checking
if (~isa(pr,'double')) | ~isreal(pr) | (size(pr,2) ~= 2)
  error('Input ranges is not a two column matrix.')
end
if any(pr(:,1) > pr(:,2))
  error('Input ranges has values in the second column larger in the values in the same row of the first column.')
end
if (~isa(s1,'double')) | ~isreal(s1) | any(size(s1) ~= 1) | (s1<1) | (round(s1) ~= s1)
  error('Number of hidden neurons is not a positive integer.')
end
if (~isa(pc,'double')) | (~isreal(pc)) | (size(pc,1) ~= 1) | (abs(sum(pc)-1) > 1e-10)
  error('Class percentages is not a row vector whose elements sum to 1.0.')
end
if (~isa(lr,'double')) | ~isreal(lr) | any(size(lr) ~= 1) | (lr < 0) | (lr > 1)
  error('Learning rate is not a real value between 0.0 and 1.0.')
end

% Values
pc = pc(:);
s2 = length(pc);

% Architecture
net = network(1,2,[0;0],[1; 0],[0 0;1 0],[0 1],[0 1]);

% Simulation
net.inputs{1}.range = pr;
net.layers{1}.size = s1;
net.inputWeights{1,1}.weightFcn = 'negdist';
net.layers{1}.transferFcn = 'compet';
net.layers{2}.size = s2;
indices = [0; floor(cumsum(pc)*s1)];
lw21 = zeros(s2,s1);
for i=1:s2
  lw21(i,(indices(i)+1):indices(i+1)) = 1;
end
net.lw{2,1} = lw21;

% Performance
net.performFcn = 'mse';

% Learning (Adaption and Training)
net.inputWeights{1,1}.learnFcn = lf;
net.inputWeights{1,1}.learnParam.lr = lr;

% Adaption
net.adaptFcn = 'trains';

% Training
net.trainFcn = 'trainr';

% Initialization
net.initFcn = 'initlay';
net.layers{1}.initFcn = 'initwb';
net.inputWeights{1,1}.initFcn = 'midpoint';
net = init(net);
