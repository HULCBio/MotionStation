function y = log(x)
% Embedded MATLAB Library function.
%
% Limitations:
% No known limitations.

% $INCLUDE(DOC) toolbox/eml/lib/matlab/log.m $
% Copyright 2002-2004 The MathWorks, Inc.
% $Revision: 1.1.6.6 $  $Date: 2004/04/14 23:58:25 $
% Comments:
% -Need to add call to -inf

% Error check nargin
eml_assert(nargin > 0, 'error', 'Not enough input arguments.');
eml_assert(isfloat(x), 'error', ['Function ''log'' is not defined for values of class ''' class(x) '''.']);

if isempty(x),
    y = x;
    return
end

if isreal(x)
	y = vector_log(x);
else
	y = vector_clog(x);
end

function y = vector_log(x)

	% Declare y
	y = ones(size(x),class(x));

	for i = 1 : length(x(:))
		y(i) = scalar_log(x(i), class(x));
	end

function y = scalar_log(x,resultClass)
    y = x;
    switch resultClass
    case 'double'
        if isnan(x)
            y(:) = NaN;
        else
            y = eml_log(x);
        end
    case 'single'
        if isnan(x)
            y(:) = single(NaN);
        else
            y = single(eml_log(x));
        end
    end

function y = vector_clog(x)

	% Declare y
	base = ones(size(x),class(x));
	y    = complex(base, base);

	for i = 1 : length(x(:))
		y(i) = scalar_clog(x(i));
	end

function y = scalar_clog(x)

	% Adapted from utComplexScalarLog in src\util\libm\cmath1.cpp

	xr = real(x);
	xi = imag(x);

	r = abs(x);
	if r == 0 
        y = complex(real(x),imag(x));
        y(:) = complex(-inf, 0);
	else
		yr = eml_log(r);
		yi = atan2(xi, xr);
		y  = complex(yr, yi);
	end

    if(strcmp(class(x), 'single'))
        y = single(y);
    end

function bool = isfloat(x)
    bool = isa(x,'double') || isa(x,'single');

% [EOF]
