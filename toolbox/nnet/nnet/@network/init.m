function net=init(net)
%INIT Initialize a neural network.
%
%  Syntax
%
%    net = init(net)
%
%  Description
%
%    INIT(NET) returns neural network NET with weight and bias values
%    updated according to the network initialization function, indicated
%    by NET.initFcn, and the parameter values, indicated by NET.initParam.
%
%  Examples
%
%    Here a perceptron is created with a 2-element input (with ranges
%    of 0 to 1, and -2 to 2) and 1 neuron.  Once it is created we can display
%    the neuron's weights and bias.
%
%      net = newp([0 1;-2 2],1);
%      net.iw{1,1}
%      net.b{1}
%
%    Training the perceptron alters its weight and bias values.
%
%      P = [0 1 0 1; 0 0 1 1];
%      T = [0 0 0 1];
%      net = train(net,P,T);
%      net.iw{1,1}
%      net.b{1}
%
%    INIT reinitializes those weight and bias values.
%
%      net = init(net);
%      net.iw{1,1}
%      net.b{1}
%
%    The weights and biases are zeros again, which are the initial values
%    used by perceptron networks (see NEWP). 
%
%  Algorithm
%
%    INIT calls NET.initFcn to initialize the weight and bias values
%    according to the parameter values NET.initParam.
%
%    Typically, NET.initFcn is set to 'initlay' which initializes each
%    layer's weights and biases according to its NET.layers{i}.initFcn.
%
%    Backpropagation networks have NET.layers{i}.initFcn set to 'initnw'
%    which calculates the weight an bias values for layer i using the
%    Nguyen-Widrow initialization method.
%
%    Other networks have NET.layers{i}.initFcn set to 'initwb', which
%    initializes each weight and bias with its own initialization function.
%    The most common weight and bias initialization function is RANDS
%    which generates random values between -1 and 1.
%
%  See also REVERT, SIM, ADAPT, TRAIN, INITLAY, INITNW, INITWB, RANDS.

%  Mark Beale, 11-31-97
%  Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.9 $ $Date: 2002/04/14 21:28:54 $

net = struct(net);

initFcn = net.initFcn;
if length(initFcn)
  net = feval(initFcn,net);
end

% Warn user of constant inputs
for i=1:net.numInputs
  prange = net.inputs{i}.range;
  if (any(prange(:,1) == prange(:,2)))
    fprintf('\n')
    fprintf('** Warning in INIT\n')
    fprintf('** Network "input{%g}.range" has a row with equal min and max values.\n',i)
    fprintf('** Constant inputs do not provide useful information.\n')
    fprintf('\n')
  end
end

% Save values for future calls to REVERT
net.revert.IW = net.IW;
net.revert.LW = net.LW;
net.revert.b = net.b;

net = class(net,'network');
