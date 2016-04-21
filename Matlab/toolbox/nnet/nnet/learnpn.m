function [dw,ls] = learnpn(w,p,z,n,a,t,e,gW,gA,d,lp,ls)
%LEARNPN Normalized perceptron weight/bias learning function.
%  
%  Syntax
%  
%    [dW,LS] = learnpn(W,P,Z,N,A,T,E,gW,gA,D,LP,LS)
%    info = learnpn(code)
%
%  Description
%
%    LEARNPN is a weight/bias learning function.  It can result
%    in faster learning than LEARNP when input vectors have
%    widely varying magnitudes.
%
%    LEARNPN(W,P,Z,N,A,T,E,gW,gA,D,LP,LS) takes several inputs,
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
%    LEARNPN(CODE) returns useful information for each CODE string:
%      'pnames'    - Returns names of learning parameters.
%      'pdefaults' - Returns default learning parameters.
%      'needg'     - Returns 1 if this function uses gW or gA.
%
%  Examples
%
%    Here we define a random input P and error E to a layer
%    with a 2-element input and 3 neurons.
%
%      p = rand(2,1);
%      e = rand(3,1);
%
%    Since LEARNPN only needs these values to calculate a weight
%    change (see Algorithm below), we will use them to do so.
%
%      dW = learnpn([],p,[],[],[],[],e,[],[],[],[],[])
%
%  Network Use
%
%    You can create a standard network that uses LEARNPN with NEWP.
%
%    To prepare the weights and the bias of layer i of a custom network
%    to learn with LEARNPN:
%    1) Set NET.trainFcn to 'trainb'.
%       NET.trainParam will automatically become TRAINB's default parameters.
%    2) Set NET.adaptFcn to 'trains'.
%       NET.adaptParam will automatically become TRAINS's default parameters.
%    3) Set each NET.inputWeights{i,j}.learnFcn to 'learnpn'.
%       Set each NET.layerWeights{i,j}.learnFcn to 'learnpn'.
%       Set NET.biases{i}.learnFcn to 'learnpn'.
%       Each weight and bias learning parameter property will automatically
%       become the empty matrix since LEARNPN has no learning parameters.
%
%    To train the network (or enable it to adapt):
%    1) Set NET.trainParam (NET.adaptParam) properties to desired values.
%    2) Call TRAIN (ADAPT).
%
%    See NEWP for adaption and training examples.
%    
%  Algorithm
%
%    LEARNPN calculates the weight change dW for a given neuron from the
%    neuron's input P and error E according to the normalized perceptron
%    learning rule:
%
%      pn = p / sqrt(1 + p(1)^2 + p(2)^2) + ... + p(R)^2)
%      dw =  0,   if e =  0
%         =  pn', if e =  1
%         = -pn', if e = -1
%
%    The expression for dW can be summarized as:
%
%      dw = e*pn'
%
%  See also LEARNP, NEWP, ADAPT, TRAIN.

% Mark Beale, 12-15-93
% Revised 11-31-97, MB
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.11 $  $Date: 2002/04/14 21:35:47 $

% **[ NNT2 Support ]**
if nargin == 2
  nntobsu('learnpn','See help on LEARNPN for new argument list.')
  e = p; p = w;
  dw = learnpn([],p,[],[],[],[],e,[],[],[],[],[]);
  db = learnpn([],ones(1,size(p,2)),[],[],[],[],e,[],[],[],[],[]);
  ls = db;
  return
end

% FUNCTION INFO
% =============
if isstr(w)
  switch lower(w)
  case 'pnames'
    dw = {};
  case 'pdefaults'
      dw = [];
  case 'needg'
    dw = 0;
  otherwise
    error('Unrecognized property.')
  end
  return
end

% CALCULATION
% ===========

R = size(p,1);
lenp = sqrt(1+sum(p.^2,1));
pn = p./lenp(ones(1,R),:);
dw = e*pn';
