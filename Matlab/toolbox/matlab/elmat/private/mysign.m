function S = mysign(A)
%MYSIGN True sign function with MYSIGN(0) = 1.

%   Called by various matrices in elmat/private.
%
%   Nicholas J. Higham, Dec 1999.
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.4 $  $Date: 2002/04/15 03:43:23 $

S = sign(A);
S(find(S==0)) = 1;
