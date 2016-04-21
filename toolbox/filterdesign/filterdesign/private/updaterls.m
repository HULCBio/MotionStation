function S = updaterls(x,d,S)
% Execute one iteration of the RLS adaptive filter.

%   Author(s): A. Ramasubramanian
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.5 $  $Date: 2002/04/14 15:39:06 $

% Use QR or regular method depending on field
switch S.alg,
case 'direct',
	S = updatedirectrls(x,d,S);
case 'sqrt',
	S = updatesqrtrls(x,d,S);
end

%-----------------------------------------------------------------------------
function S = updatedirectrls(x,d,S)
% Execute one iteration of the RLS adaptive filter.

uvec     = [x ; S.states(:)];
z        = S.invcov*conj(uvec);
S.gain   = z./(S.lambda+uvec.'*z);   
ea       = d - S.coeffs*uvec; % A priori error, coeffs haven't been updated
S.coeffs = S.coeffs + (S.gain.*ea).'; % Now update coeffs using apriori error                    
S.invcov = 1./S.lambda.*(S.invcov - S.gain*z'); 


%-----------------------------------------------------------------------------
function S = updatesqrtrls(x,d,S)
% Execute one iteration of the RLS adaptive filter.
% Use QR method for numerical reliability

uvec    = [x ; S.states(:)];
lam_inv = 1/S.lambda;

if S.iter == 0,
	% Find the lower triangular cholesky factor
	S.Plower = chol(S.invcov)';
end

A = [1 sqrt(lam_inv)*uvec.'*S.Plower;zeros(length(S.coeffs),1) ...
     sqrt(lam_inv)*S.Plower];

B = givens_rot(A);

S.Plower = B(2:end,2:end);
S.gain   = B(2:end,1)/B(1,1);
ea       = d - S.coeffs*uvec; % A priori error, coeffs haven't been updated
S.coeffs = S.coeffs + (S.gain*ea).';  % Now update coeffs using apriori error                         

%----------------------------------------------------------------------------
function A = givens_rot(A)
% Apply Givens transformations to the first row of A

[m,n] = size(A);

for k=n:-1:2
  G = planerot([A(1,1);A(1,k)]);
  A(:,[1 k]) = A(:,[1 k])*G.';
end
A(1,2:end)=0;

% EOF
