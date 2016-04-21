function obj = sethandles(libname,obj)
% SETHANDLES set up the function handle components of a library function.
% OBJ_OUT = SETHANDLES(FUNNAME, OBJ) set the fields of OBJ that
% contain function handles, and is normally done by LIBLOOKUP
% during object creation or after the object is loaded from a file.
%
% Note: .expr, .derexpr, .intexpr functions may assume X is a column vector.

% Syntax for functions that function handles point to:
% Function evalution, which is called via fittype/feval (with or 
% without optimization):
%   function [F,J] = eqn(coeff1,coeff2,...,probparam1,probparam2,...
%                probconstant1,probconstant2,...,X) 
%   (probparams and probconstants are optional. probconstants are
%   "inserted" into the call during fittype/feval method rather
%   than explicitly passed in.)
%
% Function evalution, which is called via fittype/feval (with or 
% separable optimization):
%   function [F,J,allcoeffs] = eqn(nonlinearcoeff1,nonlinearcoeff2, ...  
%     probparam1,probparam2,...Y,'separable',probconstant1,probconstant2,X) 
%   (probparams and probconstants are optional. 
%   Note: probconstants are "inserted" into the call during fittype/feval 
%   method rather than explicitly passed in.)
%
% Function start point calculation (called from FIT and 
% cftoolgui/private/getstartpoint):                 
%   function start = eqnstart(probparam1,probparam2,...,X,Y,probconstants)
%   (probparams and probconstants are optional.) 
%
% Function derivaties (called from cfit/derivative):
%   function [deriv1,deriv2]  = eqnder(coeff1,coeff2,...,probparam1,probparam2,...
%                probconstant1,probconstant2,...,X) 
%   (probparams and probconstants are optional)
%
% Function integration (called from cfit/integrate):
%   function int = eqnint(coeff1,coeff2,...,probparam1,probparam2,...
%                probconstant1,probconstant2,...,X) 
%   (probparams and probconstants are optional)

%   Copyright 2001-2004 The MathWorks, Inc.
%   $Revision: 1.26.2.4 $  $Date: 2004/03/02 21:46:15 $

switch libname(1:3)
case 'exp'
    n = str2num(libname(end));
    if n == 1
        obj.expr = @exp1;
        obj.derexpr = @exp1der;
        obj.intexpr = @exp1int;
        obj.startpt = @exp1start;
    else
        obj.expr = @exp2;
        obj.derexpr = @exp2der;
        obj.intexpr = @exp2int;
        obj.startpt = @exp2start;
    end
case 'pow'
    n = str2num(libname(end));
    if n == 1
        obj.expr = @power1;
        obj.derexpr = @power1der; 
        obj.intexpr = @power1int;
        obj.startpt = @power1start;
    else
        obj.expr = @power2;
        obj.derexpr = @power2der; 
        obj.intexpr = @power2int;
        obj.startpt = @power2start;
    end
case 'gau'
    obj.expr = @gaussn;
    obj.derexpr = @gaussnder;
    obj.intexpr = @gaussnint;
    obj.startpt = @gaussnstart;
case 'sin'
    obj.expr = @sinn;
    obj.derexpr = @sinnder;
    obj.intexpr = @sinnint;
    m = str2num(libname(end));
    if m == 1
      obj.startpt = @sinnstart;
    end
case 'rat'
    obj.expr = @ratn;
    obj.derexpr = @ratnder;
    m = str2num(libname(end));
    if m <= 2
        obj.intexpr = @ratnint;
    end
case 'wei'
    obj.expr = @weibull;
    obj.derexpr = @weibullder;
    obj.intexpr = @weibullint;
case 'fou'
    obj.expr = @fouriern;
    obj.derexpr = @fouriernder;
    obj.intexpr = @fouriernint;
    obj.startpt = @fouriernstart;
case 'pol'
    % Y = P(1)*X^N + P(2)*X^(N-1) + ... + P(N)*X + P(N+1)
    obj.expr = @polyn;
    obj.derexpr = @polynder;
    obj.intexpr = @polynint;
    obj.startpt = [];
case {'smo','cub','nea','spl','lin','pch'}
    obj.expr = @ppval;
    obj.derexpr = @ppder;
    obj.intexpr = @ppint;
otherwise
    error('curvefit:fittype:sethandles:LibNameNotFound', ...
          'Library name %s not found.',libname);
end

%---------------------------------------------------------
%  EXP1
%---------------------------------------------------------
function [f,J,p] = exp1(varargin)
% EXP1 library function a*exp(b*x).
% F = EXP1(A,B,X) returns function value F at A,B,X.
%
% [F,J] = exp1(A,B,X) returns function and Jacobian values, F and J,
% at A,B,X.
%
% [F,Jnonlinear] = exp1(B,Y,wts,'separable',X) is used with separable 
% least squares to compute F and "reduced" J (J with respect 
% to only the nonlinear coefficients).
%
% [F,J,p] = exp1(B,Y,wts,'separable',X) is the syntax when optimizing using 
% separable least squares to get all the coefficients p, linear and nonlinear,
% as well as F and the "full" Jacobian J with respect to all the coefficients.

separable = isequal(varargin{end-1},'separable');
if separable
    [b,y,wts,tmp,x] = deal(varargin{:});
    ws = warning('off', 'all');
    sqrtwts = sqrt(wts);
    a = sqrtwts.*(exp(b*x))\(sqrtwts.*y);
    warning(ws);
else
    [a,b,x] = deal(varargin{:});
end    
if (size(x,2) ~= 1)
    error('curvefit:fittype:sethandles:LastXMustBeColVector', ...
          'Last input x must be a column vector.');
end
f = a*exp(b*x);

if nargout > 1
    if separable & isequal(nargout,2)
        J = [f.*x];
    else % ~separable or (separable and nargout > 2)
        J = [exp(b*x) f.*x];
        if nargout > 2
            p = [a;b];            
        end
    end
end
%---------------------------------------------------------
function [deriv1,deriv2]  = exp1der(a,b,x)
% EXP1DER derivative function for EXP1 library function.
% DERIV1 = EXP1DER(A,B,X) returns the derivative DERIV1 with 
% respect to x at the points X.
%
% [DERIV1,DERIV2] = EXP1DER(A,B,X) also returns the second
% derivative DERIV2.

deriv1 = b*a*exp(b*x);    
deriv2 = b^2*a*exp(b*x);
%---------------------------------------------------------
function int = exp1int(a,b,x)
% EXP1INT integral function for EXP1 library function.
% INT = EXP1INT(A,B,X) returns the integral function with 
% respect to x at the points X.

if b==0
    int = a*x;
else
    int = a*exp(b*x)/b;
end
%---------------------------------------------------------
function start  = exp1start(x,y)
% EXP1START start point for EXP1 library function.
% START = EXP1START(X,Y) computes a start point START based on X.
% START is a column vector, e.g. [a0; b0].

% The idea in the starting point computation is to use geometric
% sequence. If the xdata is uniformly distributed, then the y data
% should form a geometric sequence. Using the summation formula for
% geometric sequence and the know y data, we can get an equation of the
% unknown parameter and solve them. In the case where x is not uniformly
% distributed, we use the given (x,y) data to generate uniformly
% distributed data, and start from there. The interpolation is done
% using the exponential function at the two ends.
%
% Reference: "Initial Values for the Exponential Sum Least Squares
% Fitting Problem"  by Joran Petersson and Kenneth Holmstrom
% http://www.ima.mdh.se/tom

x = x(:); y = y(:);
if any(diff(x)<0) % sort x
    [x,idx] = sort(x);
    y = y(idx);
end
n = length(x);
q = floor(n/2);
if q < 1 
    error('curvefit:fittype:ssethandles:twoDataPointsRequired', ...
          'EXP1 requires at least two data points.'); 
end

if any(diff(diff(x))>1/n^2) % non-uniform x so create uniform x1
    % since we are going to use x as bin boundaries, we will not need
    % repeated entries.
    idx = (diff(x) < eps^0.7);
    x(idx) = [];
    y(idx) = []; % ideally, we should take average of y's on identical x.
    n = length(x);
    if n < 2 % can't do anything, return rand;
      ws=rand('state');
      start = rand(2,1);
      rand('state',ws);
      return;
    end
    q = floor(n/2);
    sid = sign(y);
    x1 = (min(x):(max(x)-min(x))/(n-1):max(x))'; % n > 1, single data
                                                 % will not pass fit.
    x1(end) = x1(end) - eps(x1(end));
    [ignor,id]=histc(x1,x);
    id(id==n) = n-1;
    y = log(abs(y)+eps);
    b = (y(id+1)-y(id))./(x(id+1)-x(id));
    a = y(id)-b.*x(id);
    y = sid.*exp(a+b.*x1);
    x = x1;
