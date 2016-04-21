function [net,tr,Ac,El]=trainc(net,Pd,Tl,Ai,Q,TS,VV,TV)
%TRAINC Cyclical order incremental training w/learning functions.
%
%  Syntax
%  
%    [net,tr,Ac,El] = trainc(net,Pd,Tl,Ai,Q,TS,VV,TV)
%    info = trainc(code)
%
%  Description
%
%    TRAINC is not called directly.  Instead it is called by TRAIN for
%    network's whose NET.trainFcn property is set to 'trainc'.
%
%    TRAINC trains a network with weight and bias learning rules with
%    incremental updates after each presentation of an input.  Inputs
%    are presented in cyclic order.
%
%    TRAINC(NET,Pd,Tl,Ai,Q,TS,VV) takes these inputs,
%      NET - Neural network.
%      Pd  - Delayed inputs.
%      Tl  - Layer targets.
%      Ai  - Initial input conditions.
%      Q   - Batch size.
%      TS  - Time steps.
%      VV  - Ignored.
%      TV  - Ignored.
%    and returns,
%      NET - Trained network.
%      TR  - Training record of various values over each epoch:
%            TR.epoch - Epoch number.
%            TR.perf  - Training performance.
%      Ac  - Collective layer outputs.
%      El  - Layer errors.
%
%    Training occurs according to the TRAINC's training parameters
%    shown here with their default values:
%      net.trainParam.epochs  100  Maximum number of epochs to train
%      net.trainParam.goal      0  Performance goal
%      net.trainParam.show     25  Epochs between displays (NaN for no displays)
%      net.trainParam.time    inf  Maximum time to train in seconds
%
%    Dimensions for these variables are:
%      Pd - NoxNixTS cell array, each element Pd{i,j,ts} is a DijxQ matrix.
%      Tl - NlxTS cell array, each element P{i,ts} is a VixQ matrix or [].
%    Ai - NlxLD cell array, each element Ai{i,k} is an SixQ matrix.
%    Where
%      Ni = net.numInputs
%    Nl = net.numLayers
%    LD = net.numLayerDelays
%      Ri = net.inputs{i}.size
%      Si = net.layers{i}.size
%      Vi = net.targets{i}.size
%      Dij = Ri * length(net.inputWeights{i,j}.delays)
%
%    TRAINC does not implement validation or test vectors, so arguments
%    VV and TV are ignored.
%
%    TRAINC(CODE) returns useful information for each CODE string:
%      'pnames'    - Names of training parameters.
%      'pdefaults' - Default training parameters.
%
%  Network Use
%
%    You can create a standard network that uses TRAINC by calling
%    NEWP.
%
%    To prepare a custom network to be trained with TRAINC:
%    1) Set NET.trainFcn to 'trainc'.
%       (This will set NET.trainParam to TRAINC default parameters.)
%    2) Set each NET.inputWeights{i,j}.learnFcn to a learning function.
%       Set each NET.layerWeights{i,j}.learnFcn to a learning function.
%       Set each NET.biases{i}.learnFcn to a learning function.
%       (Weight and bias learning parameters will automatically be
%       set to default values for the given learning function.)
%
%    To train the network:
%    1) Set NET.trainParam properties to desired values.
%    2) Set weight and bias learning parameters to desired values.
%    3) Call TRAIN.
%
%    See NEWP for training examples.
%
%  Algorithm
%
%    For each epoch, each vector (or sequence) is presented in order
%    to the network with the weight and bias values updated accordingly
%    after each individual presentation.
%
%    Training stops when any of these conditions are met:
%    1) The maximum number of EPOCHS (repetitions) is reached.
%    2) Performance has been minimized to the GOAL.
%    3) The maximum amount of TIME has been exceeded.
%
%  See also NEWP, NEWLIN, TRAIN.

% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.6 $  $Date: 2002/04/14 21:37:50 $

% FUNCTION INFO
% =============

% OBSOLETE VERSION OF TRAINC FROM NNT 2.0
if (nargin == 2)
    net = traincold(net,Pd);
    return
elseif (nargin == 3)
    net = traincold(net,Pd,Tl);
    return
end


if isstr(net)
  switch (net)
    case 'pnames',
    net = {'epochs';'goal';'show';'time'};
    case 'pdefaults',
    trainParam.epochs = 100;
    trainParam.goal = 0;
    trainParam.show = 25;
    trainParam.time = inf;
    net = trainParam;
    otherwise,
    error('Unrecognized code.')
  end
  return
end

% CALCULATION
% ===========

% Parameters
epochs = net.trainParam.epochs;
goal = net.trainParam.goal;
show = net.trainParam.show;
time = net.trainParam.time;

% Parameter Checking
if (~isa(epochs,'double')) | (~isreal(epochs)) | (any(size(epochs)) ~= 1) | ...
  (epochs < 1) | (round(epochs) ~= epochs)
  error('Epochs is not a positive integer.')
end
if (~isa(goal,'double')) | (~isreal(goal)) | (any(size(goal)) ~= 1) | ...
  (goal < 0)
  error('Goal is not zero or a positive real value.')
end
if (~isa(show,'double')) | (~isreal(show)) | (any(size(show)) ~= 1) | ...
  (isfinite(show) & ((show < 1) | (round(show) ~= show)))
  error('Show is not ''NaN'' or a positive integer.')
end
if (~isa(time,'double')) | (~isreal(time)) | (any(size(time)) ~= 1) | ...
  (time < 0)
  error('Time is not zero or a positive real value.')
end
this = 'TRAINC';
if (~isempty(VV))
  fprintf('Warning - %s does not support validation vectors.\n',this);
end
if (~isempty(TV))
  fprintf('Warning - %s does not support test vectors.\n',this);
end

% Generate functions
simfunc = gensimm(net);
[x,simfuncname] = fileparts(simfunc);
bpfunc = genbpm(net);
[x,bpfuncname] = fileparts(bpfunc);
traincfunc = gentraincm(net,simfuncname,bpfuncname);
[x,traincfuncname] = fileparts(traincfunc);

% Call generated function
[net,tr,Ac,El]=feval(traincfuncname,net,Pd,Tl,Ai,Q,TS,VV,TV);

% Delete functions
delete(simfunc);
delete(bpfunc);
delete(traincfunc);
