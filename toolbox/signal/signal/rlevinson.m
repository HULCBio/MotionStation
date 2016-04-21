function [R,U,kr,e]=rlevinson(a,efinal)
%RLEVINSON  Reverse Levinson-Durbin Recursion.
%   R=RLEVINSON(A,Efinal) computes the autocorrelation coefficients, R based   
%   on the prediction polynomial A and the final prediction error Efinal,  
%   using the stepdown algorithm. A should be a minimum phase polynomial
%   and A(1) is assumed to be unity. 
%
%   [R,U]=RLEVINSON(...) returns a (P+1)x(P+1) upper triangular matrix, U, 
%   that holds the i'th order prediction polynomials Ai, i=1:P, where P 
%   is the order of the input polynomial, A.
%   
%   The format of this matrix U, is:
%
%         [ 1  a1(1)*  a2(2)* ..... aP(P)  * ]
%         [ 0  1       a2(1)* ..... aP(P-1)* ]
%   U  =  [ .................................]
%         [ 0  0       0      ..... 1        ]
%
%   from which the i'th order prediction polynomial can be extracted  
%   using Ai=U(i+1:-1:1,i+1)'. The first row of U contains the 
%   conjugates of the reflection coefficients, and the K's may be
%   extracted using, K=conj(U(1,2:end)). 
%
%   [R,U,K]=RLEVINSON(...) returns the reflection coefficients in K. 
%   [R,U,K,E]=RLEVINSON(...) returns the prediction error of descending
%   orders P,P-1,...,1 in the vector E.
%
%   See also LEVINSON.

%   References: [1] S. Kay, Modern Spectral Estimation,
%                   Prentice Hall, N.J., 1987, Chapter 6.
%               [2] P. Stoica R. Moses, Introduction to Spectral Analysis
%                   Prentice Hall, N.J., 1997, Chapter 3.
%
%   Author(s): A. Ramasubramanian
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.11 $  $Date: 2002/04/15 01:15:25 $

%   Some preliminaries first

a = a(:);                   % Convert to a column vector if not already so
if a(1)~=1,
   warning(['First coefficient of the prediction polynomial ' ...
            'was not unity.']);
   a = a/a(1);
end

p = length(a);

if p < 2
   error('Polynomial should have at least two coefficients');
end

U = zeros(p,p);             % This matrix will have the prediction polynomials 
                            % of orders 1:p
U(:,p) = conj(a(end:-1:1)); % Prediction coefficients of order p

p = p-1;

% First we find the prediction coefficients of smaller orders and form the
% Matrix U

% Initialize the step down
e(p) = efinal;             % Prediction error of order p

% Step down
for k=p-1:-1:1
   [a,e(k)] = levdown(a,e(k+1));
   U(:,k+1) = [conj(a(end:-1:1).');zeros(p-k,1)];
end

e0 = e(1)/(1-abs(a(2)^2)); % Because a[1]=1 (true polynomial)
U(1,1) = 1;                % Prediction coefficient of zeroth order 
kr = conj(U(1,2:end));     % The reflection coefficients 
kr = kr.';                 % To make it into a column vector             

% Once we have the matrix U and the prediction error at various orders, we can 
% use this information to find the autocorrelation coefficients. 

% Initialize recursion
k = 1;
R0 = e0;                   % To take care of the zero indexing problem  
R(1) = -conj(U(1,2))*R0;   % R[1]=-a1[1]*R[0]

% Actual recursion
for k = 2:1:p
   R(k) = -sum(conj(U(k-1:-1:1,k)).*R(end:-1:1).')-kr(k)*e(k-1);
end

% Include R(0) and make it a column vector. Note the dot transpose

R = [R0 R].';

% [EOF] rlevinson.m