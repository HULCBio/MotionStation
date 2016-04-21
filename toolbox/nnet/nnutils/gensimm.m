function filename = gensimm(net)
% GENSIMM Generate simulation m-file for a network.
%
% filename = gensimm(net)

% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.6 $  $Date: 2002/04/14 21:18:33 $

% SHORTCUTS
numLayerDelays = net.numLayerDelays;
numLayerStr = num2str(net.numLayers);
numInputStr = num2str(net.numInputs);
performFcn = net.performFcn;
if length(performFcn) == 0
  performFcn = 'nullpf';
end

% INPUT WEIGHTS
iwcode = {'%% Input weights'};
for i=1:net.numLayers
  for j=find(net.inputConnect(i,:))
    line = [inputWeightName(i,j) ' = net.IW{' num2str(i) ',' num2str(j) '};'];
      iwcode = [iwcode; {line}];
  end
end

% LAYER WEIGHTS
lwcode = {'%% Layer weights'};
for i=1:net.numLayers
  for j=find(net.layerConnect(i,:))
    line = [layerWeightName(i,j) ' = net.LW{' num2str(i) ',' num2str(j) '};'];
      lwcode = [lwcode; {line}];
  end
end

% BIASES
bcode = {'%% Biases'};
line = ['QOnes = ones(1,Q);'];
bcode = [bcode; {line}];
for i=find(net.biasConnect)'
  line = [biasName(i) ' = net.b{' num2str(i) '}(:,QOnes);'];
    bcode = [bcode; {line}];
end
line = ['BZ = {'];
firstBias = 1;
for i=1:net.numLayers
  if firstBias, firstBias = 0; else line = [line '; ']; end
  if (net.biasConnect(i))
    line = [line biasName(i)];
  else
    line = [line '{}'];
  end
end
line = [line '};'];
bcode = [bcode; {line}];

% SIMULATION CODE
simcode = {};
firstLayer = 1;
for i=net.hint.simLayerOrder
  if (firstLayer) firstLayer = 0; else simcode = [simcode; {' '}]; end
  
  % Layer title
  line = sprintf('%%%% Simulate Layer %g',i);
  simcode = [simcode; {line}];
  
  % Weighted Inputs
  for j=find(net.inputConnect(i,:))
    line = [weightedInputName(i,j) ' = '];
    weightFcn = net.inputWeights{i,j}.weightFcn;
    switch (weightFcn)
    case 'dotprod'
      line = [line inputWeightName(i,j) '*' delayedInputName(i,j) ';'];
    otherwise
        line = [line weightFcn '(' inputWeightName(i,j) ',' delayedInputName(i,j) ');'];
    end
    simcode = [simcode; {line}];
  end
  
  % Weighted Layer Outputs
  for j=find(net.layerConnect(i,:))
    
    % Delayed Layer Outputs
    delays = net.layerWeights{i,j}.delays;
    if (length(delays) == 1)
      if (delays == 0)
        delayStr = '';
      else
        delayStr = ['-' num2str(delays)];
      end
      AdName = ['Ac{' num2str(j) ',tsc' delayStr '}'];
    else
      AdName = 'Ad';
      line = [AdName ' = ['];
      firstDelay = 1;
      for k=delays
        if (firstDelay) firstDelay = 0; else line = [line ';']; end
        if (k == 0)
          delayStr = '';
        else
          delayStr = ['-' num2str(k)];
        end
        line = [line 'Ac{' num2str(j) ',tsc-' delayStr '}'];
        end
      line = [line '];'];
      simcode = [simcode; {line}];
    end
  
    % Weighted Layer Outputs
    line = [weightedLayerName(i,j) ' = '];
    weightFcn = net.layerWeights{i,j}.weightFcn;
    switch (weightFcn)
    case 'dotprod'
      line = [line layerWeightName(i,j) '*' AdName ';'];
    otherwise
        line = [line weightFcn '(' layerWeightName(i,j) ',' AdName ');'];
    end
    simcode = [simcode; {line}];
  end
  
  % Net Input Arguments
  arguments = {};
  for j=find(net.inputConnect(i,:))
      arguments = [arguments; {weightedInputName(i,j)}];
  end
  for j=find(net.layerConnect(i,:))
      arguments = [arguments; {weightedLayerName(i,j)}];
  end
  if (net.biasConnect(i))
      arguments = [arguments; {biasName(i)}];
  end

  % Net input calculation
  line = [netInputName(i) ' = '];
  firstWeightedInput = 1;
  netInputFcn = net.layers{i}.netInputFcn;
  switch(netInputFcn)
  case 'netsum'
    for j=1:length(arguments)
      if (firstWeightedInput) firstWeightedInput = 0; else line = [line '+']; end
      line = [line arguments{j}];
    end
  case 'netprod'
    for j=1:length(arguments)
      if (firstWeightedInput) firstWeightedInput = 0; else line = [line '.*']; end
      line = [line arguments{j}];
    end
  otherwise
    line = [line netInputFcn '('];
    for j=1:length(arguments)
      if (firstWeightedInput) firstWeightedInput = 0; else line = [line ',']; end
      line = [line arguments{j}];
    end
    line = [line ')'];
  end
  line = [line ';'];
  simcode = [simcode; {line}];
  
  % Layer Output
  transferFcn = net.layers{i}.transferFcn;
  switch(transferFcn)
  case 'purelin'
    line = [layerOutputName(i) ' = ' netInputName(i) ';'];
  otherwise
    line = [layerOutputName(i) ' = ' net.layers{i}.transferFcn '(' netInputName(i) ');'];
  end
  simcode = [simcode; {line}];
  
  % Layer Error
  if (net.targetConnect(i))
    line = [errorName(i) ' = ' targetName(i) ' - ' layerOutputName(i) ';'];
    simcode = [simcode; {line}];
  end
