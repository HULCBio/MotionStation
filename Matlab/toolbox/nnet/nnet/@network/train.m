function [net,tr,Y,E,Pf,Af]=train(net,P,T,Pi,Ai,VV,TV)
%TRAIN Train a neural network.
%
%  Syntax
%
%    [net,tr,Y,E,Pf,Af] = train(NET,P,T,Pi,Ai,VV,TV)
%
%  Description
%
%    TRAIN trains a network NET according to NET.trainFcn and
%    NET.trainParam.
%
%    TRAIN(NET,P,T,Pi,Ai) takes,
%      NET - Network.
%      P   - Network inputs.
%      T   - Network targets, default = zeros.
%      Pi  - Initial input delay conditions, default = zeros.
%      Ai  - Initial layer delay conditions, default = zeros.
%      VV  - Structure of validation vectors, default = [].
%      TV  - Structure of test vectors, default = [].
%    and returns,
%      NET - New network.
%      TR  - Training record (epoch and perf).
%      Y   - Network outputs.
%      E   - Network errors.
%      Pf  - Final input delay conditions.
%      Af  - Final layer delay conditions.
%
%    Note that T is optional and need only be used for networks
%    that require targets.  Pi and Pf are also optional and need
%    only be used for networks that have input or layer delays.
%    Optional arguments VV and TV are described below.
%
%    TRAIN's signal arguments can have two formats: cell array or matrix.
%    
%    The cell array format is easiest to describe.  It is most
%    convenient for networks with multiple inputs and outputs,
%    and allows sequences of inputs to be presented:
%      P  - NixTS cell array, each element P{i,ts} is an RixQ matrix.
%      T  - NtxTS cell array, each element P{i,ts} is an VixQ matrix.
%      Pi - NixID cell array, each element Pi{i,k} is an RixQ matrix.
%      Ai - NlxLD cell array, each element Ai{i,k} is an SixQ matrix.
%      Y  - NOxTS cell array, each element Y{i,ts} is an UixQ matrix.
%      E  - NtxTS cell array, each element P{i,ts} is an VixQ matrix.
%      Pf - NixID cell array, each element Pf{i,k} is an RixQ matrix.
%      Af - NlxLD cell array, each element Af{i,k} is an SixQ matrix.
%    Where:
%      Ni = net.numInputs
%      Nl = net.numLayers
%      Nt = net.numTargets
%      ID = net.numInputDelays
%      LD = net.numLayerDelays
%      TS = number of time steps
%      Q  = batch size
%      Ri = net.inputs{i}.size
%      Si = net.layers{i}.size
%      Vi = net.targets{i}.size
%
%    The columns of Pi, Pf, Ai, and Af are ordered from the oldest delay
%    condition to most recent:
%      Pi{i,k} = input i at time ts=k-ID.
%      Pf{i,k} = input i at time ts=TS+k-ID.
%      Ai{i,k} = layer output i at time ts=k-LD.
%      Af{i,k} = layer output i at time ts=TS+k-LD.
%
%    The matrix format can be used if only one time step is to be
%    simulated (TS = 1).  It is convenient for network's with
%     only one input and output, but can be used with networks that
%     have more.
%
%    Each matrix argument is found by storing the elements of
%    the corresponding cell array argument into a single matrix:
%      P  - (sum of Ri)xQ matrix
%      T  - (sum of Vi)xQ matrix
%      Pi - (sum of Ri)x(ID*Q) matrix.
%      Ai - (sum of Si)x(LD*Q) matrix.
%      Y  - (sum of Ui)xQ matrix.
%      E  - (sum of Vi)xQ matrix
%      Pf - (sum of Ri)x(ID*Q) matrix.
%      Af - (sum of Si)x(LD*Q) matrix.
%
%    If VV and TV are supplied they should be an empty matrix [] or
%    a structure with the following fields:
%      VV.P,  TV.P  - Validation/test inputs.
%      VV.T,  TV.T  - Validation/test targets, default = zeros.
%      VV.Pi, TV.Pi - Validation/test initial input delay conditions, default = zeros.
%      VV.Ai, TV.Ai - Validation/test layer delay conditions, default = zeros.
%    The validation vectors are used to stop training early if further
%    training on the primary vectors will hurt generalization to the
%    validation vectors.  Test vector performance can be used to measure
%    how well the network generalizes beyond primary and validation vectors.
%    If VV.T, VV.Pi, or VV.Ai are set to an empty matrix or cell array,
%    default values will be used. The same is true for TV.T, TV.Pi, TV.Ai.
%
%    Not all training functions support validation and test vectors.
%    Those that do not ignore the VV and TV arguments.
%
%  Examples
%
%    Here input P and targets T define a simple function which
%    we can plot:
%
%      p = [0 1 2 3 4 5 6 7 8];
%      t = [0 0.84 0.91 0.14 -0.77 -0.96 -0.28 0.66 0.99];
%      plot(p,t,'o')
%
%    Here NEWFF is used to create a two layer feed forward network.
%    The network will have an input (ranging from 0 to 8), followed
%    by a layer of 10 TANSIG neurons, followed by a layer with 1
%    PURELIN neuron.  TRAINLM backpropagation is used.  The network
%    is also simulated.
%
%      net = newff([0 8],[10 1],{'tansig' 'purelin'},'trainlm');
%      y1 = sim(net,p)
%      plot(p,t,'o',p,y1,'x')
%
%    Here the network is trained for up to 50 epochs to a error goal of
%    0.01, and then resimulated.
%
%      net.trainParam.epochs = 50;
%      net.trainParam.goal = 0.01;
%      net = train(net,p,t);
%      y2 = sim(net,p)
%      plot(p,t,'o',p,y1,'x',p,y2,'*')
%      
%  Algorithm
%
%    TRAIN calls the function indicated by NET.trainFcn, using the
%    training parameter values indicated by NET.trainParam.
%
%    Typically one epoch of training is defined as a single presentation
%    of all input vectors to the network.  The network is then updated
%    according to the results of all those presentations.
%
%    Training occurs until a maximum number of epochs occurs, the
%    performance goal is met, or any other stopping condition of the
%    function NET.trainFcn occurs.
%
%    Some training functions depart from this norm by presenting only
%    one input vector (or sequence) each epoch. An input vector (or sequence)
%    is chosen randomly each epoch from concurrent input vectors (or sequences).
%    NEWC and NEWSOM return networks that use TRAINR, a training function
%    that does this.
%
%  See also INIT, REVERT, SIM, ADAPT

