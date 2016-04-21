function [Y,Pf,Af,E,perf]=sim(net,P,Pi,Ai,T)
%SIM Simulate a neural network.
%
%  Syntax
%
%    [Y,Pf,Af,E,perf] = sim(net,P,Pi,Ai,T)
%    [Y,Pf,Af,E,perf] = sim(net,{Q TS},Pi,Ai,T)
%    [Y,Pf,Af,E,perf] = sim(net,Q,Pi,Ai,T)
%
%  Description
%
%    SIM simulates neural networks.
%
%    [Y,Pf,Af,E,perf] = SIM(net,P,Pi,Ai,T) takes,
%      NET  - Network.
%      P    - Network inputs.
%      Pi   - Initial input delay conditions, default = zeros.
%      Ai   - Initial layer delay conditions, default = zeros.
%      T    - Network targets, default = zeros.
%    and returns:
%      Y    - Network outputs.
%      Pf   - Final input delay conditions.
%      Af   - Final layer delay conditions.
%      E    - Network errors.
%      perf - Network performance.
%
%    Note that arguments Pi, Ai, Pf, and Af are optional and
%    need only be used for networks that have input or layer delays.
%
%    SIM's signal arguments can have two formats: cell array or matrix.
%    
%    The cell array format is easiest to describe.  It is most
%    convenient for networks with multiple inputs and outputs,
%    and allows sequences of inputs to be presented:
%      P  - NixTS cell array, each element P{i,ts} is an RixQ matrix.
%      Pi - NixID cell array, each element Pi{i,k} is an RixQ matrix.
%    Ai - NlxLD cell array, each element Ai{i,k} is an SixQ matrix.
%      T  - NtxTS cell array, each element P{i,ts} is an VixQ matrix.
%    Y  - NOxTS cell array, each element Y{i,ts} is a UixQ matrix.
%      Pf - NixID cell array, each element Pf{i,k} is an RixQ matrix.
%    Af - NlxLD cell array, each element Af{i,k} is an SixQ matrix.
%      E  - NtxTS cell array, each element P{i,ts} is an VixQ matrix.
%    Where:
%      Ni = net.numInputs
%    Nl = net.numLayers, 
%      No = net.numOutputs
%    ID = net.numInputDelays
%    LD = net.numLayerDelays
%      TS = number of time steps
%      Q  = batch size
%      Ri = net.inputs{i}.size
%      Si = net.layers{i}.size
%      Ui = net.outputs{i}.size
%
%    The columns of Pi, Pf, Ai, and Af are ordered from oldest delay
%    condition to most recent:
%      Pi{i,k} = input i at time ts=k-ID.
%      Pf{i,k} = input i at time ts=TS+k-ID.
%      Ai{i,k} = layer output i at time ts=k-LD.
%      Af{i,k} = layer output i at time ts=TS+k-LD.
%
%    The matrix format can be used if only one time step is to be
%    simulated (TS = 1).  It is convenient for networks with only
%     one input and output, but can also be used with networks that
%     have more.
%
%    Each matrix argument is found by storing the elements of
%    the corresponding cell array argument into a single matrix:
%      P  - (sum of Ri)xQ matrix
%      Pi - (sum of Ri)x(ID*Q) matrix.
%    Ai - (sum of Si)x(LD*Q) matrix.
%      T  - (sum of Vi)xQ matrix
%    Y  - (sum of Ui)xQ matrix.
%      Pf - (sum of Ri)x(ID*Q) matrix.
%    Af - (sum of Si)x(LD*Q) matrix.
%      E  - (sum of Vi)xQ matrix
%
%    [Y,Pf,Af] = SIM(net,{Q TS},Pi,Ai) is used for networks
%    which do not have an input, such as Hopfield networks
%    when cell array notation is used.
%
%  Examples
%
%    Here NEWP is used to create a perceptron layer with a
%    2-element input (with ranges of [0 1]), and a single neuron.
%
%      net = newp([0 1;0 1],1);
%
%    Here the perceptron is simulated for an individual vector,
%    a batch of 3 vectors, and a sequence of 3 vectors.
%
%      p1 = [.2; .9]; a1 = sim(net,p1)
%      p2 = [.2 .5 .1; .9 .3 .7]; a2 = sim(net,p2)
%      p3 = {[.2; .9] [.5; .3] [.1; .7]}; a3 = sim(net,p3)
%
%    Here NEWLIND is used to create a linear layer with a 3-element
%    input, 2 neurons.
%
%      net = newlin([0 2;0 2;0 2],2,[0 1]);
%
%    Here the linear layer is simulated with a sequence of 2 input
%    vectors using the default initial input delay conditions (all zeros).
%
%      p1 = {[2; 0.5; 1] [1; 1.2; 0.1]};
%      [y1,pf] = sim(net,p1)
%
%    Here the layer is simulated for 3 more vectors using the previous
%    final input delay conditions as the new initial delay conditions.
%
%      p2 = {[0.5; 0.6; 1.8] [1.3; 1.6; 1.1] [0.2; 0.1; 0]};
%      [y2,pf] = sim(net,p2,pf)
%
%    Here NEWELM is used to create an Elman network with a 1-element
%    input, and a layer 1 with 3 TANSIG neurons followed by a layer 2
%    with 2 PURELIN neurons.  Because it is an Elman network it has a
%    tap delay line with a delay of 1 going from layer 1 to layer 1.
%
%      net = newelm([0 1],[3 2],{'tansig','purelin'});
%
%    Here the Elman network is simulated for a sequence of 3 values
%    using default initial delay conditions.
%
%      p1 = {0.2 0.7 0.1};
%      [y1,pf,af] = sim(net,p1)
%
%    Here the network is simulated for 4 more values, using the previous
%    final delay conditions as the new initial delay conditions.
%
%      p2 = {0.1 0.9 0.8 0.4};
%      [y2,pf,af] = sim(net,p2,pf,af)
%
%  Algorithm
%
%    SIM uses these properties to simulate a network NET.
%
%      NET.numInputs, NET.numLayers
%      NET.outputConnect, NET.biasConnect
%      NET.inputConnect, NET.layerConnect
%
%    These properties determine the network's weight and bias values,
%    and the number of delays associated with each weight:
%
%      NET.inputWeights{i,j}.value
%      NET.layerWeights{i,j}.value
%      NET.layers{i}.value
%      NET.inputWeights{i,j}.delays
%      NET.layerWeights{i,j}.delays
%
%    These function properties indicate how SIM applies weight and
%    bias values to inputs to get each layer's output:
%
%      NET.inputWeights{i,j}.weightFcn
%      NET.layerWeights{i,j}.weightFcn
%      NET.layers{i}.netInputFcn
%      NET.layers{i}.transferFcn
%  
%    See Chapter 2 for more information on network simulation.
%
%  See also INIT, REVERT, ADAPT, TRAIN


