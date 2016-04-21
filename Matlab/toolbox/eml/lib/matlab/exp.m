function y = exp(x)
% Embedded MATLAB Library function.
% 
% Limitations:
% No known limitations.

% $INCLUDE(DOC) toolbox/eml/lib/matlab/exp.m $
%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/04/14 23:58:10 $
% Comments:
% Adapted from utComplexScalarExp in src\util\libm\cmath1.cpp

% Error check nargin
eml_assert(nargin > 0, 'error', 'Not enough input arguments.');
eml_assert(isfloat(x), 'error', ['Function ''exp'' is not defined for values of class ''' class(x) '''.']);

if isreal(x)
	y = eml_exp(x);
else
	y = complex(eml_exp(real(x)) .* eml_cos(imag(x)), ...
	            eml_exp(real(x)) .* eml_sin(imag(x)));
end;

function bool = isfloat(x)
    bool = isa(x,'double') || isa(x,'single');
