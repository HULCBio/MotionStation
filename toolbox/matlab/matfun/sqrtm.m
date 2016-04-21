function [X, arg2, condest] = sqrtm(A)
%SQRTM     Matrix square root.
%   X = SQRTM(A) is the principal square root of the matrix A, i.e. X*X = A.
%          
%   X is the unique square root for which every eigenvalue has nonnegative
%   real part.  If A has any real, negative eigenvalues then a complex
%   result is produced.  If A is singular then A may not have a
%   square root.  A warning is printed if exact singularity is detected.
%          
%   With two output arguments, [X, RESNORM] = SQRTM(A) does not print any
%   warning, and returns the residual, norm(A-X^2,'fro')/norm(A,'fro').
%
%   With three output arguments, [X, ALPHA, CONDEST] = SQRTM(A) returns a
%   stability factor ALPHA and an estimate CONDEST of the matrix square root
%   condition number of X.  The residual NORM(A-X^2,'fro')/NORM(A,'fro') is
%   bounded approximately by N*ALPHA*EPS and the Frobenius norm relative
%   error in X is bounded approximately by N*ALPHA*CONDEST*EPS, where
%   N = MAX(SIZE(A)).
%
%   See also EXPM, LOGM, FUNM.

%   References:
%   N. J. Higham, Computing real square roots of a real
%       matrix, Linear Algebra and Appl., 88/89 (1987), pp. 405-430.
%   A. Bjorck and S. Hammarling, A Schur method for the square root of a
%       matrix, Linear Algebra and Appl., 52/53 (1983), pp. 127-140.
%
%   Nicholas J. Higham
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.15.4.3 $  $Date: 2004/04/16 22:07:34 $

n = length(A);
[Q, T] = schur(A,'complex');  % T is complex Schur form.

warns = warning('query','all');
warning('off','all');

if isequal(T,diag(diag(T)))      % Check if T is diagonal.
    
    R = diag(sqrt(diag(T)));     % Square root always exists. 
    
else
    
    % Compute upper triangular square root R of T, a column at a time.
    
    R = zeros(n);  
    for j=1:n
        R(j,j) = sqrt(T(j,j));
        for i=j-1:-1:1
            k = i+1:j-1;
            s = R(i,k)*R(k,j);
            R(i,j) = (T(i,j) - s)/(R(i,i) + R(j,j));
        end
    end
    
end

warning(warns);

X = Q*R*Q';

nzeig = any(diag(T)==0);

if nzeig && (nargout ~= 2)
    warning('MATLAB:sqrtm:SingularMatrix', ...
            'Matrix is singular and may not have a square root.')
end

if nargout == 2
    arg2 = norm(X*X-A,'fro')/norm(A,'fro');
end

if nargout > 2
    
    arg2 = norm(R,'fro')^2 / norm(T,'fro');
    
    if nzeig
        condest = inf;
    else
        
        % Power method to get condition number estimate.
        
        tol = 1e-2;
        x = ones(n^2,1);    % Starting vector.
        cnt = 1;
        e = 1;
        e0 = 0;
        while abs(e-e0) > tol*e && cnt <= 6
            x = x/norm(x);
            x0 = x;
            e0 = e;
            Sx = tksolve(R, x);
            x = tksolve(R, Sx, 'T');
            e = sqrt(real(x0'*x));  % sqrt of Rayleigh quotient.
            % fprintf('cnt = %2.0f, e = %9.4e\n', cnt, e)
            cnt = cnt+1;
        end
        
        condest = e*norm(A,'fro')/norm(X,'fro');
        
    end
    
end

% As in FUNM:
if isreal(A) && norm(imag(X),1) <= 10*n*eps*norm(X,1)
   X = real(X);
end

%====================================

function x = tksolve(R, b, tran)
%TKSOLVE     Solves block triangular Kronecker system.
%            x = TKSOLVE(R, b, TRAN) solves
%                  A*x = b  if TRAN = '',
%                 A'*x = b  if TRAN = 'T',
%            where A = KRON(EYE,R) + KRON(TRANSPOSE(R),EYE).
%            Default: TRAN = ''.

if nargin < 3, tran = ''; end

n = max(size(R));
x = zeros(n^2,1);

I = eye(n);

if isempty(tran)

   % Forward substitution.
   for i = 1:n
       temp = b(n*(i-1)+1:n*i);
       for j = 1:i-1
           temp = temp - R(j,i)*x(n*(j-1)+1:n*j);
       end
       x(n*(i-1)+1:n*i) = (R + R(i,i)*I) \ temp;
   end

elseif strcmp(tran,'T')

   % Back substitution.
   for i = n:-1:1
       temp = b(n*(i-1)+1:n*i);
       for j = i+1:n
           temp = temp - conj(R(i,j))*x(n*(j-1)+1:n*j);
       end
       x(n*(i-1)+1:n*i) = (R' + conj(R(i,i))*I) \ temp;
   end

end

return