end

S1 = sum(y(1:q));
% This should happen very very rarely. If it happens, i.e. S1 =
% 0, then, we reduce q by 1 and recompute S1. If q can't be
% reduced any more, it means we have many zeros in y, a natural
% starting point would be [0 0], thus we return that.
while (S1 == 0)
    q = q-1;
    if q < 1
        start = [0 0]; return;
    end
    S1 = sum(y(1:q));
end
S2 = sum(y(q+1:2*q));
b = log((S2/S1)^(1/q))/mean(diff(x)); % q > 0, x sorted.
a = sum(y)/sum(exp(b*x));
start = [a b];

%---------------------------------------------------------
%  EXP2
%---------------------------------------------------------
function [f,J,p] = exp2(varargin)
% EXP2 library function a*exp(b*x)+c*exp(d*x).
% F = EXP2(A,B,C,D,X) returns function value F at A,B,C,D,X.
%
% [F,J] = EXP2(A,B,C,D,X) returns function and Jacobian values, F and
% J, at A,B,C,D,X.
%
% [F,Jnonlinear] = exp2(B,D,Y,wts,'separable',X) is used with separable 
% least squares to compute F and "reduced" J (J with respect 
% to only the nonlinear coefficients).
%
% [F,J,p] = exp2(B,D,Y,wts,'separable',X) is the syntax when optimizing using 
% separable least squares to get all the coefficients p, linear and nonlinear,
% as well as F and the "full" Jacobian J with respect to all the coefficients.

separable = isequal(varargin{end-1},'separable');
if separable
    [b,d,y,wts,tmp,x] = deal(varargin{:});
    sqrtwts = sqrt(wts);
    D = repmat(sqrtwts,1,2);
    ws = warning('off', 'all');
    lincoeffs = D.*[exp(b*x) exp(d*x)]\(sqrtwts.*y);
    warning(ws);
    a = lincoeffs(1);
    c = lincoeffs(2);
else
    [a,b,c,d,x] = deal(varargin{:});
end    
if (size(x,2) ~= 1)
    error('curvefit:fittype:sethandles:LastXMustBeColVector', ...
          'Last input x must be a column vector.');
end
f = a*exp(b*x)+c*exp(d*x);
    
if nargout > 1
    if separable & isequal(nargout,2) % reduced J
        J = [a*exp(b*x).*x c*exp(d*x).*x];
    else % ~separable or (separable and nargout > 2)
        J = [exp(b*x) a*exp(b*x).*x exp(d*x) c*exp(d*x).*x];
        if nargout > 2
            p = [a; b; c; d];
        end
    end
end

%---------------------------------------------------------
function [deriv1,deriv2]  = exp2der(a,b,c,d,x)
% EXP2DER derivative function for EXP2 library function.
% DERIV1 = EXP2DER(A,B,X) returns the derivative DERIV1 with 
% respect to x at the points X.
%
% [DERIV1,DERIV2] = EXP2DER(A,B,X) also returns the second
% derivative DERIV2.

deriv1 = b*a*exp(b*x)+d*c*exp(d*x);   
deriv2 = b*b*a*exp(b*x)+d*d*c*exp(d*x);
%---------------------------------------------------------
function int = exp2int(a,b,c,d,x)
% EXP2INT integral function for EXP2 library function.
% INT = EXP2INT(A,B,C,D,X) returns the integral function with 
% respect to x at the points X.

if b == 0
    int1 = a*x;
else
    int1 = a*exp(b*x)/b;
end
if d == 0
    int2 = c*x;
else
    int2 = c*exp(d*x)/d;
end
int = int1+int2;
%---------------------------------------------------------
function start  = exp2start(x,y)
% EXP2START start point for EXP2 library function.
% START = EXP2START(X) computes a start point START based on X.
% START is a column vector, e.g. [a0; b0].

% The starting point computation use the same idea as in
% exp1start(). The difference here is that the resulting equation is a
% quadratic instead of linear equation. Also, since there are 4
% unknowns, we need to partition the data into 4 parts instead of 2
% parts. See exp1start() for reference.

x = x(:); y = y(:);
if any(diff(x)<0) % sort x
    [x,idx] = sort(x);
    y = y(idx);
end
n = length(x);
q = floor(n/4);

if q < 1
    error('curvefit:fittype:sethandles:fourDataPointsRequired', ...
          'EXP2 requires at least four data points.'); 
end

if any(diff(diff(x))>1/n^2) % non-uniform x so create uniform x1
    % since we are going to use x as bin boundaries, we will not need
    % repeated entries.
    idx = (diff(x) < eps^0.7);
    x(idx) = [];
    y(idx) = []; % ideally, we should take average of y's on identical x.
    n = length(x);
    if n < 2 % can't do anything, return rand;
      ws=rand('state');
      start = rand(2,1);
      rand('state',ws);
      return;
    end
    q = floor(n/4);
    sid = sign(y);
    x1 = (min(x):(max(x)-min(x))/(n-1):max(x))';
    x1(end) = x1(end) - eps(x1(end));
    [ignor,id]=histc(x1,x);
    id(id==n) = n-1;
    y = log(abs(y)+eps);
    b = (y(id+1)-y(id))./(x(id+1)-x(id)); % x unique, can't be 0
    a = y(id)-b.*x(id);
    y = sid.*exp(a+b.*x1);
    x = x1;
end

s = zeros(4,1);
for i=1:4
    s(i) = sum(y((i-1)*q+1:i*q));
end

tmp2 = 2*(s(2)^2-s(1)*s(3));
% This should happen very very rarely. If it happens, i.e. S1 =
% 0, then, we reduce q by 1 and recompute S1. If q can't be
% reduced any more, it means we have many zeros in y, a natural
% starting point would be [0 0], thus we return that.
while (tmp2 == 0)
    q = q-1;
    if q < 1
        start = [0 0 0 0]; return;
    end
    for i=1:4
        s(i) = sum(y((i-1)*q+1:i*q));
    end
    tmp2 = 2*(s(2)^2-s(1)*s(3));
end

tmp = sqrt((s(1)^2)*(s(4)^2)-6*prod(s)-3*(s(2)^2)*(s(3)^2)+...
    4*s(1)*s(3)^3+4*(s(2)^3)*s(4));
tmp1 = s(1)*s(4)-s(2)*s(3);
tmp2 = 2*(s(2)^2-s(1)*s(3));
z1 = (tmp-tmp1)/tmp2;    % tmp2 ~= 0
z2 = (tmp+tmp1)/tmp2;
mx = mean(diff(x));
s(2) = real(log((z1)^(1/q)))/mx; % x sorted, mx > 0
s(4) = real(log((z2)^(1/q)))/mx;
ws = warning('off', 'all');
s([1 3]) = [exp(s(2)*x) exp(s(4)*x)]\y;
warning(ws);
start = s;
%---------------------------------------------------------

%---------------------------------------------------------
%  POWER1
%---------------------------------------------------------
function [f, J, p] = power1(varargin)
% POWER1 library function a*x^b.
% F = POWER1(A,B,X) returns function value F at A,B,X.
%
% [F,J] = power1(A,B,X) returns function and Jacobian values, F and J, at A,B,X.
%
% [F,Jnonlinear] = power1(B,Y,wts,'separable',X) is used with separable 
% least squares to compute F and "reduced" J (J with respect 
% to only the nonlinear coefficients).
%
% [F,J,p] = power1(B,Y,wts,'separable',X) is the syntax when optimizing using 
% separable least squares to get all the coefficients p, linear and nonlinear,
% as well as F and the "full" Jacobian J with respect to all the coefficients.

separable = isequal(varargin{end-1},'separable');
if separable
    [b,y,wts,tmp,x] = deal(varargin{:});    
    sqrtwts = sqrt(wts);
else
    [a,b,x] = deal(varargin{:});
end    
if (size(x,2) ~= 1)
    error('curvefit:fittype:sethandles:LastXMustBeColVector', ...
          'Last input x must be a column vector.');
end
f = zeros(size(x));
iposx = (x > 0);
posx = x(iposx);
if any(~iposx)
    warning('curvefit:fittype:sethandles:xMustBePositive', ...
            ['Power functions require x to be positive. Non-positive ' ...
            'data are treated as NaN.']);
end
if separable
    % compute linear coefficients
    ws = warning('off', 'all');
    a = sqrtwts.*[x.^b]\(sqrtwts.*y);
    warning(ws);
