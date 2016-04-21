function net=newc(pr,s,klr,clr)
%NEWC Create a competitive layer.
%
%  Syntax
%
%   net = newc
%   net = newc(PR,S,KLR,CLR)
%
%  Description
%
%    Competitive layers are used to solve classification
%    problems.
%
%   NET = NEWC creates a new network with a dialog box.
%
%    NET = NEWC(PR,S,KLR,CLR) takes these inputs,
%      PR - Rx2 matrix of min and max values for R input elements.
%      S  - Number of neurons.
%      KLR - Kohonen learning rate, default = 0.01.
%      CLR - Conscience learning rate, default = 0.001.
%    Returns a new competitive layer.
%
%  Examples
%
%    Here is a set of four two-element vectors P.
%
%      P = [.1 .8  .1 .9; .2 .9 .1 .8];
%
%    To competitive layer can be used to divide these inputs
%    into two classes.  First a two neuron layer is created
%    with two input elements ranging from 0 to 1, then it
%    is trained.
%
%      net = newc([0 1; 0 1],2);
%      net = train(net,P);
%
%    The resulting network can then be simulated and its
%    output vectors converted to class indices.
%
%      Y = sim(net,P)
%      Yc = vec2ind(Y)
%
%  Properties
%
%    Competitive layers consist of a single layer with the NEGDIST
%    weight function, NETSUM net input function, and the COMPET
%    transfer function.
%
%    The layer has a weight from the input, and a bias.
%
%    Weights and biases are initialized with MIDPOINT and INITCON.
%
%    Adaption and training are done with TRAINS and TRAINR,
%    which both update weight and bias values with the LEARNK
%    and LEARNCON learning functions.
%
%  See also SIM, INIT, ADAPT, TRAIN, TRAINS, TRAINR.

% Mark Beale, 11-31-97
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.9 $ $Date: 2002/04/14 21:35:35 $

if nargin < 2
  net = newnet('newc');
  return;
end

% Defaults
if nargin < 3, klr = 0.01; end
if nargin < 4, clr = 0.001; end

% Error Checking
if (~isa(pr,'double')) | ~isreal(pr) | (size(pr,2) ~= 2)
  error('Input ranges is not a two column matrix.')
end
if any(pr(:,1) > pr(:,2))
  error('Input ranges has values in the second column larger in the values in the same row of the first column.')
end
if (~isa(s,'double')) | ~isreal(s) | any(size(s) ~= 1) | (s<1) | (round(s) ~= s)
  error('Number of neurons is not a positive integer.')
end
if (~isa(klr,'double')) | any(size(klr) ~= 1) | (klr < 0) | (klr > 1)
  error('Kohonen learning rate is not a real value between 0.0 and 1.0.');
end
if (~isa(clr,'double')) | any(size(clr) ~= 1) | (clr < 0) | (clr > 1)
  error('Conscience learning rate is not a real value between 0.0 and 1.0.');
end
if (clr > klr)
  error('Conscience learning rate is greater than the Kohonen learning rate.');
end

% Architecture
net = network(1,1,[1],[1],[0],[1]);

% Simulation
net.inputs{1}.range = pr;
net.layers{1}.size = s;
net.inputWeights{1,1}.weightFcn = 'negdist';
net.layers{1}.transferFcn = 'compet';

% Learning
net.inputWeights{1,1}.learnFcn = 'learnk';
net.inputWeights{1,1}.learnParam.lr = klr;
net.biases{1}.learnFcn = 'learncon';
net.biases{1}.learnParam.lr = clr;

% Adaption
net.adaptFcn = 'trains';

% Training
net.trainFcn = 'trainr';

% Initialization
net.initFcn = 'initlay';
net.layers{1}.initFcn = 'initwb';
net.biases{1}.initFcn = 'initcon';
net.inputWeights{1,1}.initFcn = 'midpoint';
net = init(net);
