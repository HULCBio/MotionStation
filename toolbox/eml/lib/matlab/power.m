function y = power(x1, x2)
% Embedded MATLAB Library function.
% 
% Limitations:
% No known limitations.

% $INCLUDE(DOC) toolbox/eml/lib/matlab/power.m $
% Copyright 2002-2004 The MathWorks, Inc.
% $Revision: 1.1.6.5 $  $Date: 2004/04/14 23:58:30 $
% Comments:
% Adapted from utComplexScalarPower in src\util\libm\cmath1.cpp

% Error check nargin
eml_assert(nargin > 1, 'error', 'Not enough input arguments.');
eml_assert(isfloat(x1), 'error', ['Function ''power'' is not defined for values of class ''' class(x1) '''.']);
eml_assert(isfloat(x2), 'error', ['Function ''power'' is not defined for values of class ''' class(x2) '''.']);

if ~isscalar(x1) && ~isscalar(x2),
   eml_assert(all(size(x1) == size(x2)),'error','Matrix dimensions must agree.');
end

if isscalar(x1) && isempty(x2),
   y = x2;
   return;
end;

if isempty(x1) && isscalar(x2),
   y = x1;
   return;
end;

if(strcmp(class(x1),'double') && strcmp(class(x2),'double'))
    resultClass = 'double';
else
    resultClass = 'single';
end

% Handle scalar expansion
x1expand = x1 + zeros(size(x2),resultClass);
x2expand = x2 + zeros(size(x1),resultClass);

% Declare y
if isreal(x1expand) && isreal(x2expand)
	y = ones(size(x1expand),resultClass);
else
	base = ones(size(x1expand),resultClass);
	y    = complex(base, base);
end

for i = 1 : length(x1expand(:))
	y(i) = scalar_cpower(x1expand(i), x2expand(i), resultClass);
end

function y = scalar_cpower(x1, x2, resultClass)

	x1r = real(x1);
	x1i = imag(x1);
	x2r = real(x2);
	x2i = imag(x2);
	
	% real^real
	if isreal(x1) && isreal(x2)
		y = eml_pow(x1, x2);
	
	% real^real, because imaginary parts zero
	elseif (x1i == 0) && (x2i == 0)
		yr = eml_pow(x1r, x2r);
		yi = zeros(1,1,resultClass);
		y  = complex(yr, yi);
	
	% complex^integer
	elseif (x2i == 0.0) && (round(x2r) == x2r) && isfinite(x2r)
		t2 = x1;
        y = x1(1) + 0i; % Make y the same class as x1

        switch resultClass
        case 'double'
            y(:) = complex(1.0, 0.0);
        case 'single'
            y(:) = single(complex(1.0, 0.0));
        end
	
		ii = abs(x2r);
		while ii > 0
			if (eml_fmod(ii, 2.0) == 1.0) 
				y = t2 .* y;
			end;
			t2 = t2 .* t2;
			ii = fix(ii / 2.0);
		end;
	
		if x2r < 0.0
            t = y(1);

            switch resultClass
            case 'double'
                t(:) = complex(1.0, 0.0);
            case 'single'
                t(:) = single(complex(1.0, 0.0));
            end

			y = t ./ y;
		end;
	
	% complex^complex
	else

		t  = log(x1) + 0i;
		t  = x2 .* t;
		tr = real(t);
		ti = imag(t);
		tr = eml_exp(tr);
		yr = tr .* cos(ti);
		yi = tr .* sin(ti);
		y  = complex(yr, yi);
	end

function bool = isfloat(x)
    bool = isa(x,'double') || isa(x,'single');
