function d = dsse(code,e,x,perf,pp)
%DSSE Sum squared error performance derivative function.
%
%
%  Syntax
%
%    dPerf_dE = dsse('e',E,X,perf,PP)
%    dPerf_dX = dsse('x',E,X,perf,PP)
%
%  Description
%
%    DSSE is the derivative function for SSE.
%
%    DSSE('d',E,X,PERF,PP) takes these arguments,
%      E    - Matrix or cell array of error vector(s).
%      X    - Vector of all weight and bias values.
%      Perf - Network performance (ignored).
%      PP   - Performance parameters (ignored).
%    and returns the derivative dPerf/dE.
%
%    DSSE('x',E,X,PERF,PP) returns the derivative dPerf/dX.
%
%  Examples
%
%    Here we define an error E and X for a network with one
%    3-element output and six weight and bias values.
%
%      E = {[1; -2; 0.5]};
%      X = [0; 0.2; -2.2; 4.1; 0.1; -0.2];
%
%    Here we calculate the network's sum squared error
%    performance, and derivatives of performance.
%
%      perf = sse(E)
%      dPerf_dE = dsse('e',E,X)
%      dPerf_dX = dsse('x',E,X)
%
%    Note that SSE can be called with only one argument and
%    DSSE with only three arguments because the other arguments
%    are ignored.  The other arguments exist so that SSE and
%    DSSE conform to standard performance function argument lists.
%
%  See also SSE.

% Mark Beale, 11-31-97
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.9 $ $Date: 2002/04/14 21:30:50 $

doubleForm = 0;
if isa(e,'double'), e = {e}; doubleForm = 1; end

switch code
  case 'e'
   [rows,cols] = size(e);
   d = cell(rows,cols);
   for i=1:rows
      for j=1:cols
         d{i,j} = e{i,j} * 2;
      end
   end
   if doubleForm, d = d{1}; end
  case 'x'
    d = zeros(size(x));
  otherwise
    error(['Unrecognized code.'])
end
