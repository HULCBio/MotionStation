function gensim(net,st)
%GENSIM Generate a SIMULINK block to simulate a neural network.
%
%  Syntax
%
%    gensim(net,st)
%
%  Description
%
%    GENSIM(NET,ST) takes these inputs,
%      NET - Neural network.
%      ST  - Sample time (default = 1).
%    and creates a SIMULINK system containing a block which
%    simulates neural network NET with a sampling time of ST.
%
%    If NET has no input or layer delays (NET.numInputDelays
%    and NET.numLayerDelays are both 0) then you can use -1 for ST to
%    get a continuously sampling network. 
%
%  Example
%
%    net = newff([0 1],[5 1]);
%    gensim(net)

%  Mark Beale, 11-31-97
%  Copyright 1992-2004 The MathWorks, Inc.
% $Revision: 1.11.4.1 $ $Date: 2004/03/24 20:42:57 $

% Input arguments and defaults
if nargin < 1, error('Not enough input arguments.'), end
if nargin < 2, st = 1; end

% Check ST
if (st <= 0) & (st ~= -1),
  error('Sample time must be -1, or a positive number.')
end
if (st == -1) & (net.numInputDelays | net.numLayerDelays)
  error('Sample time cannot be -1 because the network contains delays.')
end
st = num2str(st);

% Neural Network Toolbox Simulink Block Library
neural

% Untitled System
sysName = get_param(new_system,'name');
open_system(sysName)
y = max(max(net.numInputs,net.numOutputs),1)*20 + 20;

% Sample Inputs
pos = y-net.numInputs*20-20;
for i=1:net.numInputs
  inputName = ['p{' num2str(i) '}'];
  inputNameL = [sysName '/' inputName];
  add_block('built-in/Constant',inputNameL,...
    'value',mat2str(rand(net.inputs{i}.size,1),2),...
  'maskdisplay',['disp(''Input ' num2str(i) ' '')'],...
    'position',[40 pos+i*40 80 pos+i*40+20])
end

% Sample Outputs
pos = y-net.numOutputs*20-20;
for i=1:net.numOutputs
  outputName = ['y{' num2str(i) '}'];
  outputNameL = [sysName '/' outputName];
  add_block('built-in/Scope',outputNameL,...
    'position',[300 pos+i*40 320 pos+i*40+20])
end

% Network Block
netName = 'Neural Network';
genNetwork(net,y,netName,sysName,st)

% Connections
for i=1:net.numInputs
  add_line(sysName,[['p{' num2str(i) '}'] '/1'],[netName '/' num2str(i)])
end
for i=1:net.numOutputs
  add_line(sysName,[netName '/' num2str(i)],[['y{' num2str(i) '}'] '/1'])
end

%======================================================================
function genNetwork(net,y,netName,sysName,st)

% Network System
netNameL = [sysName '/' netName];

add_block('built-in/SubSystem',netNameL);
set_param(netNameL, ...
  'position',[160 y-10 220 y+max([net.numInputs,net.numOutputs,1])*40-10],...
  'BackgroundColor','lightblue')
  
% Layer2Layer
Layer2LayerInd = find(sum(net.layerConnect,1));
numLayer2Layers = length(Layer2LayerInd);

% Network Block Names
inputNames = cell(1,net.numInputs);
outputNames = cell(1,net.numOutputs);
fromNames = cell(1,net.numLayers);
toNames = cell(1,net.numLayers);
layerNames = cell(1,net.numLayers);
for i=1:net.numInputs, inputNames{i} = sprintf('p{%g}',i); end
for i=1:net.numOutputs, outputNames{i} = sprintf('y{%g}',i); end
for i=1:net.numLayers, fromNames{i} = sprintf(' a{%g} ',i); end
for i=1:net.numLayers, toNames{i} = sprintf('a{%g}',i); end
for i=1:net.numLayers, layerNames{i} = sprintf('Layer %g',i); end

% Network Blocks
for i=1:net.numInputs
  genNetworkInput(net,i,i,inputNames{i},netNameL,st);
