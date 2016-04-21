function [dw,ls] = learngd(w,p,z,n,a,t,e,gW,gA,d,lp,ls)
%LEARNGD Gradient descent weight/bias learning function.
%  
%  Syntax
%  
%    [dW,LS] = learngd(W,P,Z,N,A,T,E,gW,gA,D,LP,LS)
%    [db,LS] = learngd(b,ones(1,Q),Z,N,A,T,E,gW,gA,D,LP,LS)
%    info = learngd(code)
%
%  Description
%
%    LEARNGD is the gradient descent weight/bias learning function.
%  
%    LEARNGD(W,P,Z,N,A,T,E,gW,gA,D,LP,LS) takes several inputs,
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
%    and returns
%      dW - SxR weight (or bias) change matrix.
%      LS - New learning state.
%
%    Learning occurs according to LEARNGD's learning parameter
%    shown here with its default value.
%      LP.lr - 0.01 - Learning rate
%
%    LEARNGD(CODE) return useful information for each CODE string:
%      'pnames'    - Returns names of learning parameters.
%      'pdefaults' - Returns default learning parameters.
%      'needg'     - Returns 1 if this function uses gW or gA.
%
%  Examples
%
%    Here we define a random gradient gW for a weight going
%    to a layer with 3 neurons, from an input with 2 elements.
%    We also define a learning rate of 0.5.
%
%      gW = rand(3,2);
%      lp.lr = 0.5;
%
%    Since LEARNGD only needs these values to calculate a weight
%    change (see Algorithm below), we will use them to do so.
%
%      dW = learngd([],[],[],[],[],[],[],gW,[],[],lp,[])
%
%  Network Use
%
%    You can create a standard network that uses LEARNGD with NEWFF,
%    NEWCF, or NEWELM.
%
%    To prepare the weights and the bias of layer i of a custom network
%    to adapt with LEARNGD:
%    1) Set NET.adaptFcn to 'trains'.
%       NET.adaptParam will automatically become TRAINS's default parameters.
%    2) Set each NET.inputWeights{i,j}.learnFcn to 'learngd'.
%       Set each NET.layerWeights{i,j}.learnFcn to 'learngd'.
%       Set NET.biases{i}.learnFcn to 'learngd'.
%       Each weight and bias learning parameter property will automatically
%       be set to LEARNGD's default parameters.
%
%    To allow the network to adapt:
%    1) Set NET.adaptParam properties to desired values.
%    2) Call ADAPT with the network.
%
%    See NEWFF or NEWCF for examples.
%    
%  Algorithm
%
%    LEARNGD calculates the weight change dW for a given neuron from
%    the neuron's input P and error E, and the weight (or bias) learning
%    rate LR, according to the gradient descent:
%
%      dw = lr*gW
%
%  See also LEARNGDM, NEWFF, NEWCF, ADAPT, TRAIN.

% Mark Beale, 1-31-92
% Revised 12-15-93, MB
% Revised 11-31-97, MB
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.8 $  $Date: 2002/04/14 21:36:56 $

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

dw = lp.lr*gW;