%  Mark Beale, 11-31-97
%  Copyright 1992-2002 The MathWorks, Inc.
%  $Revision: 1.11.4.1 $ $Date: 2002/09/01 23:07:37 $

% CHECK AND FORMAT ARGUMENTS
% --------------------------

if nargin < 2
  error('Not enough input arguments.');
end
if ~isa(net,'network')
  error('First argument is not a network.');
end
if net.hint.zeroDelay
  error('Network contains a zero-delay loop.')
end
switch nargin
  case 2
    [err,P,T,Pi,Ai,Q,TS,matrixForm] = trainargs(net,P);
  VV = [];
  TV = [];
  case 3
    [err,P,T,Pi,Ai,Q,TS,matrixForm] = trainargs(net,P,T);
  VV = [];
  TV = [];
  case 4
    [err,P,T,Pi,Ai,Q,TS,matrixForm] = trainargs(net,P,T,Pi);
  VV = [];
  TV = [];
  case 5
    [err,P,T,Pi,Ai,Q,TS,matrixForm] = trainargs(net,P,T,Pi,Ai);
  VV = [];
  TV = [];
  case 6
    [err,P,T,Pi,Ai,Q,TS,matrixForm] = trainargs(net,P,T,Pi,Ai);
  if isempty(VV)
    VV = [];
  else
    if ~hasfield(VV,'P'), error('VV.P must be defined or VV must be [].'), end
    if ~hasfield(VV,'T'), VV.T = []; end
    if ~hasfield(VV,'Pi'), VV.Pi = []; end
    if ~hasfield(VV,'Ai'), VV.Ai = []; end
    [err,VV.P,VV.T,VV.Pi,VV.Ai,VV.Q,VV.TS,matrixForm] = ...
      trainargs(net,VV.P,VV.T,VV.Pi,VV.Ai);
      if length(err)
      disp('??? Error with validation vectors using ==> train')
      error(err)
    end
  end
  TV = [];
  case 7
    [err,P,T,Pi,Ai,Q,TS,matrixForm] = trainargs(net,P,T,Pi,Ai);
  if isempty(VV)
    VV = [];
  else
    if ~hasfield(VV,'P'), error('VV.P must be defined or VV must be [].'), end
    if ~hasfield(VV,'T'), VV.T = []; end
    if ~hasfield(VV,'Pi'), VV.Pi = []; end
    if ~hasfield(VV,'Ai'), VV.Ai = []; end
    [err,VV.P,VV.T,VV.Pi,VV.Ai,VV.Q,VV.TS,matrixForm] = ...
      trainargs(net,VV.P,VV.T,VV.Pi,VV.Ai);
      if length(err)
      disp('??? Error with validation vectors using ==> train')
      error(err)
    end
  end
  if isempty(TV)
    TV = [];
  else
    if ~hasfield(TV,'P'), error('TV.P must be defined or TV must be [].'), end
    if ~hasfield(TV,'T'), TV.T = []; end
    if ~hasfield(TV,'Pi'), TV.Pi = []; end
    if ~hasfield(TV,'Ai'), TV.Ai = []; end
    [err,TV.P,TV.T,TV.Pi,TV.Ai,TV.Q,TV.TS,matrixForm] = ...
      trainargs(net,TV.P,TV.T,TV.Pi,TV.Ai);
      if length(err)
      disp('??? Error with test vectors using ==> train')
      error(err)
    end
  end
