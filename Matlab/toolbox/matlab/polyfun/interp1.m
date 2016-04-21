function v = interp1(varargin)
%INTERP1 1-D interpolation (table lookup)
%   YI = INTERP1(X,Y,XI) interpolates to find YI, the values of
%   the underlying function Y at the points in the vector, or array XI. X
%   must be a vector of length N, and SIZE(Y,1) must be N.  If Y is an array
%   of size [N,M1,M2,...,Mk] then the interpolation is performed for 
%   each M1-by-M2-by-...-Mk value in Y.  If XI is an array of size
%   [D1,D2,...,Dj], then YI will be of size [D1,D2,...,Dj,M1,M2,...,Mk].  
%
%   YI = INTERP1(Y,XI) assumes X = 1:N, where N is LENGTH(Y)
%   for vector Y or SIZE(Y,1) for array Y.
%
%   Interpolation is the same operation as "table lookup".  Described in
%   "table lookup" terms, the "table" is [X,Y] and INTERP1 "looks-up"
%   the elements of XI in X, and, based upon their location, returns
%   values YI interpolated within the elements of Y.
%
%   YI = INTERP1(X,Y,XI,'method') specifies alternate methods.
%   The default is linear interpolation.  Available methods are:
%
%     'nearest'  - nearest neighbor interpolation
%     'linear'   - linear interpolation
%     'spline'   - piecewise cubic spline interpolation (SPLINE)
%     'pchip'    - shape-preserving piecewise cubic interpolation
%     'cubic'    - same as 'pchip'
%     'v5cubic'  - the cubic interpolation from MATLAB 5, which does not
%                  extrapolate and uses 'spline' if X is not equally spaced.
%
%   YI = INTERP1(X,Y,XI,'method','extrap') uses the specified method for
%   extrapolation for any elements of XI outside the interval spanned by X.
%   Alternatively, YI = INTERP1(X,Y,XI,'method',EXTRAPVAL) replaces
%   the values outside of the interval spanned by X with EXTRAPVAL.  
%   NaN and 0 are often used for EXTRAPVAL.  The default extrapolation 
%   behavior with four input arguments is 'extrap' for 'spline' and 'pchip' 
%   and EXTRAPVAL = NaN for the other methods.
%
%   PP = INTERP1(X,Y,'method','pp') will use the specified method to
%   generate the ppform (piecewise polynomial form) of Y. The method may be
%   any of the above except for 'v5cubic'.
%
%   For example, generate a coarse sine curve and interpolate over a
%   finer abscissa:
%       x = 0:10; y = sin(x); xi = 0:.25:10;
%       yi = interp1(x,y,xi); plot(x,y,'o',xi,yi)
%
%   For a multi-dimensional example, we construct a table of functional
%   values:
%       x = [1:10]'; y = [ x.^2, x.^3, x.^4 ]; 
%       xi = [ 1.5, 1.75; 7.5, 7.75]; yi = interp1(x,y,xi);
%
%   creates 2-by-2 matrices of interpolated function values, one matrix for
%   each of the 3 functions. yi will be of size 2-by-2-by-3.
%
%   Class support for inputs X, Y, XI: 
%      float: double, single
%  
%   See also INTERP1Q, INTERPFT, SPLINE, INTERP2, INTERP3, INTERPN.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 5.41.4.7 $  $Date: 2004/03/26 13:26:40 $
%   
% Determine input arguments.

ix = 1; % Is x given as the first argument?
if nargin==2 || (nargin==3 && ischar(varargin{3}))  || ...
      (nargin==4 && (~ischar(varargin{4}) || strcmp(varargin{4}, 'extrap')));
   ix = 0;
end

% add method for pp output
if nargin==4 && isequal('pp',varargin{4}) && ischar(varargin{3})
    % obtain pp form of output
    v = ppinterp(varargin{1:3});
    return
end

if nargin >= 3+ix && ~isempty(varargin{3+ix})
   method = varargin{3+ix};
