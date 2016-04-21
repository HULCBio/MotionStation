function out = mod(x,y)
% Embedded MATLAB Library function.
%    
% Limitations:
% No known limitations.

% $INCLUDE(DOC) toolbox/eml/lib/matlab/mod.m $
%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2004/04/14 23:58:27 $

eml_assert(nargin > 1, 'error', 'Not enough input arguments.');
eml_assert(isreal(x), 'error', 'Arguments must be real.');
eml_assert(isreal(y), 'error', 'Arguments must be real.');
eml_assert(isfloat(x), 'error', ['Function ''mod'' is not defined for values of class ''' class(x) '''.']);
eml_assert(isfloat(y), 'error', ['Function ''mod'' is not defined for values of class ''' class(y) '''.']);


% Empty in = empty out
if(isempty(x) || isempty(y))
    out = zeros(0,class(x));
    return;
end

%-----------------------------------------------------------------
% If x is a matrix:
%       - size of output is the same as size of x
%       - size of y must be equal to size(x) or [1,1]
%           - if y is a scalar, resize it to match size(x)
%-----------------------------------------------------------------
if(size(x,1) > 1 || size(x,2) > 1)
    % If size(y) ~= size(x) and y is not a scalar
    if((size(y,1) ~= size(x,1) || size(y,2) ~= size(x,2)) && (size(y,1) > 1 || size(y,2) > 1))
        eml_assert(1==0, 'error', 'Matrix dimensions must agree.');
    end
    out = zeros(size(x), class(x));
    if(size(y,1) == 1 && size(y,2) == 1)
        new_y = y + zeros(size(x), class(x));           
    else
        new_y = y;
    end
    new_x = x;
end

%-----------------------------------------------------------------
% If x is a scalar:
%       - size of output is the same as the size of y
%       - resize x to match size(y)
%-----------------------------------------------------------------
if(size(x,1) == 1 && size(x,2) == 1)
    out = zeros(size(y),class(y));
    if(size(y,1) > 1 || size(y,2) > 1)
        new_x = x + zeros(size(y), class(y));
    else
        new_x = x;
    end
    new_y = y;
end

% Compute output
for i = 1:size(new_x,1)
    for j = 1:size(new_x,2)
        out(i,j) =scalar_mod(new_x(i,j), new_y(i,j));
    end
end


%--------------------------------------
% Invoke eML's built-in fmod 
%--------------------------------------
function out = scalar_mod(x,y)
    if (y == 0)
        out = x;
    else
        n = floor(x./y);
        out = x - n.*y;
    end
    
function bool = isfloat(x)
    bool = isa(x,'double') || isa(x,'single');

    
    