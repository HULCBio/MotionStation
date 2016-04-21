function t = trace(a)
%TRACE  Sum of diagonal elements.
%   TRACE(A) is the sum of the diagonal elements of A, which is
%   also the sum of the eigenvalues of A.
%
%   Class support for input A:
%      float: double, single

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 5.8.4.1 $  $Date: 2004/04/10 23:30:11 $

t = sum(diag(a));