else
   method = 'linear';
end
% The v5 option, '*method', asserts that x is equally spaced.
eqsp = (method(1) == '*');
if eqsp
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

% check for NaN's 
if ix
    if (any(isnan(reshape(varargin{ix},prod(size(varargin{ix})),1))))
        error('MATLAB:interp1:NaNinX','NaN is not an appropriate value for X.');
    end
end

u = varargin{2+ix}; 

% NANS are allowed as a value for F(X), since a function may be undefined
% for a given value. 
if any(isnan(reshape(varargin{ix+1},prod(size(varargin{ix+1})),1)))
    warning('MATLAB:interp1:NaNinY', ...
            ['NaN found in Y, interpolation at undefined values \n\t',...
            ' will result in undefined values.']);
end


y = varargin{1+ix}; 

% Check dimensions.  Work with column vectors.
      
if size(y,1) == 1, y = y.'; end
siz_y = size(y); % obtaining the size of y in a vector
m = siz_y(1);
n = prod(siz_y(2:end));
if ix
   x = varargin{ix};
   if length(x) ~= m
      error('MATLAB:interp1:YInvalidNumRows','Y must have length(X) rows.')
   end
   x = x(:);
   if ~eqsp
      h = diff(x);
      eqsp = (norm(diff(h),Inf) <= eps(norm(x,Inf)));
      if any(~isfinite(x))
          eqsp = 0; % if an INF in x, x is not equally spaced
      end
   end
   if eqsp
      h = (x(m)-x(1))/(m-1);
   end
else
   x = (1:m)';
   h = 1;
   eqsp = 1;
end
if (m < 2)
   if isempty(u)
      v = [];
      return
   else
      error('MATLAB:interp1:NotEnoughPts','There should be at least two data points.')
   end
end
if ~isreal(x)
   error('MATLAB:interp1:ComplexX','X should be a real vector.')
end
if ~isreal(u)
   error('MATLAB:interp1:ComplexInterpPts','The interpolation points should be real.')
end
if any(h < 0)
   [x,p] = sort(x);
   y = y(p,:); 
   if eqsp
      h = -h;
   else
      h = diff(x);
   end
end
if any(h == 0)
   error('MATLAB:interp1:RepeatedValuesX','The values of X should be distinct.');
end
siz = size(u);
u = u(:);
p = [];
      
% Interpolate

switch method(1)

   case 's'  % 'spline'
      
        if (length(siz_y)<3)
            y = y.';
         else
            y = reshape(y,[siz_y(2:end), siz_y(1)]);
        end
      v = reshape(spline(x,y,u),prod(siz_y(2:end)),prod(siz)).';
      
   case {'c','p'}  % 'cubic' or 'pchip'
      
         if (length(siz_y)<3)
            y = y.';
         else
            y = reshape(y,[siz_y(2:end), siz_y(1)]);
         end
      v = reshape(pchip(x,y,u),prod(siz_y(2:end)),prod(siz)).';
     
   otherwise
      
      v = zeros(size(u,1),n*size(u,2), superiorfloat(x,y,u));
      q = length(u);
      if ~eqsp && any(diff(u) < 0)
         [u,p] = sort(u);
      else
         p = 1:q;
      end

      % Find indices of subintervals, x(k) <= u < x(k+1), 
      % or u < x(1) or u >= x(m-1).

      if isempty(u)
         k = u;
      elseif eqsp
         k = min(max(1+floor((u-x(1))/h),1),m-1);
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
      
            if eqsp
               s = (u - x(k))/h;
            else
               s = (u - x(k))./h(k);
            end
            for j = 1:n
               v(p,j) = y(k,j) + s.*(y(k+1,j)-y(k,j));
            end

         case 'v'  % 'v5cubic'

            extrapval = NaN;
            if eqsp
               % Equally spaced
               s = (u - x(k))/h;
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
 
            error('MATLAB:interp1:InvalidMethod','Invalid method.')

      end