%  Mark Beale, 11-31-97
%  Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.8 $ $Date: 2002/04/14 21:29:14 $

% CHECK AND FORMAT ARGUMENTS
% --------------------------

if nargin < 2
  error ('Not enough input arguments.');
  return
end
if ~isa(net,'network')
  error ('First argument is not a network.');
end
if net.hint.zeroDelay
  error('Network contains a zero-delay loop.')
end
if length(net.hint.noWeights)
  error(sprintf('Layer %g has no weights.',net.hint.noWeights(1)))
end
switch nargin
  case 2, [err,P,Pi,Ai,T,Q,TS,matrixForm] = simargs(net,P);
  case 3, [err,P,Pi,Ai,T,Q,TS,matrixForm] = simargs(net,P,Pi);
  case 4, [err,P,Pi,Ai,T,Q,TS,matrixForm] = simargs(net,P,Pi,Ai);
  case 5, [err,P,Pi,Ai,T,Q,TS,matrixForm] = simargs(net,P,Pi,Ai,T);
end
if length(err), error(err), end

% SIMULATE NETWORK
% ----------------

% Combined and Delayed inputs
Pc = [Pi P];
Pd = calcpd(net,TS,Q,Pc);

% Simulate network
net = struct(net);
if (net.numLayerDelays == 0) & (TS > 1)
  Pd = seq2con(Pd);
  Ac = calca(net,Pd,Ai,Q*TS,1);
  Ac = con2seq(Ac,TS);
