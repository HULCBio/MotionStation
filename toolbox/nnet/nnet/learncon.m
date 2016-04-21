function [db,ls] = learncon(b,p,z,n,a,t,e,gW,gA,d,lp,ls)
%LEARNCON Conscience bias learning function.
%
%  Syntax
%  
%    [dB,LS] = learncon(B,P,Z,N,A,T,E,gW,gA,D,LP,LS)
%    info = learncon(code)
%
%  Description
%
%    LEARNCON is the conscience bias learning function
%    used to increase the net input to neurons which
%    have the lowest average output until each neuron
%    responds roughly an equal percentage of the time.
%
%    LEARNCON(B,P,Z,N,A,T,E,gW,gA,D,LP,LS) takes several inputs,
%      B  - Sx1 bias vector.
%      P  - 1xQ ones vector.
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
%      dB - Sx1 weight (or bias) change matrix.
%      LS - New learning state.
%
%    Learning occurs according to LEARNCON's learning parameter,
%    shown here with its default value.
%      LP.lr - 0.001 - Learning rate
%
%    LEARNCON(CODE) returns useful information for each CODE string:
%      'pnames'    - Returns names of learning parameters.
%      'pdefaults' - Returns default learning parameters.
%      'needg'     - Returns 1 if this function uses gW or gA.
%
%    NNT 2.0 compatibility: The LP.lr described above equals
%    1 minus the bias time constant used by TRAINC in NNT 2.0.
%
%  Examples
%
%    Here we define a random output A, and bias vector W for a
%    layer with 3 neurons.  We also define the learning rate LR.
%
%      a = rand(3,1);
%      b = rand(3,1);
%      lp.lr = 0.5;
%
%    Since LEARNCON only needs these values to calculate a bias
%    change (see Algorithm below), we will use them to do so.
%
%      dW = learncon(b,[],[],[],a,[],[],[],[],[],lp,[])
%
%  Network Use
%
%    To prepare the bias of layer i of a custom network
%    to learn with LEARNCON:
%    1) Set NET.trainFcn to 'trainr'.
%       (NET.trainParam will automatically become TRAINR's default parameters.)
%    2) Set NET.adaptFcn to 'trains'.
%       (NET.adaptParam will automatically become TRAINS's default parameters.)
%    3) Set NET.inputWeights{i}.learnFcn to 'learncon'.
%       Set each NET.layerWeights{i,j}.learnFcn to 'learncon'.
%       (Each weight learning parameter property will automatically
%       be set to LEARNCON's default parameters.)
%
%    To train the network (or enable it to adapt):
%    1) Set NET.trainParam (or NET.adaptParam) properties as desired.
%    2) Call TRAIN (or ADAPT).
%
%  Algorithm
%
%    LEARNCON calculates the bias change db for a given neuron
%    by first updating each neuron's "conscience", i.e. the
%    running average of its output:
%
%      c = (1-lr)*c + lr*a
%
%    The conscience is then used to compute a bias for the
%    neuron that is greatest for smaller conscience values.
%
%      b = exp(1-log(c)) - b
%
%    (Note that LEARNCON is able to recover C each time it
%     is called from the bias values.)
%
%  See also LEARNK, LEARNOS, ADAPT, TRAIN.

% Mark Beale, 1-31-92
% Revised 12-15-93, MB
% Revised 11-31-97, MB
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.9 $  $Date: 2002/04/14 21:33:05 $

% FUNCTION INFO
% =============
if isstr(b)
  switch lower(b)
  case 'pnames'
    db = {'lr'};
  case 'pdefaults'
    lp.lr = 0.001;
      db = lp;
  case 'needg'
    db = 0;
  otherwise
    error('Unrecognized property.')
  end
  return
end

% CALCULATION
% ===========

% flatten batch
[s,q] = size(a);
if q ~= 1, a = (1/q)*sum(a,2); end

% b -> conscience
c = exp(1-log(b));

% update conscience
c = (1-lp.lr) * c + lp.lr * a;

% conscience -> db
db = exp(1-log(c)) - b;