end
f(iposx) = a*posx.^b;
f(~iposx) = NaN;

if nargout > 1
    if separable & isequal(nargout,2) % reduced J
        J = zeros(size(x,1),1);
        J(iposx,:) = [a*log(posx).*posx.^b];
        J(~iposx,:) = NaN;      
    else % ~separable or (separable and nargout > 2)
        J = zeros(size(x,1),2);
        J(iposx,:) = [posx.^b a*log(posx).*posx.^b];
        J(~iposx,:) = NaN;
        if nargout > 2
            p = [a; b];
        end
    end
end

%---------------------------------------------------------
function [deriv1,deriv2]  = power1der(a,b,x)
% POWER1DER derivative function for POWER1 library function.
% DERIV1 = POWER1DER(A,B,X) returns the derivative DERIV1 with 
% respect to x at the points X.
%
% [DERIV1,DERIV2] = POWER1DER(A,B,X) also returns the second
% derivative DERIV2.

idx = (x>0);
if any(~idx)
    warning('curvefit:fittype:sethandles:xMustBePositive', ...
            ['Power functions require x to be positive. Non-positive ' ...
            'data are treated as NaN.']);
end
xi = x(idx);

deriv1 = zeros(size(x));
deriv1(idx) = a*b*xi.^(b-1);
deriv1(~idx) = NaN;
deriv2 = zeros(size(x));
deriv2(idx) = a*b*(b-1)*xi.^(b-2);
deriv2(~idx) = NaN;

%---------------------------------------------------------
function int = power1int(a,b,x)
% POWER1INT integral function for POWER1 library function.
% INT = POWER1INT(A,B,X) returns the integral function with 
% respect to x at the points X.

idx = (x>0);
if any(~idx)
    warning('curvefit:fittype:sethandles:xMustBePositive', ...
            ['Power functions require x to be positive. Non-positive ' ...
            'data are treated as NaN.']);
end
xi = x(idx);

int = zeros(size(x));

if b==-1
    int(idx) = a*log(xi);
else
    int(idx) = a*xi.^(b+1)/(b+1);
end
int(~idx) = NaN;


%---------------------------------------------------------
function start  = power1start(x,y)
% POWER1START start point for POWER1 library function.
% START = POWER1START(X) computes a start point START based on X.
% START is a column vector, e.g. [a0; b0].

% the idea here is to assume every data point is exactly from a power
% function and compute the coefficient b at each point, then, compute
% the mean of these b's to get the global b. Use this b to compute a.
% The question is, whether we should use arithematic mean or geometric
% mean. For some data, arithemetic mean works well, for others,
% geometric means works well. We choose arithemetic mean.
%

x = x(:); y = y(:);
if any(diff(x)<0) % sort x
    [x,idx] = sort(x);
    y = y(idx);
end
idx = (x>0);
if any(~idx)
    warning('curvefit:fittype:sethandles:xMustBePositive', ...
            ['Power functions require x to be positive. Non-positive ' ...
            'data are treated as NaN.']);
    x = x(idx);
    y = y(idx);
    if length(x) == 0
        s= rand('state');
        start = rand(2,1);
        rand('state',s);
        return;
    end
end

[x,id]=sort(x);
y=y(id);

id = find(y>0);
if isempty(id)
    s= rand('state');
    start = rand(2,1);
    rand('state',s);
    return;
end

y = y(id);
x = x(id);
% to avoid divide by zero, we need to make sure x(2:end) > x(1)
% since x is sorted, we only need to make sure x(2) > x(1)
n = 1; v = y(1);
while x(2) == x(1)
  x(2) = [];
  v = v + y(2);
  y(2) = [];
  n = n+1;
  if length(x) == 1
    s= rand('state');
    start = rand(2,1);
    rand('state',s);
    return;
  end
end
y(1) = v/n; % average of the combined terms.

% after all these preparation, this is the real code. Assume all data are
% from a real power function, take the average (smooth out the noise) and
% compute the parameter. May be we should take geometrical mean(for the data
% I tried, arithemetic mean works better).
b = mean(log(y(2:end)/y(1))./log(x(2:end)/x(1)));
a = mean(y./x.^b);
start = [a;b];

%---------------------------------------------------------
%  POWER2
%---------------------------------------------------------
function [f, J, p] = power2(varargin)
% POWER2 library function c+a*x^b.
% F = POWER2(A,B,C,X) returns function value F at A,B,C,X.
%
% [F,J] = power2(A,B,C,X) returns function and Jacobian values, F and
% J, at A,B,C,X. 
%
% [F,Jnonlinear] = power2(B,Y,wts,'separable',X) is used with separable 
% least squares to compute F and "reduced" J (J with respect 
% to only the nonlinear coefficients).
%
% [F,J,p] = power2(B,Y,wts,'separable',X) is the syntax when optimizing using 
% separable least squares to get all the coefficients p, linear and nonlinear,
% as well as F and the "full" Jacobian J with respect to all the coefficients.

separable = isequal(varargin{end-1},'separable');

if separable
    [b,y,wts,tmp,x] = deal(varargin{:});
    sqrtwts = sqrt(wts);
else
    [a,b,c,x] = deal(varargin{:});
end    
if (size(x,2) ~= 1)
    error('curvefit:fittype:sethandles:LastXMustBeColVector', ...
          'Last input x must be a column vector.');
end
f = zeros(size(x));
iposx = (x > 0);
posx = x(iposx);
if any(~iposx)
    warning('curvefit:fittype:sethandles:xMustBePositive', ...
            ['Power functions require x to be positive. Non-positive ' ...
            'data are treated as NaN.']);
end
if separable
    % compute linear coefficients
    ws = warning('off', 'all');
    D = repmat(sqrtwts,1,2);
    lincoeffs = D.*[x.^b ones(size(x))]\(sqrtwts.*y);
    a = lincoeffs(1);
    c = lincoeffs(2);
    warning(ws);
end
f(iposx) = a*posx.^b + c;
f(~iposx) = NaN;
if nargout > 1
    if separable & isequal(nargout,2) % reduced J
        J = zeros(size(x,1),1);
        J(iposx,:) = [a*log(posx).*posx.^b];
        J(~iposx,:) = NaN;
    else  % ~separable or (separable and nargout > 2)
        J = zeros(size(x,1),3);
        J(iposx,:) = [posx.^b, a*log(posx).*posx.^b, ones(size(posx))];
        J(~iposx,:) = NaN;
        if nargout > 2
            p = [a; b; c];
        end
    end
end

%---------------------------------------------------------
function [deriv1,deriv2]  = power2der(a,b,c,x)
% POWER2DER derivative function for POWER2 library function.
% DERIV1 = POWER2DER(A,B,C,X) returns the derivative DERIV1 with 
% respect to x at the points X.
%
% [DERIV1,DERIV2] = POWER2DER(A,B,C,X) also returns the second
% derivative DERIV2.

idx = (x>0);
if any(~idx)
    warning('curvefit:fittype:sethandles:xMustBePositive', ...
            ['Power functions require x to be positive. Non-positive ' ...
            'data are treated as NaN.']);
end
xi = x(idx);

deriv1 = zeros(size(x));
deriv1(idx) = a*b*xi.^(b-1);
deriv1(~idx) = NaN;
deriv2 = zeros(size(x));
deriv2 = a*b*(b-1)*xi.^(b-2);
deriv2(~idx) = NaN;

%---------------------------------------------------------
%--------------------------------------------------------
function int = power2int(a,b,c,x)
% POWER2INT integral function for POWER2 library function.
% INT = POWER2INT(A,B,X) returns the integral function with 
% respect to x at the points X.

idx = (x>0);
if any(~idx)
    warning('curvefit:fittype:sethandles:xMustBePositive', ...
            ['Power functions require x to be positive. Non-positive ' ...
            'data are treated as NaN.']);
end
xi = x(idx);

int = zeros(size(x));
if b==-1
    int(idx) = a*log(xi)+c*xi;
else
    int(idx) = a*xi.^(b+1)/(b+1)+c*xi;
end
int(~idx) = NaN;

%---------------------------------------------------------
function start  = power2start(x,y)
% POWER2START start point for POWER2 library function.
% START = POWER2START(X) computes a start point START based on X.
% START is a column vector, e.g. [a0; b0;c0].

% the idea here is to assume every data point is exactly from a power
% function and compute the coefficient b at each point, then, compute
% the mean of these b's to get the global b. Use this b to compute a.
% The question is, whether we should use arithematic mean or geometric
% mean. For some data, arithemetic mean works well, for others,
% geometric means works well. We choose arithemetic mean.
%

