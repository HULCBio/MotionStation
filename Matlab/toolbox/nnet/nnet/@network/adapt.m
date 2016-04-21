function [net,Y,E,Pf,Af,tr]=adapt(net,P,T,Pi,Ai)
%ADAPT Allow a neural network to adapt.
%
%  Syntax
%
%    [net,Y,E,Pf,Af,tr] = adapt(NET,P,T,Pi,Ai)
%
%  Description
%
%    [NET,Y,E,Pf,Af,tr] = ADAPT(NET,P,T,Pi,Ai) takes,
%      NET - Network.
%      P   - Network inputs.
%      T   - Network targets, default = zeros.
%      Pi  - Initial input delay conditions, default = zeros.
%      Ai  - Initial layer delay conditions, default = zeros.
%    and returns the following after applying the adapt function
%    NET.adaptFcn with the adaption parameters NET.adaptParam:
%      NET - Updated network.
%      Y   - Network outputs.
%      E   - Network errors.
%      Pf  - Final input delay conditions.
%      Af  - Final layer delay conditions.
%      TR  - Training record (epoch and perf).
%
%    Note that T is optional and only needs to be used for networks
%    that require targets.  Pi and Pf are also optional and need
%    only to be used for networks that have input or layer delays.
%
%    ADAPT's signal arguments can have two formats: cell array or matrix.
%    
%    The cell array format is easiest to describe.  It is most
%    convenient to be used for networks with multiple inputs and outputs,
%    and allows sequences of inputs to be presented:
%      P  - NixTS cell array, each element P{i,ts} is an RixQ matrix.
%      T  - NtxTS cell array, each element T{i,ts} is an VixQ matrix.
%      Pi - NixID cell array, each element Pi{i,k} is an RixQ matrix.
%      Ai - NlxLD cell array, each element Ai{i,k} is an SixQ matrix.
%      Y  - NOxTS cell array, each element Y{i,ts} is an UixQ matrix.
%      E  - NtxTS cell array, each element E{i,ts} is an VixQ matrix.
%      Pf - NixID cell array, each element Pf{i,k} is an RixQ matrix.
%    Af - NlxLD cell array, each element Af{i,k} is an SixQ matrix.
%    Where:
%      Ni = net.numInputs
%      Nl = net.numLayers
%      No = net.numOutputs
%      Nt = net.numTargets
%      ID = net.numInputDelays
%      LD = net.numLayerDelays
%      TS = number of time steps
%      Q  = batch size
%      Ri = net.inputs{i}.size
%      Si = net.layers{i}.size
%      Ui = net.outputs{i}.size
%      Vi = net.targets{i}.size
%
%    The columns of Pi, Pf, Ai, and Af are ordered from oldest delay
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
%  Examples
%
%    Here two sequences of 12 steps (where T1 is known to depend
%    on P1) are used to define the operation of a filter.
%
%      p1 = {-1  0 1 0 1 1 -1  0 -1 1 0 1};
%      t1 = {-1 -1 1 1 1 2  0 -1 -1 0 1 1};
%
%    Here NEWLIN is used to create a layer with an input range
%    of [-1 1]), one neuron, input delays of 0 and 1, and a
%    learning rate of 0.5. The linear layer is then simulated.
%
%      net = newlin([-1 1],1,[0 1],0.5);
%
%    Here the network adapts for one pass through the sequence.
%    The network's mean squared error is displayed.  (Since this
%    is the first call of ADAPT the default Pi is used.)
%
%      [net,y,e,pf] = adapt(net,p1,t1);
%      mse(e)
%      
%    Note the errors are quite large.  Here the network adapts
%    to another 12 time steps (using the previous Pf as the
%    new initial delay conditions.)
%
%      p2 = {1 -1 -1 1 1 -1  0 0 0 1 -1 -1};
%      t2 = {2  0 -2 0 2  0 -1 0 0 1  0 -1};
%      [net,y,e,pf] = adapt(net,p2,t2,pf);
%      mse(e)
%
%    Here the network adapts through 100 passes through
%    the entire sequence.
%
%      p3 = [p1 p2];
%      t3 = [t1 t2];
%      net.adaptParam.passes = 100;
%      [net,y,e] = adapt(net,p3,t3);
%      mse(e)
%
%    The error after 100 passes through the sequence is very
%    small - the network has adapted to the relationship
%    between the input and target signals.
%
%  Algorithm
%
%    ADAPT calls the function indicated by NET.adaptFcn, using the
%    adaption parameter values indicated by NET.adaptParam.
%
%    Given an input sequence with TS steps the network is
%    updated as follows.  Each step in the sequence of  inputs is
%    presented to the network one at a time.  The network's weight and
%    bias values are updated after each step, before the next step in
%    the sequence is presented. Thus the network is updated TS times.
%
%  See also INIT, REVERT, SIM, TRAIN.

%  Mark Beale, 11-31-97
%  Copyright 1992-2002 The MathWorks, Inc.
%  $Revision: 1.13 $ $Date: 2002/04/14 21:28:51 $


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
  case 3
    [err,P,T,Pi,Ai,Q,TS,matrixForm] = trainargs(net,P,T);
  case 4
    [err,P,T,Pi,Ai,Q,TS,matrixForm] = trainargs(net,P,T,Pi);
  case 5
    [err,P,T,Pi,Ai,Q,TS,matrixForm] = trainargs(net,P,T,Pi,Ai);
end
if length(err), error(err), end

% TRAIN NETWORK
% -------------

% Training function
adaptFcn = net.adaptFcn;
if ~length(adaptFcn)
  error('Network "adaptFcn" is undefined.')
end

% Delayed inputs, layer targets
Pc = [Pi P];
Pd = calcpd(net,TS,Q,Pc);
Tl = expandrows(T,net.hint.targetInd,net.numLayers);

% Train network using adaptParam (in place of trainParam)
net = struct(net);
saveTrainParam = net.trainParam;
net.trainParam = net.adaptParam;
[net,tr,Ac,El] = feval(adaptFcn,net,Pd,Tl,Ai,Q,TS,[],[]);
net.trainParam = saveTrainParam;
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
  case 'double', matrixForm = 1; name = 'matrix'; default = [];
  otherwise, err = 'P must be a matrix or cell array.'; return
end
if (nargin < 3)
  T = default;
elseif (isa(T,'double') ~= matrixForm)
  if isempty(T)
    T = default;
  else
    err = ['P is a ' name ', so T must be a ' name ' too.'];
    return
  end
end
if (nargin < 4)
  Pi = default;
elseif (isa(Pi,'double') ~= matrixForm)
  if isempty(Pi)
    Pi = default;
  else
    err = ['P is a ' name ', so Pi must be a ' name ' too.'];
    return
  end
end
if (nargin < 5)
  Ai = default;
elseif (isa(Ai,'double') ~= matrixForm)
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

