%BDSCHUR  Block-diagonal Schur factorization.
%
%   [T,B,BLKS] = BDSCHUR(A,CONDMAX) computes a transformation matrix
%   T such that B = T\A*T is block diagonal and each diagonal block is
%   a quasi upper-triangular Schur matrix.  The third output BLKS
%   is the vector of block sizes.
%
%   The optional argument CONDMAX specifies an upper bound on the 
%   condition number of T.  By default CONDMAX=1/sqrt(eps).  Use 
%   CONDMAX to control the trade off between block size and 
%   conditioning of T with respect to inversion (the larger CONDMAX, 
%   the smaller the blocks are, but the more ill-conditioned T may be). 
%
%   [T,B] = BDSCHUR(A,[],BLKS) prespecifies the desired block sizes.
%   The input matrix A should already be in Schur form when using this
%   syntax (see SCHUR for details).
%
%   See also SCHUR, ORDSCHUR.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $ $Date: 2002/11/11 22:23:08 $

%   Based on LAPACK's DTRSYL and SLICOT's MB03RD routines.