x = x(:); y = y(:);
if any(diff(x)<0) % sort x
    [x,idx] = sort(x);
    y = y(idx);
end
idx = (x>0);
if any(~idx)
    x = x(idx);
    y = y(idx);
    warning('curvefit:fittype:sethandles:xMustBePositive', ...
            ['Power functions require x to be positive. Non-positive ' ...
            'data are treated as NaN.']);
    if length(x) == 0
        s= rand('state');
        start = rand(3,1);
        rand('state',s);
        return;
    end
end

[x,id]=sort(x);
y = y(id);

id = find(y>0);
if isempty(id)
    s= rand('state');
    start = rand(3,1);
    rand('state',s);
    return;
end

y = y(id);
x = x(id);

% to avoid divide by zero, we need to make sure x(2:end) > x(1)
% since x is sorted, we only need to make sure x(2) > x(1)
n = 1; v = y(1);
while x(2) == x(1)
  x(2) = [];
  v = v + y(2);
  y(2) = [];
  n = n+1;
  if length(x) == 1
    s= rand('state');
    start = rand(2,1);
    rand('state',s);
    return;
  end
end
y(1) = v/n; % average of the combined terms.

b = mean(log(y(2:end)/y(1))./log(x(2:end)/x(1)));
a = mean(y./x.^b);
c = mean(y - a*x.^b);
start = [a;b;c];

%---------------------------------------------------------
%  Weibull function
%---------------------------------------------------------
function [f,J] = weibull(a,b,x)
% WEIBULL library function a*b*x^(b-1)*exp(-a*x^b)
% F = WEIBULL(A,B,X) returns function value F at A,B,X.
%
% [F,J] = WEIBULL(A,B,X) returns function and Jacobian values, F and
% J, at A,B,X.

if (size(x,2) ~= 1)
    error('curvefit:fittype:sethandles:LastXMustBeColVector', ...
          'Last input x must be a column vector.');
end
idx = (x>0);
if any(~idx)
    warning('curvefit:fittype:sethandles:WeibullxMustBePositive', ...
            ['Weibull functions require x to be positive. Non-positive ' ...
            'data are treated as NaN.']);
end
xi = x(idx);
f = zeros(size(x));

f(idx) = a*b*xi.^(b-1).*exp(-a*xi.^b);
f(~idx) = NaN;
if nargout > 1
    J = zeros(size(x,1),2);
    if a == 0
        J(idx,:) = [b*xi.^(b-1) 0*xi];
    elseif b == 0
        J(idx,:) = [0*xi a*exp(-a)./xi];
    else
        J(idx,:) = [(1/a-xi.^b).*f(idx) (1/b+(1-a*xi.^b).*log(xi)).*f(idx)];
    end
    J(~idx,:) = NaN;
end

%---------------------------------------------------------
function [deriv1,deriv2]  = weibullder(a,b,x)
% WEIBULLDER derivative function for WEIBULL library function.
% DERIV1 = WEIBULLDER(A,B,X) returns the derivative DERIV1 with 
% respect to x at the points X.
%
% [DERIV1,DERIV2] = WEIBULLDER(A,B,X) also returns the second
% derivative DERIV2.

idx = (x>0);
if any(~idx)
    warning('curvefit:fittype:sethandles:WeibullxMustBePositive', ...
            ['Weibull functions require x to be positive. Non-positive ' ...
            'data are treated as NaN.']);
end
xi = x(idx);
deriv1 = zeros(size(x));
deriv2 = zeros(size(x));

f = a*b*xi.^(b-3).*exp(-a*xi.^b);
deriv1(idx) = f.*xi.*(b-1-a*b*xi.^b);
deriv2(idx) = f.*((b-1-a*b*xi.^b).^2-(b-1)-a*b*(b-1)*xi.^b);
deriv1(~idx) = NaN;
deriv2(~idx) = NaN;

%---------------------------------------------------------
function int = weibullint(a,b,x)
% WEIBULLINT integral function for WEIBULL library function.
% INT = WEIBULLINT(A,B,C,D,X) returns the integral function with 
% respect to x at the points X.

idx = (x>0);
if any(~idx)
    warning('curvefit:fittype:sethandles:WeibullxMustBePositive', ...
            ['Weibull functions require x to be positive. Non-positive ' ...
            'data are treated as NaN.']);
end
xi = x(idx);

int = zeros(size(x));
int(idx) = -exp(-a*xi.^b);
int(~idx) = NaN;

%---------------------------------------------------------

%---------------------------------------------------------
%  POLYN
%---------------------------------------------------------
function [f, J] = polyn(varargin)
% POLYN library function for P1*X^N + P2*X^(N-1) + ... + PN+1.
% F = POLYN(P1,P2,...,PN+1,X) returns function value F at 
% P1,P2,...,PN+1,X.
%
% [F,J] = POLYN(P1,P2,...,PN+1,X) returns function and Jacobian values, F and
% J, at P1,P2,...,PN+1,X.

if (nargin < 2)
    error('curvefit:fittype:sethandles:tooFewImports', 'Too few inputs.');
end
n = nargin - 1;
p = [varargin{1:end-1}];
x = varargin{end};
if (size(x,2) ~= 1)
    error('curvefit:fittype:sethandles:LastXMustBeColVector', ...
          'Last input x must be a column vector.');
end
f = cfpolyval(p,x);
if nargout > 1
    J = [zeros(length(x),n-1) ones(length(x),1)];
    % Horner's rule
    for i = n-1 : -1 : 1
        J(:,i) = x .* J(:,i+1);
    end
end
%---------------------------------------------------------
function [deriv1,deriv2] = polynder(varargin) 
% POLYNDER derivative function for POLYN library function.
% DERIV1 = POLYNDER(P1,P2,...PN+1,X) returns the derivative DERIV1 with 
% respect to X at the points X for an Nth degree polynomial. DERIV1
% is a vector the same length as X.
%
% [DERIV1,DERIV2] = POLYNDER(P1,P2,...PN+1,X) also returns the second
% derivative DERIV2, also a vector the length of X.

if (nargin < 3)
    error('curvefit:fittype:sethandles:tooFewImports', 'Too few inputs.');
end
n = nargin - 1;
p = [varargin{1:n}];
x = varargin{end};
if (size(x,2) ~= 1)
    error('curvefit:fittype:sethandles:LastXMustBeColVector', ...
          'Last input x must be a column vector.');
end

p = p(1:end-1).*((n-1):-1:1);
deriv1 = cfpolyval(p,x);
if nargout > 1
    if n < 3
        deriv2 = zeros(size(x));
    else 
        p = p(1:end-1).*((n-2):-1:1);;
        deriv2 = cfpolyval(p,x);
    end
end
%---------------------------------------------------------
function int = polynint(varargin)
% POLYNINT integral function for POLYN library function.
% INT = POLYNINT(P1,P2,...PN+1,X) returns the integral INT with 
% respect to X at the points X for an Nth degree polynomial. INT
% is a vector the same length as X.

if (nargin < 3)
    error('curvefit:fittype:sethandles:tooFewImports', 'Too few inputs.');
end
n = nargin - 1;
p = [varargin{1:n}];
x = varargin{end};
if (size(x,2) ~= 1)
    error('curvefit:fittype:sethandles:InputXMustBeColVector', ...
          'Input x must be a column vector.');
end

p = p./(n:-1:1);
int = cfpolyval([p 0],x);

%---------------------------------------------------------
%  FOURIERN
%---------------------------------------------------------
function [f, J, p] = fouriern(varargin)
% FOURIERN library function for fourier sequence:
% a0+sum(ai*cos(i*x*w)+bi*sin(i*x*w), i=1,...,n).
% F = FOURIERN(A0,A1,B1,...,AN,BN,W,N,X) returns function
% value F at (A0, A1, B1, ... ,AN, BN, W, N, X).
%
% [F,J] = FOURIERN(...,X) returns function and Jacobian values, F and
% J, at (...,X).
%
% [F,Jnonlinear] = fouriern(w,Y,wts,'separable',n,X) is used with
% separable least squares to compute F and "reduced" J (J with respect
% to only the nonlinear coefficients).
%
% [F,J,p] = fouriern(w,Y,wts,'separable',n,X) is the syntax when
% optimizing using separable least squares to get all the coefficients
% p, linear and nonlinear, as well as F and the "full" Jacobian J with
% respect to all the coefficients.

% Note: the problem constant "n" is added by fittype/feval and is not
% passed in directly when calling FOURIEN via feval.

