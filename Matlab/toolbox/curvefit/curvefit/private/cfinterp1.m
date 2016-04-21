function v = cfinterp1(varargin)
%CFINTERP1 1-D interpolation (table lookup).
%   YI = CFINTERP1(X,Y,XI) interpolates to find YI, the values of
%   the underlying function Y at the points in the vector XI.
%   The vector X specifies the points at which the data Y is
%   given. If Y is a matrix, then the interpolation is performed
%   for each column of Y and YI will be length(XI)-by-size(Y,2).
%
%   YI = CFINTERP1(Y,XI) assumes X = 1:N, where N is the length(Y)
%   for vector Y or SIZE(Y,1) for matrix Y.
%
%   Interpolation is the same operation as "table lookup".  Described in
%   "table lookup" terms, the "table" is [X,Y] and CFINTERP1 "looks-up"
%   the elements of XI in X, and, based upon their location, returns
%   values YI interpolated within the elements of Y.
%
%   YI = CFINTERP1(X,Y,XI,'method') specifies alternate methods.
%   The default is linear interpolation.  Available methods are:
%
%     'nearest'  - nearest neighbor interpolation
%     'linear'   - linear interpolation
%     'spline'   - piecewise cubic spline interpolation (SPLINE)
%     'pchip'    - piecewise cubic Hermite interpolation (PCHIP)
%     'cubic'    - same as 'pchip'
%     'v5cubic'  - the cubic interpolation from MATLAB 5, which does not
%                  extrapolate and uses 'spline' if X is not equally spaced.
%
%   YI = CFINTERP1(Y,XI,'method') assumes X = 1:N, where N is the length(Y)
%   for vector Y or SIZE(Y,1) for matrix Y.
%
%   YI = CFINTERP1(X,Y,XI,'method','extrap') uses the specified method for
%   extrapolation for any elements of XI outside the interval spanned by X.
%   Alternatively, YI = CFINTERP1(X,Y,XI,'method',EXTRAPVAL) replaces
%   these values with EXTRAPVAL.  NaN and 0 are often used for EXTRAPVAL.
%   The default extrapolation behavior with four input arguments is 'extrap'
%   for 'spline' and 'pchip' and EXTRAPVAL = NaN for the other methods.
%
%   For example, generate a coarse sine curve and interpolate over a
%   finer abscissa:
%       x = 0:10; y = sin(x); xi = 0:.25:10;
%       yi = cfinterp1(x,y,xi); plot(x,y,'o',xi,yi)
%
%   CFINTERP1 also has a way to return the ppform of the interpolated
%   function. The calling syntax is:
%
%   F = CFINTERP1(X,Y,'method','pp'), the 'pp' is needed so that we can
%   distinguish it from YI = CFINTERP1(Y,XI,'method');
%
%   F = CFINTERP1(Y,'method'), when there is no X given, 'pp' is not needed,
%   X will be assumed to be 1:length(Y) 
%
%   F = CFINTERP1(Y), when no X and no method given, X will be assummed to
%   be 1:length(Y) and method will be 'linear'.
%
%   See also INTERP1Q, INTERPFT, SPLINE, INTERP2, INTERP3, INTERPN.

%   Copyright 2001-2004 The MathWorks, Inc.
%   $Revision: 1.10.2.2 $  $Date: 2004/02/01 21:43:17 $

% Determine input arguments.

if nargin == 1 || (nargin==2 && ischar(varargin{2})) || ...
        (nargin==4 && isequal(varargin{4},'pp'))
    if nargin == 1 || nargin == 2
        if nargin == 1
            method = 'linear';
        else
            method = varargin{2};
        end
        y = varargin{1};
        x = 1:length(y);
    else % nargin = 4
        x = varargin{1};
        y = varargin{2};
        method = varargin{3};
    end
    v = ppinterp(x,y,method);
    return;
end

ix = 1; % Is x given as the first argument?
if (nargin==2) || (nargin==3 && ischar(varargin{3})) || ...
        (nargin==4 && ~ischar(varargin{4}));
    ix = 0;
end

