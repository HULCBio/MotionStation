function [varargout] = accumarray(varargin)
%ACCUMARRAY Construct an array with accumulation.
%   A = ACCUMARRAY(IND,VAL) creates an array A from the elements of the
%   vector VAL, using the corresponding rows of IND as subscripts into A.
%   VAL must have the same length as the number of rows in IND, unless VAL
%   is a scalar whose value is repeated for all the rows of IND.
%   If IND is a nonempty column vector, then A is a column vector of length
%   MAX(IND).
%   If IND is a nonempty matrix with K columns, then A is a K-dimensional
%   array of size MAX(IND,[],1).
%   If IND is ZEROS(0,K) with K>1, then A is the K-dimensional empty array
%   of size 0-by-0-by-...-by-0.
%   ACCUMARRAY accumulates by adding together elements of VAL at repeated
%   subscripts of A.
%   ACCUMARRAY fills in A at unspecified subscripts with the value zero.
%
%   Examples
%   Create a vector, accumulating at repeated index 2:
%      A = accumarray([1; 2; 2; 4; 5],11:15)
%   Create a 3-D array, accumulating at repeated subscript (2,3,4):
%      ind = [1 1 1; 2 1 2; 2 3 4; 2 3 4]
%      A = accumarray(ind,11:14)
%   Scalar val=pi is repeated for all the rows in ind:
%      A = accumarray(ind,pi)
%
%   Note: VAL may be full or sparse and A has the same sparsity as VAL.
%   If VAL is sparse and IND is a column vector, then A is the same as
%   SPARSE(IND,1,VAL). If VAL is sparse and IND is a matrix with 2 columns,
%   then A is the same as SPARSE(IND(:,1),IND(:,2),VAL).
%
%   A = ACCUMARRAY(IND,VAL,SZ) creates an array of size SZ, where SZ is a
%   row vector of nonnegative integer values.
%   If IND is a nonempty column vector, then SZ must be [N 1] where
%   N>=MAX(IND).
%   If IND is a nonempty matrix with K columns, then SZ must be of length K
%   with ALL(SZ>=MAX(IND,[],1)).
%   If IND is ZEROS(0,K) with K>1, then SZ must be of length K with
%   ALL(SZ>=0). Nonzero SZ resizes A to a nonempty all-zero array.
%
%   A = ACCUMARRAY(IND,VAL,SZ,FUN) accumulates values at repeated
%   subscripts of A using the function FUN, which is specified by a
%   function handle.  FUN must accept a vector and return a scalar.  For
%   example, the default is FUN=@SUM where S=SUM(X) accepts vector input X
%   and returns scalar output S.
%
%   A = ACCUMARRAY(IND,VAL,SZ,FUN,FILLVALUE) where VAL is full, fills in
%   the values in A that are not specified by IND with the value FILLVALUE.
%   If IND is empty but SZ resizes A to nonempty, then all the values of A
%   are FILLVALUE.
%
%   Examples
%      ind = [1 2; 3 2; 5 5; 5 5]
%      val = [10.1; 10.2; 10.3; 10.4]
%   Do the default summation accumulation at the repeated subscript (5,5):
%      A = accumarray(ind, val)
%   Increase the size of A beyond max(ind,[],1):
%      A = accumarray(ind, val,[6 6])
%   Try PROD instead of SUM as the accumulation function:
%      A = accumarray(ind, val, [6,6], @prod)
%   Use MAX as the accumulation function and fill the values at unspecified
%   subscripts with -Inf:
%      A = accumarray(ind, val, [6,6], @max, -Inf)
%
%   See also FULL, SPARSE, SUM.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/04/19 01:13:46 $
%   Built-in function.

if nargout == 0
  builtin('accumarray', varargin{:});
else
  [varargout{1:nargout}] = builtin('accumarray', varargin{:});
end
