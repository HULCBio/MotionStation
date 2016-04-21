function [gB,gIW,gLW,gA]=calcgrad(net,Q,PD,BZ,IWZ,LWZ,N,Ac,gE,TS)
%CALCGRAD Calculate bias and weight performance gradients.
%
%  Synopsis
%
%    [gB,gIW,gIW] = calcgrad(net,Q,PD,BZ,IWZ,LWZ,N,Ac,gE,TS)
%
%  Warning!!
%
%    This function may be altered or removed in future
%    releases of the Neural Network Toolbox. We recommend
%    you do not write code which calls this function.

% Mark Beale, 11-31-97
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.11 $ $Date: 2002/04/14 21:17:12 $

% Shortcuts
numLayerDelays = net.numLayerDelays;
TF = net.hint.transferFcn;
dTF = net.hint.dTransferFcn;
NF = net.hint.netInputFcn;
dNF = net.hint.dNetInputFcn;
IWF = net.hint.inputWeightFcn;
dIWF = net.hint.dInputWeightFcn;
LWF = net.hint.layerWeightFcn;
dLWF = net.hint.dLayerWeightFcn;
ICF = net.hint.inputConnectFrom;
LCF = net.hint.layerConnectFrom;
LCT = net.hint.layerConnectTo;
LCTOZD = net.hint.layerConnectToOZD;
LCTWZD = net.hint.layerConnectToWZD;
BCT = net.hint.biasConnectTo;
IW = net.IW;
LW = net.LW;
b = net.b;
layerDelays = net.hint.layerDelays;

% AD
Ad = cell(net.numLayers,net.numLayers,TS);
for i=1:net.numLayers
  for j = LCF{i}
    for ts = 1:TS
      Ad{i,j,ts} = cell2mat(Ac(j,ts+numLayerDelays-layerDelays{i,j})');
    end
  end
end

% Compress Time for Elman backprop
Ae = cell(net.numLayers,1);
for i=1:net.numLayers
  Ae{i} = [Ac{i,(1+numLayerDelays):end}];
end
LWZe = cell(net.numLayers,1);
for i=1:net.numLayers
  for j=LCF{i}
    LWZe{i,j} = [LWZ{i,j,:}];
  end
end

% Signals
gA = cell(net.numLayers,1);
gN = cell(net.numLayers,1);
gBZ = [];
gIWZ = cell(net.numLayers,net.numInputs);
gLWZ = cell(net.numLayers,net.numLayers);
gB = cell(net.numLayers,1);
gIW = cell(net.numLayers,net.numInputs);;
gLW = cell(net.numLayers,net.numLayers);

% Backpropagate Elman Derivatives...

for i=net.hint.bpLayerOrder


  % ...from Performance
  if net.targetConnect(i)
    gA{i} = [gE{i,:}];
  else
    gA{i} = zeros(net.layers{i}.size,Q*TS);
  end

  % ...through Layer Weights with only zero delays
  Nc = [N{i,:}];
  for k=LCTOZD{i}
    switch dLWF{k,i}
    case 'ddotprod'
      gA{i} = gA{i} + LW{k,i}' * gLWZ{k,i};
  otherwise
    gA{i} = gA{i} + feval(dLWF{k,i},'p',LW{k,i},Ae{i},LWZe{k,i})' * gLWZ{k,i};
  end
  end

  % ...through Layer Weights with zero delays + others too be ignored
  for k=LCTWZD{i}
    ZeroDelayW = LW{k,i}(:,1:net.layers{i}.size);
  switch dLWF{k,i}
  case 'ddotprod'
    gA{i} = gA{i} + ZeroDelayW' * gLWZ{k,i};
  otherwise
    gA{i} = gA{i} + feval(dLWF{k,i},'p',ZeroDelayW,Ae{i},LWZe{k,i})' * gLWZ{k,i};
    end
  end

  % ...through Transfer Functions
  switch dTF{i}
  case 'dpurelin'
    gN{i} = gA{i};
  case 'dtansig'
    gN{i} = (1-(Ae{i}.*Ae{i})) .* gA{i};
  case 'dlogsig'
    gN{i} = Ae{i}.*(1-Ae{i}) .* gA{i};
  otherwise
    gN{i} = feval(dTF{i},Nc,Ae{i}) .* gA{i};
  end

  % ...to Bias
  if net.biasConnect(i)
    gB{i} = sum(feval(dNF{i},BZ{i}(:,ones(1,Q*TS)),Nc) .* gN{i},2);
  end

  % ...to Input Weights
  for j=ICF{i}
  IWZc = [IWZ{i,j,:}];
    gIW{i,j} = feval(dNF{i},IWZc,Nc) .* ...
    gN{i} * feval(dIWF{i,j},'w',IW{i,j},[PD{i,j,:}],IWZc)';
  end

  % ...to Layer Weights
  for j=LCF{i}
    gLWZ{i,j} = feval(dNF{i},LWZe{i,j},Nc) .* gN{i};
    gLW{i,j} = gLWZ{i,j} * feval(dLWF{i,j},'w',LW{i,j},[Ad{i,j,:}],LWZe{i,j})';
  end
end

