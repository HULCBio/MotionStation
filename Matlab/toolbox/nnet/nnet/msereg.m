function perf=msereg(e,x,pp)
%MSEREG Mean squared error with regularization performance function.
%
%  Syntax
%
%    perf = msereg(e,x,pp)
%    perf = msereg(e,net)
%    info = msereg(code)
%
%  Description
%
%    MSEREG is a network performance function.  It measures
%    network performance as the weight sum of two factors:
%    the mean squared error and the mean squared weights and biases.
%  
%    MSEREG(E,X,PP) takes from three arguments,
%      E  - Matrix or cell array of error vector(s).
%      X  - Vector of all weight and bias values.
%      PP - Performance parameter.
%    where PP defines one performance parameter,
%      PP.ratio - Relative importance of errors vs. weight and bias values.
%     and returns the sum of mean squared errors (times PP.ratio) with the
%    mean squared weight and bias values (times 1-PP.ratio).
%
%    The errors E can be given in cell array form,
%      E - NtxTS cell array, each element E{i,ts} is a VixQ matrix or [].
%    or as a matrix,
%      E - (sum of Vi)xQ matrix
%    where:
%      Nt = net.numTargets
%      TS = number of time steps
%      Q  = batch size
%      Vi = net.targets{i}.size
%
%    MSEREG(E,NET) takes an alternate argument to X and PP,
%      NET - Neural network from which X and PP can be obtained.
%
%    MSEREG(CODE) returns useful information for each CODE string:
%      'deriv'     - Returns name of derivative function.
%      'name'      - Returns full name.
%      'pnames'    - Returns names of training parameters.
%      'pdefaults' - Returns default training parameters.
%  
%  Examples
%
%    Here a two layer feed-forward is created with a 1-element input
%    ranging from -2 to 2, four hidden TANSIG neurons, and one
%    PURELIN output neuron.
%
%  net = newff([-2 2],[4 1],{'tansig','purelin'},'trainlm','learngdm','msereg');
%
%    Here the network is given a batch of inputs P.  The error is
%    calculated by subtracting the output A from target T. Then the
%    mean squared error is calculated using a ratio of 20/(20+1).
%    (Errors are 20 times as important as weight and bias values).
%
%      p = [-2 -1 0 1 2];
%      t = [0 1 1 1 0];
%      y = sim(net,p)
%      e = t-y
%      net.performParam.ratio = 20/(20+1);
%      perf = msereg(e,net)
%
%  Network Use
%
%    You can create a standard network that uses MSEREG with NEWFF,
%    NEWCF, or NEWELM.
%
%    To prepare a custom network to be trained with MSEREG, set
%    NET.performFcn to 'msereg'.  This will automatically set
%    NET.performParam to MSEREG's default performance parameters.
%
%    In either case, calling TRAIN or ADAPT will result
%    in MSEREG being used to calculate performance.
%
%    See NEWFF or NEWCF for examples.
%
%  See also MSE, MAE, DMSEREG.

% Mark Beale, 11-31-97
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.9 $

% FUNCTION INFO
% =============

if isstr(e)
  switch e
  case 'deriv',
    perf = 'dmsereg';
  case 'name',
    perf = 'Mean squared error with regularization';
  case 'pnames',
    perf = {'ratio'};
  case 'pdefaults',
    performParam.ratio = 0.9;
    perf = performParam;
  otherwise,
    error('Unrecognized code.')
  end
  return
end

% CALCULATION
% ===========

if (nargin >= 2)
  if (isa(x,'network') | isa(x,'struct'))
    pp = x.performParam;
    x=getx(x);
  end
else
  error('Not enough input arguments');
end

% Form
if isa(e,'double'), e = {e}; end

e = cell2mat(e);
perfe = sum(sum(e.^2))/prod(size(e));
perfx = sum(sum(x.^2))/length(x);
perf = pp.ratio*perfe + (1-pp.ratio)*perfx;
