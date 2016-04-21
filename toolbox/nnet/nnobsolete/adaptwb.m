function [net,out2,out3,out4]=adaptwb(net,PD,T,Ai,Q,TS,unused1,unused2)
%ADAPTWB By-weight-and-bias network adaption function.
%  
%  This function is obselete.
%  Use TRAINS to train your network.

nntobsf('adaptwb','Use TRAINS to train your network.')


%  Syntax
%
%    [net,Ac,El] = adaptwb(net,Pd,T,Ai,Q,TS)
%    info = adaptwb(code)
%
%  Description
%
%    ADAPTWB is a network adapt function which updates each
%    weight and bias according to its learning function.
%
%    ADAPTWB takes these inputs:
%      NET - Neural network.
%      Pd  - Delayed inputs.
%      Tl  - Layer targets.
%      Ai  - Initial input conditions.
%      Q   - Batch size.
%      TS  - Time steps.
%    and after training the network with its weight and bias
%    learning functions returns:
%      NET - Updated network.
%      Ac  - Collective layer outputs.
%      El  - Layer errors.
%
%    Adaption occurs according to the ADAPTWB's training parameter,
%    shown here with its default value:
%      net.adaptParam.passes  1  Number of passes through sequence
%
%    Dimensions for these variables are:
%      Pd - NoxNixTS cell array, each element P{i,j,ts} is a ZijxQ matrix.
%      Tl - NlxTS cell array, each element P{i,ts} is an VixQ matrix or [].
%    Ai - NlxLD cell array, each element Ai{i,k} is an SixQ matrix.
%      Ac - Nlx(LD+TS) cell array, each element Ac{i,k} is an SixQ matrix.
%      El - NlxTS cell array, each element El{i,k} is an SixQ matrix or [].
%    Where
%      Ni = net.numInputs
%    Nl = net.numLayers
%    LD = net.numLayerDelays
%      Ri = net.inputs{i}.size
%      Si = net.layers{i}.size
%      Vi = net.targets{i}.size
%      Zij = Ri * length(net.inputWeights{i,j}.delays)
%
%    ADAPTWB(CODE) return useful information for each CODE string:
%      'pnames'    - Names of training parameters.
%      'pdefaults' - Default training parameters.
%
%  Network Use
%
%    You can create a standard network that uses ADAPTWB by calling
%    NEWP or NEWLIN.
%
%    To prepare a custom network to adapt with ADAPTWB:
%    1) Set NET.adaptFcn to 'adaptwb'.
%       (This will set NET.adaptParam to ADAPTWB's default parameters.)
%    2) Set each NET.inputWeights{i,j}.learnFcn to a learning function.
%       Set each NET.layerWeights{i,j}.learnFcn to a learning function.
%       Set each NET.biases{i}.learnFcn to a learning function.
%       (Weight and bias learning parameters will automatically be
%       set to default values for the given learning function.)
%
%    To allow the network to adapt:
%    1) Set NET.adaptParam properties to desired values.
%    2) Set weight and bias learning parameters to desired values.
%    3) Call ADAPT.
%
%    See NEWP and NEWLIN for adaption examples.
%
%  Algorithm
%
%    Each weight and bias is updated according to its learning function
%    after each step in the input sequence.
%
%  See also NEWP, NEWLIN, TRAIN.

% Mark Beale, 11-31-97
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.9 $

% FUNCTION INFO
% =============

if isstr(net)
  switch (net)
    case 'pnames',
    net = {'passes'};
    case 'pdefaults',
    adaptParam.passes = 1;
    net = adaptParam;
    otherwise,
    error('Unrecognized code.')
  end
  return
end

% CALCULATION
% ===========

% Constants
numLayers = net.numLayers;
numInputs = net.numInputs;
passes = net.adaptParam.passes;
performFcn = net.performFcn;
if length(performFcn) == 0
  performFcn = 'nullpf';
end
dperformanceFcn = feval(performFcn,'deriv');
needGradient = net.hint.needGradient;
numLayerDelays = net.numLayerDelays;

%Signals
BP = ones(1,Q);
IWLS = cell(net.numLayers,net.numInputs);
LWLS = cell(net.numLayers,net.numLayers);
BLS = cell(net.numLayers,1);
Ac = [Ai cell(net.numLayers,TS)];
E = cell(net.numLayers,TS);
gIW = cell(numLayers,numInputs);
gLW = cell(numLayers,numLayers);
gB = cell(net.numLayers,1);
gA = cell(net.numLayers,1);
AiInd = 0:(numLayerDelays-1);
AcInd = 0:numLayerDelays;

% Initialize
tr.timesteps = 1:TS;
tr.perf = zeros(1,TS);

for pass=1:passes
  for ts=1:TS

    % Simulate
    [Ac(:,ts+numLayerDelays),N,LWZ,IWZ,BZ] = calca1(net,PD(:,:,ts),Ac(:,ts+AiInd),Q);
    E(:,ts) = calce1(net,Ac(:,ts+numLayerDelays),T(:,ts));
    tr.perf(ts) = feval(performFcn,E(:,ts),net);
 
    % Gradient
    if (needGradient)
      gE = feval(dperformanceFcn,'e',E(:,ts),net);
      [gB,gIW,gLW,gA] = calcgrad(net,Q,PD(:,:,ts),BZ,IWZ,LWZ,N,Ac(:,ts+AcInd),gE,1);
    end

    % Update
    for i=1:net.numLayers

      % Update Input Weight Values
      for j=find(net.inputConnect(i,:))
        learnFcn = net.inputWeights{i,j}.learnFcn;
        if length(learnFcn)
          [dw,IWLS{i,j}] = feval(learnFcn,net.IW{i,j}, ...
              PD{i,j,ts},IWZ{i,j},N{i},Ac{i,ts+numLayerDelays},T{i,ts},E{i,ts},gIW{i,j},...
          gA{i},net.layers{i}.distances,net.inputWeights{i,j}.learnParam,IWLS{i,j});
          net.IW{i,j} = net.IW{i,j} + dw;
      end
      end

      % Update Layer Weight Values
      for j=find(net.layerConnect(i,:))
        learnFcn = net.layerWeights{i,j}.learnFcn;
        if length(learnFcn)
          Ad = cell2mat(Ac(j,ts+numLayerDelays-net.layerWeights{i,j}.delays)');
          [dw,LWLS{i,j}] = feval(learnFcn,net.LW{i,j}, ...
          Ad,LWZ{i,j},N{i},Ac{i,ts+numLayerDelays},T{i,ts},E{i,ts},gLW{i,j},...
          gA{i},net.layers{i}.distances,net.layerWeights{i,j}.learnParam,LWLS{i,j});
          net.LW{i,j} = net.LW{i,j} + dw;
      end
      end

      % Update Bias Values
      if net.biasConnect(i)
        learnFcn = net.biases{i}.learnFcn;
        if length(learnFcn)
          [db,BLS{i}] = feval(learnFcn,net.b{i}, ...
          BP,BZ{i},N{i},Ac{i,ts+numLayerDelays},T{i,ts},E{i,ts},gB{i},...
          gA{i},net.layers{i}.distances,net.biases{i}.learnParam,BLS{i});
          net.b{i} = net.b{i} + db;
      end
      end
    
    end
  end
end

% Finish
tr.timesteps = TS;

if nargout < 4
  out2 = Ac;
  out3 = E;
  out4 = [];
else
  out2 = tr;
  out3 = Ac;
  out4 = E;
end

% =====================================================