end

% Override extrapolation?

if ~isequal(extrapval,'extrap')
   if ischar(extrapval) 
       error('MATLAB:interp1:InvalidExtrap', 'Invalid extrap option.')
   elseif ~isscalar(extrapval)
       error('MATLAB:interp1:NonScalarExtrapValue',...
           'EXTRAP option must be a scalar.')
   end
   if isempty(p)
      p = 1:length(u);
   end
   k = find(u<x(1) | u>x(m));
   v(p(k),:) = extrapval;
end

% Reshape result.

v = reshape(v,[siz, siz_y(2:end)]);

% if the first two sizes are 1 reshape output for easier reading
% that includes empties of size 0x1 or 1x0
if ( (size(v,1)==1 || size(v,2)==1) && ndims(v)>2 ) 
    siz_v = size(v); % need to get the size again.
    sv = [siz_v(1), siz_v(2)];
    if siz_v(1)~=siz_v(2) 
      sv1= sv(sv~=1); 
    else 
      sv1 = 1;
    end         
    v = reshape(v,[sv1, siz_v(3:end)]);  
    % this is the special case for xi to be a vector or point
end




function F=ppinterp(x,y,method)
% PPINTERP ppform interpretation.
%
% X is a n by 1 column vector, Y is a n by m matrix. F will be a
% ppform of size m (one for each column of Y). METHOD can be one of
% the folowing:
%
%      nearest
%      linear
%      cubic
%      spline
%      pchip
%
%

%   Copyright 2001-2003 The MathWorks, Inc.
%   $Revision: 5.41.4.7 $  $Date: 2004/03/26 13:26:40 $


siz_y = size(y);
n = siz_y(1); m = prod(siz_y(2:end));
if n == 1
    n = m;
    m = 1;
    y = y';
end
if size(x,1) == 1
    x = x';
end
if size(x,1) ~= n
    error('MATLAB:interp1:ppinterp:XYLengthMismatch',...
          'X and Y must be of the same length.');
end
if (n < 2)
    error('MATLAB:interp1:ppinterp:NotEnoughDataPts',...
          'There should be at least two data points.')
end
if ~isreal(x) || ~isreal(y)
    error('MATLAB:interp1:ppinterp:ComplexInterpPts',...
          'The interpolation points should be real.')
end

if any(diff(x) < 0)
    [x,idx]=sort(x);
    y = y(idx,:);
end

if (any(diff(x)==0))
    error('MATLAB:interp1:ppinterp:RepeatedXData',...
          'Interpolation methods require the x data to be distinct.');
end

switch method(1)
case 'n' % nearest
    F=mkpp([x(1); (x(1:end-1)+x(2:end))/2; x(end)]',y', siz_y(2:end) );
case 'l' % linear
    F=mkpp(x',cat(3,(diff(y)./repmat(diff(x),1,size(y,2)))', y(1:end-1,:)'), siz_y(2:end) );
case {'p', 'c'} % pchip and cubic
    F=pchip(x',y');
case 's' % spline
    F=spline(x',y');
case 'v' % v5cubic
    b = diff(x);
    if norm(diff(b),Inf) <= eps(norm(x,Inf)) % equally space
        a = repmat(b,m)';
        y = [3*y(1,:)-3*y(2,:)+y(3,:);y;3*y(n,:)-3*y(n-1,:)+y(n-2,:)];
        y1 = y(1:end-3,:)'; y2 = y(2:end-2,:)'; 
        y3 = y(3:end-1,:)'; y4 = y(4:end,:)';
        coefs = cat(3,(-y1+3*y2-3*y3+y4)./(2*a.^3), (2*y1-5*y2+4*y3-y4)./(2*a.^2), (-y1+y3)./(2*a), y2);
        F=mkpp(x',coefs, siz_y(2:end));
    else
        F = spline(x',y');
    end
otherwise
    error('MATLAB:interp1:ppinterp:UnknownMethod','Unrecognized method.');
end



