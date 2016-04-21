function [dw,ls] = learnwh(w,p,z,n,a,t,e,gW,gA,d,lp,ls)
%LEARNWH Widrow-Hoff weight/bias learning function.
%  
%  Syntax
%  
%    [dW,LS] = learnwh(W,P,Z,N,A,T,E,gW,gA,D,LP,LS)
%    [db,LS] = learnwh(b,ones(1,Q),Z,N,A,T,E,gW,gA,D,LP,LS)
%    info = learnwh(code)
%
%  Description
%
%    LEARNWH is the Widrow-Hoff weight/bias learning function,
%    and is also known as the delta or least mean squared (LMS) rule.
%  
%    LEARNWH(W,P,Z,N,A,T,E,gW,gA,D,LP,LS) takes several inputs,
%      W  - SxR weight matrix (or b, an Sx1 bias vector).
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
%    Learning occurs according to LEARNWH's learning parameter,
%    shown here with its default value.
%      LP.lr - 0.01 - Learning rate
%
%    LEARNWH(CODE) returns useful information for each CODE string:
%      'pnames'    - Returns names of learning parameters.
%      'pdefaults' - Returns default learning parameters.
%      'needg'     - Returns 1 if this function uses gW or gA.
%
%  Examples
%
%    Here we define a random input P and error E to a layer
%    with a 2-element input and 3 neurons.  We also define the
%    learning rate LR learning parameter.
%
%      p = rand(2,1);
%      e = rand(3,1);
%      lp.lr = 0.5;
%
%    Since LEARNWH only needs these values to calculate a weight
%    change (see Algorithm below), we will use them to do so.
%
%      dW = learnwh([],p,[],[],[],[],e,[],[],[],lp,[])
%
%  Network Use
%
%    You can create a standard network that uses LEARNWH with NEWLIN.
%
%    To prepare the weights and the bias of layer i of a custom network
%    to learn with LEARNWH:
%    1) Set NET.trainFcn to 'trainb'.
%       NET.trainParam will automatically become TRAINB's default parameters.
%    2) Set NET.adaptFcn to 'trains'.
%       NET.adaptParam will automatically become TRAINS's default parameters.
%    3) Set each NET.inputWeights{i,j}.learnFcn to 'learnwh'.
%       Set each NET.layerWeights{i,j}.learnFcn to 'learnwh'.
%       Set NET.biases{i}.learnFcn to 'learnwh'.
%       Each weight and bias learning parameter property will automatically
%       be set to LEARNWH's default parameters.
%
%    To train the network (or enable it to adapt):
%    1) Set NET.trainParam (NET.adaptParam) properties to desired values.
%    2) Call TRAIN (ADAPT).
%
%    See NEWLIN for adaption and training examples.
%    
%  Algorithm
%
%    LEARNWH calculates the weight change dW for a given neuron from the
%    neuron's input P and error E, and the weight (or bias) learning
%    rate LR, according to the Widrow-Hoff learning rule:
%
%      dw = lr*e*pn'
%
%  See also NEWLIN, ADAPT, TRAIN.

% Mark Beale, 1-31-92
% Revised 11-31-97, MB
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.12 $  $Date: 2002/04/14 21:35:59 $

% **[ NNT2 Support ]**
if nargin == 3
  nntobsu('learnp','See help on LEARNP for new argument list.')
  lp.lr = z; e = p; p = w;
  dw = learnwh([],p,[],[],[],[],e,[],[],[],lp,[]);
  db = learnwh([],ones(1,size(p,2)),[],[],[],[],e,[],[],[],lp,[]);
  ls = db;
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

dw = lp.lr*e*p';