separable = isequal(varargin{end-2},'separable');
if separable
  [w,y,wts,tmp,n,x] = deal(varargin{:});
  sqrtwts = sqrt(wts);
  extra = 5;  % extra is y, wts, 'separable', n, x
else
  x = varargin{end};
  n = varargin{end-1};
  w = varargin{end-2};
  extra = 2; % extra is n, x
end
if n < 1 | n > 9
  error('curvefit:fittype:sethandles:libFunctionNotFound', ...
        'Library function not found.');
end

if nargin ~= ~separable*(2*n+1) + 1 + extra 
  error('curvefit:fittype:sethandles:wrongNumArgs', 'Wrong number of arguments.');
end

if (size(x,2) ~= 1)
    error('curvefit:fittype:sethandles:LastXMustBeColVector', ...
          'Last input x must be a column vector.');
end

xw = x*w;
% get lincoeffs;
if separable
  A = zeros(length(x),2*n+1);
  A(:,1) = sqrtwts;
  for i=1:n
    ix = i*xw;
    A(:,2*i) = cos(ix).*sqrtwts;
    A(:,2*i+1) = sin(ix).*sqrtwts;
  end
  ws = warning('off', 'all');
  lincoeffs = A\(sqrtwts.*y);
  warning(ws);
  a0 = lincoeffs(1);
  a = lincoeffs(2:2:end)';
  b = lincoeffs(3:2:end)';
else
  a0 = varargin{1};
  a = [varargin{2:2:end-extra-1}];
  b = [varargin{3:2:end-extra-1}];
end

% compute the function value
f = a0;
for i = 1:n
    ix = i*xw;
    f = f + a(i)*cos(ix)+b(i)*sin(ix);
end

% get Jacobian.
if nargout > 1
  Jw = zeros(size(x));
  for i = 1:n
    ix = i*xw;
    Jw = Jw - i*x.*(a(i)*sin(ix) - b(i)*cos(ix));
  end
  if nargout < 3 & separable
    J = Jw;
  else
    J = zeros(length(x),2*n+2);
    J(:,1) = 1;
    J(:,end) = Jw;
    for i = 1:n
      ix = i*xw;
      J(:,2*i) = cos(ix);
      J(:,2*i+1) = sin(ix);
    end
    p = [a0; reshape([a; b],2*n,1); w];
  end
end

%---------------------------------------------------------
function [deriv1,deriv2] = fouriernder(varargin) 
% FOURIERNDER derivative function for FOURIERN library function.
% DERIV1 = FOURIERNDER(A0,A1,B1,...,AN,BN,W,N,X) returns the derivative
% DERIV1 with respect to X at the points X for FOURIERN. DERIV1 is a
% vector with the same length as X.
%
% [DERIV1,DERIV2] = FOURIERNDER(A0,A1,B1,...,AN,BN,W,N,X) also returns
% the second derivative DERIV2, also a vector with the length of X.

if (nargin < 6)
    error('curvefit:fittype:sethandles:tooFewImports', 'Too few inputs.');
end
n = varargin{end-1};
if nargin ~= 2*n+4
    error('curvefit:fittype:sethandles:wrongNumArgs', 'Wrong number of arguments.');
end

a0 = varargin{1};
a = [varargin{2:2:end-3}];
b = [varargin{3:2:end-3}];
w = varargin{end-2};
x = varargin{end};
if (size(x,2) ~= 1)
    error('curvefit:fittype:sethandles:LastXMustBeColVector', ...
          'Last input x must be a column vector.');
end

xw = x*w;

deriv1 = 0;
for i = 1:n
  ix = i*xw;
  deriv1 = deriv1 + i*w*(b(i)*cos(ix) - a(i)*sin(ix));
end

if nargout > 1
  deriv2 = 0;
  for i = 1:n
    ix = i*xw;
    deriv2 = deriv2 - i*i*w*w*(a(i)*cos(ix) + b(i)*sin(ix));
  end
end

%---------------------------------------------------------
function int = fouriernint(varargin)
% FOURIERNINT integral function for FOURIERN library function.
% INT = FOURIERNINT(A0,A1,B1,...,AN,BN,W,N,X) returns the integral INT with 
% respect to X at the points X FOURIERN. INT is a vector the same length as X.

if (nargin < 6)
    error('curvefit:fittype:sethandles:tooFewImports', 'Too few inputs.');
end
n = varargin{end-1};
if nargin ~= 2*n+4
    error('curvefit:fittype:sethandles:wrongNumArgs', 'Wrong number of arguments.');
end

a0 = varargin{1};
a = [varargin{2:2:end-3}];
b = [varargin{3:2:end-3}];
w = varargin{end-2};
x = varargin{end};
if (size(x,2) ~= 1)
    error('curvefit:fittype:sethandles:LastXMustBeColVector', ...
          'Last input x must be a column vector.');
end

int = a0*x;

xw = x*w;
for i = 1:n
    ix = i*xw;
    int = int + (a(i)*sin(ix) - b(i)*cos(ix))/(i*w);
end

%---------------------------------------------------------
function start  = fouriernstart(x,y,n)
% FOURIERSTART start point for FOURIER library function.
% START = FOURIERSTART(X,Y,N) computes a start point START based on X.
% START is a scalar w; (other parameters are treated linearly).

% The main idea in this computation is to compute the x range between
% the maximum and minimum of the y value. Double the range and
% divide by n, that will be used as the foundament frequency w.

yrange = max(y)-min(y);

m = length(y);
hm = floor(m/2);
[lymax,lmaxi] = max(y(1:hm));
if lmaxi == hm
  lmaxi = 1;
end

[rymax,rmaxi] = max(y(hm+1:end));
if rmaxi == 1
  rmaxi = m;
else
  rmaxi = rmaxi + hm;
end

start = zeros(2*n+2,1); % only the last element matters

if yrange == 0
  start(end) = pi/(max(x)-min(x));
else
  period = x(rmaxi)-x(lmaxi);
  % this loop makes sure that we don't get multiple of the period, we assume
  % that we started with less than 10 times of the period. 
  for alpha = 10:-1:2
    smallerperiod = period/alpha;
    newpos = x(lmaxi)+smallerperiod;
    [ignore,idx] = min(abs(newpos-x));
    if abs(y(idx)-rymax) < 0.1*yrange
      start(end) = 2*pi/smallerperiod;
      return;
    end
  end
  start(end) = 2*pi/period;
end


%---------------------------------------------------------
%  gaussn
%---------------------------------------------------------
function [f,J,p] = gaussn(varargin)
% GAUSSN library function for sum of gaussians: sum(ai*exp(-((x-bi)/ci)^2))
% F = gaussn(A1,B1,C1,...An,Bn,Cn,n,X) returns function value F at (...,X).
% 
% [F,J] = gaussn(...,X) returns function and Jacobian values, F and
% J, at (...,X)
%
% [F,Jnonlinear] = gaussn(b1,c1,...,bn,cn,Y,wts,'separable',n,X) is
% used with separable least squares to compute F and "reduced" J (J
% with respect to only the nonlinear coefficients).
%
% [F,J,p] = gaussn(b1,c1,...,bn,cn,Y,wts,'separable',n,X) is the
% syntax when optimizing using separable least squares to get all the
% coefficients p, linear and nonlinear, as well as F and the "full"
% Jacobian J with respect to all the coefficients.

% Note: the problem constant "n" is added by fittype/feval and is not
% passed in directly when calling GAUSSN via feval.

separable = isequal(varargin{end-2},'separable');
if separable
    extra = 5;  % extra is y, wts, 'separable', n, x
    y = varargin{end-4};
    wts = varargin{end-3};
    coeffcnt = 2; % bi, ci
else
    extra = 2; % extra is n, x
    coeffcnt = 3; % ai, bi, ci
end
n = varargin{end-1};
if n < 1 | n > 9
  error('curvefit:fittype:sethandles:libFunctionNotFound', ...
        'Library function not found.');
end

count = (nargin-extra)/coeffcnt; % subtract n, x
if nargin < extra + coeffcnt | count ~= n
  error('curvefit:fittype:sethandles:wrongNumArgs', 'Wrong number of arguments.');
end
x = varargin{end};
if (size(x,2) ~= 1)
    error('curvefit:fittype:sethandles:LastXMustBeColVector', ...
          'Last input x must be a column vector.');
end
if separable
    b = [varargin{1:2:end-extra}];
    c = [varargin{2:2:end-extra}];
    sqrtwts = sqrt(wts);
    A = zeros(length(x),n);
    for i=1:n
        if c(i) == 0
            A(:,i) = ones(length(x),1); % a's can be anything due to singularity
        else
            A(:,i) = exp(-((x-b(i))/c(i)).^2);
        end
    end
    ws = warning('off', 'all');
    D = repmat(sqrtwts,1,size(A,2));
    lincoeffs = (D.*A)\(sqrtwts.*y);
    warning(ws);
    a = lincoeffs';
