function perf=sse(e,x,pp)
%SSE Sum squared error performance function.
%
%  Syntax
%
%    perf = sse(e,x,pp)
%    perf = sse(e,net,pp)
%    info = sse(code)
%
%  Description
%
%    SSE is a network performance function.  It measures
%    performance according to the sum of squared errors.
%  
%    SSE(E,X,PP) takes from one to three arguments,
%      E  - Matrix or cell array of error vector(s).
%      X  - Vector of all weight and bias values (ignored).
%      PP - Performance parameters (ignored).
%     and returns the sum squared error.
%
%    SSE(E,NET,PP) can take an alternate argument to X,
%      NET - Neural network from which X can be obtained (ignored).
%
%    SSE(CODE) returns useful information for each CODE string:
%      'deriv'     - Returns name of derivative function.
%      'name'      - Returns full name.
%      'pnames'    - Returns names of training parameters.
%      'pdefaults' - Returns default training parameters.
%  
%  Examples
%
%    Here a two layer feed-forward is created with a 1-element input
%    ranging from -10 to 10, four hidden TANSIG neurons, and one
%    PURELIN output neuron.
%
%      net = newff([-10 10],[4 1],{'tansig','purelin'});
%
%    Here the network is given a batch of inputs P.  The error
%    is calculated by subtracting the output A from target T.
%    Then the sum squared error is calculated.
%
%      p = [-10 -5 0 5 10];
%      t = [0 0 1 1 1];
%      y = sim(net,p)
%      e = t-y
%      perf = sse(e)
%
%    Note that SSE can be called with only one argument because
%    the other arguments are ignored.  SSE supports those arguments
%    to conform to the standard performance function argument list.
%
%  Network Use
%
%    To prepare a custom network to be trained with SSE set
%    NET.performFcn to 'sse'.  This will automatically set
%    NET.performParam to the empty matrix [], as SSE has no
%    performance parameters.
%
%    Calling TRAIN or ADAPT will result in SSE being used to calculate
%    performance.
%
%  See also DSSE.

% Mark Beale, 11-31-97
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.7 $

if nargin < 1, error('Not enough input arguments.'), end

% FUNCTION INFO
% =============

if isstr(e)
  switch e
    case 'deriv',
    perf = 'dsse';
    case 'name',
    perf = 'Sum squared error';
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
  perf = sum(sum(e.^2));
else
  perf = 0;
  for i=1:size(e,1)
    for j=1:size(e,2)
      perf = perf + sum(sum(e{i,j}.^2));
    end
  end
end
