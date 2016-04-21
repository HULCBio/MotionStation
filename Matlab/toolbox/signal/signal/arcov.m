function [a,e] = arcov( x, p)
%ARCOV   AR parameter estimation via covariance method.
%   A = ARCOV(X,ORDER) returns the polynomial A corresponding to the AR
%   parametric signal model estimate of vector X using the Covariance method.
%   ORDER is the model order of the AR system.
%
%   [A,E] = ARCOV(...) returns the variance estimate E of the white noise
%   input to the AR model.
%
%   See also PCOV, ARMCOV, ARBURG, ARYULE, LPC, PRONY.

%   Ref: S. Kay, MODERN SPECTRAL ESTIMATION,
%              Prentice-Hall, 1988, Chapter 7
%        P. Stoica and R. Moses, INTRODUCTION TO SPECTRAL ANALYSIS,
%              Prentice-Hall, 1997, Chapter 3

%   Author(s): R. Losada and P. Pacheco
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.13 $  $Date: 2002/04/15 01:15:07 $

error(nargchk(2,2,nargin));

[a,e,msg] = arparest(x,p,'covariance');
error(msg);

% [EOF] - arcov.m