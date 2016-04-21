% Matrix functions - numerical linear algebra.
%
% Matrix analysis.
%   norm        - Matrix or vector norm.
%   normest     - Estimate the matrix 2-norm.
%   rank        - Matrix rank.
%   det         - Determinant.
%   trace       - Sum of diagonal elements.
%   null        - Null space.
%   orth        - Orthogonalization.
%   rref        - Reduced row echelon form.
%   subspace    - Angle between two subspaces.
%
% Linear equations.
%   \ and /     - Linear equation solution; use "help slash".
%   linsolve    - Linear equation solution with extra control.
%   inv         - Matrix inverse.
%   rcond       - LAPACK reciprocal condition estimator
%   cond        - Condition number with respect to inversion.
%   condest     - 1-norm condition number estimate.
%   normest1    - 1-norm estimate.
%   chol        - Cholesky factorization.
%   cholinc     - Incomplete Cholesky factorization.
%   lu          - LU factorization.
%   luinc       - Incomplete LU factorization.
%   qr          - Orthogonal-triangular decomposition.
%   lsqnonneg   - Linear least squares with nonnegativity constraints.
%   pinv        - Pseudoinverse.
%   lscov       - Least squares with known covariance.
%
% Eigenvalues and singular values.
%   eig         - Eigenvalues and eigenvectors.
%   svd         - Singular value decomposition.
%   gsvd        - Generalized singular value decomposition.
%   eigs        - A few eigenvalues.
%   svds        - A few singular values.
%   poly        - Characteristic polynomial.
%   polyeig     - Polynomial eigenvalue problem.
%   condeig     - Condition number with respect to eigenvalues.
%   hess        - Hessenberg form.
%   qz          - QZ factorization for generalized eigenvalues.
%   ordqz       - Reordering of eigenvalues in QZ factorization.
%   schur       - Schur decomposition.
%   ordschur    - Reordering of eigenvalues in Schur decomposition.
%
% Matrix functions.
%   expm        - Matrix exponential.
%   logm        - Matrix logarithm.
%   sqrtm       - Matrix square root.
%   funm        - Evaluate general matrix function.
%
% Factorization utilities
%   qrdelete    - Delete a column or row from QR factorization.
%   qrinsert    - Insert a column or row into QR factorization.
%   rsf2csf     - Real block diagonal form to complex diagonal form.
%   cdf2rdf     - Complex diagonal form to real block diagonal form.
%   balance     - Diagonal scaling to improve eigenvalue accuracy.
%   planerot    - Givens plane rotation.
%   cholupdate  - rank 1 update to Cholesky factorization.
%   qrupdate    - rank 1 update to QR factorization.

% Obsolete functions
%   nnls        - Non-negative least-squares.

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 5.28.4.2 $  $Date: 2002/12/25 18:13:57 $
