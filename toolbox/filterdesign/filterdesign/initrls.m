function S = initrls(w0,P0,lambda,Zi,Alg)
%INITRLS Initialize structure for RLS adaptive filter.
%   S = INITRLS(W0,P0,LAMBDA) returns the fully populated structure that 
%   must be used when calling ADAPTRLS.
%
%   W0 is the initial value of the filter coefficients.  Its length should
%   be equal to the filter order plus one.
%
%   P0 is the inverse of the initial error covariance matrix. It should be a
%   hermitian symmetric square matrix with each dimension equal to length(w0).
%
%   LAMBDA is the forgetting factor in the RLS algorithm. It should satisfy
%   0 < LAMBDA <= 1, where LAMBDA = 1 denotes infinite memory.
%
%   S = INITRLS(W0,P0,LAMBDA,Zi) specifies the filter initial conditions. If
%   omitted or specified as empty,  it defaults to a zero vector of length
%   one less than length(W0).
%
%   S = INITRLS(W0,P0,LAMBDA,Zi,ALG) specifies the algorithm to be used in RLS
%   computations. ALG can be either 'DIRECT' (default) to use the conventional
%   RLS algorithm or 'SQRT" to use the more stable square root (QR) algorithm.
%
%   See also ADAPTRLS,INITLMS, INITNLMS, INITKALMAN.

%   References: 
%     [1] S. Haykin, "Adaptive Filter Theory", 3rd Edition,
%         Prentice Hall, N.J., 1996.
%     [2] A. H. Sayed and T. Kailath, "A state-space approach to RLS
%         adaptive filtering". IEEE Signal Processing Magazine, 
%         July 1994. pp. 18-60.  
%
%   Author(s): A. Ramasubramanian
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2002/11/21 16:14:28 $

warning(generatemsgid('obsolete'), ...
        ['INITRLS is obsolete and will be removed in future versions of \n',...
            'Filter Design Toolbox. Type "help adaptfilt/rls" and "help adaptfilt/filter"\n',...
            'for more information on using the new adaptive filters.\n']);

error(nargchk(3,5,nargin));

% Convert w0 to a row vector if not already so.
w0 = w0(:).';

% Check FIR filter initial conditions.
if nargin < 4 | isempty(Zi),
    Zi = zeros(length(w0)-1,1);
end

if nargin < 5 | isempty(Alg),
	Alg = 'direct';
end

if ~isequal(length(Zi),length(w0)-1),
    error('The number of FIR initial states should equal the filter order.');
end

% Check initial value of error covariance matrix.
[mP0,nP0] = size(P0);
if ~isequal(mP0,nP0,length(w0)),
    error(sprintf(['Input covariance matrix inverse must be square \n',...
                   'with each dimension equal to the filter order.']));
end

% Check if specified error covariance matrix is hermitian symmetric.
if ~isequal(P0,P0')
    warning(sprintf(['Initial input covariance matrix inverse is not ',...
                     'symmetric: \nErratic behavior might result.']));
end

% Check lambda.
if (lambda>1)|(lambda<=0)
    warning(sprintf(['Forgetting factor is not in range ',...
                     '0 < lambda <= 1. \n',...
                     'Erratic behavior might result.']));
end

% Assign structure fields only after error checking is complete:
S.coeffs  = w0;
S.states  = Zi;
S.invcov  = P0;
S.lambda  = lambda;
S.gain    = [];  % Will be assigned after first call to ADAPTRLS.
S.iter    = 0;   % Iteration count.
S.alg     = Alg;
                     
% [EOF] initrls.m                     
