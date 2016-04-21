function [varargout] = ordqz(varargin)
%ORDQZ  Reorder eigenvalues in QZ factorization.
%   [AAS,BBS,QS,ZS] = ORDQZ(AA,BB,Q,Z,SELECT) reorders the QZ factorization 
%   Q*A*Z = AA, Q*B*Z = BB of a matrix pair (A,B) so that a selected cluster 
%   of eigenvalues appears in the leading (upper left) diagonal blocks of the 
%   quasitriangular pair (AA,BB), and the corresponding invariant subspace is 
%   spanned by the leading columns of Z.  The logical vector SELECT specifies 
%   the selected cluster as E(SELECT) where E = EIG(AA,BB).
%
%   ORDQZ takes the matrices AA,BB,Q,Z produced by the QZ command and
%   returns the reordered pair (AAS,BBS) and the cumulative orthogonal 
%   transformations QS and ZS such that QS*A*ZS = AAS, QS*B*ZS = BBS.  
%   Set Q=[] or Z=[] to get the incremental QS,ZS transforming (AA,BB)  
%   into (AAS,BBS).
% 
%   [AAS,BBS,...] = ORDQZ(AA,BB,Q,Z,KEYWORD) sets the selected cluster to 
%   include all eigenvalues in one of the following regions:
%
%       KEYWORD              Selected Region
%        'lhp'            left-half plane  (real(E)<0)
%        'rhp'            right-half plane (real(E)>0)
%        'udi'            interior of unit disk (abs(E)<1)
%        'udo'            exterior of unit disk (abs(E)>1)
%
%   ORDQZ can also reorder multiple clusters at once.  Given a vector 
%   CLUSTERS of cluster indices, commensurate with E = EIG(AA,BB), and 
%   such that all eigenvalues with same CLUSTERS value form one cluster,
%   [...] = ORDQZ(AA,BB,Q,Z,CLUSTERS) will sort the specified clusters
%   in descending order along the diagonal of (AAS,BBS), the cluster with  
%   highest index appearing in the upper left corner.
%
%   See also QZ, ORDSCHUR.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/16 22:07:27 $
%   Built-in function.

if nargout == 0
  builtin('ordqz', varargin{:});
else
  [varargout{1:nargout}] = builtin('ordqz', varargin{:});
end
