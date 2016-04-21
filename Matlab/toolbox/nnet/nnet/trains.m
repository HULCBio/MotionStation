function [net,tr,Ac,El]=trains(net,PD,Tl,Ai,Q,TS,VV,TV)
%TRAINS Sequential order incremental training w/learning functions.
%
%  Syntax
%
%    [net,TR,Ac,El] = trains(net,Pd,Tl,Ai,Q,TS,VV,TV)
%    info = trains(code)
%
%  Description
%
%    TRAINS is not called directly.  Instead it is called by ADAPT for
%   network's whose NET.adaptFcn property is set to 'trains', or by TRAIN
%    for network's whose NET.trainFcn property is set to 'trains'
%
%    TRAINS trains a network with weight and bias learning rules with
%    sequential updates. The sequence of inputs is presented to the network
%    with updates occuring after each time step.
%
%    This incremental training algorithm is commonly used for adaptive
%    applications.
%
%    TRAINS takes these inputs:
%      NET - Neural network.
%      Pd  - Delayed inputs.
%      Tl  - Layer targets.
%      Ai  - Initial input conditions.
%      Q   - Batch size.
%      TS  - Time steps.
%      VV  - Ignored.
%      TV  - Ignored.
%    and after training the network with its weight and bias
%    learning functions returns:
%      NET - Updated network.
%      TR  - Training record.
%            TR.timesteps - Number of time steps.
%            TR.perf - performance for each time step.
%      Ac  - Collective layer outputs.
%      El  - Layer errors.
%
%    If NET.adaptFcn is TRAINS then adaption occurs according to the
%   adaption parameter shown here with its default value:
%      net.adaptParam.passes    1  Number of times to present sequence
%   If NET.trainFcn is TRAINS then the analogous training paramter is used:
%      net.trainParam.passes    1  Number of times to present sequence
%
%    Dimensions for these variables are:
%      Pd - NoxNixTS cell array, each element P{i,j,ts} is a ZijxQ matrix.
%      Tl - NlxTS cell array, each element P{i,ts} is an VixQ matrix or [].
%      Ai - NlxLD cell array, each element Ai{i,k} is an SixQ matrix.
%      Ac - Nlx(LD+TS) cell array, each element Ac{i,k} is an SixQ matrix.
%      El - NlxTS cell array, each element El{i,k} is an SixQ matrix or [].
%    Where
%      Ni = net.numInputs
%      Nl = net.numLayers
%      LD = net.numLayerDelays
%      Ri = net.inputs{i}.size
%      Si = net.layers{i}.size
%      Vi = net.targets{i}.size
%      Zij = Ri * length(net.inputWeights{i,j}.delays)
%
%    TRAINS(CODE) return useful information for each CODE string:
%      'pnames'    - Names of training parameters.
%      'pdefaults' - Default training parameters.
%
%  Network Use
%
%    You can create a standard network that uses TRAINS for adapting
%    by calling NEWP or NEWLIN.
%
%    To prepare a custom network to adapt with TRAINS:
%    1) Set NET.adaptFcn to 'trains'.
%       (This will set NET.adaptParam to TRAINS' default parameters.)
%    2) Set each NET.inputWeights{i,j}.learnFcn to a learning function.
%       Set each NET.layerWeights{i,j}.learnFcn to a learning function.
%       Set each NET.biases{i}.learnFcn to a learning function.
%       (Weight and bias learning parameters will automatically be
%       set to default values for the given learning function.)
%
%    To allow the network to adapt:
%    1) Set weight and bias learning parameters to desired values.
%    2) Call ADAPT.
%
%    See NEWP and NEWLIN for adaption examples.
%
%  Algorithm
%
%    Each weight and bias is updated according to its learning function
%    after each time step in the input sequence.
%
%  See also NEWP, NEWLIN, TRAIN, TRAINB, TRAINC, TRAINR.

%  Mark Beale, 11-31-97
%  Copyright 1992-2002 The MathWorks, Inc.
%  $Revision: 1.6 $

% FUNCTION INFO
% =============

if isstr(net)
  switch (net)
    case 'pnames',
    net = {'passes'};
    case 'pdefaults',
    net.passes = 1;
    otherwise,
    error('Unrecognized code.')
  end
  return
end

% CALCULATION
% ===========

% Parameters
passes = net.trainParam.passes;

% Parameter Checking
if (~isa(passes,'double')) | (~isreal(passes)) | (any(size(passes)) ~= 1) | ...
  (passes < 1) | (round(passes) ~= passes)
  error('Passes is not a positive integer.')
end

% Generate functions
simfunc = gensimm(net);
[x,simfuncname] = fileparts(simfunc);
bpfunc = genbpm(net);
[x,bpfuncname] = fileparts(bpfunc);
trainsfunc = gentrainsm(net,simfuncname,bpfuncname);
[x,trainsfuncname] = fileparts(trainsfunc);

% Call generated function
[net,tr,Ac,El]=feval(trainsfuncname,net,PD,Tl,Ai,Q,TS,VV,TV);

% Delete functions
delete(simfunc);
delete(bpfunc);
delete(trainsfunc);
