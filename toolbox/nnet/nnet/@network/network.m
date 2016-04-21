function net=network(numInputs,numLayers,biasConnect,inputConnect, ...
  layerConnect,outputConnect,targetConnect)
%NETWORK Create a custom neural network.
%
%  Synopsis
%
%    net = network
%    net = network(numInputs,numLayers,biasConnect,inputConnect,
%      layerConnect,outputConnect,targetConnect)
%
%  Description
%
%    NETWORK creates new custom networks.  It is used to create
%    networks that are then customized by functions such as NEWP,
%    NEWLIN, NEWFF, etc.
%
%    NETWORK takes these optional arguments (shown with default values):
%      numInputs     - Number of inputs, 0.
%      numLayers     - Number of layers, 0.
%      biasConnect   - numLayers-by-1 Boolean vector, zeros.
%      inputConnect  - numLayers-by-numInputs Boolean matrix, zeros.
%      layerConnect  - numLayers-by-numLayers Boolean matrix, zeros.
%      outputConnect - 1-by-numLayers Boolean vector, zeros.
%      targetConnect - 1-by-numLayers Boolean vector, zeros.
%    and returns,
%      NET           - New network with the given property values.
%
%  Properties
%
%    Architecture properties:
%
%      net.numInputs: 0 or a positive integer.
%        Number of inputs.
%      net.numLayers: 0 or a positive integer.
%        Number of layers.
%      net.biasConnect: numLayer-by-1 Boolean vector.
%        If net.biasConnect(i) is 1 then the layer i has a bias and
%        net.biases{i} is a structure describing that bias.
%      net.inputConnect: numLayer-by-numInputs Boolean vector.
%        If net.inputConnect(i,j) is 1 then layer i has a weight coming from
%        input j and net.inputWeights{i,j} is a structure describing that weight.
%      net.layerConnect: numLayer-by-numLayers Boolean vector.
%        If net.layerConnect(i,j) is 1 then layer i has a weight coming from
%        layer j and net.layerWeights{i,j} is a structure describing that weight.
%       net.outputConnect: 1-by-numLayers Boolean vector.
%        If net.outputConnect(i) is 1 then the network has an output from
%        layer i and net.outputs{i} is a structure describing that output.
%       net.targetConnect: 1-by-numLayers Boolean vector.
%        if net.outputConnect(i) is 1 then the network has a target from
%        layer i and net.targets{i} is a structure describing that target.
%      net.numOutputs: 0 or a positive integer. Read only.
%        Number of network outputs according to net.outputConnect.
%      net.numTargets: 0 or a positive integer. Read only.
%        Number of targets according to net.targetConnect.
%      net.numInputDelays: 0 or a positive integer. Read only.
%        Maximum input delay according to all net.inputWeight{i,j}.delays.
%      net.numLayerDelays: 0 or a positive number. Read only.
%        Maximum layer delay according to all net.layerWeight{i,j}.delays.
%
%  Subobject structure properties:
%
%      net.inputs: numInputs-by-1 cell array.
%        net.inputs{i} is a structure defining input i:
%      net.layers: numLayers-by-1 cell array.
%        net.layers{i} is a structure defining layer i:
%       net.biases: numLayers-by-1 cell array.
%        if net.biasConnect(i) is 1, then net.biases{i} is a structure
%        defining the bias for layer i.
%      net.inputWeights: numLayers-by-numInputs cell array.
%        if net.inputConnect(i,j) is 1, then net.inputWeights{i,j} is a
%        structure defining the weight to layer i from input j.
%      net.layerWeights: numLayers-by-numLayers cell array.
%        if net.layerConnect(i,j) is 1, then net.layerWeights{i,j} is a
%        structure defining the weight to layer i from layer j.
%      net.outputs: 1-by-numLayers cell array.
%        if net.outputConnect(i) is 1, then net.outputs{i} is a structure
%        defining the network output from layer i.
%      net.targets: 1-by-numLayers cell array.
%        if net.targetConnect(i) is 1, then net.targets{i} is a structure
%        defining the network target to layer i.
%
%    Function properties:
%
%      net.adaptFcn: name of a network adaption function or ''.
%      net.initFcn: name of a network initialization function or ''.
%      net.performFcn: name of a network performance function or ''.
%      net.trainFcn: name of a network training function or ''.
%
%    Parameter properties:
%
%      net.adaptParam: network adaption parameters.
%      net.initParam: network initialization parameters.
%      net.performParam: network performance parameters.
%      net.trainParam: network training parameters.
%
%    Weight and bias value properties:
%
%      net.IW: numLayers-by-numInputs cell array of input weight values.
%      net.LW: numLayers-by-numLayers cell array of layer weight values.
%      net.b: numLayers-by-1 cell array of bias values.
%
%    Other properties:
%
%      net.userdata: structure you can use to store useful values.
%
%  Examples
%
%    Here is how the code to create a network without any inputs and layers,
%    and then set its number of inputs and layer to 1 and 2 respectively.
%
%      net = network
%      net.numInputs = 1
%      net.numLayers = 2
%
%    Here is the code to create the same network with one line of code.
%
%      net = network(1,2)
%
%    Here is the code to create a 1 input, 2 layer, feed-forward network.
%    Only the first layer will have a bias.  An input weight will
%    connect to layer 1 from input 1.  A layer weight will connect
%    to layer 2 from layer 1.  Layer 2 will be a network output,
%    and have a target.
%
%      net = network(1,2,[1;0],[1; 0],[0 0; 1 0],[0 1],[0 1])
%
%    We can then see the properties of subobjects as follows:
%
%      net.inputs{1}
%      net.layers{1}, net.layers{2}
%      net.biases{1}
%      net.inputWeights{1,1}, net.layerWeights{2,1}
%      net.outputs{2}
%      net.targets{2}
%
%    We can get the weight matrices and bias vector as follows:
%
%      net.iw{1,1}, net.iw{2,1}, net.b{1}
%
%    We can alter the properties of any of these subobjects.  Here
%    we change the transfer functions of both layers:
%
%      net.layers{1}.transferFcn = 'tansig';
%      net.layers{2}.transferFcn = 'logsig';
%
%    Here we change the number of elements in input 1 to 2, by setting
%     each element's range:
%
%      net.inputs{1}.range = [0 1; -1 1];
%
%    Next we can simulate the network for a 2-element input vector:
%
%      p = [0.5; -0.1];
%      y = sim(net,p)
%
%  See also INIT, REVERT, SIM, ADAPT, TRAIN.

