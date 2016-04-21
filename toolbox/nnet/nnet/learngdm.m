function [dw,ls] = learngdm(w,p,z,n,a,t,e,gW,gA,d,lp,ls)
%LEARNGDM Gradient descent w/momentum weight/bias learning function.
%  
%  Syntax
%  
%    [dW,LS] = learngdm(W,P,Z,N,A,T,E,gW,gA,D,LP,LS)
%    [db,LS] = learngdm(b,ones(1,Q),Z,N,A,T,E,gW,gA,D,LP,LS)
%    info = learngdm(code)
%
%  Description
%
%    LEARNGDM is the gradient descent with momentum weight/bias
%    learning function.
%  
%    LEARNGDM(W,P,Z,N,A,T,E,gW,gA,D,LP,LS) takes several inputs,
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
%    Learning occurs according to LEARNGDM's learning parameters,
%    shown here with their default values.
%      LP.lr - 0.01 - Learning rate
%      LP.mc - 0.9  - Momentum constant
%
%    LEARNGDM(CODE) returns useful information for each CODE string:
%      'pnames'    - Returns names of learning parameters.
%      'pdefaults' - Returns default learning parameters.
%      'needg'     - Returns 1 if this function uses gW or gA.
%
%  Examples
%
%    Here we define a random gradient G for a weight going
%    to a layer with 3 neurons, from an input with 2 elements.
%    We also define a learning rate of 0.5 and momentum constant
%    of 0.8;
%
%      gW = rand(3,2);
%      lp.lr = 0.5;
%      lp.mc = 0.8;
%
%    Since LEARNGDM only needs these values to calculate a weight
%    change (see Algorithm below), we will use them to do so.
%    We will use the default initial learning state.
% 
%      ls = [];
%      [dW,ls] = learngdm([],[],[],[],[],[],[],gW,[],[],lp,ls)
%
%    LEARNGDM returns the weight change and a new learning state.
%
%  Network Use
%
%    You can create a standard network that uses LEARNGD with NEWFF,
%    NEWCF, or NEWELM.
%
%    To prepare the weights and the bias of layer i of a custom network
%    to adapt with LEARNGDM:
%    1) Set NET.adaptFcn to 'trains'.
%       NET.adaptParam will automatically become TRAINS's default parameters.
%    2) Set each NET.inputWeights{i,j}.learnFcn to 'learngdm'.
%       Set each NET.layerWeights{i,j}.learnFcn to 'learngdm'.
%       Set NET.biases{i}.learnFcn to 'learngdm'.
%       Each weight and bias learning parameter property will automatically
%       be set to LEARNGDM's default parameters.
%
%    To allow the network to adapt:
%    1) Set NET.adaptParam properties to desired values.
%    2) Call ADAPT with the network.
%
%    See NEWFF or NEWCF for examples.
%    
%  Algorithm
%
%    LEARNGDM calculates the weight change dW for a given neuron
%    from the neuron's input P and error E, the weight (or bias)
%    learning rate LR, and momentum constant MC, according to
%    gradient descent with momentum:
%
%      dW = mc*dWprev + (1-mc)*lr*gW
%
%    The previous weight change dWprev is stored and read
%    from the learning state LS.
%
%  See also LEARNGD, NEWFF, NEWCF, ADAPT, TRAIN.

% Mark Beale, 1-31-92
% Revised 12-15-93, MB
% Revised 11-31-97, MB
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.9 $  $Date: 2002/04/14 21:35:02 $

% FUNCTION INFO
% =============
if isstr(w)
  switch lower(w)
  case 'pnames'
    dw = {'lr';'mc'};
  case 'pdefaults'
    lp.lr = 0.01;
    lp.mc = 0.9;
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

% Initial learning state
if isempty(ls)
  ls.dw = lp.lr*gW;
end

% Gradient descent w/momentum rule
dw = lp.mc*ls.dw + ((1-lp.mc)*lp.lr)*gW;

% Next learning state
ls.dw = dw;
