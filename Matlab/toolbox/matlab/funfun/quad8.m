function [Q,cnt] = quad8(varargin)
%QUAD8  Numerically evaluate integral, higher order method.
%
%   QUAD8 is obsolete.  We use QUADL instead.
%
%   Q = QUAD8(FUN,A,B) approximates the integral of function FUN from 
%   A to B to within a relative error of 1e-3 using an adaptive recursive
%   Newton-Cotes 8 panel rule.  FUN accepts a vector input X and returns a 
%   vector Y that is the function FUN evaluated at each element of X.  
%   Q = Inf is returned if an excessive recursion level is reached, 
%   indicating a possibly singular integral.
%
%   Q = QUAD8(FUN,A,B,TOL) integrates to a relative error of TOL.  Use
%   a two element tolerance, TOL = [rel_tol abs_tol], to specify a
%   combination of relative and absolute error.
%
%   Q = QUAD8(FUN,A,B,TOL,TRACE) integrates to a relative error of TOL and
%   for non-zero TRACE traces the function evaluations with a point plot
%   of the integrand.
%
%   Q = QUAD8(FUN,A,B,TOL,TRACE,P1,P2,...) provides for additional 
%   arguments P1, P2, ... to be passed directly to function FUN,
%   FUN(X,P1,P2,...). Pass empty matrices for TOL or TRACE to use 
%   the default values.
%
%   See also QUADL, QUAD, DBLQUAD, INLINE, @.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.23.4.2 $  $Date: 2004/04/16 22:06:52 $

% [Q,cnt] = quad8(F,a,b,tol) also returns a function evaluation count.

persistent obsolete
if isempty(obsolete)
   warning('MATLAB:quad8:ObsoleteFunction', ...
       'QUAD8 is obsolete.  We use QUADL instead.')
   obsolete = 1;
end

[Q,cnt] = quadl(varargin{:});
