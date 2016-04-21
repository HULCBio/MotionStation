function filename = genbpm(net)
% GENBPM Generate backpropagation m-file for a network.
%
% filename = genbpm(net)

% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.7 $  $Date: 2002/04/14 21:18:30 $

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
performFcn = net.performFcn;
if length(performFcn) == 0
   performFcn = 'nullpf';
end

% INPUT WEIGHTS
iwcode = {'%% Input weights'};
for i=1:net.numLayers
  istr = num2str(i);
  for j=find(net.inputConnect(i,:))
    jstr = num2str(j);
    line = ['iw' istr '_' jstr ' = net.IW{' num2str(i) ',' num2str(j) '};'];
      iwcode = [iwcode; {line}];
  end
end

% LAYER WEIGHTS
lwcode = {'%% Layer weights'};
for i=1:net.numLayers
  istr = num2str(i);
  for j=find(net.layerConnect(i,:))
    jstr = num2str(j);
    line = ['lw' istr '_' jstr ' = net.LW{' num2str(i) ',' num2str(j) '};'];
      lwcode = [lwcode; {line}];
  end
end

% BIASES
bcode = {'%% Biases'};
line = ['QOnes = ones(1,Q);'];
bcode = [bcode; {line}];
for i=find(net.biasConnect)'
  istr = num2str(i);
  line = ['b' istr ' = net.b{' num2str(i) '}(:,QOnes);'];
    bcode = [bcode; {line}];
end

% AD
adcode = {'%% Delayed layer outputs'};
line = ['Ad = cell(' num2str(net.numLayers) ',' num2str(net.numLayers) ',TS);'];
adcode = [adcode; {line} ];
for i=1:net.numLayers
  istr = num2str(i);
  for j = LCF{i}
    jstr = num2str(j);
    line = ['for ts = 1:TS'];
    adcode = [adcode; {line}];
      delays = mat2str(numLayerDelays-layerDelays{i,j});
      line = ['  Ad{' istr ',' jstr ',ts} = cell2mat(Ac(' jstr ',ts+' delays ')'');'];
      adcode = [adcode; {line} ];
    line = ['end'];
    adcode = [adcode; {line}];
  end
end

% COMPRESS TIME FOR ELMAN CALCULATIONS
comcode = {'%% Compress Time for Elman backprop'};
for i=1:net.numLayers
  istr = num2str(i);
  line = ['Ae' istr ' = [Ac{' istr ',' num2str(1+numLayerDelays) ':end}];'];
  comcode = [comcode; {line}];
end
LWZe = cell(net.numLayers,1);
for i=1:net.numLayers
  istr = num2str(i);
  for j=LCF{i}
    jstr = num2str(j);
    line = ['LWZe_' istr '_' jstr ' = [LWZ{' istr ',' jstr ',:}];'];
    comcode = [comcode; {line}];
  end
end

% SIGNAL INITIALIZATION CODE
sigcode = ...
  {
  ['%% Signals'];
  ['gA = cell(' num2str(net.numLayers) ',1);'];
  ['gN = cell(' num2str(net.numLayers) ',1);'];
  ['gBZ = [];'];
  ['gIWZ = cell(' num2str(net.numLayers) ',' num2str(net.numInputs) ');'];
  ['gLWZ = cell(' num2str(net.numLayers) ',' num2str(net.numLayers) ');'];
  ['gB = cell(' num2str(net.numLayers) ',1);'];
  ['gIW = cell(' num2str(net.numLayers) ',' num2str(net.numLayers) ');'];
  ['gLW = cell(' num2str(net.numLayers) ',' num2str(net.numLayers) ');'];
  };

% ERROR GRADIENT
errcode = {'%% Error Gradient'};
line = ['gE = ' feval(performFcn,'deriv') '(''e'',El,net);'];
errcode = [errcode; {line}];

