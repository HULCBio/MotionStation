function [dw,ls] = learnh(w,p,z,n,a,t,e,gW,gA,d,lp,ls)
%LEARNH Hebb weight learning rule.
%
%  Syntax
%  
%    [dW,LS] = learnh(W,P,Z,N,A,T,E,gW,gA,D,LP,LS)
%    info = learnh(code)
%
%  Description
%
%    LEARNH is the Hebb weight learning function.
%
%    LEARNH(W,P,Z,N,A,T,E,gW,gA,D,LP,LS) takes several inputs,
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
%    Learning occurs according to LEARNH's learning parameter,
%    shown here with its default value.
%      LP.lr - 0.01 - Learning rate
%
%    LEARNH(CODE) returns useful information for each CODE string:
%      'pnames'    - Returns names of learning parameters.
%      'pdefaults' - Returns default learning parameters.
%      'needg'     - Returns 1 if this function uses gW or gA.
%
%  Examples
%
%    Here we define a random input P and output A for a layer
%    with a 2-element input and 3 neurons.  We also define the
%    learning rate LR.
%
%      p = rand(2,1);
%      a = rand(3,1);
%      lp.lr = 0.5;
%
%    Since LEARNH only needs these values to calculate a weight
%    change (see Algorithm below), we will use them to do so.
%
%      dW = learnh([],p,[],[],a,[],[],[],[],[],lp,[])
%
%  Network Use
%
%    To prepare the weights and the bias of layer i of a custom network
%    to learn with LEARNH:
%    1) Set NET.trainFcn to 'trainr'.
%       (NET.trainParam will automatically become TRAINR's default parameters.)
%    2) Set NET.adaptFcn to 'trains'.
%       (NET.adaptParam will automatically become TRAINS's default parameters.)
%    3) Set each NET.inputWeights{i,j}.learnFcn to 'learnh'.
%       Set each NET.layerWeights{i,j}.learnFcn to 'learnh'.
%       (Each weight learning parameter property will automatically
%       be set to LEARNH's default parameters.)
%
%    To train the network (or enable it to adapt):
%    1) Set NET.trainParam (NET.adaptParam) properties to desired values.
%    2) Call TRAIN (ADAPT).
%
%  Algorithm
%
%    LEARNH calculates the weight change dW for a given neuron from the
%    neuron's input P, output A, and learning rate LR according to the
%    Hebb learning rule:
%
%      dw =  lr*a*p'
%
%  See also LEARNHD, ADAPT, TRAIN.

% Mark Beale, 1-31-92
% Revised 11-31-97, MB
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.11 $  $Date: 2002/04/14 21:32:27 $

% **[ NNT2 Support ]**
if nargin == 3
  nntobsu('learnh','See help on LEARNH for new argument list.')
  a = p; p = w; lp.lr = z;
  dw = learnh([],p,[],[],a,[],[],[],[],[],lp,[]);
  return
end

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
    dw = 0;
  otherwise
    error('Unrecognized property.')
  end
  return
end

% CALCULATION
% ===========

dw = lp.lr*a*p';
