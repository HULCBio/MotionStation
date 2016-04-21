function sys = uminus(sys)
%UMINUS  Unary minus for IDARX models.
%
%   MMOD = UMINUS(MOD) is invoked by MMOD = -MOD.
%
%   See also MINUS, PLUS.

 
%       Copyright 1986-2001 The MathWorks, Inc.
%       $Revision: 1.3 $  $Date: 2001/04/06 14:21:59 $

[a,b] = arxdata(sys);
sys = pvset(sys,'B',-b);
% REVISIT Covariance matrix

