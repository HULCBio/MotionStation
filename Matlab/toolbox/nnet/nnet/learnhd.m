function [dw,ls] = learnhd(w,p,z,n,a,t,e,gW,gA,d,lp,ls)
%LEARNHD Hebb with decay weight learning rule.
%
%  Syntax
%  
%    [dW,LS] = learnhd(W,P,Z,N,A,T,E,gW,gA,D,LP,LS)
%    info = learnhd(code)
%
%  Description
%
%    LEARNHD is the Hebb weight learning function.
%
%    LEARNHD(W,P,Z,N,A,T,E,gW,gA,D,LP,LS) takes several inputs,
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
%    Learning occurs according to LEARNHD's learning parameters
%    shown here with default values.
%      LP.dr - 0.01 - Decay rate.
%      LP.lr - 0.1  - Learning rate
%
%    LEARNHD(CODE) returns useful information for each CODE string:
%      'pnames'    - Returns names of learning parameters.
%      'pdefaults' - Returns default learning parameters.
%      'needg'     - Returns 1 if this function uses gW or gA.
%
%  Examples
%
%    Here we define a random input P, output A, and weights W
%    for a layer with a 2-element input and 3 neurons.  We also
%    define the decay and learning rates.
%
%      p = rand(2,1);
%      a = rand(3,1);
%      w = rand(3,2);
%      lp.dr = 0.05;
%      lp.lr = 0.5;
%
%    Since LEARNHD only needs these values to calculate a weight
%    change (see Algorithm below), we will use them to do so.
%
%      dW = learnhd(w,p,[],[],a,[],[],[],[],[],lp,[])
%
%  Network Use
%
%    To prepare the weights and the bias of layer i of a custom network
%    to learn with LEARNHD:
%    1) Set NET.trainFcn to 'trainr'.
%       (NET.trainParam will automatically become TRAINR's default parameters.)
%    2) Set NET.adaptFcn to 'trains'.
%       (NET.adaptParam will automatically become TRAINS's default parameters.)
%    3) Set each NET.inputWeights{i,j}.learnFcn to 'learnhd'.
%       Set each NET.layerWeights{i,j}.learnFcn to 'learnhd'.
%       (Each weight learning parameter property will automatically
%       be set to LEARNHD's default parameters.)
%
%    To train the network (or enable it to adapt):
%    1) Set NET.trainParam (NET.adaptParam) properties to desired values.
%    2) Call TRAIN (ADAPT).
%
%  Algorithm
%
%    LEARNHD calculates the weight change dW for a given neuron from the
%    neuron's input P, output A, decay rate DR, and learning rate LR
%    according to the Hebb with decay learning rule:
%
%      dw =  lr*a*p' - dr*w
%
%  See also LEARNH, ADAPT, TRAIN.

% Mark Beale, 1-31-92
% Revised 11-31-97, MB
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.12 $  $Date: 2002/04/14 21:32:33 $

% **[ NNT2 Support ]**
if nargin == 5
  nntobsu('learnhd','See help on LEARNHD for new argument list.')
  lp.lr = n; lp.dr = a; a = z;
  dw = learnhd(w,p,[],[],a,[],[],[],[],[],lp,[]);
  return
end

% FUNCTION INFO
% =============
if isstr(w)
  switch lower(w)
  case 'pnames'
    dw = {'dr'; 'lr'};
  case 'pdefaults'
    lp.dr = 0.01;
    lp.lr = 0.1;
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

dw = lp.lr*a*p' - lp.dr*w;