end
for i=1:net.numOutputs
  genNetworkOutput(net,i,i+1+numLayer2Layers,outputNames{i},netNameL);
end
for k=1:numLayer2Layers
  i = Layer2LayerInd(k);
  genNetworkFrom(net,i,k+net.numInputs+1,fromNames{i},netNameL);
end
for k=1:numLayer2Layers
  i = Layer2LayerInd(k);
  genNetworkTo(net,i,k,toNames{i},netNameL);
end
layerPos = 40;
for i=1:net.numLayers
  layerPos = genNetworkLayer(net,i,layerNames{i},netNameL,inputNames,toNames,fromNames,layerPos,st);
end

% Network Block Connections
for i=1:net.numLayers
  inputInd = find(net.inputConnect(i,:));
  numInputs = length(inputInd);
  for j=1:numInputs
    add_line(netNameL,[inputNames{inputInd(j)} '/1'],[layerNames{i} '/' num2str(j)])
  end
end
for k=1:numLayer2Layers
  j = Layer2LayerInd(k);
  add_line(netNameL,[layerNames{j} '/1'],[toNames{j} '/1'])
  layerInd = find(net.layerConnect(:,j)');
  numLayers = length(layerInd);
  for m=1:numLayers
    i = layerInd(m);
    numInputs = length(find(net.inputConnect(i,:)));
  x = sum(net.layerConnect(i,1:j));
    add_line(netNameL,[fromNames{j} '/1'],[layerNames{i} '/' num2str(numInputs+x)])
  end
end
outputInd = find(net.outputConnect);
numOutputs = length(outputInd);
for i=1:numOutputs
  add_line(netNameL,[layerNames{outputInd(i)} '/1'],[outputNames{i} '/1'])
end

%======================================================================
function genNetworkInput(net,i,pos,inputName,netNameL,st)

  y = pos*40;
  inputNameL = [netNameL '/' inputName];
  add_block('built-in/Inport',inputNameL,...
    'port',sprintf('%g',i), ...
  'position',[40 y 60 y+20],...
  'portwidth',num2str(net.inputs{i}.size),...
  'sampletime',st,...
  'BackgroundColor','Magenta')

%======================================================================
function genNetworkOutput(net,i,pos,outputName,netNameL)

  outputInd = find(net.outputConnect);
  siz = net.outputs{outputInd(i)}.size;

  y = pos*40;
  outputNameL = [netNameL '/' outputName];
  add_block('built-in/Outport',outputNameL,...
    'port',sprintf('%g',i), ...
  'position',[380 y 400 y+20],...
  'BackgroundColor','Magenta',...
  'InitialOutput',mat2str(zeros(siz,1)))

%======================================================================
function genNetworkFrom(net,i,pos,fromName,netNameL)

  y = pos*40;
  fromNameL = [netNameL '/' fromName];
  add_block('built-in/From',fromNameL,...
    'gototag',sprintf('feedback%g',i), ...
  'position',[40 y 60 y+20],...
  'maskdisplay','plot(cos(0:.1:2*pi),sin(0:.1:2*pi))',...
  'MaskIconFrame','off',...
  'ForegroundColor','black')

%======================================================================
function genNetworkTo(net,i,pos,toName,netNameL)

  y = pos*40;
  toNameL = [netNameL '/' toName];
  add_block('built-in/Goto',toNameL,...
    'gototag',sprintf('feedback%g',i), ...
  'position',[380 y 400 y+20],...
  'maskdisplay','plot(cos(0:.1:2*pi),sin(0:.1:2*pi))',...
  'MaskIconFrame','off',...
  'ForegroundColor','black')

%======================================================================
function layerPos = genNetworkLayer(net,i,layerName,netNameL,inputName,toName,fromName,layerPos,st)

  % Useful constants
  inputInd = find(net.inputConnect(i,:));
  numInputs = length(inputInd);
  layerInd = find(net.layerConnect(i,:));
  numLayers = length(layerInd);
  hasBias = net.biasConnect(i);
  y = (numInputs+numLayers+hasBias)/2 * 40 + 30;
  dy = max(10,(numInputs+numLayers+hasBias)*5);

  % Layer System
  layerNameL = [netNameL '/' layerName];
  layerHeight = max(1,numInputs+numLayers)*20;
  add_block('built-in/SubSystem',layerNameL)
  set_param(layerNameL,...
  'position',[190 layerPos 250 layerPos+layerHeight],...
  'BackgroundColor','lightblue')
  
  % increase LayerPos
  layerPos = layerPos + layerHeight + 20;

  % Layer Block Names
  outputName = sprintf('a{%g}',i);
  transferName = net.layers{i}.transferFcn;
  netInputName = net.layers{i}.netInputFcn;
  for k=1:numInputs
    j = inputInd(k);
    IWName{k} = sprintf('IW{%g,%g}',i,j);
  IDName{k} = sprintf('Delays %g',k);
  PName{k} = inputName{j};
  end
  for k=1:numLayers
    j = layerInd(k);
    LWName{k} = sprintf('LW{%g,%g}',i,j);
  LDName{k} = sprintf('Delays %g',k+numInputs);
  AName{k} = sprintf('a{%g} ',j);
  end
  if hasBias
    bName = sprintf('b{%g}',i);
  end
    
  % Layer Blocks
  genLayerOutput(net,i,y,layerNameL,outputName);
  genLayerTransfer(y,layerNameL,transferName);
  numSignals = numInputs+numLayers+hasBias;
  genLayerNet(numSignals,y,dy,layerNameL,netInputName);
  for k=1:numInputs
    j = inputInd(k);
    genInputSignal(net,i,j,k,layerNameL,PName{k},st);
  genInputDelays(net,i,j,k,layerNameL,IDName{k},st);
    genInputWeight(net,i,j,k,layerNameL,IWName{k},st);
  end
  for k=1:numLayers
    j = layerInd(k);
    genLayerSignal(net,i,j,k+numInputs,layerNameL,AName{k},st);
  genLayerDelays(net,i,j,k+numInputs,layerNameL,LDName{k},st);
    genLayerWeight(net,i,j,k+numInputs,layerNameL,LWName{k},st);
  end
  if hasBias
   genLayerBias(net,i,numInputs+numLayers+1,layerNameL,bName);
  end
  
  % Layer Block Connections
  for j=1:numInputs
    add_line(layerNameL,[PName{j} '/1'],[IDName{j} '/1'])
    add_line(layerNameL,[IDName{j} '/1'],[IWName{j} '/1'])
    add_line(layerNameL,[IWName{j} '/1'],[netInputName '/' num2str(j)])
  end
  for j=1:numLayers
    add_line(layerNameL,[AName{j} '/1'],[LDName{j} '/1'])
    add_line(layerNameL,[LDName{j} '/1'],[LWName{j} '/1'])
    add_line(layerNameL,[LWName{j} '/1'],[netInputName '/' num2str(j+numInputs)])
  end
  if hasBias
    add_line(layerNameL,[bName '/1'],[netInputName '/' num2str(numInputs+numLayers+1)])
  end
  add_line(layerNameL,[netInputName '/1'],[transferName '/1'])
  add_line(layerNameL,[transferName '/1'],[outputName '/1'])

%======================================================================
function genLayerOutput(net,i,y,layerNameL,outputName)

  outputNameL = [layerNameL '/' outputName];
  add_block('built-in/Outport',outputNameL,...
    'port','1',...
    'position',[360 y-10 380 y+10],...
  'BackgroundColor','Magenta',...
  'InitialOutput',mat2str(zeros(net.layers{i}.size,1)))

%======================================================================
function genLayerTransfer(y,layerNameL,transferName)

  transferNameL = [layerNameL '/' transferName];
  transferBlock = ['neural/Transfer Functions/' transferName];
  add_block(transferBlock,transferNameL,...
    'position',[300 y-10 320 y+10],...
  'BackgroundColor','lightblue')

%======================================================================
function genLayerNet(numSignals,y,dy,layerNameL,netInputName)

  netInputNameL = [layerNameL '/' netInputName];
  if (numSignals > 1)
    netInputBlock = ['neural/Net Input Functions/' netInputName];
    add_block(netInputBlock,netInputNameL,...
      'inputs',num2str(numSignals),...
      'position',[240 y-dy 260 y+dy],...
      'BackgroundColor','lightblue')
  else
    % Special case: numSignals == 1
    % netInputBlocks fail when there is only 1 signal,
    % summing across neurons instead of across signals.
    add_block('built-in/Gain',netInputNameL,...
      'gain','1',...
      'position',[240 y-dy 260 y+dy],...
      'BackgroundColor','lightblue')
  end

%======================================================================
function genLayerBias(net,i,pos,layerNameL,bName)

    add_block('built-in/Constant',[layerNameL '/' bName],...
      'value',mat2str(net.b{i},100),...
      'position',[160 pos*40 200 pos*40+20],...
      'maskdisplay','disp(''bias'')',...
    'BackgroundColor','lightblue')
    
%======================================================================
function genInputSignal(net,i,j,pos,layerNameL,PName,st)

  % Input Signal
  add_block('built-in/Inport',[layerNameL '/' PName],...
    'port',sprintf('%g',pos),...
  'portwidth',num2str(net.inputs{j}.size),...
  'sampletime',st,...
    'position',[40 pos*40 60 pos*40+20],...
  'BackgroundColor','Magenta')

%======================================================================
function genInputDelays(net,i,j,pos,layerNameL,IDName,st)

  % System
  name = IDName;
  nameL = [layerNameL '/' name];
  add_block('built-in/SubSystem',nameL)
  set_param(nameL,...
  'position',[100 pos*40 120 pos*40+20],...
    'maskdisplay','disp(''TDL'')',...
  'BackgroundColor','lightblue');

  % Constants
  delays = net.inputWeights{i,j}.delays;
  numDelays = length(delays);
  maxDelay = delays(end);
  
  % Names
  PName = sprintf('p{%g}',i);
  for k=1:maxDelay
    DName{k} = sprintf('Delay %g',k);
  end
  MuxName = 'mux';
  PDName = sprintf('pd{%g,%g}',i,j);
  
  % Blocks
  y = numDelays*20;
  add_block('built-in/Inport',[nameL '/' PName],...
    'port',sprintf('%g',1),...
  'portwidth',num2str(net.inputs{j}.size),...
  'sampletime',st,...
    'position',[60 40 80 60],...
  'Orientation','down',...
  'NamePlacement','alternate',...
  'BackgroundColor','Magenta')
  for k=1:maxDelay
    add_block('built-in/UnitDelay',[nameL '/' DName{k}],...
    'SampleTime',st,...
    'position',[60 40+k*40 80 60+k*40],...
    'BackgroundColor','lightblue',...
    'Orientation','down',...
    'NamePlacement','alternate')
  end
  add_block('built-in/Mux',[nameL '/' MuxName],...
    'inputs',num2str(numDelays),...
    'position',[200 40+y 240 60+y],...
  'BackgroundColor','lightblue')
  add_block('built-in/Outport',[nameL '/' PDName],...
    'port','1',...
    'position',[300 40+y 320 60+y],...
  'BackgroundColor','Magenta')
  
  % Connections
  for k=1:maxDelay
    if k == 1
    add_line(nameL,[PName '/1'],[DName{k} '/1'])
  else
    add_line(nameL,[DName{k-1} '/1'],[DName{k} '/1'])
  end
  end
  for k=1:numDelays
    if delays(k) == 0
    add_line(nameL,[PName '/1'],[MuxName '/' num2str(k)])
  else
    add_line(nameL,[DName{delays(k)} '/1'],[MuxName '/' num2str(k)])
  end
  end
  add_line(nameL,[MuxName '/1'],[PDName '/1'])

%======================================================================
function genInputWeight(net,i,j,pos,layerNameL,IWName,st)

  % System
  weightName = IWName;
  weightNameL = [layerNameL '/' weightName];
  add_block('built-in/SubSystem',weightNameL)
  set_param(weightNameL,...
  'position',[160 pos*40 200 pos*40+20],...
    'maskdisplay','disp(''weight'')',...
  'BackgroundColor','lightblue');

  % Names
  for k=1:net.layers{i}.size
    weightVectorName{k} = sprintf('IW{%g,%g}(%g,:)''',i,j,k);
    vectorOpName{k} = [net.inputWeights{i,j}.weightFcn num2str(k)];
  end
  muxName = 'Mux';
  outputName = ['iz{' num2str(i) ',' num2str(j) '}'];
  PName = sprintf('pd{%g,%g}',i,j);
  
  % Blocks
  y = net.layers{i}.size * 30 + 40;
  add_block('built-in/Inport',[weightNameL '/' PName],...
    'port',sprintf('%g',1),...
  'portwidth',num2str(net.inputWeights{i,j}.size(2)),...
  'sampletime',st,...
    'position',[40 y-10 60 y+10],...
  'BackgroundColor','Magenta')

  for k=1:net.layers{i}.size
    nameL = [weightNameL '/' vectorOpName{k}];
    block = ['neural/Weight Functions/' net.inputWeights{i,j}.weightFcn];
    add_block(block,nameL,...
      'position',[240 40+(k-1)*60 260 80+(k-1)*60],...
      'BackgroundColor','lightblue')
    
    add_block('built-in/Constant',[weightNameL '/' weightVectorName{k}],...
      'value',mat2str(net.IW{i,j}(k,:)',100),...
      'position',[140 40+(k-1)*60 180 60+(k-1)*60],...
      'maskdisplay','disp(''weights'')',...
    'BackgroundColor','lightblue')
  end

  add_block('built-in/Mux',[weightNameL '/' muxName],...
  'inputs',num2str(net.layers{i}.size),...
    'position',[340 y-10 380 y+10])

  outputNameL = [weightNameL '/' outputName];
  add_block('built-in/Outport',outputNameL,...
    'port','1',...
    'position',[420 y-10 440 y+10],...
  'BackgroundColor','Magenta')
  
  % Connections
  for k=1:net.layers{i}.size
    add_line(weightNameL,[weightVectorName{k} '/1'],[vectorOpName{k} '/1'])
    add_line(weightNameL,[PName '/1'],[vectorOpName{k} '/2'])
    add_line(weightNameL,[vectorOpName{k} '/1'],[muxName '/' num2str(k)])
  end
  add_line(weightNameL,[muxName '/1'],[outputName '/1'])

%======================================================================
function genLayerSignal(net,i,j,pos,layerNameL,AName,st)

  % Layer Signal
  add_block('built-in/Inport',[layerNameL '/' AName],...
    'port',sprintf('%g',pos),...
  'portwidth',num2str(net.layers{j}.size),...
  'sampletime',st,...
    'position',[40 pos*40 60 pos*40+20],...
  'BackgroundColor','Magenta')
 
%======================================================================
function genLayerDelays(net,i,j,pos,layerNameL,LDName,st)

  % System
  name = LDName;
  nameL = [layerNameL '/' name];
  add_block('built-in/SubSystem',nameL)
  set_param(nameL,...
  'position',[100 pos*40 120 pos*40+20],...
    'maskdisplay','disp(''TDL'')',...
  'BackgroundColor','lightblue');

  % Constants
  delays = net.layerWeights{i,j}.delays;
  numDelays = length(delays);
  maxDelay = delays(end);
  
  % Names
  PName = sprintf('p{%g}',i);
  for k=1:maxDelay
    DName{k} = sprintf('Delay %g',k);
  end
  MuxName = 'mux';
  ADName = sprintf('pd{%g,%g}',i,j);
  
  % Blocks
  y = numDelays*20;
  add_block('built-in/Inport',[nameL '/' PName],...
    'port',sprintf('%g',1),...
  'portwidth',num2str(net.layers{j}.size),...
  'sampletime',st,...
    'position',[60 40 80 60],...
  'Orientation','down',...
  'NamePlacement','alternate',...
  'BackgroundColor','Magenta')
  for k=1:maxDelay
    add_block('built-in/UnitDelay',[nameL '/' DName{k}],...
    'SampleTime',st,...
    'position',[60 40+k*40 80 60+k*40],...
    'BackgroundColor','lightblue',...
    'Orientation','down',...
    'NamePlacement','alternate')
  end
  add_block('built-in/Mux',[nameL '/' MuxName],...
    'inputs',num2str(numDelays),...
    'position',[200 40+y 240 60+y],...
  'BackgroundColor','lightblue')
  add_block('built-in/Outport',[nameL '/' ADName],...
    'port','1',...
    'position',[300 40+y 320 60+y],...
  'BackgroundColor','Magenta')
  
  % Connections
  for k=1:maxDelay
    if k == 1
    add_line(nameL,[PName '/1'],[DName{k} '/1'])
  else
    add_line(nameL,[DName{k-1} '/1'],[DName{k} '/1'])
  end
  end
  for k=1:numDelays
    if delays(k) == 0
    add_line(nameL,[PName '/1'],[MuxName '/' num2str(k)])
  else
    add_line(nameL,[DName{delays(k)} '/1'],[MuxName '/' num2str(k)])
  end
  end
  add_line(nameL,[MuxName '/1'],[ADName '/1'])

%======================================================================
function genLayerWeight(net,i,j,pos,layerNameL,LWName,st)

  % System
  weightName = LWName;
  weightNameL = [layerNameL '/' weightName];
  add_block('built-in/SubSystem',weightNameL)
  set_param(weightNameL,...
  'position',[160 pos*40 200 pos*40+20],...
    'maskdisplay','disp(''weight'')',...
  'BackgroundColor','lightblue');

  % Names
  for k=1:net.layers{i}.size
    weightVectorName{k} = sprintf('IW{%g,%g}(%g,:)''',i,j,k);
    vectorOpName{k} = [net.layerWeights{i,j}.weightFcn num2str(k)];
  end
  muxName = 'Mux';
  outputName = ['lz{' num2str(i) ',' num2str(j) '}'];
  AName = sprintf('ad{%g,%g}',i,j);
  
  % Blocks
  y = net.layers{i}.size * 30 + 40;
  add_block('built-in/Inport',[weightNameL '/' AName],...
    'port',sprintf('%g',1),...
  'portwidth',num2str(net.layerWeights{i,j}.size(2)),...
  'sampletime',st,...
    'position',[40 y-10 60 y+10],...
  'BackgroundColor','Magenta')

  for k=1:net.layers{i}.size
    nameL = [weightNameL '/' vectorOpName{k}];
    block = ['neural/Weight Functions/' net.layerWeights{i,j}.weightFcn];
    add_block(block,nameL,...
      'position',[240 40+(k-1)*60 260 80+(k-1)*60],...
      'BackgroundColor','lightblue')
    
    add_block('built-in/Constant',[weightNameL '/' weightVectorName{k}],...
      'value',mat2str(net.LW{i,j}(k,:)',100),...
      'position',[140 40+(k-1)*60 180 60+(k-1)*60],...
      'maskdisplay','disp(''weights'')',...
    'BackgroundColor','lightblue')
  end

  add_block('built-in/Mux',[weightNameL '/' muxName],...
  'inputs',num2str(net.layers{i}.size),...
    'position',[340 y-10 380 y+10])

  outputNameL = [weightNameL '/' outputName];
  add_block('built-in/Outport',outputNameL,...
    'port','1',...
    'position',[420 y-10 440 y+10],...
  'BackgroundColor','Magenta')
  
  % Connections
  for k=1:net.layers{i}.size
    add_line(weightNameL,[weightVectorName{k} '/1'],[vectorOpName{k} '/1'])
    add_line(weightNameL,[AName '/1'],[vectorOpName{k} '/2'])
    add_line(weightNameL,[vectorOpName{k} '/1'],[muxName '/' num2str(k)])
  end
  add_line(weightNameL,[muxName '/1'],[outputName '/1'])

%======================================================================