else
    a = [varargin{1:3:end-extra}];
    b = [varargin{2:3:end-extra}];
    c = [varargin{3:3:end-extra}];
end

f = 0;
for i=1:n
    if c(i) == 0
        df = zeros(length(x),1);
    else
        df = a(i)*exp(-((x-b(i))/c(i)).^2);
    end
    f = f + df;
end

if nargout > 1
    if isequal(nargout,3) % only nonlinear coeff coming in, but want full J
        Jcoeffcnt = coeffcnt + 1;
    else % J wrt number of coefficients coming in
        Jcoeffcnt = coeffcnt;
    end
    J = zeros(length(x),Jcoeffcnt*n);
    for i = 1:n
        if c(i) ~= 0
            tf = exp(-((x-b(i))/c(i)).^2);
            start = i*Jcoeffcnt - Jcoeffcnt + 1;
            if separable & isequal(nargout,2) % reduced J
                J(:,start:start+Jcoeffcnt-1) = [2*a(i)*(x-b(i)).*tf/c(i)^2 2*a(i)*tf.*(x-b(i)).^2/c(i)^3];
            else % ~separable or (separable and nargout > 2)
                J(:,start:start+Jcoeffcnt-1) = [tf 2*a(i)*(x-b(i)).*tf/c(i)^2 2*a(i)*tf.*(x-b(i)).^2/c(i)^3];
            end
        end
    end
    if nargout > 2
        p = reshape([a; b; c],3*n,1);
    end
end

%---------------------------------------------------------
function [deriv1,deriv2]  = gaussnder(varargin)
% GAUSSNDER derivative function for GAUSSN library function.
% DERIV1 = GAUSSNDER(A1,B1,C1,...,N,X) returns the derivative DERIV1 with 
% respect to x at the points A1,B1,C1,...,X.
%
% [DERIV1,DERIV2] = GAUSSNDER(A1,B1,C1,...,N,X) also returns the second
% derivative DERIV2.

if nargin < 4 | rem(nargin,3) ~= 2
  error('curvefit:fittype:sethandles:wrongNumArgs', 'Wrong number of arguments.');
end

a = [varargin{1:3:end-2}];
b = [varargin{2:3:end-2}];
c = [varargin{3:3:end-2}];
n = varargin{end-1};
x = varargin{end};

deriv1 = 0;
for i = 1:n
    if c(i) ~= 0 % when c(i) = 0, the increment will be 0.
        deriv1 = deriv1 + 2*a(i)*exp(-((x-b(i))/c(i)).^2).*(b(i)-x)/c(i)^2;
    end
end

if nargout > 1
    deriv2 = 0;
    for i = 1:n
        if c(i) ~= 0 % when c(i) = 0, the increment will be 0.
            deriv2 = deriv2 + 2*a(i)*exp(-((x-b(i))/c(i)).^2).*...
                (2*(x-b(i)).^2/c(i)^2-1)/c(i)^2;
        end
    end
end

%---------------------------------------------------------
function int = gaussnint(varargin)
% GAUSSNINT integral function for GAUSSN library function.
% INT = GAUSSNINT(...,N,X) returns the integral function with 
% respect to x at the points X.

if nargin < 4 | rem(nargin,3) ~= 2
  error('curvefit:fittype:sethandles:wrongNumArgs', 'Wrong number of arguments.');
end

n = varargin{end-1};
a = [varargin{1:3:end-2}];
b = [varargin{2:3:end-2}];
c = [varargin{3:3:end-2}];
x = varargin{end};

int = 0;
for i = 1:n
    if c(i) ~= 0
        int = int + a(i)*c(i)*0.5*erf((x-b(i))/c(i));
    end
end
int = int*sqrt(pi);

%---------------------------------------------------------
function start  = gaussnstart(x,y,n)
% GAUSSNSTART start point for GAUSSN library function.
% START = GAUSSNSTART(X,Y,N) computes a start point START based on X.
% START is a column vector, e.g. [p1, p2, ... pn+1,q1,...,qm];

