function c = outer(a, b, dim)
%OUTER  Vector outer product.
%   C = OUTER(A,B,DIM) is equivalent to C = MULTIPROD(A,B,[DIM 0],[0 DIM])
%   and returns outer products performed along the dimension DIM of 
%   A and B. If A and B have N dimensions, with N>=2 (including trailing
%   singletons up to dimension DIM, if they exist), and if along dimension
%   DIM A contains M P-element vectors, and B contains M Q-element vectors,
%   C has N+1 dimensions and contains the M P-by-Q outer products of the
%   vectors in A by those in B (M = NUMEL(A)/P = NUMEL(B)/Q). Matrices in C
%   are constructed along dimensions D1 and D2. The size of C along all
%   dimensions other than DIM and DIM+1 is the same as that of A and B
%   along all dimensions other than DIM. Products involving scalars 
%   (1-element vectors) are allowed. D1 is allowed to be larger than
%   NDIMS(A) and/or NDIMS(B). Function MULTIPROD turns the vectors found in
%   A and B into P-by-1 and 1-by-Q matrices. The products of these matrices
%   are outer products. By definition of the matrix multiplication, the
%   inner dimensions of these matrices must have the same length L (in this
%   case L=1), while their outer dimensions may have different lengths P
%   and Q. Since P = SIZE(A,DIM) and Q = SIZE(B,DIM), A and B may have
%   different lengths along dimension DIM. A and B must have the same size
%   along all their other dimensions. 
%
%   Example:
%      A 5-by-6-by-2 array may be considered to be a 1-by-6-by-2 block 
%      array containing twelve 5-element vectors along its first dimension.
%      In this case, its size is so indicated: (5)-by-6-by-2 or (5)x6x2.
%      If  A is ............ a (5)x6x2   array of 5-element VECTORS,
%      and B is ............ a (3)x6x2   array of 3-element VECTORS,
%      C = OUTER(A, B, 1) is a (5x3)x6x2 array of 5x3 MATRICES constructed
%      along dimensions 1 and 2.
%
%   See also MAGN, UNIT, DOT, CROSS, CROSSDIV, MULTIPROD.

% $ Version: 1.0 $
% CODE      by:                 Paolo de Leva (IUSM, Rome, IT) 2005 Sep 13
% COMMENTS  by:                 Code author                    2005 Sep 27
% -------------------------------------------------------------------------

c = multiprod(a, b, [dim 0], [0 dim]);