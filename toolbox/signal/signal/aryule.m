function [a,e,k] = aryule( x, p)
%ARYULE   AR parameter estimation via Yule-Walker method.
%   A = ARYULE(X,ORDER) returns the polynomial A corresponding to the AR
%   parametric signal model estimate of vector X using the Yule-Walker
%   (autocorrelation) method.  ORDER is the model order of the AR system. 
%   This method solves the Yule-Walker equations by means of the Levinson-
%   Durbin recursion.
%
%   [A,E] = ARYULE(...) returns the final prediction error E (the variance
%   estimate of the white noise input to the AR model).
%
%   [A,E,K] = ARYULE(...) returns the vector K of reflection coefficients.
%
%   See also PYULEAR, ARMCOV, ARBURG, ARCOV, LPC, PRONY.

%   Ref: S. Orfanidis, OPTIMUM SIGNAL PROCESSING, 2nd Ed.
%              Macmillan, 1988, Chapter 5
%        M. Hayes, STATISTICAL DIGITAL SIGNAL PROCESSING AND MODELING, 
%              John Wiley & Sons, 1996, Chapter 8

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.12 $  $Date: 2002/05/04 01:38:58 $

error(nargchk(2,2,nargin))

[mx,nx] = size(x);
if isempty(x) | length(x) < p | min(mx,nx) > 1,
   error('X must be a vector with length greater or equal to the model order.');
elseif isempty(p) | ~(p == round(p))
   error('Model order must be an integer.')
end
if issparse(x)
   error('Input signal cannot be sparse.')
end

R = xcorr(x,p,'biased');
[a,e,k] = levinson(R(p+1:end),p);


