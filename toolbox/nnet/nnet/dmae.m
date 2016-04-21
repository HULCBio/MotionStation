function d = dmae(code,e,x,perf,pp)
%DMAE Mean absolute error performance derivative function.
%
%  Syntax
%
%    dPerf_dE = dmae('e',E,X,perf,PP)
%    dPerf_dX = dmae('x',E,X,perf,PP)
%
%  Description
%
%    DMAE is the derivative function for MAE.
%
%    DMAE('d',E,X,PERF,PP) takes these arguments,
%      E    - Matrix or cell array of error vector(s).
%      X    - Vector of all weight and bias values.
%      Perf - Network performance (ignored).
%      PP   - Performance parameters (ignored).
%    and returns the derivative dPerf/dE.
%
%    DMAE('x',E,X,PERF,PP) returns the derivative dPerf/dX.
%
%  Examples
%
%    Here we define E and X for a network with one
%    3-element output and six weight and bias values.
%
%      E = {[1; -2; 0.5]};
%      X = [0; 0.2; -2.2; 4.1; 0.1; -0.2];
%
%    Here we calculate the network's mean absolute error
%    performance, and derivatives of performance.
%
%      perf = mae(E)
%      dPerf_dE = dmae('e',E,X)
%      dPerf_dX = dmae('x',E,X)
%
%    Note that MAE can be called with only one argument and
%    DMAE with only three arguments because the other arguments
%    are ignored.  The other arguments exist so that MAE and
%    DMAE conform to standard performance function argument lists.
%
%  See also MAE.

% Mark Beale, 11-31-97
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.8 $

switch lower(code)
  case 'e',
    [rows,cols] = size(e);
    d = cell(rows,cols);
  for i=1:rows
    for j=1:cols
      d{i,j} = sign(e{i,j});
    end
  end

  case 'x',
    d = zeros(size(x));

  otherwise,
    error(['Unrecognized code.'])
end
