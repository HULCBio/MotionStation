function y = atanh(x)
% Embedded MATLAB Library function.
%
% Limitations:
% 1) Does not handle any scaling issues.

% $INCLUDE(DOC) toolbox/eml/lib/matlab/atanh.m $
%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2004/04/14 23:58:03 $
%
% Comments:
% Should use algorithm similar to utFdlibm_atanh in src\util\libm\fdlibm.cpp

% Error check nargin
eml_assert(nargin > 0, 'error', 'Not enough input arguments.');
eml_assert(isfloat(x), 'error', ['Function ''atanh'' is not defined for values of class ''' class(x) '''.']);

switch class(x)
case 'single'
    sd = single(1);
case 'double'
    sd = double(1);
end

if(isreal(x))
	% NOTE: Using formal definition which will
	%       likely have scaling problems.

	% See utFdlibm_atanh in src\util\libm\fdlibm.cpp
	% for a better algorithm
	
	% -1 < x < 1
	y = 0.5 .* eml_log((1 + x) / 1 - x);
else
	% Declare y
	base = sd*ones(size(x));
	y = complex(base, base);
	
	for i = 1 : length(x(:))
		y(i) = scalar_catanh(x(i),sd);
	end
end

function y = scalar_catanh(x,sd)

	theta = sd*(3.3e+153);  % sqrt(realmax)/4
	rho   = sd*(3.0e-154);  % 1/theta

	xr  = real(x);
	xi  = imag(x);
	sig = sd * qc(xr < 0.0, -1, 1);
	xr  = abs(xr);
	xi  = qc(sig < 0, xi, -xi);

	if (xr > theta) || (abs(xi) > theta)
		tmp = complex(1, 0) ./ complex(xr, xi);
		yr  = real(tmp);
		yi  = sd * qc(xi <= 0.0, -pi/2, pi/2);
	elseif (xr == 1.0) && (xi == 0.0)
		yr = sd*NaN;
		yi = sd*NaN;
	elseif xr == 1.0
		yr = eml_log(sqrt(sqrt(4 + xi * xi)) / sqrt(abs(xi) + rho));
		yi = pi/2 + atan((abs(xi) + rho) / 2);
		yi = qc(xi < 0.0, -yi, yi) / 2;
	else
		t = abs(xi) + rho;
		yr = log1p(4 * xr / ((1 - xr) * (1 - xr) + t * t)) / 4;
		yi = atan2(2 * xi, (1 - xr) * (1 + xr) - t * t) / 2;
	end
	yr = qc(sig < 0, -yr,  yr);
	yi = qc(sig < 0,  yi, -yi);
	y = complex(yr, yi);


% Scaling issues
function y = log1p(x)

y = eml_log(1 + x);

% Ternary ?: operator
function y = qc(exp1, exp2, exp3)

if exp1
	y = exp2;
else
	y = exp3;
end

% Predicates for Embedded MATLAB assertions
function bool = isfloat(x)
    bool = isa(x,'double') || isa(x,'single');
