function [dw,ls] = learnlv2(w,p,z,n,a,t,e,gW,gA,d,lp,ls)
%LEARNLV2 LVQ 2.1 weight learning function.
%
%  Syntax
%  
%    [dW,LS] = learnlv2(W,P,Z,N,A,T,E,gW,gA,D,LP,LS)
%    info = learnlv2(code)
%
%  Description
%
%    LEARNLV2 is the LVQ2 weight learning function.
%
%    LEARNLV2(W,P,Z,N,A,T,E,gW,gA,D,LP,LS) takes several inputs,
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
%     LP.window - 0.25 - Window size (0 to 1, typically 0.2 to 0.3).
%
%    LEARNLV2(CODE) returns useful information for each CODE string:
%      'pnames'    - Returns names of learning parameters.
%      'pdefaults' - Returns default learning parameters.
%      'needg'     - Returns 1 if this function uses gW or gA.
%
%  Examples
%
%    Here we define a sample input P, output A, weight matrix W, and
%    output gradient gA for a layer with a 2-element input and 3 neurons.
%    We also define the learning rate LR.
%
%      p = [0;1];
%      w = [-1 1; 1 0; 1 1];
%      n = negdist(w,p);
%      a = compet(n);
%      gA = [-1;1;1];
%      lp.lr = 0.5;
%     lp.window = 0.25;
%
%    Since LEARNLV2 only needs these values to calculate a weight
%    change (see Algorithm below), we will use them to do so.
%
%      dW = learnlv2(w,p,[],n,a,[],[],[],gA,[],lp,[])
%
%  Network Use
%
%   LEARNLV2 should only be used to train networks which have already
%   been trained with LEARNLV1.
%
%    You can create a standard network that uses LEARNLV2 with NEWLVQ.
%
%    To prepare the weights of layer i of a custom network, or a
%   network which has been trained with LEARNLV1, to learn with LEARNLV2,
%   do the following:
%    1) Set NET.trainFcn to 'trainr'.
%       (NET.trainParam will automatically become TRAINR's default parameters.)
%    2) Set NET.adaptFcn to 'trains'.
%       (NET.adaptParam will automatically become TRAINS's default parameters.)
%    3) Set each NET.inputWeights{i,j}.learnFcn to 'learnlv2'.
%       Set each NET.layerWeights{i,j}.learnFcn to 'learnlv2'.
%       (Each weight learning parameter property will automatically
%       be set to LEARNLV2's default parameters.)
%
%    To train the network (or enable it to adapt):
%    1) Set NET.trainParam (or NET.adaptParam) properties as desired.
%    2) Call TRAIN (or ADAPT).
%
%  Algorithm
%
%    LEARNLV2 implements Learning Vector Quantization 2.1 which works as
%   follows.  For each presentation examine the winning neuron k1 and the
%   runner up neuron k2.  If one of them is in the correct class and the
%   the other is not, then indicate the one that is incorrect as neuron i,
%   and the one that is correct as neuron j.  Also assign the distance
%   from neuron k1 to the input as d1, and the distance from neuron k2
%   to the input as k2.
%
%   If the ratio of distances falls into a window as follows,
%
%     min(di/dj, dj/di) > (1-window)/(1+window)
%
%   then move the incorrect neuron i away from the input vector, and
%   move the correct neuron j toward the input according to:
%
%     dw(i,:) = - lp.lr*(p'-w(i,:))
%     dw(j,:) = + lp.lr*(p'-w(j,:))
%
%  See also LEARNLV1, ADAPT, TRAIN.

% Mark Beale, 11-31-97
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.9 $ $Date: 2002/04/14 21:37:02 $

% FUNCTION INFO
% =============
if isstr(w)
  switch lower(w)
  case 'pnames'
    dw = {'lr';'window'};
  case 'pdefaults'
    lp.lr = 0.01;
    lp.window = 0.25;
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

% For each q...
for q=1:Q
  
  % Find closest neuron k1
  nq = n(:,q);
  k1 = find(nq == max(nq));
  k1 = k1(1);
  
  % Find next closest neuron k2
  nq(k1) = -inf;
  k2 = find(nq == max(nq));
  k2 = k2(1);
  
  % If one neuron is in correct class and the other is not...
  % (Which happens if both neurons have no error, or both have error)
  if (abs(gA(k1,q)) == abs(gA(k2,q)))
    
    % indicate the incorrect neuron with i, the other with j
    if gA(k1,q) ~= 0
      i = k1;
      j = k2;
    else
      i = k2;
      j = k1;
    end
    
    % and if x falls into the window...
    d1 = abs(n(k1,q)); % Shorter distance
    d2 = abs(n(k2,q)); % Greater distance
    if (d1/d2 > ((1-lp.window)/(1+lp.window)))
      
      % then move incorrect neuron away from input,
      % and the correct neuron towards the input
      ptq = pt(q,:);
      dw(i,:) = dw(i,:) - lp.lr*(ptq-w(i,:));
      dw(j,:) = dw(j,:) + lp.lr*(ptq-w(j,:));
    end
  end
end

