function net=newlind(p,t,pi)
%NEWLIND Design a linear layer.
%
%  Syntax
%
%    net = newlind
%    net = newlind(P,T,Pi)
%
%  Description
%
%   NET = NEWLIND creates a new network with a dialog box.
%
%    NEWLIND(P,T,Pi) takes these input arguments,
%      P  - RxQ matrix of Q input vectors.
%      T  - SxQ matrix of Q target class vectors.
%      Pi - 1xID cell array of initial input delay states,
%           each element Pi{i,k} is an RixQ matrix, default = [].
%    and returns a linear layer designed to output T
%    (with minimum sum square error) given input P.
%
%    NEWLIND(P,T,Pi) can also solve for linear networks with input delays and
%    multiple inputs and layers by supplying input and target data in cell
%    array form:
%      P  - NixTS cell array, each element P{i,ts} is an RixQ input matrix.
%      T  - NtxTS cell array, each element P{i,ts} is an VixQ matrix.
%      Pi - NixID cell array, each element Pi{i,k} is an RixQ matrix, default = [].
%    returns a linear network with ID input delays, Ni network inputs, Nl layers,
%    and  designed to output T (with minimum sum square error) given input P.
%
%  Examples
%
%    We would like a linear layer that outputs T given P
%    for the following definitions.
%
%      P = [1 2 3];
%      T = [2.0 4.1 5.9];
%
%    Here we use NETLIND to design such a linear network that minimizes
%    the sum squared error between its output Y and T.
%
%      net = newlind(P,T);
%      Y = sim(net,P)
%
%    We would like another linear layer that outputs the sequence T
%    given the sequence P and two initial input delay states Pi.
%
%      P = {1 2 1 3 3 2};
%      Pi = {1 3};
%      T = {5.0 6.1 4.0 6.0 6.9 8.0};
%      net = newlind(P,T,Pi);
%      Y = sim(net,P,Pi)
%
%    We would like a linear network with two outputs Y1 and Y2, that generate
%    sequences T1 and T2, given the sequences P1 and P2 with 3 initial input
%    delay states Pi1 for input 1, and 3 initial delays states Pi2 for input 2.
%
%      P1 = {1 2 1 3 3 2}; Pi1 = {1 3 0};
%      P2 = {1 2 1 1 2 1}; Pi2 = {2 1 2};
%      T1 = {5.0 6.1 4.0 6.0 6.9 8.0};
%      T2 = {11.0 12.1 10.1 10.9 13.0 13.0};
%      net = newlind([P1; P2],[T1; T2],[Pi1; Pi2]);
%      Y = sim(net,[P1; P2],[Pi1; Pi2]);
%      Y1 = Y(1,:)
%      Y2 = Y(2,:)
%
%  Algorithm
%
%    NEWLIND calculates weight W and bias B values for a
%    linear layer from inputs P and targets T by solving
%    this linear equation in the least squares sense:
%    
%      [W b] * [P; ones] = T
%
%  See also SIM, NEWLIN.

% Mark Beale, 11-31-97
% Cell array arguments, Mark Beale, 5-23-98
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.11 $ $Date: 2002/04/14 21:34:02 $

% Arguments
if nargin < 2
  net = newnet('newlind');
  return
end
if nargin < 3, pi = {}; end

% Check Inputs
if isnumeric(p)
  p = {p};
end
if (~isa(p,'cell'))
  error('Inputs is not a matrix or cell array of matrices.');
end
TS = size(p,2);
Ni = size(p,1);
Q = size(p{1,1},2);
for j=1:Ni
  r(j) = size(p{j,1},1);
end
R = sum(r);
for i=1:Ni
  for j=1:TS
    if size(p{i,j},1) ~= r(i)
      error('Input matrices in the same row have a different numbers of rows.')
    end
    if size(p{i,j},2) ~= Q
      error('All Input matrices do not have the same number of columns.')
    end
  end
end

% Check Targets
if isnumeric(t)
  t = {t};
end
if (~isa(t,'cell'))
  error('Targets is not a matrix or cell array of matrices.');
end
Nl = size(t,1);
for i=1:Nl
  s(i) = size(t{i,1},1);
end
S = sum(s);
if size(t,2) ~= TS
  error('Inputs and Targets have different numbers of time steps (columns of matrices).')
end
for i=1:Ni
  for j=1:TS
    if size(t{i,j},1) ~= s(i)
      error('Target matrices in the same row have different numbers of rows.')
    end
    if size(t{i,j},2) ~= Q
      error('Target matrices do not have the same number of columns as Input matrices.')
    end
  end
end

% Check Initial Inputs
if isnumeric(pi)
  pi = {pi};
end
if length(pi) == 0
  pi = cell(Nl,0);
end
if (~isa(pi,'cell'))
  error('Initial Inputs is not a matrix or cell array of matrices.');
end
id = size(pi,2);
if size(pi,1) ~= Nl
  error('Initial Inputs must have as many rows of matrices as Inputs.');
end
for i=1:Ni
  for j=1:id
    if size(pi{i,j},1) ~= r(i)
      error('Initial Input matrices have different numbers of rows from Input matrices in the same row.')
    end
    if size(pi{i,j},2) ~= Q
      error('Initial Input matrices do not have the same number of columns as Input matrices.')
    end
  end
end

% Delayed input states
pd = delayed_inputs(TS,Q,[pi p],id,Nl,Ni,r);
p2 = cell(1,TS);
for ts = 1:TS
  p2{1,ts} = cell2mat(pd(1,:,ts)');
end

% Network architecture
net = network(Ni,Nl,ones(Nl,1),ones(Nl,Ni),zeros(Nl,Nl),ones(1,Nl),ones(1,Nl));

% Input ranges
for j=1:Ni
  net.inputs{j}.range = minmax([p{j,:} pi{j,:}]);
end

% Convert from sequential to concurrent
p2 = seq2con(p2);
p2 = p2{1,1};
t2 = seq2con(t);
Q2 = Q*TS;
R2 = R*(id+1);

% For each layer...
for i=1:Nl
  
  % Targets
  ti = t2{i,1};

  % Parameter values
  x = ti/[p2; ones(1,Q2)];
  w = x(:,1:R2);
  b = x(:,R2+1);

  % Layer size
  net.layers{i}.size = s(i);

  % Biases
  net.b{i} = b;

  % Weights
  rstart = 0;
  for j=1:Ni
    net.inputWeights{i,j}.delays = [0:id];
    net.iw{i,j} = w(:,rstart + [1:r(j)*(id+1)]);
    rstart = rstart + r(j)*(id+1);
  end
end

%===================================
function PD=delayed_inputs(TS,Q,Pc,id,numLayers,numInputs,inputSizes)
% TS - time steps
% Q - batch size
% Pc - combined input sequence = [Pi P]
% id - number of input delay states

totalTS = TS + id;

PD = cell(numLayers,numInputs,totalTS);
start = 1;
for ts=1:totalTS
  for i=1:numLayers
    for j=1:numInputs
      delays = 0:id;
      inputsize = inputSizes(j);
      numDelays = length(delays);
      pd = zeros(0,Q);
      for k=1:numDelays
        d = delays(k);
        if (ts-d) > 0
        pd = [pd; Pc{j,ts-d}];
        else
          pd = [pd; zeros(inputsize,Q)];
          start = ts+1;
        end
        PD{i,j,ts} = pd;
      end
    end
  end
end

PD = PD(:,:,start:ts);
