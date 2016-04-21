function y = acosh(x)
% Embedded MATLAB Library function.
%
% Limitations:
% 1) Does not handle any scaling issues.

% $INCLUDE(DOC) toolbox/eml/lib/matlab/acosh.m $
% Copyright 2002-2004 The MathWorks, Inc.
% $Revision: 1.1.6.3 $  $Date: 2004/04/01 16:07:03 $
%
% Comments:
% Should use algorithm similar to utFdlibm_acosh in src\util\libm\fdlibm.cpp

% Error check nargin
eml_assert(nargin > 0, 'error', 'Not enough input arguments.');
eml_assert(isfloat(x), 'error', ['Function ''acosh'' is not defined for values of class ''' class(x) '''.']);

if(isreal(x))
	% NOTE: Using formal definition which will
	%       likely have scaling problems.

	% See utFdlibm_acosh in src\util\libm\fdlibm.cpp
	% for a better algorithm

	% x >= 1
	y = eml_log(x + sqrt(x .* x - 1));
else
	% v = sqrt(x+1)
	% u = sqrt(x-1)
	% y = asinh(real(u'*v)) + 2*i*atan(imag(u)/real(v))

	v = sqrt(x + 1);
	u = sqrt(x - 1);
	y = asinh(real(conj(u) .* v)) + 2i .* atan(imag(u) ./ real(v));
end

function bool = isfloat(x)
    bool = isa(x,'double') || isa(x,'single');
