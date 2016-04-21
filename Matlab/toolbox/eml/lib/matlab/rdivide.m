function z = rdivide(x,y)
% Embedded MATLAB Library function.
%
% No known limitations.

% $INCLUDE(DOC) toolbox/eml/lib/matlab/rdivide.m $
%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2004/04/14 23:58:32 $

% Error check nargin
eml_assert(nargin > 1, 'error', 'Not enough input arguments.');
eml_assert(isfloat(x), 'error', ['Function ''rdivide'' is not defined for values of class ''' class(x) '''.']);
eml_assert(isfloat(y), 'error', ['Function ''rdivide'' is not defined for values of class ''' class(y) '''.']);

if(strcmp(class(x),'double') && strcmp(class(y),'double'))
    resultClass = 'double';
else
    resultClass = 'single';
end

if eml_all(isreal(x)) && eml_all(isreal(y))
    z = eml_rdivide(x,y);
else
    % Perform scalar expansion and force them both to be complex.    
    xtemp = x + zeros(size(y),resultClass) + 0i;
    ytemp = y + zeros(size(x),resultClass);    
    
    if(isreal(ytemp)) 
        xr = real(xtemp);
        xi = imag(xtemp);
        z = complex(eml_rdivide(xr,ytemp),eml_rdivide(xi,ytemp));
    else        
        z = complex(zeros(size(ytemp),resultClass),0);
        
        for k = 1 : length(ytemp(:))
            z(k) = scalar_cdiv(xtemp(k),ytemp(k));            
        end
    end
end 

function z = scalar_cdiv(x,y)
% Complex division. x and y are both expected to be complex scalars
ar = real(x);
ai = imag(x);
br = real(y);
bi = imag(y);

if (ai == 0) && (bi == 0),
    cr = ar / br;
    ci = zeros(1,1,class(x));
else
    if bi == 0,
        ci = ai / br;
        cr = ar / br;
    elseif br == 0,
        ci = -ar / bi;
        cr = ai / bi;
    elseif abs(br) > abs(bi),
        s = bi / br;
        d = br + s * bi;
        ci = (ai - s * ar) / d;
        cr = (ar + s * ai) / d;
    else
        s = br / bi;
        d = bi + s * br;
        ci = (s * ai - ar) / d;
        cr = (s * ar + ai) / d;
    end
end 
z = complex(cr,ci);    

function bool = isfloat(x)
    bool = isa(x,'double') || isa(x,'single');
