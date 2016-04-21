function perf=nullpf(e,x,pp)
%NULLPF Null performance function.
%
%  Syntax
%
%    perf = nullpf(e,x,pp)
%    perf = nullpf(e,net,pp)
%    info = nullpf(code)
%
%  Warning!!
%
%    This function may be altered or removed in future
%    releases of the Neural Network Toolbox. We recommend
%    you do not write code which calls this function.

% Mark Beale, 11-31-97
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.8 $

if nargin < 1, error('Not enough input arguments.'), end

% FUNCTION INFO
% =============

if isstr(e)
  switch e
    case 'deriv',
    perf = 'dnullpf';
    case 'name',
    perf = 'Null';
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

perf = NaN;
