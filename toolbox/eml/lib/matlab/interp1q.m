function yi = interp1q(x,y,xi)
% Embedded MATLAB Library function.
%
% Limitations:
% 1) X must be strictly monotonically increasing or strictly monotinically 
%    decreasing; indices will not be reordered.

% $INCLUDE(DOC) toolbox/matlab/polyfun/interp1q.m $
% Copyright 2002-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $  $Date: 2004/04/14 23:58:15 $

eml_assert(nargin == 3,'Input argument xi is undefined');
eml_assert(isfloat(x) && isreal(x),...
           'The data abscissae should be real.');
eml_assert(isfloat(y),...
           'The table y must contain only numbers');
eml_assert(isfloat(xi) && isreal(xi),...
           'The indices xi must contain only real numbers');

if isempty(xi)
    yi = ones(0,0,class(y));
    return
end

% initialize yi
if isreal(y)
    yi = nan * ones(size(xi,1)*size(xi,2),size(y,2),class(y));
else
    yi = nan * ones(size(xi,1)*size(xi,2),size(y,2),class(y)) + 0i;
end


% main algorithm
for ii = 1:length(xi)
    if xi(ii) > x(end) ||  xi(ii) < x(1)
        % leave as nan
    else
        index = binary_search(x,xi(ii));
        yi(ii,:) = interpolate(x(index+1),x(index),...
            y(index+1,:),y(index,:),xi(ii));
    end
end


function yi = interpolate(xhi,xlo,yhi,ylo,xi)

yi = (xi - xlo) * ((yhi - ylo)/(xhi - xlo)) + ylo;


function index = binary_search(x,xi)

low_i = 1;
high_i = length(x);

while high_i - low_i > 1
    mid_i = floor((high_i + low_i) / 2);
    if xi >= x(mid_i)
        low_i = mid_i;
    else
        high_i = mid_i;
    end
end

index = low_i;

function bool = isfloat(x)
    bool = isa(x,'double') || isa(x,'single');
