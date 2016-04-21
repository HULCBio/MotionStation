function [Q,fcnt] = quadv(funfcn,a,b,tol,trace,varargin)
%QUADV  Vectorized QUAD.
%   Q = QUADV(FUN,A,B) approximates the integral of the complex
%   array-valued function FUN from A to B to within an error of
%   1.e-6 using recursive adaptive Simpson quadrature.
%   The function Y = FUN(X) should accept a scalar argument X
%   and return an array result Y, whose components are the integrands
%   evaluated at X.
%
%   Q = QUADV(FUN,A,B,TOL) uses the absolute error tolerance TOL for all
%   the integrals instead of the default, which is 1.e-6. 
%
%   Q = QUADV(FUN,A,B,TOL,TRACE) with non-zero TRACE shows the values
%   of [fcnt a b-a Q(1)] during the recursion.
%
%   Q = QUADV(FUN,A,B,TOL,TRACE,P1,P2,...) passes the additional arguments
%   P1, P2, ... directly to the integrand, FUN(X,P1,P2,...).
%   Use [] as a placeholder to obtain the default values of TOL and TRACE.
%
%   [Q,FCNT] = QUADV(...) returns the number of function evaluations.
%
%   The same tolerance is used for all components, so the results obtained
%   with QUADV are usually not the same as those obtained with QUAD on the
%   individual components.
%
%   Example:
%      F = @(x,n) (1./((1:n)+x));
%      Q = quadv(F,0,1,[],[],10);
%
%      The resulting array Q has elements Q(k) = log((k+1)./(k)).
%
%   Class support for inputs A, B, and the output of FUN:
%      float: double, single
%
%   See also QUAD, DBLQUAD, TRIPLEQUAD, @.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.3 $  $Date: 2004/03/24 03:05:32 $

f = fcnchk(funfcn);
if nargin < 4 || isempty(tol), tol = 1.e-6; end;
if nargin < 5 || isempty(trace), trace = 0; end;

% Initialize with three unequal subintervals.
h = 0.13579*(b-a);
x = [a a+h a+2*h (a+b)/2 b-2*h b-h b];
for j = 1:7
   y{j} = feval(f, x(j), varargin{:});
end
fcnt = 7;

% Fudge endpoints to avoid infinities.
if any(~isfinite(y{1}(:)))
   y{1} = feval(f,a+eps(superiorfloat(a,b))*(b-a),varargin{:});
   fcnt = fcnt+1;
end
if any(~isfinite(y{7}(:)))
   y{7} = feval(f,b-eps(superiorfloat(a,b))*(b-a),varargin{:});
   fcnt = fcnt+1;
end

% Call the recursive core integrator.
hmin = eps(b-a)/1024;
[Q1,fcnt,warn1] = ...
   quadstep(f,x(1),x(3),y{1},y{2},y{3},tol,trace,fcnt,hmin,varargin{:});
[Q2,fcnt,warn2] = ...
   quadstep(f,x(3),x(5),y{3},y{4},y{5},tol,trace,fcnt,hmin,varargin{:});
[Q3,fcnt,warn3] = ...
   quadstep(f,x(5),x(7),y{5},y{6},y{7},tol,trace,fcnt,hmin,varargin{:});
Q = Q1+Q2+Q3;
warn = max([warn1 warn2 warn3]);

switch warn
   case 1
      warning('MATLAB:quadv:MinStepSize', ...
          'Minimum step size reached; singularity possible.')
   case 2
      warning('MATLAB:quadv:MaxFcnCount', ...
          'Maximum function count exceeded; singularity likely.')
   case 3
      warning('MATLAB:quadv:ImproperFcnValue', ...
          'Infinite or Not-a-Number function value encountered.')
   otherwise
      % No warning.
end

% ------------------------------------------------------------------------

function [Q,fcnt,warn] = quadstep (f,a,b,fa,fc,fb,tol,trace,fcnt,hmin,varargin)
%QUADSTEP  Recursive core routine for function QUAD.

maxfcnt = 10000;

% Evaluate integrand twice in interior of subinterval [a,b].
h = b - a;
c = (a + b)/2;
if abs(h) < hmin || c == a || c == b
   % Minimum step size reached; singularity possible.
   Q = h*fc;
   warn = 1;
   return
end
d = (a + c)/2;
e = (c + b)/2;
fd = feval(f,d,varargin{:});
fe = feval(f,e,varargin{:});
fcnt = fcnt + 2;
if fcnt > maxfcnt
   % Maximum function count exceeded; singularity likely.
   Q = h*fc;
   warn = 2;
   return
end

% Three point Simpson's rule.
Q1 = (h/6)*(fa + 4*fc + fb);

% Five point double Simpson's rule.
Q2 = (h/12)*(fa + 4*fd + 2*fc + 4*fe + fb);

% One step of Romberg extrapolation.
Q = Q2 + (Q2 - Q1)/15;

if ~all(isfinite(Q))
   % Infinite or Not-a-Number function value encountered.
   warn = 3;
   return
end
if trace
   disp(sprintf('%8.0f %16.10f %18.8e %16.10f',fcnt,a,h,Q(1)))
end

% Check accuracy of integral over this subinterval.
if norm(Q2 - Q,Inf) <= tol
   warn = 0;
   return

% Subdivide into two subintervals.
else
   [Qac,fcnt,warnac] = quadstep(f,a,c,fa,fd,fc,tol,trace,fcnt,hmin,varargin{:});
   [Qcb,fcnt,warncb] = quadstep(f,c,b,fc,fe,fb,tol,trace,fcnt,hmin,varargin{:});
   Q = Qac + Qcb;
   warn = max(warnac,warncb);
end
