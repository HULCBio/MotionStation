function [varargout] = ordschur(varargin)
%ORDSCHUR  Reorder eigenvalues in Schur factorization.
%   [US,TS] = ORDSCHUR(U,T,SELECT) reorders the Schur factorization 
%   X = U*T*U' of a matrix X so that a selected cluster of eigenvalues 
%   appears in the leading (upper left) diagonal blocks of the 
%   quasitriangular Schur matrix T, and the corresponding invariant 
%   subspace is spanned by the leading columns of U.  The logical vector
%   SELECT specifies the selected cluster as E(SELECT) where E = EIG(T).
%
%   ORDSCHUR takes the matrices U,T produced by the SCHUR command and
%   returns the reordered Schur matrix TS and the cumulative orthogonal 
%   transformation US such that X = US*TS*US'.  Set U=[] to get the 
%   incremental transformation T = US*TS*US'.  
% 
%   [US,TS] = ORDSCHUR(U,T,KEYWORD) sets the selected cluster to include
%   all eigenvalues in one of the following regions:
%
%       KEYWORD              Selected Region
%        'lhp'            left-half plane  (real(E)<0)
%        'rhp'            right-half plane (real(E)>0)
%        'udi'            interior of unit disk (abs(E)<1)
%        'udo'            exterior of unit disk (abs(E)>1)
%
%   ORDSCHUR can also reorder multiple clusters at once.  Given a vector 
%   CLUSTERS of cluster indices, commensurate with E = EIG(T), and such
%   that all eigenvalues with the same CLUSTERS value form one cluster,
%   [US,TS] = ORDSCHUR(U,T,CLUSTERS) will sort the specified clusters in
%   descending order along the diagonal of TS, the cluster with highest 
%   index appearing in the upper left corner.
%
%   See also SCHUR, ORDQZ.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/16 22:07:28 $
%   Built-in function.

if nargout == 0
  builtin('ordschur', varargin{:});
else
  [varargout{1:nargout}] = builtin('ordschur', varargin{:});
end
