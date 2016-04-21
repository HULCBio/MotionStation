function varargout = arburg( x, p)
%ARBURG   AR parameter estimation via Burg method.
%   A = ARBURG(X,ORDER) returns the polynomial A corresponding to the AR
%   parametric signal model estimate of vector X using Burg's method.
%   ORDER is the model order of the AR system.
%
%   [A,E] = ARBURG(...) returns the final prediction error E (the variance
%   estimate of the white noise input to the AR model).
%
%   [A,E,K] = ARBURG(...) returns the vector K of reflection 
%   coefficients (parcor coefficients).
%
%   See also PBURG, ARMCOV, ARCOV, ARYULE, LPC, PRONY.

%   Ref: S. Kay, MODERN SPECTRAL ESTIMATION,
%              Prentice-Hall, 1988, Chapter 7
%        S. Orfanidis, OPTIMUM SIGNAL PROCESSING, 2nd Ed.
%              Macmillan, 1988, Chapter 5

%   Author(s): D. Orofino and R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.12 $  $Date: 2002/04/15 01:15:16 $

error(nargchk(2,2,nargin))

[mx,nx] = size(x);
if isempty(x) | min(mx,nx) > 1,
   error('X must be a vector with length greater than twice the model order.');
elseif isempty(p) | ~(p == round(p))
   error('Model order must be an integer.')
end
if issparse(x),
   error('Input signal cannot be sparse.')
end

x  = x(:);
N  = length(x);

% Initialization
ef = x;
eb = x;
a = 1;

% Initial error
E = x'*x./N;

for m=1:p
   % Calculate the next order reflection (parcor) coefficient
   efp = ef(2:end);
   ebp = eb(1:end-1);
   num = -2.*ebp'*efp;
   den = efp'*efp+ebp'*ebp;
   
   k(m) = num ./ den;
   
   % Update the forward and backward prediction errors
   ef = efp + k(m)*ebp;
   eb = ebp + k(m)'*efp;
   
   % Update the AR coeff.
   a=[a;0] + k(m)*[0;conj(flipud(a))];
   
   % Update the prediction error
   E(m+1) = (1 - k(m)'*k(m))*E(m);
end

a = a(:).'; % By convention all polynomials are row vectors
varargout{1} = a;
if nargout >= 2
    varargout{2} = E(end);
end
if nargout >= 3
    varargout{3} = k(:);
end
