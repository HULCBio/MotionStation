function m2 = minreal(m,tol)
%IDSS/MINREAL  Minimal realization.
%
%   MMOD = MINREAL(MODEL) produces, for a given IDSS model MODEL, an
%   equivalent model MMOD where all uncontrollable or unobservable 
%   modes have been removed.
%
%   MSYS = MINREAL(SYS,TOL) further specifies the tolerance TOL
%   used for state dynamics elimination. 
%   The default value is TOL=SQRT(EPS) and increasing this tolerance
%   forces additional cancellations.
%  
%   MINREAL requires the Control Systems Toolbox.

%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.10 $  $Date: 2002/01/21 09:36:02 $

if nargin ==1
   tol = sqrt(eps);
end

m2=idss(minreal(ss(m),tol));
% [a,b,c,d,k,x0]=ssdata(m2);
% m2 = idss(a,b,c,d,k,x0);
% 
 m2 = inherit(m2,m);
