function [r,D,G,x] = musol4(M,K,T,x)
%MUSOL4 Mixed real/complex structured singular value.
%
%  Synopsis: musol4(M), musol4(M,K), musol4(M,K,T), musol4(M,K,T,x).
%
%  MUSOL4 computes the upper bound of structured singular value reported in
%
%     "Robustness in the Presence of Mixed Parametric Uncertainty and
%     Unmodeled Dynamics," by M.K.H. Fan, A.L. Tits and J.C. Doyle, IEEE
%     Transactions on Automatic Control, January 1991.
%
%  MUSOL4 uses the interior point method (with enhancements) reported in
%
%     "An Interior Point Method for Solving Linear Matrix Inequality
%     Problems," by M.K.H. Fan and B. Nekooie, SIAM Journal on Control
%     and Optimization, to appear.
%
%  Inputs:
%     M  -  n by n matrix for which the upper bound of SSV is to be computed.
%
%     Optional inputs:
%     K  -  m by 1 vector contains the block structure. K(i), i=1:m, is the
%           size of each block, and sum(K) should be equal to n.
%           default: K = ones(n,1).
%     T  -  m by 1 vector indicates the type of each block. For i=1:m,
%           T(i)=1 indicates the corresponding block is a real block, and
%           T(i)=2 indicates the corresponding block is a complex block.
%           K(i) must be 1 if T(i)=1.
%           default: T = 2*ones(length(K),1).
%     x  -  a vector contains information from a previous call to musol4.
%
%  Outputs:
%     r   -  real scalar contains the computed upper bound.
%     D,G -  n by n matrices such that the matrix
%            M'*D^2*M + sqrt(-1)*(G*M-M'*G) - r^2*D^2
%            is negative semi-definite.
%     x   -  a vector contains information that can be used for the next
%            call to musol4 for a matrix close to M.

%
%  Version 3.0
%  Date: January 1, 1995
%  Author: Michael Fan
%          School of Electrical and Computer Engineering
%          Georgia Institute of Technology
%          Atlanta, GA 30332-0250
%          TEL: 404-853-9828
%          FAX: 404-853-9171
%          email: fan@ee.gatech.edu
%
% Revised  by  R. Y. Chiang 10/30/96
% For use with MATLAB 5.0
%
% R. Y. Chiang & M. G. Safonov 3/96
% Copyright 1988-2004 The MathWorks, Inc.
% $Revision: 1.11.4.3 $
% All Rights Reserved.
% -------------------------------------------------------------------
%

nag1 = nargin;

verbose = 0;       % turn on intermediate information if set to 1

G = [];   % initialize G

% take care of a trivial case.

if norm(M,'fro') == 0,
   r = 0;
   return;
end

% check input data

[n, n2] = size(M);
if (n < 1) | (n ~= n2)
   error('matrix M must be square');
end

if nag1 == 1,
   K = ones(n,1);
   T = 2*ones(n,1);
elseif nag1 == 2,
   T = 2*ones(length(K),1);
end

K = K(:);
K = fix(K);
if min(K) < 1,
   error('K must contain positive integers');
end
if sum(K) ~= n,
   error('sum(K) must be n');
end
m = length(K);

T = fix(T);
if length(T) ~= m,
   error('T and K must be of same size');
end
if sum(T==1)+sum(T==2) ~= m,
   error('T must contain either 1 or 2');
end

if max(K(T==1)) > 1,
   error('K(i) must be one if T(i)=1');
end

p = [0; cumsum(K)];
mr = sum(T==1);

% find osborne scaling if initial scaling is not given.

if nag1 <= 3,
   W = zeros(m);
   d = ones(m, 1);
   t = norm(M,'fro');

   for i=1:m,
      for j=1:m,
         if i ~= j,
            W(i,j) = norm(M(p(i)+1:p(i+1),p(j)+1:p(j+1))) + 1e-12*t;
         end
      end
   end

   h = zeros(m,1);
   while norm(h-1) > 1e-12,
      for k=1:m,
         h(k) = sqrt(sum(W(:,k))/sum(W(k,:)));
         W(k,:) = W(k,:)*h(k);
         W(:,k) = W(:,k)/h(k);
         d(k) = d(k)*h(k);
      end
   end

   d = d/d(1);
else
   d = [1; x(1:m-1)].^(0.5);
end

for i=1:m,
   for j=1:m,
      if i ~= j,
         Mij = M(p(i)+1:p(i+1),p(j)+1:p(j+1));
         M(p(i)+1:p(i+1),p(j)+1:p(j+1)) = Mij*d(i)/d(j);
      end
   end
end

scale = norm(M);
M = M/scale;

mt = m + mr - 1;

% form A0, AA, B0d, BBd

AA  = [];
BBd = [];
BB  = [];

