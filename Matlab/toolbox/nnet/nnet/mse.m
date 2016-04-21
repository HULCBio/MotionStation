function perf=mse(e,x,pp)
%MSE Mean squared error performance function.
%
%  Syntax
%
%    perf = mse(e,x,pp)
%    perf = mse(e,net,pp)
%    info = mse(code)
%
%  Description
%
%    MSE is a network performance function.  It measures the
%    network's performance according to the mean of squared errors.
%  
%    MSE(E,X,PP) takes from one to three arguments,
%      E  - Matrix or cell array of error vector(s).
%      X  - Vector of all weight and bias values (ignored).
%      PP - Performance parameters (ignored).
%     and returns the mean squared error.
%
%    MSE(E,NET,PP) can take an alternate argument to X,
%      NET - Neural network from which X can be obtained (ignored).
%
%    MSE(CODE) returns useful information for each CODE string:
%      'deriv'     - Returns name of derivative function.
%      'name'      - Returns full name.
%      'pnames'    - Returns names of training parameters.
%      'pdefaults' - Returns default training parameters.
%  
%  Examples
%
%    Here a two layer feed-forward network is created with a 1-element
%    input ranging from -10 to 10, four hidden TANSIG neurons, and one
%    PURELIN output neuron.
%
%      net = newff([-10 10],[4 1],{'tansig','purelin'});
%
%    Here the network is given a batch of inputs P.  The error
%    is calculated by subtracting the output A from target T.
%    Then the mean squared error is calculated.
%
%      p = [-10 -5 0 5 10];
%      t = [0 0 1 1 1];
%      y = sim(net,p)
%      e = t-y
%      perf = mse(e)
%
%    Note that MSE can be called with only one argument because the
%    other arguments are ignored.  MSE supports those ignored arguments
%    to conform to the standard performance function argument list.
%
%  Network Use
%
%    You can create a standard network that uses MSE with NEWFF,
%    NEWCF, or NEWELM.
%
%    To prepare a custom network to be trained with MSE set
%    NET.performFcn to 'mse'.  This will automatically set
%    NET.performParam to the empty matrix [], as MSE has no
%    performance parameters.
%
%    In either case, calling TRAIN or ADAPT will result
%    in MSE being used to calculate performance.
%
%    See NEWFF or NEWCF for examples.
%
%  See also MSEREG, MAE, DMSE

% Mark Beale, 11-31-97
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.7 $

if nargin < 1, error('Not enough input arguments.'), end

% FUNCTION INFO
% =============

if isstr(e)
  switch lower(e)
    case 'deriv',
    perf = 'dmse';
    case 'name',
    perf = 'Mean squared error';
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

if isa(e,'double')
  perf = sum(sum(e.^2)) / prod(size(e));
else
  perf = 0;
  elements = 0;
  for i=1:size(e,1)
    for j=1:size(e,2)
      perf = perf + sum(sum(e{i,j}.^2));
    elements = elements + prod(size(e{i,j}));
    end
  end
  perf = perf / elements;
end
