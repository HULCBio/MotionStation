function d = dmsereg(code,e,x,perf,pp)
%DMSEREG Mean squared error w/reg performance derivative function.
%
%  Syntax
%
%    dPerf_dE = dmsereg('e',E,X,perf,PP)
%    dPerf_dX = dmsereg('x',E,X,perf,PP)
%
%  Description
%
%    DMSEREG is the derivative function for MSEREG.
%
%    DMSEREG('d',E,X,PERF,PP) takes these arguments,
%      E    - Matrix or cell array of error vector(s).
%      X    - Vector of all weight and bias values.
%      Perf - Network performance (ignored).
%      PP   - MSE performance parameters.
%    where PP defines one performance parameter,
%      PP.ratio - Relative importance of errors vs. weight and bias values.
%    and returns the derivative dPerf/dE.
%
%    DMSEREG('x',E,X,PERF) returns the derivative dPerf/dX.
%
%    MSE has only one performance parameter
%
%  Examples
%
%    Here we define an error E and X for a network with one
%    3-element output and six weight and bias values.
%
%      E = {[1; -2; 0.5]};
%      X = [0; 0.2; -2.2; 4.1; 0.1; -0.2];
%
%    Here the ratio performance parameter is defined so
%    that squared errors are 5 times as important as
%    squared weight and bias values.
%
%      pp.ratio = 5/(5+1);
%
%    Here we calculate the network's mean performance,
%    and derivatives of performance.
%
%      perf = msereg(E,X,pp)
%      dPerf_dE = dmsereg('e',E,X,perf,pp)
%      dPerf_dX = dmsereg('x',E,X,perf,pp)
%
%  See also MSEREG.

% Mark Beale, 11-31-97
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.10 $

if nargin < 5, error('Not enough input arguments.'),end

doubleForm = 0;
if isa(e,'double'), e = {e}; doubleForm = 1; end

switch code
  case 'e',
    numElements = prod(size(cell2mat(e)));
    [rows,cols] = size(e);
    d = cell(rows,cols);
  m = pp.ratio * 2/numElements;
  for i=1:rows
    for j=1:cols
      d{i,j} = e{i,j} * m;
    end
  end
  if doubleForm, d = cell2mat(d); end

  case 'x',
    m = 2*(1-pp.ratio)/length(x);
    d = -x * m;

  otherwise,
    error(['Unrecognized code.'])
end
