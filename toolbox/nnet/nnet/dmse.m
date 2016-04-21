function d = dmse(code,e,x,perf,pp)
%DMSE Mean squared error performance derivatives function.
%
%  Syntax
%
%    dPerf_dE = dmse('e',E,X,perf,PP)
%    dPerf_dX = dmse('x',E,X,perf,PP)
%
%  Description
%
%    DMSE is the derivative function for MSE.
%
%    DMSE('d',E,X,PERF,PP) takes these arguments,
%      E    - Matrix or cell array of error vector(s).
%      X    - Vector of all weight and bias values.
%      Perf - Network performance (ignored).
%      PP   - Performance parameters (ignored).
%    and returns the derivative dPerf/dE.
%
%    DMSE('x',E,X,PERF,PP) returns the derivative dPerf/dX.
%
%  Examples
%
%    Here we define E and X for a network with one
%    3-element output and six weight and bias values.
%
%      E = {[1; -2; 0.5]};
%      X = [0; 0.2; -2.2; 4.1; 0.1; -0.2];
%
%    Here we calculate the network's mean squared error
%    performance, and derivatives of performance.
%
%      perf = mse(E)
%      dPerf_dE = dmse('e',E,X)
%      dPerf_dX = dmse('x',E,X)
%
%    Note that MSE can be called with only one argument and
%    DMSE with only three arguments because the other arguments
%    are ignored.  The other arguments exist so that MSE and
%    DMSE conform to standard performance function argument lists.
%
%  See also MSE.

% Mark Beale, 11-31-97
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.8 $ $Date: 2002/04/14 21:37:38 $

if nargin < 3, error('Not enough input arguments.'),end

doubleForm = 0;
if isa(e,'double'), e = {e}; doubleForm = 1; end

switch lower(code)
case 'e',
   numElements = prod(size(cell2mat(e)));
   [rows,cols] = size(e);
   d = cell(rows,cols);
   m = 2/numElements;
   for i=1:rows
      for j=1:cols
         d{i,j} = e{i,j} * m;
      end
   end
   if doubleForm, d = cell2mat(d); end
   
case 'x',
   d = zeros(size(x));
   
otherwise,
   error(['Unrecognized code.'])
end
