function x=getx(net)
%GETX Get all network weight and bias values as a single vector.
%
%  Syntax
%
%    X = getx(net)
%
%  Description
%
%    This function gets a networks weight and biases as
%    a vector of values.
%
%    X = GETX(NET)
%      NET - Neural network.
%      X   - Vector of weight and bias values.
%
%  Examples
%
%    Here we create a network with a 2-element input, and one
%    layer of 3 neurons.
%
%      net = newff([0 1; -1 1],[3]);
%
%    We can get its weight and bias values as follows:
%
%      net.iw{1,1}
%      net.b{1}
%
%    We can get these values as a single vector as follows:
%
%      x = getx(net);
%
%  See also SETX, FORMX.

% Mark Beale, 11-31-97
% Mark Beale, Updated help, 5-25-98
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.8 $ $Date: 2002/04/14 21:18:09 $

% Shortcuts
inputLearn = net.hint.inputLearn;
layerLearn = net.hint.layerLearn;
biasLearn = net.hint.biasLearn;
inputWeightInd = net.hint.inputWeightInd;
layerWeightInd = net.hint.layerWeightInd;
biasInd = net.hint.biasInd;

x = zeros(net.hint.xLen,1);
for i=1:net.numLayers
  for j=find(inputLearn(i,:))
    x(inputWeightInd{i,j}) = net.IW{i,j}(:);
  end
  for j=find(layerLearn(i,:))
    x(layerWeightInd{i,j}) = net.LW{i,j}(:);
  end
  if biasLearn(i)
    x(biasInd{i}) = net.b{i};
  end
end
