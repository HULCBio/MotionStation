function v=ppval(pp,xx)
%PPVAL  Evaluate piecewise polynomial.
%   V = PPVAL(PP,XX) returns the value, at the entries of XX, of the 
%   piecewise polynomial f contained in PP, as constructed by PCHIP, SPLINE,
%   or the spline utility MKPP.
%
%   V is obtained by replacing each entry of XX by the value of f there.
%   If f is scalar-valued, then V is of the same size as XX. 
%   If f is [D1,..,Dr]-valued, and XX has size [N1,...,Ns], then V has size
%   [D1,...,Dr, N1,...,Ns], with V(:,...,:, J1,...,Js) the value of f at 
%   XX(J1,...,Js), -- except that 
%   (1) N1 is ignored if it is 1 and s is 2, i.e., if XX is a row vector; and
%   (2) PPVAL ignores any trailing singleton dimensions of XX.
%
%   V = PPVAL(XX,PP) is also acceptable, and of use in conjunction with
%   FMINBND, FZERO, QUAD, and other function functions.
%
%   Example:
%   Compare the results of integrating the function cos and its spline
%   interpolant:
%
%     a = 0; b = 10;
%     int1 = quad(@cos,a,b,[],[]);
%     x = a:b; y = cos(x); pp = spline(x,y); 
%     int2 = quad(@ppval,a,b,[],[],pp);
%
%   int1 provides the integral of the cosine function over the interval [a,b]
%   while int2 provides the integral, over the same interval, of the piecewise
%   polynomial pp which approximates the cosine function by interpolating the
%   computed x,y values.
%
%   Class support for inputs pp, xx:
%      float: double, single
%
%   See also SPLINE, PCHIP, MKPP, UNMKPP, SPLINES (The Spline Toolbox).

%   Carl de Boor 7-2-86
%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 5.16.4.3 $  $Date: 2004/03/02 21:48:01 $

if isstruct(xx) % we assume that ppval(xx,pp) was used
   temp = xx; xx = pp; pp = temp;
end

%  obtain the row vector xs equivalent to XX
sizexx = size(xx); lx = numel(xx); xs = reshape(xx,1,lx);
%  if XX is row vector, suppress its first dimension
if length(sizexx)==2&&sizexx(1)==1, sizexx(1) = []; end

% if necessary, sort xs 
if any(diff(xs)<0), [xs,ix] = sort(xs); end

% take apart PP
[b,c,l,k,dd]=unmkpp(pp);

% for each data point, compute its breakpoint interval
[ignored,index] = sort([b(1:l) xs]);
index = max([find(index>l)-(1:lx);ones(1,lx)]);

% now go to local coordinates ...
xs = xs-b(index);

d = prod(dd);
if d>1 % ... replicate xs and index in case PP is vector-valued ...
   xs = reshape(xs(ones(d,1),:),1,d*lx);
   index = d*index; temp = (-d:-1).';
   index = reshape(1+index(ones(d,1),:)+temp(:,ones(1,lx)), d*lx, 1 );
else
   if length(sizexx)>1, dd = []; else dd = 1; end
end

% ... and apply nested multiplication:
   v = c(index,1);
   for i=2:k
      v = xs(:).*v + c(index,i);
   end

v = reshape(v,d,lx);
if exist('ix'), v(:,ix) = v; end
v = reshape(v,[dd,sizexx]);