% The main idea in this computation is to compute one peak at a
% time. Assuming all data is coming from one gaussian model, find out
% the estimated correponding coefficients for this gaussian, use them as
% the coefficient for the first peak. Then, subtract this peak
% (evaluated at all x) from y data, repeat the procedure for the second
% peak. When we cannot continue for some reason (such as not enough
% significant data, we break, and assign random numbers for the rest of
% the starting point.

x = x(:); y = y(:);
if any(diff(x)<0) % sort x
    [x,idx] = sort(x);
    y = y(idx);
end
m = length(y);
p = []; q = []; r = [];
while length(p) < n
    m = length(y);
    k = max(find(y == max(y)));
    a = y(k);
    b = x(k);
    id = (y>0)&(y<a);
    if length(find(id)) == 0, break; end
    c = mean(abs(x(id)-b)./sqrt(log(a./y(id))))/(2*n-length(p)); 
    % 0<y(id)<a , length(p) < 2n, c > 0.
    y = y - a*exp(-((x-b)/c).^2);
    p = [p b];
    q = [q a];
    r = [r c];
end
if length(p) < n
    k = n-length(p);
    s = rand('state');
    p = [p rand(1,k)];
    q = [q rand(1,k)];
    r = [r rand(1,k)];
    rand('state',s);
end
start = zeros(3*n,1);
start(1:3:3*n) = q;
start(2:3:3*n) = p;
start(3:3:3*n) = r;

%---------------------------------------------------------
%---------------------------------------------------------
%  sinn
%---------------------------------------------------------
function [f,J,p] = sinn(varargin)
% SINN library function for sum of sins: sum(ai*sin(bi*x+ci))
% F = sinn(A1,B1,C1,...,An,Bn,Cn,n,X) returns function value F at (...,X).
% 
% [F,J] = sinn(...,n,X) returns function and Jacobian values, F and
% J, at (...,X)
%
% [F,Jnonlinear] = sinn(b1,c1,...,bn,cn,Y,wts,'separable',n,X) is used with separable 
% least squares to compute F and "reduced" J (J with respect 
% to only the nonlinear coefficients).
%
% [F,J,p] = sinn(b1,c1,...,bn,cn,Y,wts,'separable',n,X) is the syntax when optimizing using 
% separable least squares to get all the coefficients p, linear and nonlinear,
% as well as F and the "full" Jacobian J with respect to all the coefficients.

% Note: the problem constant "n" is added by fittype/feval and is not
% passed in directly when calling SINN via feval.

separable = isequal(varargin{end-2},'separable');
if separable
    extra = 5;  % extra is y, wts,'separable', n, x
    y = varargin{end-4};
    wts = varargin{end-3};
    coeffcnt = 2; % bi, ci
else
    extra = 2; % extra is n, x
    coeffcnt = 3; % ai, bi, ci
end
n = varargin{end-1};
if n < 1 | n > 9
  error('curvefit:fittype:sethandles:libFunctionNotFound', ...
        'Library function not found.');
end
count = (nargin-extra)/coeffcnt; % subtract n, x
if nargin < extra + coeffcnt | count ~= n
  error('curvefit:fittype:sethandles:wrongNumArgs', 'Wrong number of arguments.');
end
x = varargin{end};
if (size(x,2) ~= 1)
    error('curvefit:fittype:sethandles:LastXMustBeColVector', ...
          'Last input x must be a column vector.');
end
if separable
    b = [varargin{1:2:end-extra}];
    c = [varargin{2:2:end-extra}];
    sqrtwts = sqrt(wts);
    A = zeros(length(x),n);
    for i=1:n
        A(:,i) = sin(b(i)*x+c(i));
    end
    ws = warning('off', 'all');
    D = repmat(sqrtwts,1,size(A,2));
    lincoeffs = (D.*A)\(sqrtwts.*y);
    warning(ws);
    a = lincoeffs';
else
    a = [varargin{1:3:end-extra}];
    b = [varargin{2:3:end-extra}];
    c = [varargin{3:3:end-extra}];
end

f = 0;
for i=1:n
    f = f + a(i)*sin(b(i)*x+c(i));
end

if nargout > 1
    if isequal(nargout,3) % only nonlinear coeff coming in, but want full J
        Jcoeffcnt = coeffcnt + 1;
    else % J wrt number of coefficients coming in
        Jcoeffcnt = coeffcnt;
    end
    J = zeros(length(x),Jcoeffcnt*n);
    for i = 1:n
        xi = b(i)*x+c(i);
        start = i*Jcoeffcnt - Jcoeffcnt + 1;
        if separable & isequal(nargout,2) % reduced J
            J(:,start:start+Jcoeffcnt-1) = [a(i)*x.*cos(xi) a(i)*cos(xi)];
        else % ~separable or (separable and nargout > 2)
            J(:,start:start+Jcoeffcnt-1) = [sin(xi) a(i)*x.*cos(xi) a(i)*cos(xi)];
        end
    end
    if nargout > 2
        p = reshape([a; b; c],3*n,1);
    end
end

%---------------------------------------------------------
function [deriv1,deriv2]  = sinnder(varargin)
% SINNDER derivative function for SINN library function.
% DERIV1 = SINNDER(A1,B1,C1,...,N,X) returns the derivative DERIV1 with 
% respect to x at the points A1,B1,C1,...,X.
%
% [DERIV1,DERIV2] = SINNDER(A1,B1,C1,...N,,X) also returns the second
% derivative DERIV2.

if nargin < 4 | rem(nargin,3) ~= 2
  error('curvefit:fittype:sethandles:wrongNumArgs', 'Wrong number of arguments.');
end

n = varargin{end-1};
a = [varargin{1:3:end-2}];
b = [varargin{2:3:end-2}];
c = [varargin{3:3:end-2}];
x = varargin{end};

deriv1 = 0;
for i = 1:n
    deriv1 = deriv1 + a(i)*b(i)*cos(b(i)*x+c(i));
end

if nargout > 1
    deriv2 = 0;
    for i = 1:n
        deriv2 = deriv2 - a(i)*b(i)*b(i)*sin(b(i)*x+c(i));
    end
end

%---------------------------------------------------------
function int = sinnint(varargin)
% SINNINT integral function for SINN library function.
% INT = SINNINT(...,N,X) returns the integral function with 
% respect to x at the points X.

if nargin < 4 | rem(nargin,3) ~= 2
  error('curvefit:fittype:sethandles:wrongNumArgs', 'Wrong number of arguments.');
end

n = varargin{end-1};
a = [varargin{1:3:end-2}];
b = [varargin{2:3:end-2}];
c = [varargin{3:3:end-2}];
x = varargin{end};

int = 0;
for i = 1:n
    if b(i) ~= 0
        int = int - a(i)*cos(b(i)*x+c(i))/b(i);
    end
end

%---------------------------------------------------------
function start  = sinnstart(x,y,n)
% SINNSTART start point for SINN library function.
% START = SINNSTART(X,Y,N) computes a start point START based on X.
% START is a column vector, e.g. [p1, p2, ... pn+1,q1,...,qm];

%
% The idea of this algorithm is to figure out the span of one peak. We start
% from a maximum point (y value at maximum). Then we go down to left and
% right to find the turning point (i.e. when the start to go up again). We
% use these two turning points as the span of the peak and compute the period
% from the span. One tricky thing about finding the turning point is that the
% data may be noisy, thus, it may turn at any point. To avoid this effect
% from noise, we introduce the steplength. Steplength can be either 1,2 or 3
% depends on the data size. Basically, instead of comparing the two neighbor
% points, we compare the points that are steplength away, if this difference is
% turning, then, we think it is really turning (not just due to noise). Also,
% to determine if it is really turning, we also have to introduce a tolerence
% parameter which is depended on the magnitude of the y data. In other word,
% if the difference is too small for the data, then, it is not turning. 
  
x = x(:); y = y(:);
if any(diff(x)<0) % sort x
    [x,idx] = sort(x);
    y = y(idx);
end
% To avoid divide by zero, we will get rid of repeated x entries.
idx = (diff(x) < eps^0.7);
x(idx) = [];
y(idx) = []; % idealy, we should take average of y's on identical x.
k = length(x);
if k < 2 % can't do anything, return rand.
  ws=rand('state');
  start = rand(2,1);
  rand('state',ws);
  return;
end

% figure out the steplength. If data is too small, can't use a big steplength.
m = length(y);
if m < 5
  steplength = 1;
elseif m < 7
  steplength = 2;
else
  steplength = max(3,floor(m/10));
end
% tolerance is a tricky parameter to set. Can be adjusted. The current
% setting seems working for many examples.
tolerance = 0.01*steplength*(max(y)-min(y))/(max(x)-min(x)); 
start = [];
% the following code is designed for general n. The current sinn model only
% uses start computation for n=1. Thus, this while loop is not really needed.
while length(start) < 3*n
  % find out the difference between points that are steplength apart.
  diffs = y(1+steplength:end) - y(1:end-steplength);

  % locate the maximum point (absolute value maximum)
  [a, maxidx] = max(abs(y));
  maxsign = sign(y(maxidx));
  if a == 0, break; end % function is constant
  left = maxidx-steplength; 
  right = maxidx;

  % in case the maximu is at the boundary point, then, we only get to go down
  % in one direction. In this case, we only get half of the span, thus,
  % divider will be 1, for general cases, divider = 2;
  divider = 2;
  
  % determine left turning point
  if maxidx <= steplength
    left = 1;
    divider = 1;
  else
    % keep going down until turning. Since we start from the absolute value
    % maximum, it may be actually the minimum, in this case, we are actually
    % going up until turnning. maxsign is used to tell whether it is positive
    % or negative.
    while left > 0
      if ((maxsign > 0) & diffs(left) < -tolerance) | ...
         ((maxsign < 0) & diffs(left) > tolerance)
        break;
      end
      left = left - 1;
    end
    left = left+1;
  end
  
  % same procedure as the left branch.
  % determine right turning point
  if maxidx > m-steplength
    right = m;
    divider = 1;
  else
    while right <= m-steplength
      if ((maxsign > 0) & diffs(right) > tolerance) | ...
         ((maxsign < 0) & diffs(right) < -tolerance)
        break;
      end
      right = right + 1;
    end
    right = min(right+1,m);
  end
  span = abs(x(right)-x(left));
  
  % now that we have the span, we can determine the parameters.
  b = pi*divider/span;
  c = mod(maxsign*pi/2 - b*x(maxidx), 2*pi);
  start = [start; a; b; c];
  y = y - a*sin(b*x+c); % subtract the peak and go over again (for n > 1 case)
end

% again, for n==1, this check is not needed.
if length(start) < 3*n
    s = rand('state');
    start = [start; rand(3*n-length(start),1)];
    rand('state',s);
end


%---------------------------------------------------------
%  RATN
%---------------------------------------------------------
function [f,J,allcoeffs] = ratn(varargin)
% RATN library function for 
%     (P1*X^N + P2*X^(N-1) + ... + PN+1)/(X^M + Q1*X^(M-1) + ... + QM).
% F = RATN(P1,P2,...,PN+1,Q1,Q2,...,QM,N,M,X) returns function value F
% at P1,P2,...,PN+1,Q1,Q2,...,QM,X. N describe the order of the numerator.
%
% [F,J] = RATN(P1,P2,...,PN+1,Q1,Q2,...,QM,N,M,X) returns function and
% Jacobian values, F and J, at P1,P2,...,PN+1,Q1,Q2,...,QM+1,X,N,M.
%

% [F,Jnonlinear] = ratn(Q1,Q2,...,QM,Y,wts,'separable',N,M,X) is used with
% separable least squares to compute F and "reduced" J (J with respect to only
% the nonlinear coefficients).
%
% [F,J,p] = ratn(Q1,Q2,...,QM,Y,wts,'separable',N,M,X) is the syntax when
% optimizing using separable least squares to get all the coefficients p, linear
% and nonlinear, as well as F and the "full" Jacobian J with respect to all the
% coefficients.

% Note: we force the first coefficient of the denominator to
% be 1, otherwise, it will be an underdetermined system. It also forces
% the denominator to be at least first degree (can't be a constant).

separable = isequal(varargin{end-3},'separable');
x = varargin{end};
if (size(x,2) ~= 1)
    error('curvefit:fittype:sethandles:LastXMustBeColVector', ...
          'Last input x must be a column vector.');
end
lenx = length(x);
n = varargin{end-2};
m = varargin{end-1};
if separable
    extra = 6; % extra is y, wts, 'separable', n, m, x
else
    extra = 3; % extra is n, m, x
end    
if separable 
    if ( nargin ~= (m  + extra) )
        error('curvefit:fittype:sethandles:wrongNumArgs', 'Wrong number of arguments.');
    end
elseif nargin ~= (m + (n+1) + extra)
    error('curvefit:fittype:sethandles:wrongNumArgs', 'Wrong number of arguments.');
end

if separable
    wts = varargin{end-4};
    y = varargin{end-5};
    q = [1 varargin{1:m}];
    fq = cfpolyval(q,x);
    % compute linear coefficients
    A = zeros(lenx,n+1);
    for i=1:n+1
        A = [zeros(lenx,n) 1./fq]; 
        % Horner's rule
        for i = n : -1 : 1
            A(:,i) = x .* A(:,i+1);
        end
    end
    sqrtwts = sqrt(wts);
    ws = warning('off', 'all');
    D = repmat(sqrtwts,1,size(A,2));
    lincoeffs = (D.*A)\(sqrtwts.*y);
    warning(ws);
    p = lincoeffs';
else
    p = [varargin{1:n+1}];
    q = [1 varargin{n+2:n+1+m}];
end        

ws = warning('off', 'all');
fp = cfpolyval(p,x);
fq = cfpolyval(q,x);
f = fp./fq; 

if nargout > 1
    fdivfq = f./fq;
    if separable & isequal(nargout,2) % reduced J: only wrt q's
        J = [zeros(lenx,m-1) -fdivfq];
        for i = m-1 : -1 : 1
            J(:,i) = x .* J(:,i+1);
        end
    else % ~separable or (separable and nargout > 2)
        J1 = [zeros(lenx,n) 1./fq]; % J wrt p's
        % Horner's rule
        for i = n : -1 : 1
            J1(:,i) = x .* J1(:,i+1);
        end
        J2 = [zeros(lenx,m-1) -fdivfq]; % J wrt q's
        for i = m-1 : -1 : 1
            J2(:,i) = x .* J2(:,i+1);
        end
        J = [J1 J2];
        
        if nargout > 2
            qshort = q(2:end);
            allcoeffs = [p(:); qshort(:)]; % Leave off q(1) since it is fixed
        end
    end
end

warning(ws);

%---------------------------------------------------------
function [deriv1,deriv2] = ratnder(varargin) 
% RATNDER derivative function for RATN library function.
% DERIV1 = RATNDER(P1,P2,...PN+1,Q1,Q2,...,QM,N,M,X) returns the
% derivative DERIV1 with respect to X at the points X for the rational
% function. DERIV1 is a vector the same length as X.
%
% [DERIV1,DERIV2] = RATNDER(P1,P2,...PN+1,Q1,Q2,...,QM,N,M,X) also
% returns the second derivative DERIV2, also a vector the length of X.

if (nargin < 5)
    error('curvefit:fittype:sethandles:tooFewImports', 'Too few inputs.');
end
n = varargin{end-2};
m = varargin{end-1};
if nargin ~= m+n+4
    error('curvefit:fittype:sethandles:wrongNumArgs', 'Wrong number of arguments.');
end
p = [varargin{1:n+1}];
q = [1 varargin{n+2:n+1+m}];
x = varargin{end};
[mx,nx] = size(x);
if (nx ~= 1)
    error('curvefit:fittype:sethandles:LastXMustBeColVector', ...
          'Last input x must be a column vector.');
end
fn = cfpolyval(p,x);
fm = cfpolyval(q,x);
ws = warning('off', 'all');
lw = lastwarn;

p = p(1:end-1).*(n:-1:1);
q = q(1:end-1).*(m:-1:1);
pp = cfpolyval(p,x);
qp = cfpolyval(q,x);
deriv1 = pp./fm-fn.*qp./fm.^2;
if nargout > 1
    p = p(1:end-1).*((n-1):-1:1);
    q = q(1:end-1).*((m-1):-1:1);
    deriv2 = cfpolyval(p,x)./fm-cfpolyval(q,x).*fn./fm.^2 - ...
        2*deriv1.*qp./fm;
end
lastwarn(lw);
warning(ws);

%----------------------------------------------------------------------
function int = ratnint(varargin)
% RATNINT integral function for RATN library function.  
% INT = RATNINT(P1,P2,...PN+1,Q1,Q2,...,QM,N,M,X) returns the integral INT
% with respect to X at the points X for the corresponding rational
% function. INT is a vector the same length as X.

% Generally speaking, there's no closed form for the integral of a
% rational form if the denominator is of order 3 or higher. However, for
% linear and quadratic denominator, we can work out a closed form. We
% only get in here if m < 3;

if (nargin < 5)
    error('curvefit:fittype:sethandles:tooFewImports', 'Too few inputs.');
end
n = varargin{end-2};
m = varargin{end-1};
if nargin ~= m+n+4
  error('curvefit:fittype:sethandles:wrongNumArgs', 'Wrong number of arguments.');
end
p = [varargin{1:n+1}];
q = [varargin{n+2:n+1+m}];
x = varargin{end};
[mx,nx] = size(x);
if (nx ~= 1)
    error('curvefit:fittype:sethandles:LastXMustBeColVector', ...
          'Last input x must be a column vector.');
end

ws = warning('off', 'all');
lw = lastwarn;

int = 0;
if m == 1 % linear case
    % do long division first
    if n > 0
        for i = 2:n+1
            p(i) = p(i)-p(i-1)*q(1);
        end
        p(1:n) = p(1:n)./(n:-1:1);
        int = int + cfpolyval([p(1:n) 0],x);
    end
    int = int + p(n+1)*log(abs(x+q(1))).*sign(x>=-q(1));
elseif m == 2 % quadratic
    if n > 0
        if n > 1
            for i = 2:n
                p(i) = p(i)-p(i-1)*q(1);
                p(i+1) = p(i+1)-p(i-1)*q(2);
            end
            p(1:n-1) = p(1:n-1)./(n-1:-1:1);
            int = int + cfpolyval([p(1:n-1) 0],x);
        end
        if n > 0
            int = int + log(x.^2+q(1)*x+q(2))*p(n)/2;
            p(n+1) = p(n+1) - p(n)*q(1)/2;
        end
    end
    q(1)=q(1)/2;
    r = q(1)^2-q(2);
    if r == 0 % multiple root
        int = int - 1./(x+q(1));
    elseif r > 0  % two real solutions
        r = sqrt(r);
        r1 = -q(1)+r;
        r2 = -q(1)-r;
        int = int + log((x-r1)./(x-r2))*p(n+1)/(2*r);
    else % no singular point
        r = sqrt(-r);
        int = int + p(n+1)*atan((x+q(1))/r)/r;
    end
else
    error('curvefit:fittype:sethandles:noClosedFormIntegral', ...
          'No closed form integral.');
end

lastwarn(lw);
warning(ws);

%---------------------------------------------------------
%  PP (splines and interpolants)
%---------------------------------------------------------
% ppval is in toolbox/matlab/polyfun
%---------------------------------------------------------
function [deriv1,deriv2]  = ppder(p,x)
% PPDER derivative function for ppform functions.
% DERIV1 = PPDER(P,X) returns the derivative DERIV1 with 
% respect to x at the points X of the ppform P.
%
% [DERIV1,DERIV2] = PPDER(P,X) also returns the second
% derivative DERIV2.

coefs = p.coefs;
p.order = p.order-1; 
m = p.pieces;
% this will only work for single column y's.
coefs = coefs(:,1:end-1).*repmat(p.order:-1:1,m,1);
if (size(x,2) ~= 1)
    error('curvefit:fittype:sethandles:LastXMustBeColVector', ...
          'Last input x must be a column vector.');
end
if size(coefs,2) == 0
    deriv1 = zeros(size(x));
    deriv2 = zeros(size(x));
    return;
end
p.coefs = coefs;
deriv1 = ppval(p,x);
if nargout > 1
    if p.order > 1
        p.order = p.order-1;
        p.coefs = coefs(:,1:end-1).*repmat(p.order:-1:1, m,1);
        deriv2 = ppval(p,x);
    else
        deriv2 = zeros(size(x));
    end
end
%---------------------------------------------------------
function int = ppint(p,x)
% PPINT integral function for ppform functions.
% INT = PPINT(P,X) returns the integral with 
% respect to x at the points X of the ppform P.

coefs = p.coefs; breaks = p.breaks; m = p.pieces;
% this will only work for single column y's.
p.coefs = [coefs ./repmat(p.order:-1:1, m,1) zeros(m,1)];
p.order = p.order+1;

% This next line can be made more accurate but will be less efficient
breps = max(eps(breaks(1)),eps(breaks(end)));
yt = cumsum(ppval(p,breaks(2:end-1)-breps)); 
p.coefs(:,end) = [0 yt];
int = ppval(p,x);
%---------------------------------------------------------