end
if length(err), error(err), end

% TRAIN NETWORK
% -------------

% Training function
trainFcn = net.trainFcn;
if ~length(trainFcn)
  error('Network "trainFcn" is undefined.')
end

% Delayed inputs, layer targets
Pc = [Pi P];
Pd = calcpd(net,TS,Q,Pc);
Tl = expandrows(T,net.hint.targetInd,net.numLayers);

% Validation and Test vectors
doValidation = ~isempty(VV);
doTest = ~isempty(TV);
if (doValidation)
  VV.Pd = calcpd(net,VV.TS,VV.Q,[VV.Pi VV.P]);
  VV.Tl = expandrows(VV.T,net.hint.targetInd,net.numLayers);
end
if (doTest)
  TV.Pd = calcpd(net,TV.TS,TV.Q,[TV.Pi TV.P]);
  TV.Tl = expandrows(TV.T,net.hint.targetInd,net.numLayers);
end

% Train network
net = struct(net);
flatten_time = (net.numLayerDelays == 0) & (TS > 1) & (~strcmp(trainFcn,'trains'));
if flatten_time
  Pd = seq2con(Pd);
  Tl = seq2con(Tl);
  if (doValidation)
    VV.Pd = seq2con(VV.Pd);
    VV.Tl = seq2con(VV.Tl);
    VV.Q = VV.Q*VV.TS;
    VV.TS = 1;
  end
  if (doTest)
    TV.Pd = seq2con(TV.Pd);
    TV.Tl = seq2con(TV.Tl);
    TV.Q = TV.Q*TV.TS;
    TV.TS = 1;
  end
  [net,tr,Ac,El] = feval(trainFcn,net,Pd,Tl,Ai,Q*TS,1,VV,TV);
  Ac = con2seq(Ac,TS);
  El = con2seq(El,TS);
else
  [net,tr,Ac,El] = feval(trainFcn,net,Pd,Tl,Ai,Q,TS,VV,TV);
end
net = class(net,'network');

% Network outputs, errors, final inputs
Y = Ac(net.hint.outputInd,net.numLayerDelays+[1:TS]);
E = El(net.hint.targetInd,:);
Pf = Pc(:,TS+[1:net.numInputDelays]);
Af = Ac(:,TS+[1:net.numLayerDelays]);

% FORMAT OUTPUT ARGUMENTS
% -----------------------

if (matrixForm)
  Y = cell2mat(Y);
  E = cell2mat(E);
  Pf = cell2mat(Pf);
  Af = cell2mat(Af);
end

% ============================================================
function [s2] = expandrows(s,ind,rows)

s2 = cell(rows,size(s,2));
s2(ind,:) = s;

% ============================================================
function [err,P,T,Pi,Ai,Q,TS,matrixForm] = trainargs(net,P,T,Pi,Ai);

err = '';

% Check signals: all matrices or all cell arrays
% Change empty matrices/arrays to proper form
switch class(P)
  case 'cell', matrixForm = 0; name = 'cell array'; default = {};
  case {'double','logical'}, matrixForm = 1; name = 'matrix'; default = [];
  otherwise, err = 'P must be a matrix or cell array.'; return
end
if (nargin < 3)
  T = default;
elseif ((isa(T,'double')|isa(T,'logical')) ~= matrixForm)
  if isempty(T)
    T = default;
  else
    err = ['P is a ' name ', so T must be a ' name ' too.'];
    return
  end
end
if (nargin < 4)
  Pi = default;
elseif ((isa(Pi,'double')|isa(Pi,'logical')) ~= matrixForm)
  if isempty(Pi)
    Pi = default;
  else
    err = ['P is a ' name ', so Pi must be a ' name ' too.'];
    return
  end
end
if (nargin < 5)
  Ai = default;
elseif ((isa(Ai,'double')|isa(Ai,'logical')) ~= matrixForm)
  if isempty(Ai)
    Ai = default;
  else
    err = ['P is a ' name ', so Ai must be a ' name ' too.'];
    return
  end
end

% Check Matrices, Matrices -> Cell Arrays
if (matrixForm)
  [R,Q] = size(P);
  TS = 1;
  [err,P] = formatp(net,P,Q); if length(err), return, end
  [err,T] = formatt(net,T,Q,TS); if length(err), return, end
  [err,Pi] = formatpi(net,Pi,Q); if length(err), return, end
  [err,Ai] = formatai(net,Ai,Q); if length(err), return, end
  
% Check Cell Arrays
else
  [R,TS] = size(P);
  [R1,Q] = size(P{1,1});
  [err] = checkp(net,P,Q,TS); if length(err), return, end
  [err,T] = checkt(net,T,Q,TS); if length(err), return, end
  [err,Pi] = checkpi(net,Pi,Q); if length(err), return, end
  [err,Ai] = checkai(net,Ai,Q); if length(err), return, end
end

% ============================================================

