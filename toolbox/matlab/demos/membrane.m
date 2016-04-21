function Lout = membrane(k,m,n,np)
%MEMBRANE Generates the MATLAB logo.
%
%   L = MEMBRANE(k), for k <= 12, is the k-th eigenfunction of
%   the L-shaped membrane.  The first three eigenfunctions have
%   been shown on the covers of various MathWorks publications.
%
%   MEMBRANE(k), with no output parameters, plots the k-th eigenfunction.
%
%   MEMBRANE, with no input or output parameters, plots MEMBRANE(1).
%
%   L = MEMBRANE(k,m,n,np) also sets some mesh and accuracy parameters:
%
%     k = index of eigenfunction, default k = 1.
%     m = number of points on 1/3 of boundary.  The size of
%         the output is 2*m+1-by-2*m+1.  The default m = 15.
%     n = number of terms in sum, default n = min(m,9).
%     np = number of terms in partial sum, default np = min(n,2).
%     With np = n, the eigenfunction is nearly zero on the boundary.
%     With np < n, like np = 2, the boundary is not tied down.

%   Out-of-date reference:
%       Fox, Henrici & Moler, SIAM J. Numer. Anal. 4, 1967, pp. 89-102.
%   Cleve Moler 4-21-85, 7-21-87, 6-30-91, 6-17-92;
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.9 $  $Date: 2002/04/15 03:35:59 $

if nargin < 1, k = 1; end
if nargin < 2, m = 15; end
if nargin < 3, n = min(m,9); end
if nargin < 4, np = min(n,2); end
if k > 12
   error('Only the first 12 membrane eigenfunctions are available.')
end

lambda = [9.6397238445, 15.19725192, 2*pi^2, 29.5214811, 31.9126360, ...
    41.4745099, 44.948488, 5*pi^2, 5*pi^2, 56.709610, 65.376535, 71.057755];
lambda = lambda(k);
sym = [1 2 3 2 1 1 2 3 3 1 2 1];
sym = sym(k);

% Part of the boundary in polar coordinates
theta = (1:3*m)'/m * pi/4;
r = [ones(m,1)./cos(theta(1:m)); ones(2*m,1)./sin(theta(m+1:3*m))];

% if sym = 1, alfa = [1 5 7 11 13 17 19 ... ] * 2/3, (odd, not divisible by 3)
% if sym = 2, alfa = [2 4 8 10 14 16 20 ... ] * 2/3, (even, not divisible by 3)
% if sym = 3, alfa = [3 6 9 12 15 18 21 ... ] * 2/3, (multiples of 3)
alfa = sym;
del = sym + 3*(sym == 1);
for j = 2:n,
   alfa(j) = alfa(j-1) + del;
   del = 6-del;
end;
alfa = alfa * 2/3;
if sym ~= 3
   alf1 = (alfa(1):1:max(alfa));
   alf2 = (alfa(2):1:max(alfa));
   k1 = 1:4:length(alf1);
   k2 = 1:4:length(alf2);
else
   alf1 = (alfa(1):1:max(alfa));
   alf2 = [];
   k1 = 1:2:length(alf1);
   k2 = [];
end

% Build up the matrix of fundamental solutions evaluated on the boundary.
t = sqrt(lambda)*r;
b1 = besselj(alf1,t);
b2 = besselj(alf2,t);
A = [b1(:,k1) b2(:,k2)];
[ignore,k] = sort([k1 k2]);
A = A(:,k);
A = A.*sin(theta*alfa);

% The desired coefficients are the null vector.
% (lambda was chosen so that the matrix is rank deficient).  
[Q,R,E] = qr(A);
j = 1:n-1;
c = -R(j,j)\R(j,n);
c(n) = 1;
c = E*c(:);
if c(1) < 0, c = -c; end
% The residual should be small.
% res = norm(A*c,inf)/norm(abs(A)*abs(c),inf)

% Now evaluate the eigenfunction on a rectangular mesh in the interior.
mm = 2*m+1;
x = ones(m+1,1)*(-m:m)/m;
y = (m:-1:0)'/m*ones(1,mm);
r = sqrt(x.*x + y.*y);
theta = atan2(y,x);
theta(m+1,m+1) = 0;
S = zeros(m+1,mm);
r = sqrt(lambda)*r;
for j = 1:np
   S = S + c(j) * besselj(alfa(j),r) .* sin(alfa(j)*theta);
end

L = zeros(mm,mm);
L(1:m+1,:) = triu(S);
if sym == 1, L = L + L' - diag(diag(L)); end
if sym == 2, L = L - L'; end
if sym == 3, L = L + L' - diag(diag(L)); end
L = rot90(L/max(max(abs(L))),-1);

if nargout == 0
   x = -1:1/m:1;
   surf(x,x',L)
   colormap(cool)
else
   Lout = L;
end
