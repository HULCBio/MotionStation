function net=newlin(pr,s,id,lr)
%NEWLIN Create a linear layer.
%
%  Syntax
%
%    net = newlin
%    net = newlin(PR,S,ID,LR)
%
%  Description
%
%    Linear layers are often used as adaptive filters
%    for signal processing and prediction.
%
%   NET = NEWLIN creates a new network with a dialog box.
%
%    NEWLIN(PR,S,ID,LR) takes these arguments,
%      PR - Rx2 matrix of min and max values for R input elements.
%      S  - Number of elements in the output vector.
%      ID - Input delay vector, default = [0].
%      LR - Learning rate, default = 0.01;
%    and returns a new linear layer.
%
%    NET = NEWLIN(PR,S,0,P) takes an alternate argument,
%      P  - Matrix of input vectors.
%    and returns a linear layer with the maximum stable
%    learning rate for learning with inputs P.
%
%  Examples
%
%    This code creates a single input (range of [-1 1] linear
%    layer with one neuron, input delays of 0 and 1, and a learning
%    rate of 0.01.  It is simulated for an input sequence P1.
%
%      net = newlin([-1 1],1,[0 1],0.01);
%      P1 = {0 -1 1 1 0 -1 1 0 0 1};
%      Y = sim(net,P1)
%
%    Here targets T1 are defined and the layer adapts to them.
%    (Since this is the first call to ADAPT, the default input
%    delay conditions are used.)
%
%      T1 = {0 -1 0 2 1 -1 0 1 0 1};
%      [net,Y,E,Pf] = adapt(net,P1,T1); Y
%
%    Here the linear layer continues to adapt for a new sequence
%    using the previous final conditions PF as initial conditions.
%
%      P2 = {1 0 -1 -1 1 1 1 0 -1};
%      T2 = {2 1 -1 -2 0 2 2 1 0};
%      [net,Y,E,Pf] = adapt(net,P2,T2,Pf); Y
%
%    Here we initialize the layer's weights and biases to new values.
%
%      net = init(net);
%
%    Here we train the newly initialized layer on the entire sequence
%    for 200 epochs to an error goal of 0.1.
%
%      P3 = [P1 P2];
%      T3 = [T1 T2];
%      net.trainParam.epochs = 200;
%      net.trainParam.goal = 0.1;
%      net = train(net,P3,T3);
%      Y = sim(net,[P1 P2])
%
%  Algorithm
%
%    Linear layers consist of a single layer with the DOTPROD
%    weight function, NETSUM net input function, and PURELIN
%    transfer function.
%
%    The layer has a weight from the input and a bias.
%
%    Weights and biases are initialized with INITZERO.
%
%    Adaption and training are done with TRAINS and TRAINB,
%    which both update weight and bias values with LEARNWH.
%    Performance is measured with MSE.
%
%  See also NEWLIND, SIM, INIT, ADAPT, TRAIN, TRAINB, TRAINS.

% Mark Beale, 11-31-97
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.10 $ $Date: 2002/04/14 21:37:14 $

if nargin < 2
  net = newnet('newlin');
  return
end
if (nargin >= 4) & (length(lr) > 1)
  if ((length(id) ~= 1) | (id ~= 0))
    error('ID must be 0 for maximum learning rate to be calculated.')
  end
end

% Defaults
if nargin < 3, id = [0]; end
if nargin < 4, lr = 0.01; end

% Checking
if (~isa(pr,'double')) | ~isreal(pr) | (size(pr,2) ~= 2)
  error('Input ranges is not a two column matrix.')
end
if any(pr(:,1) > pr(:,2))
  error('Input ranges has values in the second column larger in the values in the same row of the first column.')
end
if ~isa(s,'double')
  error('Number of neurons is not a positive integer.')
end
if (~isa(s,'double')) | ~isreal(s) | any(size(s) ~= 1) | (s<1) | (round(s) ~= s)
  error('Number of neurons is not a positive integer.')
end
if (~isa(id,'double')) | ~isreal(id) | (size(id,1) ~= 1) | any(id ~= round(id)) | any(diff(id) <= 0)
  error('Input delays is not a row vector of increasing zero or positive integers.');
end
if (~isa(lr,'double')) | ~isreal(lr) | any(size(lr) ~= 1) | (lr < 0) | (lr > 1)
  error('Learning rate is not a real value between 0.0 and 1.0.')
end
  
% Architecture
net = network(1,1,1,1,0,1,1);
net.inputs{1}.range = pr;
net.layers{1}.size = s;
net.inputWeights{1,1}.delays = id;

% Performance
net.performFcn = 'mse';

% Learning (Adaption and Training)
net.inputWeights{1,1}.learnFcn = 'learnwh';
net.biases{1}.learnFcn = 'learnwh';
if (length(lr) > 1), lr = maxlinlr(lr,'bias'); end
net.inputWeights{1,1}.learnParam.lr = lr;
net.biases{1}.learnParam.lr = lr;

% Adaption
net.adaptFcn = 'trains';

% Training
net.trainFcn = 'trainb';

% Initializiaton
net.initFcn = 'initlay';
net.layers{1}.initFcn = 'initwb';
net.inputWeights{1,1}.initFcn = 'initzero';
net.biases{1}.initFcn = 'initzero';
net = init(net);

