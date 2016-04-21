function [dw,ls] = learnlv1(w,p,z,n,a,t,e,gW,gA,d,lp,ls)
%LEARNLV1 LVQ1 weight learning function.
%
%  Syntax
%  
%    [dW,LS] = learnlv1(W,P,Z,N,A,T,E,gW,gA,D,LP,LS)
%    info = learnlv1(code)
%
%  Description
%
%    LEARNLV1 is the LVQ1 weight learning function.
%
%    LEARNLV1(W,P,Z,N,A,T,E,gW,gA,D,LP,LS) takes several inputs,
%      W  - SxR weight matrix (or Sx1 bias vector).
%      P  - RxQ input vectors (or ones(1,Q)).
%      Z  - SxQ weighted input vectors.
%      N  - SxQ net input vectors.
%      A  - SxQ output vectors.
%      T  - SxQ layer target vectors.
%      E  - SxQ layer error vectors.
%      gW - SxR weight gradient with respect to performance.
%      gA - SxQ output gradient with respect to performance.
%      D  - SxS neuron distances.
%      LP - Learning parameters, none, LP = [].
%      LS - Learning state, initially should be = [].
%    and returns,
%      dW - SxR weight (or bias) change matrix.
%      LS - New learning state.
%
%    Learning occurs according to LEARNLV1's learning parameter,
%    shown here with its default value.
%      LP.lr - 0.01 - Learning rate
%
%    LEARNLV1(CODE) returns useful information for each CODE string:
%      'pnames'    - Returns names of learning parameters.
%      'pdefaults' - Returns default learning parameters.
%      'needg'     - Returns 1 if this function uses gW or gA.
%
%  Examples
%
%    Here we define a random input P, output A, weight matrix W, and
%    output gradient gA for a layer with a 2-element input and 3 neurons.
%    We also define the learning rate LR.
%
%      p = rand(2,1);
%      w = rand(3,2);
%      a = compet(negdist(w,p));
%      gA = [-1;1; 1];
%      lp.lr = 0.5;
%
%    Since LEARNLV1 only needs these values to calculate a weight
%    change (see Algorithm below), we will use them to do so.
%
%      dW = learnlv1(w,p,[],[],a,[],[],[],gA,[],lp,[])
%
%  Network Use
%
%    You can create a standard network that uses LEARNLV1 with NEWLVQ.
%
%    To prepare the weights of layer i of a custom network
%    to learn with LEARNLV1:
%    1) Set NET.trainFcn to 'trainr'.
%       (NET.trainParam will automatically become TRAINR's default parameters.)
%    2) Set NET.adaptFcn to 'trains'.
%       (NET.adaptParam will automatically become TRAINS's default parameters.)
%    3) Set each NET.inputWeights{i,j}.learnFcn to 'learnlv1'.
%       Set each NET.layerWeights{i,j}.learnFcn to 'learnlv1'.
%       (Each weight learning parameter property will automatically
%       be set to LEARNLV1's default parameters.)
%
%    To train the network (or enable it to adapt):
%    1) Set NET.trainParam (or NET.adaptParam) properties as desired.
%    2) Call TRAIN (or ADAPT).
%
%  Algorithm
%
%    LEARNLV1 calculates the weight change dW for a given neuron from
%    the neuron's input P, output A, output gradient gA and learning rate LR,
%    according to the LVQ1 rule, given i the index of the neuron whose
%    output a(i) is 1:
%
%      dw(i,:) = +lr*(p-w(i,:)) if gA(i) = 0
%              = -lr*(p-w(i,:)) if gA(i) = -1
%
%  See also LEARNLV2, ADAPT, TRAIN.

% Mark Beale, 11-31-97
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.9 $

% FUNCTION INFO
% =============
if isstr(w)
  switch lower(w)
  case 'pnames'
    dw = {'lr'};
  case 'pdefaults'
    lp.lr = 0.01;
      dw = lp;
  case 'needg'
    dw = 1;
  otherwise
    error('Unrecognized property.')
  end
  return
end

% CALCULATION
% ===========

[S,R] = size(w);
Q = size(p,2);
pt = p';
dw = zeros(S,R);

for q=1:Q
  i = find(a(:,q));
  if any(gA(:,q) ~= 0)
  
    % Move incorrect winner away from input
    dw(i,:) = dw(i,:) - lp.lr*(pt(q,:)-w(i,:));
  
  else
  
    % Move correct winner toward input
    dw(i,:) = dw(i,:) + lp.lr*(pt(q,:)-w(i,:));
  end
end
