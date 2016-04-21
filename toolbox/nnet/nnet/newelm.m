function net = newelm(pr,s,tf,btf,blf,pf)
%NEWELM Create an Elman backpropagation network.
%
%  Syntax
%
%    net = newelm
%    net = newelm(PR,[S1 S2...SNl],{TF1 TF2...TFNl},BTF,BLF,PF)
%
%  Description
%    
%    NET = NEWELM creates a new network with a dialog box.
%
%     NET = NEWELM(PR,[S1 S2...SNl],{TF1 TF2...TFNl},BTF,BLF,PF) takes several arguments,
%      PR  - Rx2 matrix of min and max values for R input elements.
%      Si  - Size of ith layer, for Nl layers.
%      TFi - Transfer function of ith layer, default = 'tansig'.
%      BTF - Backprop network training function, default = 'traingdx'.
%      BLF - Backprop weight/bias learning function, default = 'learngdm'.
%      PF  - Performance function, default = 'mse'.
%    and returns an Elman network.
%
%    The training function BTF can be any of the backprop training
%    functions such as TRAINGD, TRAINGDM, TRAINGDA, TRAINGDX, etc.
%
%    *WARNING*: Algorithms which take large step sizes, such as TRAINLM,
%    and TRAINRP, etc., are not recommended for Elman networks.  Because
%    of the delays in Elman networks the gradient of performance used
%    by these algorithms is only approximated making learning difficult
%    for large step algorithms.
%
%    The learning function BLF can be either of the backpropagation
%    learning functions such as LEARNGD, or LEARNGDM.
%
%    The performance function can be any of the differentiable performance
%    functions such as MSE or MSEREG.
%
%  Examples
%
%    Here is a series of Boolean inputs P, and another sequence T
%    which is 1 wherever P has had two 1's in a row.
%
%      P = round(rand(1,20));
%      T = [0 (P(1:end-1)+P(2:end) == 2)];
%
%    We would like the network to recognize whenever two 1's
%    occur in a row.  First we arrange these values as sequences.
%
%      Pseq = con2seq(P);
%      Tseq = con2seq(T);
%
%    Next we create an Elman network whose input varies from 0 to 1,
%    and has five hidden neurons and 1 output.
%
%      net = newelm([0 1],[10 1],{'tansig','logsig'});
%
%    Then we train the network with a mean squared error goal of
%    0.1, and simulate it.
%
%      net = train(net,Pseq,Tseq);
%      Y = sim(net,Pseq)
%
%  Algorithm
%
%    Elman networks consists of Nl layers using the DOTPROD
%    weight function, NETSUM net input function, and the specified
%    transfer functions.
%
%    The first layer has weights coming from the input.  Each subsequent
%    layer has a weight coming from the previous layer.  All layers except
%    the last have a recurrent weight. All layers have biases.  The last
%    layer is the network output.
%
%    Each layer's weights and biases are initialized with INITNW.
%
%    Adaption is done with TRAINS which updates weights with the
%    specified learning function. Training is done with the specified
%    training function. Performance is measured according to the specified
%    performance function.
%
%  See also NEWFF, NEWCF, SIM, INIT, ADAPT, TRAIN, TRAINS

% Mark Beale, 11-31-97
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.9 $  $Date: 2002/04/14 21:36:02 $

if nargin < 2
  net = newnet('newelm');
  return
end

% Defaults
if nargin < 4, btf = 'traingdx'; end
if nargin < 5, blf = 'learngdm'; end
if nargin < 6, pf = 'mse'; end

% Error checking
if (~isa(pr,'double')) | ~isreal(pr) | (size(pr,2) ~= 2)
  error('Input ranges is not a two column matrix.')
end
if any(pr(:,1) > pr(:,2))
  error('Input ranges has values in the second column larger in the values in the same row of the first column.')
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
if nargin < 3, tf = {'tansig'}; tf = [tf(ones(1,Nl))]; end

% Architecture
net = network(1,Nl);
net.biasConnect = ones(Nl,1);
net.inputConnect(1,1) = 1;
[j,i] = meshgrid(1:Nl,1:Nl);
net.layerConnect = (j == (i-1)) | ((j == i) & (i < Nl));
net.outputConnect(Nl) = 1;
net.targetConnect(Nl) = 1;

% Simulation
net.inputs{1}.range = pr;
for i=1:Nl
  net.layerWeights{i,i}.delays = [1];
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