P = diag([ones(1,K(1)) zeros(1,n-p(2))]);
A0  = M'*P*M; A0 = A0(:);
B0d = diag(P);
B0  = P(:);

for k=2:m,
   P   = diag([zeros(1,p(k)) ones(1,K(k)) zeros(1,n-p(k+1))]);
   t   = M'*P*M;
   AA  = [AA t(:)];
   BBd = [BBd diag(P)];
   BB  = [BB P(:)];
end

j = 0;
for k=1:m,
   if T(k) == 1,
      P  = diag([zeros(1,p(k)) ones(1,K(k)) zeros(1,n-p(k+1))]);
      t  = sqrt(-1)*(P*M-M'*P);
      AA = [AA t(:)];
      BB = [BB zeros(n*n,1)];
      j  = j + 1;
   end
end

% set initial x

if nag1 <= 3,
   x = [ones(m-1,1); zeros(mr,1)];
else
   x = [ones(m-1,1); x(m:mt)];
   j = 0;
   for k = 1:m,
      if T(k) == 1,
         x(m+j) = x(m+j)/d(k)^2;
         j = j + 1;
      end
   end
end

beta  = 0.01;
alpha = 100;
theta = 0.01;
lamsv = 1e20;
c     = 1;
iter  = -1;
A     = zeros(n);
Ai    = zeros(n);
At    = zeros(n);
H     = eye(mt);

% set taua and taub

taua = [0 1 4 8 40];
taub = [2 5 10 50 100];

while 1,

   A(:) = A0+AA*x;
   Binv = diag((1)./(B0d+BBd*x(1:m-1)));
   e = max(real(eig(Binv*A)));

   if isempty(x(m:mt))
      tau = zeros(0,1);
   else
      tau = max(taub(max(abs(x(m:mt))) >= taua));
   end

   iter = iter+1;

   if iter == 0,
      lambda = e + 0.001;
   else
      y = [e; x];
      lambda = (1-theta)*y(1) + theta*yf(1);
      xh = y(2:mt+1);
      xf = yf(2:mt+1);

      l = 0;
      while 1,
         x = (1-0.5^l*theta)*xh + 0.5^l*theta*xf;
         At(:) = A0+AA*x;
         Bt = diag(B0d+BBd*x(1:m-1));
         W = (theta*beta*(yf(1)-y(1)))/2*eye(n) - lambda*Bt + At;
         if max(real(eig(W))) <= 0,
            break;
         end
         l = l + 1;
      end
   end

   if verbose == 1,
      fprintf ('iter= %g    lambda= %.10g\n', iter, lambda);
   end

   y = [lambda; x];

   if lamsv-lambda < 1e-6,
      r = sqrt(max(e,0))*scale;
      x(1:m-1) = x(1:m-1).*(d(2:m).^2);
      D = diag(B0d+BBd*sqrt(x(1:m-1)));
      j = 0;
      for k = 1:m,
         if T(k) == 1,
            x(m+j) = x(m+j)*d(k)^2;
            G = [G; x(m+j)];
            j = j + 1;
         else
            G = [G; zeros(K(k),1)];
         end
      end
      G = scale*diag(G);
      return;
   end

   lamsv = lambda;

   for i = 1:m,
      xD    = x(1:m-1,1);
      xG    = x(m:mt,1);
      A(:)  = A0+AA*x;
      B     = B0d+BBd*xD;
      F    = lambda*diag(B)-A;
      Finv = inv(F);
      phi   = -log(real(det(F))) ...
              -log(prod([xD-beta; alpha-xD; xG+tau; tau-xG]));

      g = - real(Finv(:)'*(lambda*BB-AA))' ...
          - [(1)./(xD-beta)-(1)./(alpha-xD); (1)./(xG+tau)-(1)./(tau-xG)];

      h = H\g;

      stepsize = 1;

      hD = h(1:m-1);
      k = (hD > 0);
      if sum(k) > 0,
         stepsize = min(stepsize, min((xD(k)-beta)./hD(k)));
      end
      k = (hD < 0);
      if sum(k) > 0,
         stepsize = min(stepsize, min((alpha-xD(k))./(-hD(k))));
      end

      hG = h(m:mt);
      k = (hG > 0);
      if sum(k) > 0,
         stepsize = min(stepsize, min((xG(k)+tau)./hG(k)));
      end
      k = (hG < 0);
      if sum(k) > 0,
         stepsize = min(stepsize, min((tau-xG(k))./(-hG(k))));
      end
      stepsize = 0.9*stepsize;

      while stepsize >= 0.001,
         xnew = x - stepsize * h;
         xD = xnew(1:m-1,1);
         xG = xnew(m:mt,1);
         A(:) = A0+AA*xnew;
         B = B0d + BBd*xD;
         e = real(eig(lambda*diag(B)-A));

         if min(e) <= 0 | ...
            -log(prod([e; xD-beta; alpha-xD; xG+tau; tau-xG])) >= phi,
            stepsize = stepsize/10;
         else
            x = xnew;
            break;
         end
      end

      if stepsize < 0.001,
         break;
      end
   end

   while 1,
      xD    = x(1:m-1,1);
      xG    = x(m:mt,1);
      A(:)  = A0+AA*x;
      B     = B0d+BBd*xD;
      F    = lambda*diag(B)-A;
      Finv = inv(F);

% compute barrier function
      phi   = -log(real(det(F))) ...
              -log(prod([xD-beta; alpha-xD; xG+tau; tau-xG]));

% compute gradient of barrier function
      g = - real(Finv(:)'*(lambda*BB-AA))' ...
          - [(1)./(xD-beta)-(1)./(alpha-xD); (1)./(xG+tau)-(1)./(tau-xG)];

% compute Hessian of barrier function
      FF   = zeros(n*n,mt);
      FF(:) = Finv*reshape(lambda*BB-AA,n,n*mt);
      W     = zeros(n);
      H     = zeros(mt);

      for i=1:mt,
         W(:) = FF(:,i);
         W = W';
         H(i,1:i) = real(W(:)'*FF(:,1:i));
      end

      H = H + diag([(1)./((xD-beta).^2)+(1)./((alpha-xD).^2); ...
                    (1)./((xG+tau).^2)+(1)./((tau-xG).^2)]);
      H = H + H' - diag(diag(H));
      while rcond(H) < 1e-15,
         H = H + 1e-13*norm(H,'fro')*eye(mt);
      end

% compute tangent line to path of center
      h = H\g;

% check if x-h satisfies Goldstein test

      gtest = 0;
      xnew  = x - h;
      xD    = xnew(1:m-1,1);
      xG    = xnew(m:mt,1);
      A(:)  = A0+AA*xnew;
      B     = B0d + BBd*xD;
      w     = [real(eig(lambda*diag(B)-A)); xD-beta; alpha-xD; xG+tau; tau-xG];

      if min(w) <= 0,
         gtest = 0;
      else
         pp = g'*h;
         t1 = -log(prod(w));
         t2 = phi - 0.1*pp;
         t3 = phi - 0.9*pp;
         if t1 >= t3 & t1 < t2,
            gtest = 1;
         end
      end

% use x-h if Goldstein test is satisfied. otherwise, use
% Nesterov-Nemirovsky's stepsize length

      delta = sqrt(g'*h);

      if verbose == 1,
         fprintf ('-------------------> delta = %g\n', delta);
      end

      if gtest == 1 | delta <= 0.25,
         x = x - h;
      else
         x = x - h/(1+delta);
      end

% analytic center is found if delta is sufficiently small

      if delta < 1e-3,
         break;
      end
   end

   yf   = [lambda ; x];
   yw   = yf;
   Fb   = (Finv*diag(B))';
   w    = Fb(:)';
   h1   = H\(real(w*FF)');
   hn   = norm(h1);
   y    = [lambda-c/hn ; x+c*h1/hn];
   xD   = y(2:m,1);
   xG   = y(m+1:mt+1,1);
   A    = zeros(n);
   A(:) = A0+AA*y(2:mt+1);
   B    = B0d+BBd*xD;

   pos = 1;
   if min([xD-beta; alpha-xD; xG+tau; tau-xG]) <= 0 | ...
      min(real(eig(y(1)*diag(B)-A))) <= 0,
      pos = 0;
   end

   while pos == 1,
      y2   = y;
      y    = y+1.5*(y-yw);
      xD   = y(2:m,1);
      xG   = y(m+1:mt+1,1);
      A(:) = A0+AA*y(2:mt+1);
      B    = B0d+BBd*xD;
      yw   = y2;

      pos = 1;
      if min([xD-beta; alpha-xD; xG+tau; tau-xG]) <= 0 | ...
         min(real(eig(y(1)*diag(B)-A))) <= 0,
         pos = 0;
      end
   end

   while 1,
      y1   = (y+yw)/2;
      xD   = y1(2:m,1);
      xG   = y1(m+1:mt+1,1);
      A(:) = A0+AA*y1(2:mt+1);
      B    = B0d+BBd*xD;

      pos = 1;
      if min([xD-beta; alpha-xD; xG+tau; tau-xG]) <= 0 | ...
         min(real(eig(y1(1)*diag(B)-A))) <= 0,
         pos = 0;
      end

      if pos == 1,
         yw = y1;
      else
         y = y1;
      end

      if norm(y-yw) < norm(y-yf)*theta,
         break;
      end
   end

   c = norm(yw-yf);
   x = yw(2:mt+1);
end
%
% ------- End of MUSOL4.M %
