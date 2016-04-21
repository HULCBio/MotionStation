function [a,e] = armcov( x, p)
%ARMCOV   AR parameter estimation via modified covariance method.
%   A = ARMCOV(X,ORDER) returns the polynomial A corresponding to the AR
%   parametric signal model estimate of vector X using the Modified Covariance
%   method. ORDER is the model order of the AR system. 
%
%   [A,E] = ARMCOV(...) returns the variance estimate E of the white noise
%   input to the AR model.
%
%   See also PMCOV, ARCOV, ARBURG, ARYULE, LPC, PRONY.

%   References:
%     [1] S. Lawrence Marple, DIGITAL SPECTRAL ANALYSIS WITH APPLICATIONS,
%              Prentice-Hall, 1987, Chapter 8
%     [2] Steven M. Kay, MODERN SPECTRAL ESTIMATION THEORY & APPLICATION,
%              Prentice-Hall, 1988, Chapter 7

%   Author(s): R. Losada and P. Pacheco
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.13 $  $Date: 2002/04/15 01:15:10 $

error(nargchk(2,2,nargin));

[a,e,msg] = arparest(x,p,'modified');
error(msg);

% [EOF] - armcov.m