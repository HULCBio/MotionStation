function gX = formx(net,gB,gIW,gLW)
%FORMX Form bias and weights into single vector.
%
%  Syntax
%
%    X = formx(net,B,IW,LW)
%
%  Description
%
%    This function takes weight matrices and bias vectors
%    for a network and reshapes them into a single vector.
%
%    X = FORMX(NET,B,IW,LW) takes these arguments,
%      NET - Neural network.
%      B   - Nlx1 cell array of bias vectors.
%      IW  - NlxNi cell array of input weight matrices.
%      LW  - NlxNl cell array of layer weight matrices.
%    and returns,
%      X   - Vector of weight and bias values.
%
%  Examples
%
%    Here we create a network with a 2-element input, and one
%    layer of 3 neurons.
%
%      net = newff([0 1; -1 1],[3]);
%
%    We can get view its weight matrices and bias vectors as follows:
%
%      b = net.b
%      iw = net.iw
%      lw = net.lw
%
%    We can put these values into a single vector as follows:
%
%      x = formx(net,net.b,net.iw,net.lw)
%
%  See also GETX, SETX.

% Mark Beale, Created from FORMGX, 5-25-98
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.5 $  $Date: 2002/04/14 21:18:27 $

% Shortcuts
inputLearn = net.hint.inputLearn;
layerLearn = net.hint.layerLearn;
biasLearn = net.hint.biasLearn;
inputWeightInd = net.hint.inputWeightInd;
layerWeightInd = net.hint.layerWeightInd;
biasInd = net.hint.biasInd;

gX = zeros(net.hint.xLen,1);
for i=1:net.numLayers
  for j=find(inputLearn(i,:))
    gX(inputWeightInd{i,j}) = gIW{i,j}(:);
  end
  for j=find(layerLearn(i,:))
    gX(layerWeightInd{i,j}) = gLW{i,j}(:);
  end
  if biasLearn(i)
    gX(biasInd{i}) = gB{i}(:);
  end
end
