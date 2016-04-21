function output = spline(x,y,xx)
%SPLINE Cubic spline data interpolation.
%   PP = SPLINE(X,Y) provides the piecewise polynomial form of the 
%   cubic spline interpolant to the data values Y at the data sites X,
%   for use with the evaluator PPVAL and the spline utility UNMKPP.
%   X must be a vector.
%   If Y is a vector, then Y(j) is taken as the value to be matched at X(j), 
%   hence Y must be of the same length as X  -- see below for an exception
%   to this.
%   If Y is a matrix or ND array, then Y(:,...,:,j) is taken as the value to
%   be matched at X(j),  hence the last dimension of Y must equal length(X) --
%   see below for an exception to this.
%
%   YY = SPLINE(X,Y,XX) is the same as  YY = PPVAL(SPLINE(X,Y),XX), thus
%   providing, in YY, the values of the interpolant at XX.  For information
%   regarding the size of YY see PPVAL.
%
%   Ordinarily, the not-a-knot end conditions are used. However, if Y contains
%   two more values than X has entries, then the first and last value in Y are
%   used as the endslopes for the cubic spline.  If Y is a vector, this
%   means:
%       f(X) = Y(2:end-1),  Df(min(X))=Y(1),    Df(max(X))=Y(end).
%   If Y is a matrix or N-D array with SIZE(Y,N) equal to LENGTH(X)+2, then
%   f(X(j)) matches the value Y(:,...,:,j+1) for j=1:LENGTH(X), then
%   Df(min(X)) matches Y(:,:,...:,1) and Df(max(X)) matches Y(:,:,...:,end).
%
%   Example:
%   This generates a sine-like spline curve and samples it over a finer mesh:
%       x = 0:10;  y = sin(x);
%       xx = 0:.25:10;
%       yy = spline(x,y,xx);
%       plot(x,y,'o',xx,yy)
%
%   Example:
%   This illustrates the use of clamped or complete spline interpolation where
%   end slopes are prescribed. In this example, zero slopes at the ends of an 
%   interpolant to the values of a certain distribution are enforced:
%      x = -4:4; y = [0 .15 1.12 2.36 2.36 1.46 .49 .06 0];
%      cs = spline(x,[0 y 0]);
%      xx = linspace(-4,4,101);
%      plot(x,y,'o',xx,ppval(cs,xx),'-');
%
%   Class support for inputs x, y, xx:
%      float: double, single
%
%   See also INTERP1, PPVAL, UNMKPP, MKPP, SPLINES (The Spline Toolbox).

%   Carl de Boor 7-2-86
%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 5.18.4.3 $  $Date: 2004/03/02 21:48:06 $

output=[];

% Check that data are acceptable and, if not, try to adjust them appropriately
[x,y,sizey,endslopes] = chckxy(x,y);
n = length(x); yd = prod(sizey);

% Generate the cubic spline interpolant in ppform

dd = ones(yd,1); dx = diff(x); divdif = diff(y,[],2)./dx(dd,:); 
if n==2
   if isempty(endslopes) % the interpolant is a straight line
      pp=mkpp(x,[divdif y(:,1)],sizey);
   else         % the interpolant is the cubic Hermite polynomial
      pp = pwch(x,y,endslopes,dx,divdif); pp.dim = sizey;
   end
elseif n==3&&isempty(endslopes) % the interpolant is a parabola
   y(:,2:3)=divdif;
   y(:,3)=diff(divdif')'/(x(3)-x(1));
   y(:,2)=y(:,2)-y(:,3)*dx(1); 
   pp = mkpp(x([1,3]),y(:,[3 2 1]),sizey);
else % set up the sparse, tridiagonal, linear system b = ?*c for the slopes
   b=zeros(yd,n);
   b(:,2:n-1)=3*(dx(dd,2:n-1).*divdif(:,1:n-2)+dx(dd,1:n-2).*divdif(:,2:n-1));
   if isempty(endslopes)
      x31=x(3)-x(1);xn=x(n)-x(n-2);
      b(:,1)=((dx(1)+2*x31)*dx(2)*divdif(:,1)+dx(1)^2*divdif(:,2))/x31;
      b(:,n)=...
      (dx(n-1)^2*divdif(:,n-2)+(2*xn+dx(n-1))*dx(n-2)*divdif(:,n-1))/xn;
   else
      x31 = 0; xn = 0; b(:,[1 n]) = dx(dd,[2 n-2]).*endslopes;
   end
   dxt = dx(:);
   c = spdiags([ [x31;dxt(1:n-2);0] ...
        [dxt(2);2*[dxt(2:n-1)+dxt(1:n-2)];dxt(n-2)] ...
        [0;dxt(2:n-1);xn] ],[-1 0 1],n,n);

   % sparse linear equation solution for the slopes
   mmdflag = spparms('autommd');
   spparms('autommd',0);
   s=b/c;
   spparms('autommd',mmdflag);

   % construct piecewise cubic Hermite interpolant
   % to values and computed slopes
   pp = pwch(x,y,s,dx,divdif); pp.dim = sizey;

end

if nargin==2, output = pp; else output = ppval(pp,xx); end
