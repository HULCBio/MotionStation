function J = jordbloc(n, lambda)
%JORDBLOC Jordan block.
%   GALLERY('JORDBLOC',N,LAMBDA) is the N-by-N Jordan block 
%   with eigenvalue LAMBDA.  LAMBDA = 1 is the default.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9 $  $Date: 2002/04/15 03:42:38 $

if nargin == 1, lambda = 1; end

J = lambda*eye(n) + diag(ones(n-1,1),1);