if nargin >= 3+ix && ~isempty(varargin{3+ix})
    method = varargin{3+ix};
else
    method = 'linear';
end
% Ignore '*' in v5 option, '*method'.
if method(1) == '*'
    method(1) = [];
end

if nargin >= 4+ix
    extrapval = varargin{4+ix};
else
    switch method(1)
    case {'s','p','c'}
        extrapval = 'extrap';
    otherwise
        extrapval = NaN;
    end
end

u = varargin{2+ix}; 
y = varargin{1+ix}; 


% Check dimensions.  Work with column vectors.

if size(y,1) == 1, y = y.'; end
[m,n] = size(y);
if ix 
    x = varargin{ix}; 
else 
    x = 1:m; 
end
if length(x) ~= m
    error('curvefit:cfinterp1:invalidNumOfRows', 'Y must have length(X) rows.')
end
if (m < 2)
    if isempty(u)
        v = [];
        return
    else
        error('curvefit:cfinterp1:notEnoughPoints', ...
              'There should be at least two data points.')
    end
end
if ~isreal(x)
    error('curvefit:cfinterp1:abscissaeNotReal', ...
          'The data abscissae should be real.')
end
if ~isreal(u)
    error('curvefit:cfinterp1:interpNotReal', ...
          'The interpolation points should be real.')
end
x = x(:);
h = diff(x);
if any(h < 0)
    [x,p] = sort(x);
    y = y(p,:);
    h = diff(x);
end
if any(h == 0)
    error('curvefit:cfinterp1:dataNotDistinct', ...
          'Interpolation methods require the x data to be distinct.');
end
siz = size(u);
u = u(:);
p = [];

% Interpolate

switch method(1)
    
case 's'  % 'spline'
    
    v = spline(x,y.',u.').';
    
case {'c','p'}  % 'cubic' or 'pchip'
    
    v = pchip(x,y.',u.').';
    
otherwise
    
    v = zeros(size(u,1),n*size(u,2));
    q = length(u);
    if any(diff(u) < 0)
        [u,p] = sort(u);
    else
        p = 1:q;
    end
    
    % Find indices of subintervals, x(k) <= u < x(k+1), 
    % or u < x(1) or u >= x(m-1).
    
    if isempty(u)
        k = u;
    else
        [ignore,k] = histc(u,x);
        k(u<x(1) | ~isfinite(u)) = 1;
        k(u>=x(m)) = m-1;
    end
    
    switch method(1)
        
    case 'n'  % 'nearest'
        
        i = find(u >= (x(k)+x(k+1))/2);
        k(i) = k(i)+1;
        v(p,:) = y(k,:);
        
    case 'l'  % 'linear'
        
        s = u - x(k);
        for j = 1:n
            del = diff(y(:,j))./h;
            v(p,j) = y(k,j) + s.*del(k);
        end
        
    case 'v'  % 'v5cubic'
        
        extrapval = NaN;
        if norm(diff(h),Inf) <= eps*norm(x,Inf)
            % Equally spaced
            s = (u - x(k))./h(k);
            s2 = s.*s;
            s3 = s.*s2;
            % Add extra points for first and last interval
            y = [3*y(1,:)-3*y(2,:)+y(3,:); y;
                3*y(m,:)-3*y(m-1,:)+y(m-2,:)];
            for j = 1:n
                v(p,j) = (y(k,j).*(-s3+2*s2-s) + y(k+1,j).*(3*s3-5*s2+2) ...
                    + y(k+2,j).*(-3*s3+4*s2+s) + y(k+3,j).*(s3-s2))/2;
            end
        else
            % Not equally spaced
            v = spline(x,y.',u(:).').';
        end
        
    otherwise
        
        error('curvefit:cfinterp1:invalidMethod', 'Invalid method.')
        
    end
end

% Override extrapolation?

if ~isequal(extrapval,'extrap')
    if isempty(p)
        p = 1:length(u);
    end
    k = find(u<min(x) | u>max(x));
    v(p(k),:) = extrapval;
end

% Reshape result.

if min(size(v))==1 && prod(siz)>1
    v = reshape(v,siz);
end
