function [dw,ls] = learnp(w,p,z,n,a,t,e,gW,gA,d,lp,ls)
%LEARNP Perceptron weight/bias learning function.
%
%  Syntax
%  
%    [dW,LS] = learnp(W,P,Z,N,A,T,E,gW,gA,D,LP,LS)
%    [db,LS] = learnp(b,ones(1,Q),Z,N,A,T,E,gW,gA,D,LP,LS)
%    info = learnp(code)
%
%  Description
%
%    LEARNP is the perceptron weight/bias learning function.
%
%    LEARNP(W,P,Z,N,A,T,E,gW,gA,D,LP,LS) takes several inputs,
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
%    LEARNP(CODE) returns useful information for each CODE string:
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
%    Since LEARNP only needs these values to calculate a weight
%    change (see Algorithm below), we will use them to do so.
%
%      dW = learnp([],p,[],[],[],[],e,[],[],[],[],[])
%
%  Network Use
%
%    You can create a standard network that uses LEARNP with NEWP.
%
%    To prepare the weights and the bias of layer i of a custom network
%    to learn with LEARNP:
%    1) Set NET.trainFcn to 'trainb'.
%       (NET.trainParam will automatically become TRAINB's default parameters.)
%    2) Set NET.adaptFcn to 'trains'.
%       (NET.adaptParam will automatically become TRAINS's default parameters.)
%    3) Set each NET.inputWeights{i,j}.learnFcn to 'learnp'.
%       Set each NET.layerWeights{i,j}.learnFcn to 'learnp'.
%       Set NET.biases{i}.learnFcn to 'learnp'.
%       (Each weight and bias learning parameter property will automatically
%       become the empty matrix since LEARNP has no learning parameters.)
%
%    To train the network (or enable it to adapt):
%    1) Set NET.trainParam (NET.adaptParam) properties to desired values.
%    2) Call TRAIN (ADAPT).
%
%    See NEWP for adaption and training examples.
%
%  Algorithm
%
%    LEARNP calculates the weight change dW for a given neuron from the
%    neuron's input P and error E according to the perceptron learning rule:
%
%      dw =  0,  if e =  0
%         =  p', if e =  1
%         = -p', if e = -1
%
%    This can be summarized as:
%
%      dw = e*p'
%
%  See also LEARNPN, NEWP, ADAPT, TRAIN.

% Mark Beale, 1-31-92
% Revised 11-31-97, MB
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.12 $  $Date: 2002/04/14 21:35:44 $

% **[ NNT2 Support ]**
if nargin == 2
  nntobsu('learnp','See help on LEARNP for new argument list.')
  e = p; p = w;
  dw = learnp([],p,[],[],[],[],e,[],[],[],[],[]);
  db = learnp([],ones(1,size(p,2)),[],[],[],[],e,[],[],[],[],[]);
  ls = db;
  return
end
if nargin == 3
  nntobsu('learnp','See help on LEARNP for new argument list.')
  e = z-p; p = w;
  dw = learnp([],p,[],[],[],[],e,[],[],[],[],[]);
  db = learnp([],ones(1,size(p,2)),[],[],[],[],e,[],[],[],[],[]);
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

dw = e*p';
