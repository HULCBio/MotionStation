function sys = uminus(sys)
%UMINUS  Unary minus for IDPOLY models.
%
%   MMOD = UMINUS(MOD) is invoked by MMOD = -MOD.
%
%   See also MINUS, PLUS.

 
%       Copyright 1986-2001 The MathWorks, Inc.
%       $Revision: 1.3 $  $Date: 2001/04/06 14:22:21 $

[a,b] = polydata(sys);
sys = pvset(sys,'b',-b);
% REVISIT Covariance matrix

