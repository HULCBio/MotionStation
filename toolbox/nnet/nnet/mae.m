function perf=mae(e,x,pp)
%MAE Mean absolute error performance function.
%
%  Syntax
%
%    perf = mae(e,x,pp)
%    perf = mae(e,net,pp)
%    info = mae(code)
%
%  Description
%
%    MAE is a network performance function.
%  
%    MAE(E,X,PP) takes from one to three arguments,
%      E - Matrix or cell array of error vector(s).
%      X  - Vector of all weight and bias values (ignored).
%      PP - Performance parameters (ignored).
%     and returns the mean absolute error.
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
%    MAE(E,NET,PP) can take an alternate argument to X,
%      NET - Neural network from which X can be obtained (ignored).
%
%    MAE(CODE) return useful information for each CODE string:
%      'deriv'     - Returns name of derivative function.
%      'name'      - Returns full name.
%      'pnames'    - Returns names of training parameters.
%      'pdefaults' - Returns default training parameters.
%  
%  Examples
%
%    Here a perceptron is created with a 1-element input ranging
%    from -10 to 10, and one neuron.
%
%      net = newp([-10 10],1);
%
%    Here the network is given a batch of inputs P.  The error
%    is calculated by subtracting the output A from target T.
%    Then the mean absolute error is calculated.
%
%      p = [-10 -5 0 5 10];
%      t = [0 0 1 1 1];
%      y = sim(net,p)
%      e = t-y
%      perf = mae(e)
%
%    Note that MAE can be called with only one argument because
%    the other arguments are ignored.  MAE supports those arguments
%    to conform to the standard performance function argument list.
%
%  Network Use
%
%    You can create a standard network that uses MAE with NEWP.
%
%    To prepare a custom network to be trained with MAE, set
%    NET.performFcn to 'mae'.  This will automatically set
%    NET.performParam to the empty matrix [], as MAE has no
%    performance parameters.
%
%    In either case, calling TRAIN or ADAPT will result
%    in MAE being used to calculate performance.
%
%    See NEWP for examples.
%
%  See also MSE, MSEREG, DMAE.

% Mark Beale, 11-31-97
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.7 $

if nargin < 1, error('Not enough input arguments.'), end

% FUNCTION INFO
% =============

if isstr(e)
  switch e
    case 'deriv',
    perf = 'dmae';
    case 'name',
    perf = 'Mean absolute error';
    case 'pnames',
    perf = {};
    case 'pdefaults',
    perf = [];
    otherwise,
    error('Unrecognized code.')
  end
  return
end

% CALCULATION
% ===========

% Form
if isa(e,'double'), e = {e}; end

e = cell2mat(e);
perf = sum(sum(abs(e)))/prod(size(e));