end

% FILENAME
[filename,name]=newnntempfile;

% COMBINE CODE
code = ...
  [
  {['function [perf,El,Ac,N,LWZ,IWZ,BZ] = ' name '(net,Pd,Ai,Tl,Q,TS)']};
  {['%%' upper(name) ' Temporary network simulation file.']};
  {'%%'};
  {['%%  [perf,El,Ac,N,LWZ,IWZ,BZ] = ' name '(net,Pd,Ai,Tl,Q,TS)']};
  {'%%    net  - Neural network.'};
  {'%%    Pd   - numInputs-by-numLayers-by-TS cell array of delayed inputs.'};
  {'%%    Ai   - numLayers-by-numLayerDelays cell array of layer delay conditions.'};
  {'%%    Tl   - numLayers-by-TS cell array of layer targets.'};
  {'%%    Q    - number of concurrent simulations.'};
  {'%%    TS   - number of time steps.'};
  {'%%  returns:'};
  {'%%    perf - network performance:'};
  {'%%    El   - numLayers-by-TS cell array of layer errors:'};
  {'%%    Ac   - numLayers-by-(numLayerDelays+TS) cell array of layer outputs:'};
  {'%%    N    - numLayers-by-TS cell array of net inputs:'};
  {'%%    LWZ  - numLayers-by-numLayers-by-TS cell array of weighed layer outputs:'};
  {'%%    IWZ  - numLayers-by-numInputs-by-TS cell array of weighed inputs:'};
  {'%%    BZ   - numLayers-by-1 cell array of expanded biases:'};
  {' '};
  iwcode;
  {' '};
  lwcode;
  {' '};
  bcode;
  {' '};
  {'%% Signals'};
  {['El = cell(' numLayerStr ',TS);']};
  {['Ac = [Ai cell(' numLayerStr ',TS)];']};
  {['N = cell(' numLayerStr ',TS);']};
  {['IWZ = cell(' numLayerStr ',' numInputStr ',TS);']};
  {['LWZ = cell(' numLayerStr ',' numLayerStr ',TS);']};
  {' '};
  {'for ts=1:TS;'};
  indent({['tsc = ts + ' num2str(numLayerDelays) ';']});
  {'  ';};
  indent(simcode);
  {'end;'};
  {' '};
  {['perf = ' performFcn '(El,net,net.trainParam);']};
  ];

% SAVE
addnntemppath;
[fid,message] = fopen(filename,'w');
for i=1:length(code)
  fprintf(fid,code{i});
  fprintf(fid,'\n');
end
fclose(fid);

%======================================================
function name = layerOutputName(i)

name = sprintf('Ac{%g,tsc}',i);

%======================================================
function name = netInputName(i)

name = sprintf('N{%g,ts}',i);

%======================================================
function name = delayedInputName(i,j)

name = sprintf('Pd{%g,%g,ts}',i,j);

%======================================================
function name = inputWeightName(i,j)

name = sprintf('IW%g_%g',i,j);

%======================================================
function name = layerWeightName(i,j)

name = sprintf('LW%g_%g',i,j);

%======================================================
function name = biasName(i)

name = sprintf('B%g',i);

%======================================================
function name = errorName(i)

name = sprintf('El{%g,ts}',i);

%======================================================
function name = targetName(i)

name = sprintf('Tl{%g,ts}',i);

%======================================================
function name = weightedInputName(i,j)

name = sprintf('IWZ{%g,%g,ts}',i,j);

%======================================================
function name = weightedLayerName(i,j)

name = sprintf('LWZ{%g,%g,ts}',i,j);

%======================================================
function code = indent(code)

for i=1:length(code)
  code{i} = ['  ' code{i}];
end
