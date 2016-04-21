function yi = interp1(par1,par2,par3,par4,par5)
% Embedded MATLAB Library function.
%
% Limitations:
% 1) The only supported interpolation methods are 'linear' and 'nearest'.
% 2) Evenly spaced X indices will not be handled separately.
% 3) X must be strictly monotonically increasing or strictly monotinically 
%      decreasing; indices will not be reordered.

% $INCLUDE(DOC) toolbox/eml/lib/matlab/interp1.m $
%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/14 23:58:14 $

% input switchyard
switch (nargin)
    case 2
        yi = interp1_work(generate_x(par1,par2),par1,par2,'linear','fill',nan);
    case 3
        if ischar(par3)
            yi = interp1_work(generate_x(par1,par2),par1,par2,...
                destar_method(par3),'fill',nan);
        else
            yi = interp1_work(par1,par2,par3,'linear','fill',nan);
        end
    case 4
        if ischar(par3)
            % recursive call to handle method and type
            yi = interp1(generate_x(par1,par2),par1,par2,par3,par4);
        else
            yi = interp1_work(par1,par2,par3,destar_method(par4),'fill',nan);
        end
    case 5
        if ischar(par5)
          eml_assert(strcmp(par5,'extrap'),...
                            'Invalid extrapolation method.');
          yi = interp1_work(par1,par2,par3,destar_method(par4),par5,nan);
        else
          yi = interp1_work(par1,par2,par3,destar_method(par4),'fill',par5);
        end
    otherwise
        eml_assert(false,'Invalid number of input arguments');
end


function x = generate_x(y,xi)

if (size(y,1) == 1)
    if isa(y,'double')
        x = 1:length(y);
    else
        x = single(1:length(y));
    end
else
    if isa(y,'double')
        x = 1:size(y,1);
    else
        x = single(1:size(y,1));
    end
end


function method = destar_method(method_in)

if (method_in(1) == '*')
    method = method_in(2:end);
else
    method = method_in;
end


function yi_return = interp1_work(x,y_in,xi,method,extrap_type,extrap_val)

% make a vector y be a column vector
if (size(y_in,1) == 1)
    y = y_in.';
else
    y = y_in;
end

if isempty(xi)
    yi_return = ones(0,0,class(y));
    return
end

% initialize yi
if isreal(y)
    yi = zeros(size(xi,1)*size(xi,2),size(y,2),class(y));
else
    yi = zeros(size(xi,1)*size(xi,2),size(y,2),class(y)) + 0i;
end

%check x
eml_assert(isfloat(x) && isreal(x),...
           'The data abscissae should be real.');
if any(any(isnan(x)))
    yi_return = interp1_error(y,xi,...
        'NaN is not an appropriate value for X.');
    return
end
eml_assert((size(x,1) == 1 && size(x,2) >= 2) || ...
    (size(x,1) >= 2 && size(x,2) == 1),...
    'There should be at least two data points.');

%check y
eml_assert(isfloat(y),...
    'The table y must contain only numbers');
eml_assert(size(y,1) == length(x),...
    'Y must have length(X) rows.');

%check xi
eml_assert(isfloat(xi) && isreal(xi),...
   'The indices xi must contain only real numbers');

% we must ensure that x is strictly monotonically increasing at runtime
if x(2) > x(1)
    % confirm increasing
    for ii = 2:length(x)
        if x(ii) <= x(ii-1)
            yi_return = interp1_error(y,xi,...
                'The data abscissae should be distinct and strictly monotonic.');
            return
        end
    end
else
    % confirm decreasing
    for ii = 2:length(x)
        if x(ii) >= x(ii-1)
            yi_return = interp1_error(y,xi,...
                'The data abscissae should be distinct and strictly monotonic.');
            return
        end
    end
    % make it increasing
    x = x(length(x):-1:1);
    y = y(length(x):-1:1,:);
end

% main algorithm
switch(method)
    case 'nearest'
        for ii = 1:length(xi)
            if xi(ii) > x(end)
                yi(ii,:) = y(end,:);
            elseif xi(ii) < x(1)
                yi(ii,:) = y(1,:);
            else
                index = binary_search(x,xi(ii));

                if xi(ii) >= (x(index + 1) + x(index))/2
                    yi(ii,:) = y(index+1,:);
                else
                    yi(ii,:) = y(index,:);
                end
            end
        end

    case 'linear'
        for ii = 1:length(xi)
            if xi(ii) > x(end)
                % extrapolate past the top
                index = length(x) - 1;
            elseif xi(ii) < x(1)
                % extrapolate below the bottom
                index = 1;
            else
                index = binary_search(x,xi(ii));
            end
            yi(ii,:) = interpolate(x(index+1),x(index),...
                y(index+1,:),y(index,:),xi(ii));
        end
    otherwise
        eml_assert(false,'Invalid method.');
        return
end

% 'fill' out of bounds regions if required
if strcmp(extrap_type,'fill')
    for ii = 1:length(xi)
        if xi(ii) > x(end) || xi(ii) < x(1)
            yi(ii,:) = extrap_val * ones(1,size(yi,2));
        end
    end
end

% if xi is a row vector and y is a vector, we should output a row vector
if size(xi,1) == 1 && size(y,2) == 1
    yi_return = yi.';
else
    yi_return = yi;
end



function error_val = interp1_error(y,xi,error_message)

error(error_message);

if size(y,2) == 1
    allnans = makenans(zeros(size(xi,1),size(xi,2),class(y)));
else
    allnans = makenans(zeros(length(xi),size(y,2),class(y)));
end

if isreal(y)
    error_val = allnans;
else
    error_val = allnans + 0i;
end


function allnans = makenans(input)

allnans = input;

for ii = 1:size(input,1)
    for jj = 1:size(input,2)
        allnans(ii,jj) = nan;
    end
end


function yi = interpolate(xhi,xlo,yhi,ylo,xi)

yi = (xi - xlo) *((yhi - ylo)/(xhi - xlo)) + ylo;


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
