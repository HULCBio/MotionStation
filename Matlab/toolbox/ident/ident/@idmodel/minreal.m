function m = minreal(m,tol)
%IDMODEL/MINREAL  Minimal realization.
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
%   $Revision: 1.7 $  $Date: 2001/04/06 14:22:10 $

if nargin ==1
   tol = sqrt(eps);
end

if ~isa(m,'idss')
  disp('NOTE: Model changed to IDSS object.')
end

m = idss(m);
m = minreal(m,tol);
