function net = updatenet(s)
%UPDATENET Creates a current network object from an old network structure.
%
%
%  NET = UPDATE(S)
%    S - Structure with fields of old neural network object.
%  Returns
%    NET - New neural network
%
%  This function is caled by NETWORK/LOADOBJ to update old neural
%  network objects when they are loaded from an M-file.

% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.2 $  $Date: 2002/04/14 21:19:21 $

% Architecture
net = network;
net.numInputs = s.numInputs;
net.numLayers = s.numLayers;
net.biasConnect = s.biasConnect;
net.inputConnect = s.inputConnect;
net.layerConnect = s.layerConnect;
net.outputConnect = s.outputConnect;
net.targetConnect = s.targetConnect;

% Subobject Properties

% inputs
for i=1:s.numInputs
  net.inputs{i}.size = s.inputs{i}.size;
  net.inputs{i}.range = s.inputs{i}.range;
  net.inputs{i}.userdata = s.inputs{i}.userdata;
end

% layers
for i=1:s.numLayers
  net.layers{i}.size = s.layers{i}.size;
  net.layers{i}.dimensions = s.layers{i}.dimensions;
  net.layers{i}.distanceFcn = s.layers{i}.distanceFcn;
  net.layers{i}.initFcn = s.layers{i}.initFcn;
  net.layers{i}.netInputFcn = s.layers{i}.netInputFcn;
  net.layers{i}.topologyFcn = s.layers{i}.topologyFcn;
  net.layers{i}.transferFcn = s.layers{i}.transferFcn;
  net.layers{i}.userdata = s.layers{i}.userdata;
end

% biases
for i=find(s.biasConnect')
  net.biases{i}.initFcn = s.biases{i}.initFcn;
  net.biases{i}.learn = s.biases{i}.learn;
  net.biases{i}.learnFcn = s.biases{i}.learnFcn;
  net.biases{i}.learnParam = s.biases{i}.learnParam;
  net.biases{i}.userdata = s.biases{i}.userdata;
end

% inputsWeights
for i=1:s.numLayers
  for j = find(s.inputConnect(i,:))
    net.inputWeights{i,j}.delays = s.inputWeights{i,j}.delays;
    net.inputWeights{i,j}.initFcn = s.inputWeights{i,j}.initFcn;
    net.inputWeights{i,j}.learn = s.inputWeights{i,j}.learn;
    net.inputWeights{i,j}.learnFcn = s.inputWeights{i,j}.learnFcn;
    net.inputWeights{i,j}.learnParam = s.inputWeights{i,j}.learnParam;
    net.inputWeights{i,j}.userdata = s.inputWeights{i,j}.userdata;
    net.inputWeights{i,j}.weightFcn = s.inputWeights{i,j}.weightFcn;
  end
end

% layerWeights
for i=1:s.numLayers
  for j = find(s.layerConnect(i,:))
    net.layerWeights{i,j}.delays = s.layerWeights{i,j}.delays;
    net.layerWeights{i,j}.initFcn = s.layerWeights{i,j}.initFcn;
    net.layerWeights{i,j}.learn = s.layerWeights{i,j}.learn;
    net.layerWeights{i,j}.learnFcn = s.layerWeights{i,j}.learnFcn;
    net.layerWeights{i,j}.learnParam = s.layerWeights{i,j}.learnParam;
    net.layerWeights{i,j}.userdata = s.layerWeights{i,j}.userdata;
    net.layerWeights{i,j}.weightFcn = s.layerWeights{i,j}.weightFcn;
  end
end

% outputs
for i=find(s.outputConnect)
  net.outputs{i}.userdata = s.outputs{i}.userdata;
end

% targets
for i=find(s.targetConnect)
  net.targets{i}.userdata = s.targets{i}.userdata;
end

% Functions
net.adaptFcn = s.adaptFcn;
net.adaptParam = s.adaptParam;
net.initFcn = s.initFcn;
net.initParam = s.initParam;
net.performFcn = s.performFcn;
net.performParam = s.performParam;
net.trainFcn = s.trainFcn;
net.trainParam = s.trainParam;

% Weight and Bias Values
net.IW = s.IW;
net.LW = s.LW;
net.b = s.b;
