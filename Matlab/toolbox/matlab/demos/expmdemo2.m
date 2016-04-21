function E = expmdemo2(A)
%EXPMDEMO2  Matrix exponential via Taylor series.
%   E = expmdemo2(A) illustrates the classic definition for the
%   matrix exponential.  As a practical numerical method,
%   this is often slow and inaccurate.
%
%   See also EXPM, EXPMDEMO1, EXPMDEMO3.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/10 23:24:39 $

% Taylor series for exp(A)
E = zeros(size(A));
F = eye(size(A));
k = 1;
while norm(E+F-E,1) > 0
   E = E + F;
   F = A*F/k;
   k = k+1;
end
