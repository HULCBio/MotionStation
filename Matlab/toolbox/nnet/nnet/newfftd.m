function net = newfftd(pr,id,s,tf,btf,blf,pf)
%NEWFFTD Create a feed-forward input-delay backprop network.
%
%  Syntax
%
%    net = newfftd
%    net = newfftd(PR,ID,[S1 S2...SNl],{TF1 TF2...TFNl},BTF,BLF,PF)
%
%  Description
%
%   NET = NEWFFTD creates a new network with a dialog box.
%
%    NEWFFTD(PR,ID,[S1 S2...SNl],{TF1 TF2...TFNl},BTF,BLF,PF) takes,
%      PR  - Rx2 matrix of min and max values for R input elements.
%      ID  - Input delay vector.
%      Si  - Size of ith layer, for Nl layers.
%      TFi - Transfer function of ith layer, default = 'tansig'.
%      BTF - Backprop network training function, default = 'trainlm'.
%      BLF - Backprop weight/bias learning function, default = 'learngdm'.
%      PF  - Performance function, default = 'mse'.
%    and returns an N layer feed-forward backprop network.
%
%    The transfer functions TFi can be any differentiable transfer
%    function such as TANSIG, LOGSIG, or PURELIN.
%
%    The training function BTF can be any of the backprop training
%    functions such as TRAINLM, TRAINBFG, TRAINRP, TRAINGD, etc.
%
%    *WARNING*: TRAINLM is the default training function because it
%    is very fast, but it requires a lot of memory to run.  If you get
%    an "out-of-memory" error when training try doing one of these:
%
%    (1) Slow TRAINLM training, but reduce memory requirements, by
%        setting NET.trainParam.mem_reduc to 2 or more. (See HELP TRAINLM.)
%    (2) Use TRAINBFG, which is slower but more memory efficient than TRAINLM.
%    (3) Use TRAINRP which is slower but more memory efficient than TRAINBFG.
%
%    The learning function BLF can be either of the backpropagation
%    learning functions such as LEARNGD, or LEARNGDM.
%
%    The performance function can be any of the differentiable performance
%    functions such as MSE or MSEREG.
%
%  Examples
%
%    Here is a problem consisting of an input sequence P and target
%    sequence T that can be solved by a network with one delay.
%
%      P = {1  0 0 1 1  0 1  0 0 0 0 1 1  0 0 1};
%      T = {1 -1 0 1 0 -1 1 -1 0 0 0 1 0 -1 0 1};
%
%    Here a two-layer feed-forward network is created with input
%    delays of 0 and 1.  The network's input ranges from [0 to 1].
%    The first layer has five TANSIG neurons, the second layer has one
%    PURELIN neuron.  The TRAINLM network training function is to be used.
%
%      net = newfftd([0 1],[0 1],[5 1],{'tansig' 'purelin'});
%
%    Here the network is simulated.
%
%      Y = sim(net,P)
%
%    Here the network is trained for 50 epochs.  Again the network's
%     output is calculated.
%
%      net.trainParam.epochs = 50;
%      net = train(net,P,T);
%      Y = sim(net,P)
%
%  Algorithm
%
%    Feed-forward networks consists of Nl layers using the DOTPROD
%    weight function, NETSUM net input function, and the specified
%    transfer functions.
%
%    The first layer has weights coming from the input with the
%    specified input delays.  Each subsequent layer has a weight coming
%    from the previous layer.  All layers have biases.  The last layer
%    is the network output.
%
%    Each layer's weights and biases are initialized with INITNW.
%
%    Adaption is done with TRAINS which updates weights with the
%    specified learning function. Training is done with the specified
%    training function. Performance is measured according to the specified
%    performance function.
%
%  See also NEWCF, NEWELM, SIM, INIT, ADAPT, TRAIN, TRAINS

% Mark Beale, 11-31-97
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.11 $ $Date: 2002/04/14 21:34:38 $

if nargin < 3
  net = newnet('newfftd');
  return
end

% Defaults
if nargin < 5, btf = 'trainlm'; end
if nargin < 6, blf = 'learngdm'; end
if nargin < 7, pf = 'mse'; end

% Error checking
if (~isa(pr,'double')) | ~isreal(pr) | (size(pr,2) ~= 2)
  error('Input ranges is not a two column matrix.')
end
if any(pr(:,1) > pr(:,2))
  error('Input ranges has values in the second column larger in the values in the same row of the first column.')
end
if (~isa(id,'double')) | ~isreal(id) | (size(id,1) ~= 1) | any(id ~= round(id)) | any(diff(id) <= 0)
  error('Input delays is not a row vector of increasing zero or positive integers.');
end
if isa(s,'cell')
  if (size(s,1) ~= 1)
    error('Layer sizes is not a row vector of positive integers.')
  end
  for i=1:length(s)
    si = s{i};
    if ~isa(si,'double') | ~isreal(si) | any(size(si) ~= 1) | any(si<1) | any(round(si) ~= si)
      error('Layer sizes is not a row vector of positive integers.')
    end
  end
  s = cell2mat(s);
end
if (~isa(s,'double')) | ~isreal(s) | (size(s,1) ~= 1) | any(s<1) | any(round(s) ~= s)
  error('Layer sizes is not a row vector of positive integers.')
end

% More defaults
Nl = length(s);
if nargin < 4, tf = {'tansig'}; tf = [tf(ones(1,Nl))]; end

% Architecture
net = network(1,Nl);
net.biasConnect = ones(Nl,1);
net.inputConnect(1,1) = 1;
[j,i] = meshgrid(1:Nl,1:Nl);
net.layerConnect = (j == (i-1));
net.outputConnect(Nl) = 1;
net.targetConnect(Nl) = 1;

% Simulation
net.inputs{1}.range = pr;
net.inputWeights{1,1}.delays = id;
for i=1:Nl
  net.layers{i}.size = s(i);
  net.layers{i}.transferFcn = tf{i};
end

% Performance
net.performFcn = pf;

% Adaption
net.adaptfcn = 'trains';
net.inputWeights{1,1}.learnFcn = blf;
for i=1:Nl
  net.biases{i}.learnFcn = blf;
  net.layerWeights{i,:}.learnFcn = blf;
end

% Training
net.trainfcn = btf;

% Initialization
net.initFcn = 'initlay';
for i=1:Nl
  net.layers{i}.initFcn = 'initnw';
end
net = init(net);