% ELMAN BACKPROPAGATION CODE
bpcode = {};
firstLayer = 1;
for i=net.hint.bpLayerOrder
  istr = num2str(i);
  if (firstLayer) firstLayer = 0; else bpcode = [bpcode; {' '}]; end

  % Layer title
  line = sprintf('%%%% Backpropagate through Layer %g',i);
  bpcode = [bpcode; {line}];


  % ...from Performance
  if net.targetConnect(i)
    line = ['gA{' istr '} = [gE{' istr ',:}];'];
  else
    line = ['gA{' istr '} = zeros(net.layers{' istr '}.size,Q*TS);'];
  end
  bpcode = [bpcode; {line}];

  % ...through Layer Weights with only zero delays
  for k=LCTOZD{i}
    kstr = num2str(k);
    switch dLWF{k,i}
    case 'ddotprod'
      line = ['gA{' istr '} = gA{' istr '} + lw' kstr '_' istr ''' * gLWZ{' kstr ',' istr '};'];
    otherwise
      line = ['gA{' istr '} = gA{' istr '} + ' dLWF{' kstr ',i} '(''p'',lw' kstr '_' istr ',Ae' istr ',' ...
        'LWZc{' kstr ',' istr '})'' * gLWZ{' kstr ',' istr '};'];
    end
    bpcode = [bpcode; {line}];
  end

  % ...through Layer Weights with zero delays + others too be ignored
  for k=LCTWZD{i}
    kstr = num2str(k);
    line = ['ZeroDelayW = lw' kstr '_' istr '(:,' mat2str(1:net.layers{i}.size) ';'];
    bpcode = [bpcode; {line}];
    switch dLWF{k,i}
    case 'ddotprod'
      line = ['gA{' istr '} = gA{' istr '} + ZeroDelayW'' * gLWZ{k,i};'];
    otherwise
      line = ['gA{' istr '} = gA{' istr '} + ' dLWF{k,i} '(''p'',ZeroDelayW,Ae ' istr ...
        ',LWZe' kstr '_' istr '})'' * gLWZ{' kstr ',' istr '};'];
    end
    bpcode = [bpcode; {line}];
  end

  % ...through Transfer Functions
  line = ['Ne = [N{' istr ',:}];'];
  bpcode = [bpcode; {line}];
  switch dTF{i}
  case 'dpurelin'
    line = ['gN{' istr '} = gA{' istr '};'];
  otherwise
    line = ['gN{' istr '} = ' dTF{i} '(Ne,Ae' istr ') .* gA{' istr '};'];
  end
  bpcode = [bpcode; {line}];

  % ...to Bias
  if net.biasConnect(i)
    line = ['gB{' istr '} = sum(' dNF{i} '(b' istr '(:,ones(1,Q*TS)),Ne) .* gN{' istr '},2);'];
    bpcode = [bpcode; {line}];
  end

  % ...to Input Weights
  for j=ICF{i}
    jstr = num2str(j);
    line = ['IWZe = [IWZ{' istr ',' jstr ',:}];'];
    bpcode = [bpcode; {line}];
    line = ['gIW{ ' istr ',' jstr '} = ' dNF{i} '(IWZe,Ne) .* gN{' istr '} * ' ...
       dIWF{i,j} '(''w'',iw' istr '_' jstr ',[PD{' istr ',' jstr ',:}],IWZe)'';'];
    bpcode = [bpcode; {line}];
  end

  % ...to Layer Weights
  for j=LCF{i}
    jstr = num2str(j);
    line = ['gLWZ{' istr ',' jstr '} = ' dNF{i} '(LWZe_' istr '_' jstr ',Ne) .* gN{' istr '};'];
    bpcode = [bpcode; {line}];
    line = ['gLW{' istr ',' jstr '} = gLWZ{' istr ',' jstr '} * ' ...
      dLWF{i,j} '(''w'',lw' istr '_' jstr ',[Ad{' istr ',' jstr ',:}],LWZe_' istr '_' jstr ')'';'];
    bpcode = [bpcode; {line}];
  end
end

% FILENAME
[filename,name]=newnntempfile;

% COMBINE CODE
code = ...
  [
  {['function [gB,gIW,gLW,gA] = ' name '(net,PD,BZ,IWZ,LWZ,N,Ac,El,Q,TS)']};
  {' '};
  iwcode;
  {' '};
  lwcode;
  {' '};
  bcode;
  {' '};
  sigcode;
  {' '};
  adcode;
  {' '};
  comcode;
  {' '};
  errcode;
  {' '};
  bpcode;
  ];

% SAVE
addnntemppath;
[fid,message] = fopen(filename,'w');
for i=1:length(code)
  fprintf(fid,code{i});
  fprintf(fid,'\n');
end
fclose(fid);

