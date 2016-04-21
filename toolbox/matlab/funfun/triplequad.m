function Q = triplequad(intfcn,xmin,xmax,ymin,ymax,zmin,zmax,tol,quadf,varargin)
%TRIPLEQUAD Numerically evaluate triple integral. 
%   TRIPLEQUAD(FUN,XMIN,XMAX,YMIN,YMAX,ZMIN,ZMAX) evaluates the triple
%   integral of FUN(X,Y,Z) over the three dimensional rectangular region
%   XMIN <= X <= XMAX, YMIN <= Y <= YMAX, ZMIN <= Z <= ZMAX.
%   FUN(X,Y,Z) should accept a vector X and scalar Y and Z and return a
%   vector of values of the integrand.
%
%   TRIPLEQUAD(FUN,XMIN,XMAX,YMIN,YMAX,ZMIN,ZMAX,TOL) uses a tolerance TOL
%   instead of the default, which is 1.e-6.
%
%   TRIPLEQUAD(FUN,XMIN,XMAX,YMIN,YMAX,ZMIN,ZMAX,TOL,@QUADL) uses quadrature
%   function QUADL instead of the default QUAD.  
%   TRIPLEQUAD(FUN,XMIN,XMAX,YMIN,YMAX,TOL,ZMIN,ZMAX,@MYQUADF) uses your own
%   quadrature function MYQUADF instead of QUAD.  MYQUADF should
%   have the same calling sequence as QUAD and QUADL.
%
%   TRIPLEQUAD(FUN,XMIN,XMAX,YMIN,YMAX,ZMIN,ZMAX,TOL,@QUADL,P1,P2,...) passes
%   the extra parameters to FUN(X,Y,P1,P2,...).
%   TRIPLEQUAD(FUN,XMIN,XMAX,YMIN,YMAX,ZMIN,ZMAX,[],[],P1,P2,...) is the same
%   as TRIPLEQUAD(FUN,XMIN,XMAX,YMIN,YMAX,ZMIN,ZMAX,1.e-6,@QUAD,P1,P2,...)
%
%   Example:
%       FUN can be an anonymous function or a function handle.
%
%         Q = triplequad(@(x,y,z) (y*sin(x)+z*cos(x)), 0, pi, 0, 1, -1, 1) 
%
%       or
%
%         Q = triplequad(@integrnd, 0, pi, 0, 1, -1, 1) 
%
%       where integrnd.m is an M-file:       
%           function f = integrnd(x, y, z)
%           f = y*sin(x)+z*cos(x);  
%
%       This integrates y*sin(x)+z*cos(x) over the region
%       0 <= x <= pi, 0 <= y <= 1, -1 <= z <= 1.  Note that the integrand 
%       can be evaluated with a vector x and scalars y and z.
%
%   Class support for inputs XMIN,XMAX,YMIN,YMAX,ZMIN,ZMAX and the output of FUN:
%      float: double, single
%
%   See also QUAD, QUADL, DBLQUAD, @.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.2.4.2 $  $Date: 2004/03/24 03:05:33 $

if nargin < 7 
  error('MATLAB:triplequad:NotEnoughInputs', 'Requires at least seven inputs');
end
if nargin < 8 || isempty(tol), tol = 1.e-6; end 
if nargin < 9 || isempty(quadf), quadf = @quad; end
intfcn = fcnchk(intfcn);

trace = [];
Q = dblquad(@innerintegral, ymin, ymax, zmin, zmax, tol, trace, intfcn, ...
           xmin, xmax, tol, quadf, varargin{:}); 

%---------------------------------------------------------------------------

function Q = innerintegral(y, z, intfcn, xmin, xmax, tol, quadf, varargin) 
%INNERINTEGRAL Used with TRIPLEQUAD to evaluate inner integral.
%
%   Q = INNERINTEGRAL(Y,Z,INTFCN,XMIN,XMAX,TOL,QUADF)

% Evaluate the innermost integral at each value of the outer variables. 

fcl = intfcn(xmin, y(1), z(1), varargin{:});
Q = zeros(size(y), superiorfloat(fcl, xmax, y, z, varargin{:}));
trace = [];
for i = 1:length(y) 
    Q(i) = feval(quadf, intfcn, xmin, xmax, tol, trace, y(i), z, varargin{:}); 
end 
