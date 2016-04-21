% Sparse matrices.
%
% Elementary sparse matrices.
%   speye       - Sparse identity matrix.
%   sprand      - Sparse uniformly distributed random matrix.
%   sprandn     - Sparse normally distributed random matrix.
%   sprandsym   - Sparse random symmetric matrix.
%   spdiags     - Sparse matrix formed from diagonals.
%
% Full to sparse conversion.
%   sparse      - Create sparse matrix.
%   full        - Convert sparse matrix to full matrix.
%   find        - Find indices of nonzero elements.
%   spconvert   - Import from sparse matrix external format.
%
% Working with sparse matrices.
%   nnz         - Number of nonzero matrix elements.
%   nonzeros    - Nonzero matrix elements.
%   nzmax       - Amount of storage allocated for nonzero matrix elements.
%   spones      - Replace nonzero sparse matrix elements with ones.
%   spalloc     - Allocate space for sparse matrix.
%   issparse    - True for sparse matrix.
%   spfun       - Apply function to nonzero matrix elements.
%   spy         - Visualize sparsity pattern.
%
% Reordering algorithms.
%   colamd      - Column approximate minimum degree permutation.
%   symamd      - Symmetric approximate minimum degree permutation.
%   colmmd      - Column minimum degree permutation.
%   symmmd      - Symmetric minimum degree permutation.
%   symrcm      - Symmetric reverse Cuthill-McKee permutation.
%   colperm     - Column permutation.
%   randperm    - Random permutation.
%   dmperm      - Dulmage-Mendelsohn permutation.
%
% Linear algebra.
%   eigs        - A few eigenvalues, using ARPACK.
%   svds        - A few singular values, using eigs.
%   luinc       - Incomplete LU factorization.
%   cholinc     - Incomplete Cholesky factorization.
%   normest     - Estimate the matrix 2-norm.
%   condest     - 1-norm condition number estimate.
%   sprank      - Structural rank.
%
% Linear Equations (iterative methods).
%   pcg         - Preconditioned Conjugate Gradients Method.
%   bicg        - BiConjugate Gradients Method.
%   bicgstab    - BiConjugate Gradients Stabilized Method.
%   cgs         - Conjugate Gradients Squared Method.
%   gmres       - Generalized Minimum Residual Method.
%   lsqr        - Conjugate Gradients on the Normal Equations.
%   minres      - Minimum Residual Method.
%   qmr         - Quasi-Minimal Residual Method.
%   symmlq      - Symmetric LQ Method.
%
% Operations on graphs (trees).
%   treelayout  - Lay out tree or forest.
%   treeplot    - Plot picture of tree.
%   etree       - Elimination tree.
%   etreeplot   - Plot elimination tree.
%   gplot       - Plot graph, as in "graph theory".
%
% Miscellaneous.
%   symbfact    - Symbolic factorization analysis.
%   spparms     - Set parameters for sparse matrix routines.
%   spaugment   - Form least squares augmented system.

% Utility functions.
%   rjr         - Random Jacobi rotation.
%   sparsfun    - Sparse auxiliary functions and parameters.
%   unmesh      - Convert a list of edges to a graph or matrix.
%   eigs2       - eigs helper function.
%   arpackc     - ARPACK interface.
%   umfpack     - Copyright and License information for UMFPACK.

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 5.24 $  $Date: 2002/05/14 06:24:54 $


