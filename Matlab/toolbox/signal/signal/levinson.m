function [A,E,K] = levinson(R,N);
%LEVINSON  Levinson-Durbin Recursion.
%   A = LEVINSON(R,N) solves the Hermitian Toeplitz system of equations
%
%       [  R(1)   R(2)* ...  R(N)* ] [  A(2)  ]  = [  -R(2)  ]
%       [  R(2)   R(1)  ... R(N-1)*] [  A(3)  ]  = [  -R(3)  ]
%       [   .        .         .   ] [   .    ]  = [    .    ]
%       [ R(N-1) R(N-2) ...  R(2)* ] [  A(N)  ]  = [  -R(N)  ]
%       [  R(N)  R(N-1) ...  R(1)  ] [ A(N+1) ]  = [ -R(N+1) ]
%
%   (also known as the Yule-Walker AR equations) using the Levinson-
%   Durbin recursion.  Input R is typically a vector of autocorrelation
%   coefficients with lag 0 as the first element.
%
%   N is the order of the recursion; if omitted, N = LENGTH(R)-1.
%   A will be a row vector of length N+1, with A(1) = 1.0.
%
%   [A,E] = LEVINSON(...) returns the prediction error, E, of order N.
%
%   [A,E,K] = LEVINSON(...) returns the reflection coefficients K as a
%   column vector of length N.  Since K is computed internally while
%   computing the A coefficients, then returning K simultaneously
%   is more efficient than converting A to K afterwards via TF2LATC.
%
%   If R is a matrix, LEVINSON finds coefficients for each column of R,
%   and returns them in the rows of A
%
%   See also LPC, PRONY, STMCB.

%   Author(s): T. Krauss, 3-18-93
%   C-MEX Update: R. Firtion
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.10 $  $Date: 2002/04/15 01:12:28 $
%
%   Reference(s):
% 	  [1] Lennart Ljung, "System Identification: Theory for the User",
%         pp. 278-280

% The following comment, MATLAB compiler pragma, is necessary to avoid compiling 
% this M-file instead of linking against the MEX-file.  Don't remove.
%# mex

error('C-MEX function not found');

% [EOF] levinson.m
