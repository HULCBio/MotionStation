%Arithmetic operators.
% +   Plus.
%     X + Y adds matrices X and Y.  X and Y must have the same
%     dimensions unless one is a scalar (a 1-by-1 matrix).
%     A scalar can be added to anything.  
%
% -   Minus.
%     X - Y subtracts matrix X from Y.  X and Y must have the same
%     dimensions unless one is a scalar.  A scalar can be subtracted
%     from anything.  
%
% *   Matrix multiplication.
%     X*Y is the matrix product of X and Y.  Any scalar (a 1-by-1 matrix)
%     may multiply anything.  Otherwise, the number of columns of X must
%     equal the number of rows of Y.
%
% .*  Array multiplication
%     X.*Y denotes element-by-element multiplication.  X and Y
%     must have the same dimensions unless one is a scalar.
%     A scalar can be multiplied into anything.
%
% ^   Matrix power.
%     Z = X^y is X to the y power if y is a scalar and X is square. If y is an
%     integer greater than one, the power is computed by repeated
%     multiplication. For other values of y the calculation
%     involves eigenvalues and eigenvectors.
%     Z = x^Y is x to the Y power, if Y is a square matrix and x is a scalar,
%     computed using eigenvalues and eigenvectors.
%     Z = X^Y, where both X and Y are matrices, is an error.
%
% .^  Array power.
%     Z = X.^Y denotes element-by-element powers.  X and Y
%     must have the same dimensions unless one is a scalar. 
%     A scalar can operate into anything.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.9 $  $Date: 2002/04/15 04:11:28 $
