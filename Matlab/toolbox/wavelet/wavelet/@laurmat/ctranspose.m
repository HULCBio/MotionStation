function B = ctranspose(A)
%CTRANSPOSE Laurent matrix transpose (non-conjugate).
%    B = CTRANSPOSE(A) is called for the syntax A' (non-conjugate
%    transpose) when A is a Laurent matrix object.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 30-Mar-2001.
%   Last Revision 12-Jun-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/13 00:39:10 $ 

MA = A.Matrix;
B = laurmat(MA');