%  Mark Beale, 11-31-97
%  Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.9 $ $Date: 2002/04/14 21:28:57 $

% SPECIAL CASE - Remaking a network from a struct
if (nargin == 1) & isa(numInputs,'struct')
  net = class(numInputs,'network');
  return
end

% DEFAULT ARGUMENTS
if nargin < 1
  numInputs = 0;
end
if ~isposint(numInputs)
  error('NumInputs must be 0 or a positive integer.')
end
if nargin < 2
  numLayers = 0;
end
if ~isposint(numLayers)
  error('NumLayers must be 0 or a positive integer.')
end
if nargin < 3
  biasConnect = zeros(numLayers,1);
end
if ~isbool(biasConnect,numLayers,1)
  error('BiasConnect must be a NumLayers-by-1 boolean matrix.')
end
if nargin < 4
  inputConnect = zeros(numLayers,numInputs);
end
if ((numLayers == 0) | (numInputs == 0)) & (prod(size(inputConnect)) == 0)
  inputConnect = zeros(numLayers,numInputs);
end
if ~isbool(inputConnect,numLayers,numInputs)
  error('InputConnect must be a NumLayers-by-NumInputs boolean matrix.')
end
if nargin < 5
  layerConnect = zeros(numLayers,numLayers);
end
if (numLayers == 0) & (prod(size(layerConnect)) == 0)
  layerConnect = zeros(0,0);
end
if ~isbool(layerConnect,numLayers,numLayers)
  error('LayerConnect must be a NumLayers-by-NumLayers boolean matrix.')
end
if nargin < 6
  outputConnect = zeros(1,numLayers);
end
if ~isbool(outputConnect,1,numLayers)
  error('OutputConnect must be a 1-by-NumLayers boolean matrix.')
end

if nargin < 7
  targetConnect = zeros(1,numLayers);
end
if ~isbool(targetConnect,1,numLayers)
  error('TargetConnect must be a 1-by-NumLayers boolean matrix.')
end

% NULL NETWORK
net.numInputs = 0;
net.numLayers = 0;
net.numInputDelays = 0;
net.numLayerDelays = 0;
net.biasConnect = [];
net.inputConnect = [];
net.layerConnect = [];
net.outputConnect = [];
net.targetConnect = [];
net.numOutputs = 0;
net.numTargets = 0;
net.inputs = cell(0,1);
net.layers = cell(0,1);
net.biases = cell(0,1);
net.inputWeights = cell(0,0);
net.layerWeights = cell(0,0);
net.outputs = cell(1,0);
net.targets = cell(1,0);
net.adaptFcn = '';
net.adaptParam = [];
net.initFcn = '';
net.initParam = [];
net.performFcn = '';
net.performParam = [];
net.trainFcn = '';
net.trainParam = [];
net.IW = {};
net.LW = {};
net.b = cell(0,1);
net.userdata.note = 'Put your custom network information here.';
net.hint.ok = 0;
net.revert.IW = {};
net.revert.LW = {};
net.revert.b = {};

% CLASS
net = class(net,'network');

% INSURE HINTS ARE CREATED
net.b = net.b;

% ARCHITECTURE
net = setnet(net,'numInputs',numInputs);
net = setnet(net,'numLayers',numLayers);
net = setnet(net,'biasConnect',biasConnect);
net = setnet(net,'inputConnect',inputConnect);
net = setnet(net,'layerConnect',layerConnect);
net = setnet(net,'outputConnect',outputConnect);
net = setnet(net,'targetConnect',targetConnect);

% ====================================================

function net = setnet(net,field,value)

subscripts.type = '.';
subscripts.subs = field;
net = subsasgn(net,subscripts,value);

% ====================================================
