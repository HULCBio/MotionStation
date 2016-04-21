function y = asinh(x)
% Embedded MATLAB Library function.
%
% Limitations:
% 1) Does not handle any scaling issues.

% $INCLUDE(DOC) toolbox/eml/lib/matlab/asinh.m $
%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/14 23:58:01 $

% Error check nargin
eml_assert(nargin > 0, 'error', 'Not enough input arguments.');
eml_assert(isfloat(x), 'error', ['Function ''asinh'' is not defined for values of class ''' class(x) '''.']);

if(isreal(x))
	% NOTE: Using formal definition which will
	%       likely have scaling problems.

	% See utFdlibm_asinh in src\util\libm\fdlibm.cpp
	% for a better algorithm

	% -inf < x < inf
	y = eml_log(x + sqrt(x .* x + 1));
else
	% y = -i*asin(i*x)
	y = -1i * asin(1i * x);
end

function bool = isfloat(x)
    bool = isa(x,'double') || isa(x,'single');