else
  Ac = calca(net,Pd,Ai,Q,TS);
end
net = class(net,'network');

% Network outputs, final inputs
Y = Ac(net.hint.outputInd,net.numLayerDelays+[1:TS]);
Pf = Pc(:,TS+[1:net.numInputDelays]);
Af = Ac(:,TS+[1:net.numLayerDelays]);
if nargout >= 4
  Tl = expandrows(T,net.hint.targetInd,net.numLayers);
  El = calce(net,Ac,Tl,TS);
  E = El(net.hint.targetInd,:);
end
if nargout >= 5
  perf = feval(net.performFcn,El,getx(net),net.performParam);
end

% FORMAT OUTPUT ARGUMENTS
% -----------------------

if (matrixForm)
  Y = cell2mat(Y);
  if (net.numOutputs == 0)
    Y = zeros(size(Y,1),Q);
  end
  Pf = cell2mat(Pf);
  Af = cell2mat(Af);
  if nargout >= 4
    E = cell2mat(E);
  end
end

% ============================================================
function [s2] = expandrows(s,ind,rows)

s2 = cell(rows,size(s,2));
s2(ind,:) = s;

% ============================================================
function [err,P,Pi,Ai,T,Q,TS,matrixForm] = simargs(net,P,Pi,Ai,T);

err = '';

% Check signals: all matrices or all cell arrays
% Change empty matrices/arrays to proper form
switch class(P)
  case 'cell', matrixForm = 0; name = 'cell array'; default = {};
  case 'double', matrixForm = 1; name = 'matrix'; default = [];
  otherwise, err = 'P must be a matrix or cell array.'; return
end
if (nargin < 3)
  Pi = default;
elseif (isa(Pi,'double') ~= matrixForm)
  if isempty(Pi)
    Pi = default;
  else
    err = ['P is a ' name ', so Pi must be a ' name ' too.'];
    return
  end
end
if (nargin < 4)
  Ai = default;
elseif (isa(Ai,'double') ~= matrixForm)
  if isempty(Ai)
    Ai = default;
  else
    err = ['P is a ' name ', so Ai must be a ' name ' too.'];
    return
  end
end
if (nargin < 5)
  T = default;
elseif (isa(T,'double') ~= matrixForm)
  if isempty(Ai)
    T = default;
  else
    err = ['P is a ' name ', so T must be a ' name ' too.'];
    return
  end
end

% Check Matrices, Matrices -> Cell Arrays
if (matrixForm)
  if (net.numInputs == 0) & all(size(P) == [1 1])
    Q = P;
  P = zeros(0,Q);
  else
    Q = size(P,2);
  end
  TS = 1;
  [err,P] = formatp(net,P,Q); if length(err), return, end
  [err,Pi] = formatpi(net,Pi,Q); if length(err), return, end
  [err,Ai] = formatai(net,Ai,Q); if length(err), return, end
  [err,T] = formatt(net,T,Q,TS); if length(err), return, end
  
% Check Cell Arrays
else
  if (net.numInputs == 0) & all(size(P) == [1 2])
  Q = P{1};
    TS = P{2};
  P = cell(0,TS);
  else
    TS = size(P,2);
  if prod(size(P))
      Q = size(P{1,1},2);
  elseif prod(size(Pi))
    Q = size(Pi{1,1},2);
  elseif prod(size(Ai))
    Q = size(Ai{1,1},2);
  else
    Q = 1;
  end
  end
  [err] = checkp(net,P,Q,TS); if length(err), return, end
  [err,Pi] = checkpi(net,Pi,Q); if length(err), return, end
  [err,Ai] = checkai(net,Ai,Q); if length(err), return, end
  [err,T] = checkt(net,T,Q,TS); if length(err), return, end
end

% ============================================================
