function Q = dblquad(intfcn,xmin,xmax,ymin,ymax,tol,quadf,varargin) 
%DBLQUAD Numerically evaluate double integral. 
%   DBLQUAD(FUN,XMIN,XMAX,YMIN,YMAX) evaluates the double integral of
%   FUN(X,Y) over the rectangle XMIN <= X <= XMAX, YMIN <= Y <= YMAX.
%   FUN(X,Y) should accept a vector X and a scalar Y and return a
%   vector of values of the integrand.
%
%   DBLQUAD(FUN,XMIN,XMAX,YMIN,YMAX,TOL) uses a tolerance TOL
%   instead of the default, which is 1.e-6.
%
%   DBLQUAD(FUN,XMIN,XMAX,YMIN,YMAX,TOL,@QUADL) uses quadrature
%   function QUADL instead of the default QUAD.  
%   DBLQUAD(FUN,XMIN,XMAX,YMIN,YMAX,TOL,@MYQUADF) uses your own
%   quadrature function MYQUADF instead of QUAD.  MYQUADF should
%   have the same calling sequence as QUAD and QUADL.
%
%   DBLQUAD(FUN,XMIN,XMAX,YMIN,YMAX,TOL,@QUADL,P1,P2,...) passes
%   the extra parameters to FUN(X,Y,P1,P2,...).
%   DBLQUAD(FUN,XMIN,XMAX,YMIN,YMAX,[],[],P1,P2,...) is the same
%   as DBLQUAD(FUN,XMIN,XMAX,YMIN,YMAX,1.e-6,@QUAD,P1,P2,...)
%
%   Example:
%       FUN can be an anonymous function or a function handle.
%
%         Q = dblquad(@(x,y) (y*sin(x)+x*cos(y)), pi, 2*pi, 0, pi) 
%
%       or
%
%         Q = dblquad(@integrnd, pi, 2*pi, 0, pi) 
%
%       where integrnd.m is an M-file:       
%           function z = integrnd(x, y)
%           z = y*sin(x)+x*cos(y);  
%
%       This integrates y*sin(x)+x*cos(y) over the square
%       pi <= x <= 2*pi, 0 <= y <= pi.  Note that the integrand 
%       can be evaluated with a vector x and a scalar y .
%
%       Nonsquare regions can be handled by setting the integrand
%       to zero outside of the region.  The volume of a hemisphere is
%
%         dblquad(@(x,y) sqrt(max(1-(x.^2+y.^2),0)),-1,1,-1,1)
%
%       or
%
%         dblquad(@(x,y) sqrt(1-(x.^2+y.^2)).*(x.^2+y.^2<=1), -1,1,-1,1)
%
%   Class support for inputs XMIN,XMAX,YMIN,YMAX, and the output of FUN:
%      float: double, single
%
%   See also QUAD, QUADL, TRIPLEQUAD, @.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.15.4.2 $  $Date: 2004/03/24 03:05:29 $

if nargin < 5, error('MATLAB:dblquad:NotEnoughInputs',...
                     'Requires at least five inputs.'); end
if nargin < 6 || isempty(tol), tol = 1.e-6; end 
if nargin < 7 || isempty(quadf), quadf = @quad; end
intfcn = fcnchk(intfcn);

trace = [];

Q = feval(quadf, @innerintegral, ymin, ymax, tol, trace, intfcn, ...
           xmin, xmax, tol, quadf, varargin{:}); 

%---------------------------------------------------------------------------

function Q = innerintegral(y, intfcn, xmin, xmax, tol, quadf, varargin) 
%INNERINTEGRAL Used with DBLQUAD to evaluate inner integral.
%
%   Q = INNERINTEGRAL(Y,INTFCN,XMIN,XMAX,TOL,QUADF)
%   Y is the value(s) of the outer variable at which evaluation is
%   desired, passed directly by QUAD. INTFCN is the name of the
%   integrand function, passed indirectly from DBLQUAD. XMIN and XMAX
%   are the integration limits for the inner variable, passed indirectly
%   from DBLQUAD. TOL is passed to QUAD (QUADL) when evaluating the inner 
%   loop, passed indirectly from DBLQUAD. The function handle QUADF
%   determines what quadrature function is used, such as QUAD, QUADL
%   or some user-defined function.

% Evaluate the inner integral at each value of the outer variable. 

fcl = intfcn(xmin, y(1), varargin{:}); %evaluate only to get the class below
Q = zeros(size(y), superiorfloat(fcl, xmax, y)); 
trace = [];
for i = 1:length(y) 
    Q(i) = feval(quadf, intfcn, xmin, xmax, tol, trace, y(i), varargin{:}); 
end 
