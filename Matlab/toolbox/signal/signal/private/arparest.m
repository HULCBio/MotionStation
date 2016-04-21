function [a,e,msg] = arparest( x, p, method)
%ARPAREST   AR parameter estimation via a specified method.
%   A = ARPAREST(X,ORDER,METHOD) returns the polynomial A corresponding to 
%   the AR parametric signal model estimate of vector X using the specified
%   METHOD.  ORDER is the model order of the AR system.
%
%   Supported methods are: 'covariance' and 'modified' although all of the
%   methods of CORRMTX will work. In particular if 'autocorrelation' is
%   used, the results should be the same as those of ARYULE (but slower).
%
%   [A,E] = ARPAREST(...) returns the variance estimate E of the white noise
%   input to the AR model.

%   Ref: S. Kay, MODERN SPECTRAL ESTIMATION,
%              Prentice-Hall, 1988, Chapter 7
%        S. Marple, DIGITAL SPECTRAL ANALYSIS WITH APPLICATION,
%              Prentice-Hall, 1987, Chapter 8.
%        P. Stoica and R. Moses, INTRODUCTION TO SPECTRAL ANALYSIS,
%              Prentice-Hall, 1997, Chapter 3

%   Author(s): R. Losada and P. Pacheco
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.5 $  $Date: 2002/04/15 01:08:54 $

error(nargchk(3,3,nargin))
[mx,nx] = size(x);

% Initialize in case we return early
a = []; e = [];

% Assign msg in case there are no errors
msg ='';

% Set up necessary but not sufficient conditions for the correlation
% matrix to be nonsingular. From (Marple)
switch method,
case 'covariance',
   minlength_x = 2*p;
case 'modified',
   minlength_x = 3*p/2;
otherwise
   msg = 'Unrecognized method specified.';
   return
end

% Do some data sanity testing
if isempty(x) | length(x) < minlength_x | min(mx,nx) > 1,
   msg = 'X must be a vector with length greater than twice the model order.';
   return
end
if issparse(x),
   msg = 'Input signal cannot be sparse.';
   return
end
if isempty(p) | p ~= round(p),
   msg = 'Model order must be an integer.';
   return
end

x  = x(:);

% Generate the appropriate data matrix
XM = corrmtx(x,p,method);
Xc = XM(:,2:end);
X1 = XM(:,1);

% Coefficients estimated via the covariance method
a = [1; -Xc\X1];


% Estimate the input white noise variance
Cz = X1'*Xc;
e = X1'*X1 + Cz*a(2:end);

e = real(e); %ignore the possible imaginary part due to numerical errors

a = a(:).'; % By convention all polynomials are row vectors

% [EOF] arparest.m