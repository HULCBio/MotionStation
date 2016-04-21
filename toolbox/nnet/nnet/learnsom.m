function [dw,ls] = learnsom(w,p,z,n,a,t,e,gW,gA,d,lp,ls)
%LEARNSOM Self-organizing map weight learning function.
%
%  Syntax
%  
%    [dW,LS] = learnk(W,P,Z,N,A,T,E,gW,gA,D,LP,LS)
%    info = learnk(code)
%
%  Description
%
%    LEARNSOM is the self-organizing map weight learning function.
%
%    LEARNSOM(W,P,Z,N,A,T,E,gW,gA,D,LP,LS) takes several inputs,
%      W  - SxR weight matrix (or Sx1 bias vector).
%      P  - RxQ input vectors (or ones(1,Q)).
%      Z  - SxQ weighted input vectors.
%      N  - SxQ net input vectors.
%      A  - SxQ output vectors.
%      T  - SxQ layer target vectors.
%      E  - SxQ layer error vectors.
%      gW - SxR gradient with respect to performance.
%      gA - SxQ output gradient with respect to performance.
%      D  - SxS neuron distances.
%      LP - Learning parameters, none, LP = [].
%      LS - Learning state, initially should be = [].
%    and returns,
%      dW - SxR weight (or bias) change matrix.
%      LS - New learning state.
%
%    Learning occurs according to LEARNSOM's learning parameter,
%    shown here with its default value.
%      LP.order_lr    -  0.9 - Ordering phase learning rate.
%      LP.order_steps - 1000 - Ordering phase steps.
%      LP.tune_lr     - 0.02 - Tuning phase learning rate.
%      LP.tune_nd     -    1 - Tuning phase neighborhood distance.
%
%    LEARNSOM(CODE) returns useful information for each CODE string:
%      'pnames'    - Returns names of learning parameters.
%      'pdefaults' - Returns default learning parameters.
%      'needg'     - Returns 1 if this function uses gW or gA.
%
%  Examples
%
%    Here we define a random input P, output A, and weight matrix W,
%    for a layer with a 2-element input and 6 neurons.  We also calculate
%    the positions and distances for the neurons which are arranged in a
%    2x3 hexagonal pattern. Then we define the four learning parameters.
%
%      p = rand(2,1);
%      a = rand(6,1);
%      w = rand(6,2);
%      pos = hextop(2,3);
%      d = linkdist(pos);
%      lp.order_lr = 0.9;
%      lp.order_steps = 1000;
%      lp.tune_lr = 0.02;
%      lp.tune_nd = 1;
%
%    Since LEARNSOM only needs these values to calculate a weight
%    change (see Algorithm below), we will use them to do so.
%
%      ls = [];
%      [dW,ls] = learnsom(w,p,[],[],a,[],[],[],[],d,lp,ls)
%
%  Network Use
%
%    You can create a standard network that uses LEARNSOM with NEWSOM.
%
%    To prepare the weights of layer i of a custom network
%    to learn with LEARNSOM:
%    1) Set NET.trainFcn to 'trainr'.
%       (NET.trainParam will automatically become TRAINR's default parameters.)
%    2) Set NET.adaptFcn to 'trains'.
%       (NET.adaptParam will automatically become TRAINS's default parameters.)
%    3) Set each NET.inputWeights{i,j}.learnFcn to 'learnsom'.
%       Set each NET.layerWeights{i,j}.learnFcn to 'learnsom'.
%       (Each weight learning parameter property will automatically
%       be set to LEARNSOM's default parameters.)
%
%    To train the network (or enable it to adapt):
%    1) Set NET.trainParam (or NET.adaptParam) properties as desired.
%    2) Call TRAIN (or ADAPT).
%
%  Algorithm
%
%    LEARNSOM calculates the weight change dW for a given neuron from
%    the neuron's input P, activation A2, and learning rate LR:
%
%      dw =  lr*a2*(p'-w)
%
%    where the activation A2 is found from the layer output A and
%    neuron distances D and the current neighborhood size ND:
%
%      a2(i,q) = 1,   if a(i,q) = 1
%              = 0.5, if a(j,q) = 1 and D(i,j) <= nd
%              = 0,   otherwise
%
%    The learning rate LR and neighborhood size NS are altered
%    through two phases: an ordering phase and a tuning phase.
%
%    The ordering phase lasts as many steps as LP.order_steps.
%    During this phase LR is adjusted from LP.order_lr down to
%    LP.tune_lr, and ND is adjusted from the maximum neuron distance
%    down to 1.  It is during this phase that neuron weights are expected
%    to order themselves in the input space consistent with
%    the associated neuron positions.
%
%    During the tuning phase LR decreases slowly from LP.tune_lr and
%    ND is always set to LP.tune_nd.  During this phase the weights are
%    expected to spread out relatively evenly over the input space while
%    retaining their topological order found during the ordering phase.
%
%  See also ADAPT, TRAIN.

% Mark Beale, 11-31-97
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.9 $

% FUNCTION INFO
% =============
if isstr(w)
  switch lower(w)
  case 'pnames'
    dw = fieldnames(learnsom('pdefaults'));
  case 'pdefaults'
    lp.order_lr = 0.9;
    lp.order_steps = 1000;
    lp.tune_lr = .02;
    lp.tune_nd = 1;
      dw = lp;
  case 'needg'
    dw = 0;
  otherwise
    error('Unrecognized property.')
  end
  return
end

% CALCULATION
% ===========

% Initial learning state
if isempty(ls)
  ls.step = 0;
  ls.nd_max = max(max(d));
end

% Neighborhood and learning rate
if (ls.step < lp.order_steps)
  percent = 1 - ls.step/lp.order_steps;
  nd = 1.00001 + (ls.nd_max-1) * percent;
  lr = lp.tune_lr + (lp.order_lr-lp.tune_lr) * percent;
else
  nd = lp.tune_nd + 0.00001;
  lr = lp.tune_lr * lp.order_steps/ls.step;
end

% Bubble neighborhood
a2 = 0.5*(a + (d < nd)*a);

% Instar rule
[S,R] = size(w);
[R,Q] = size(p);
pt = p';
lr_a = lr * a2;
dw = zeros(S,R);
for q=1:Q
  dw = dw + lr_a(:,q+zeros(1,R)) .* (pt(q+zeros(S,1),:)-w);
end

% Next learning state
ls.step = ls.step + 1;
