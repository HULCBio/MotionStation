function [dw,ls] = mywblf(w,p,z,n,a,t,e,gW,gA,d,lp,ls)
%MYWBLF Example custom weight and bias learning function.
%  
%  Calculation Syntax
%  
%    [dW,LS] = mywblf(W,P,Z,N,A,T,E,gW,gA,D,LP,LS)
%    [db,LS] = mywblf(b,ones(1,Q),Z,N,A,T,E,gW,gA,D,LP,LS)
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
%      dW - SxR weight (or bias) change matrix.
%
%  Information Syntax
%
%    info = mywblf(code) returns useful information for each CODE string:
%      'version'   - Returns the Neural Network Toolbox version (3.0).
%      'pdefaults' - Returns the name of the associated derivative function.
%      'needg'     - Returns the output range.
%
%  Example
%
%    W = rand(4,5);
%    gW = rand(4,5);
%    lp = mywblf('pdefaults')
%    [dW,ls] = mywblf(w,[],[],[],[],[],[],gW,[],[],lp,[]);
%    W = W + dW;
%    gW = rand(4,5);
%    [dW,ls] = mywblf(w,[],[],[],[],[],[],gW,[],[],lp,ls);
%    W = W + dW;

% Copyright 1997 The MathWorks, Inc.
% $Revision: 1.3.2.1 $

if isstr(w)
  switch lower(w)
    case 'version'
    dw = 3.0;       % <-- Must be 3.0.
    
  case 'pdefaults'
    dw.lr = 0.01;   % <-- Replace with your own learning
                    %     parameters or the null matrix [].
  case 'needg'
    dw = 1;         % <-- 1 or 0 depending on whether your
                    %     function uses gW or gA, or not.
  otherwise
    error('Unrecognized property.')
  end

else
  if isempty(ls)
    ls.x = 0.3;       % <-- Replace with your own functions initial
                    %     learning state or the null matrix []
  end

  dw = lp.lr*ls.x*gW; % <-- Replace with your own weight change
                      %     calculation.
  
  ls.x = 1-ls.x;      % <-- Replace with your own learning state
                      %     update code, if you have any such state.
end
