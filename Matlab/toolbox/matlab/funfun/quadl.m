function [Q,fcnt] = quadl(funfcn,a,b,tol,trace,varargin)
%QUADL  Numerically evaluate integral, adaptive Lobatto quadrature.
%   Q = QUADL(FUN,A,B) tries to approximate the integral of function
%   FUN from A to B to within an error of 1.e-6 using high order
%   recursive adaptive quadrature.  The function Y = FUN(X) should
%   accept a vector argument X and return a vector result Y, the
%   integrand evaluated at each element of X.  
%
%   Q = QUADL(FUN,A,B,TOL) uses an absolute error tolerance of TOL 
%   instead of the default, which is 1.e-6.  Larger values of TOL
%   result in fewer function evaluations and faster computation,
%   but less accurate results.
%
%   [Q,FCNT] = QUADL(...) returns the number of function evaluations.
%
%   QUADL(FUN,A,B,TOL,TRACE) with non-zero TRACE shows the values
%   of [fcnt a b-a Q] during the recursion.
%
%   QUADL(FUN,A,B,TOL,TRACE,P1,P2,...) provides for additional 
%   arguments P1, P2, ... to be passed directly to function FUN,
%   FUN(X,P1,P2,...).  Pass empty matrices for TOL or TRACE to
%   use the default values.
%
%   Use array operators .*, ./ and .^ in the definition of FUN
%   so that it can be evaluated with a vector argument.
%
%   Function QUAD may be more efficient with low accuracies or
%   nonsmooth integrands.
%
%   Example:
%       FUN can be specified as:
%
%       An anonymous function:
%          F = @(x) (1./(x.^3-2*x-5));
%          Q = quadl(F,0,2);
%
%       A function handle:
%          Q = quadl(@myfun,0,2);
%          where myfun.m is an M-file:
%             function y = myfun(x)
%             y = 1./(x.^3-2*x-5);
%
%   Class support for inputs A, B, and the output of FUN:
%      float: double, single
%
%   See also QUAD, DBLQUAD, TRIPLEQUAD, @.

%   Based on "adaptlob" by Walter Gautschi.
%   Ref: W. Gander and W. Gautschi, "Adaptive Quadrature Revisited", 1998.
%   http://www.inf.ethz.ch/personal/gander
%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.8.4.3 $  $Date: 2004/03/24 03:05:31 $

f = fcnchk(funfcn);
if nargin < 4 || isempty(tol), tol = 1.e-6; end;
if nargin < 5 || isempty(trace), trace = 0; end;

% Initialize with 13 function evaluations.
c = (a + b)/2;
h = (b - a)/2;
s = [.942882415695480 sqrt(2/3) .641853342345781 1/sqrt(5) .236383199662150];
x = [a c-h*s c c+h*fliplr(s) b];
y = zeros(size(x), class(x));
y = feval(f,x,varargin{:}); y = y(:).';
fcnt = 13;

% Fudge endpoints to avoid infinities.
if ~isfinite(y(1))
   y(1) = feval(f,a+eps(superiorfloat(a,b))*(b-a),varargin{:});
   fcnt = fcnt+1;
end
if ~isfinite(y(13))
   y(13) = feval(f,b-eps(superiorfloat(a,b))*(b-a),varargin{:});
   fcnt = fcnt+1;
end

% Increase tolerance if refinement appears to be effective.
Q1 = (h/6)*[1 5 5 1]*y(1:4:13).';
Q2 = (h/1470)*[77 432 625 672 625 432 77]*y(1:2:13).';
s = [.0158271919734802 .094273840218850 .155071987336585 ...
     .188821573960182  .199773405226859 .224926465333340];
w = [s .242611071901408 fliplr(s)];
Q0 = h*w*y.';
r = abs(Q2-Q0)/abs(Q1-Q0+realmin);
if r > 0 & r < 1
   tol = tol/r;
end;

% Call the recursive core integrator.
hmin = eps(b-a)/1024;
[Q,fcnt,warn] = quadlstep(f,a,b,y(1),y(13),tol,trace,fcnt,hmin,varargin{:});

switch warn
   case 1
      warning('MATLAB:quadl:MinStepSize', ...
          'Minimum step size reached; singularity possible.')
   case 2
      warning('MATLAB:quadl:MaxFcnCount', ...
          'Maximum function count exceeded; singularity likely.')
   case 3
      warning('MATLAB:quadl:ImproperFcnValue', ...
          'Infinite or Not-a-Number function value encountered.')
   otherwise
      % No warning.
end

% ------------------------------------------------------------------------

function [Q,fcnt,warn] = quadlstep(f,a,b,fa,fb,tol,trace,fcnt,hmin,varargin)
%QUADLSTEP  Recursive core routine for function QUADL.

maxfcnt = 10000;

% Evaluate integrand five times in interior of subinterval [a,b].
c = (a + b)/2;
h = (b - a)/2;
if abs(h) < hmin || c == a || c == b
   % Minimum step size reached; singularity possible.
   Q = h*(fa+fb);
   warn = 1;
   return
end
alpha = sqrt(2/3);
beta = 1/sqrt(5);
x = [c-alpha*h c-beta*h c c+beta*h c+alpha*h];
y = feval(f,x,varargin{:});
fcnt = fcnt + 5;
if fcnt > maxfcnt
   % Maximum function count exceeded; singularity likely.
   Q = h*(fa+fb);
   warn = 2;
   return
end
x = [a x b];
y = [fa y(:).' fb];

% Four point Lobatto quadrature.
Q1 = (h/6)*[1 5 5 1]*y(1:2:7).';

% Seven point Kronrod refinement.
Q2 = (h/1470)*[77 432 625 672 625 432 77]*y.';

Q = Q2;
if ~isfinite(Q)
   % Infinite or Not-a-Number function value encountered.
   warn = 3;
   return
end
if trace
   disp(sprintf('%8.0f %16.10f %18.8e %16.10f',fcnt,a,h,Q))
end

% Check accuracy of integral over this subinterval.
if abs(Q1 - Q2) <= tol
   warn = 0;
   return

% Subdivide into six subintervals.
else
   Q = 0;
   warn = 0;
   for k = 1:6
      [Qk,fcnt,wk] = quadlstep(f,x(k),x(k+1),y(k),y(k+1), ...
                            tol,trace,fcnt,hmin,varargin{:});
      Q = Q + Qk;
      warn = max(warn,wk);
   end
end
