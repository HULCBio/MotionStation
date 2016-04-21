% [X1,X2] = ricpen(H,L)
%       X = ricpen(H,L)
%
% Generalized Schur Solver for continuous-time Riccati equations.
%
% Computes the stabilizing solution  X = X2/X1  of the
% Riccati equation associated with the Hamiltonian pencil
%
%               [  A     F     S1 ]       [  E   0   0 ]
%   H - t L  =  [  G    -A'   -S2 ]  - t  [  0   E'  0 ]
%               [ S2'   S1'     R ]       [  0   0   0 ]
%
% The blocks   S1, S2, R  may be all empty.
%
% Assumptions:
%    * R  and  E are invertible,
%    * the pencil H - t L has no finite generalized eigenvalue on
%      the imaginary axis.
%
% When L is omitted, RICPEN solves the Riccati equation of Hamiltonian
% matrix H   (L and R are set to the default value L=I and R=[]).
% If  H - t L  has imaginary-axis eigenvalues,  X, X1, and X2 are
% empty on output. In addition, X is empty whenever X1 is singular.
%
%
% See also   CARE.

% Authors: A.J. Laub and P. Gahinet  10/93
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.7.2.3 $



function [x1,x2,d1,d2]=ricpen(h,le)

x1=[]; x2=[]; d1=[]; d2=[];

if size(h,1)~=size(h,2),
  error('H must be a square matrix');
elseif nargin == 1,
  le=eye(size(h));
elseif nargin>2,
  error(sprintf(...
     ['usage: X = ricpen(H,L) or [X1,X2] = ricpen(H,L)']));
end

% determine size of E
if norm(le,1)==0, return, end
m=0; i=size(h,1);
while max(abs(le(:,i)))==0,
  m=m+1; i=i-1;
end


n2=size(h,1)-m;
if 2*round(n2/2)~=n2,
  error('[ E  0 ; 0  E'' ]  must have even row size');
end
n=n2/2;     % number of states
e=le(1:n,1:n);



macheps=mach_eps;
toleig=macheps^(3/4);      % relative tolerance for imag. axis eigenvalues


%  compression if E is singular

if m>0,
   h2=h(:,n2+1:n2+m);
   h22=h2(n2+1:n2+m,:);

   % test whether R is invertible
   s=rcond(h22);
   if s < macheps,
     disp('RICPEN: R is singular to the machine precision');return
   elseif s > sqrt(mach_eps),
     h=h(1:n2,1:n2)-h(1:n2,n2+1:n2+m)/h22*h(n2+1:n2+m,1:n2);
     le=le(1:n2,1:n2);
   else
     [q,r] = qr(h2);
     h = q(:,m+1:m+n2)'*h(:,1:n2);
     le = q(:,m+1:m+n2)'*le(:,1:n2);
   end
end



% Do initial QZ algorithm; eigenvalues of the pencil E - t H
% will have a tendency to deflate out in the "desired" order


[aa,bb,q,z] = qz(h,le,'complex');

% Order eigenvalues; this part of the code is adapted from
% Kjell Gustafsson's genric m-file and will be replaced with
% a new real re-ordering code that works with a QZ algorithm
% implemented in real arithmetic; it may also be replaced
% with a simpler and more efficient complex code

% Find all eigenvalues outside the open left-half plane
daa = diag(aa);
dbb = diag(bb);
ind=real(daa./dbb) < -toleig;
if sum(ind) ~= n, return, end


% This part of the code is a direct translation of the sorting
% of 1x1 eigenvalue blocks in ACM TOMS Algorithm 590

j = find(ind(1:n2)==0);
k = find(ind(j(1)+1:n2)==1);
while ~isempty(k)
   j = j(1);
   k = k(1)+j;
   % Propagate element up the diagonal from k-th to j-th entry
   for l = k-1:-1:j
      l1 = l+1;
      % exchange elements l and l1 using EXCHQZ from Algorithm 590
      f = max(abs([aa(l1,l1),bb(l1,l1)]));
      altb = abs(aa(l1,l1)) < f;
      % construct the column transformation zt
      zt = givens((bb(l,l)*aa(l1,l1)-aa(l,l)*bb(l1,l1))/f, ...
                  (bb(l,l1)*aa(l1,l1)-aa(l,l1)*bb(l1,l1))/f);
      zt = [zt(2,:); zt(1,:)];
      aa(:,l:l1) = aa(:,l:l1)*zt;
      bb(:,l:l1) = bb(:,l:l1)*zt;
      z(:,l:l1) = z(:,l:l1)*zt;
      % construct the row transformation qt
      if altb
         qt = givens(bb(l,l),bb(l1,l));
      else
         qt = givens(aa(l,l),aa(l1,l));
      end
      aa(l:l1,:) = qt*aa(l:l1,:);
      bb(l:l1,:) = qt*bb(l:l1,:);
      ix = ind(l); ind(l) = ind(l1); ind(l1) = ix;
   end;
   % Find next element to shift
   j = find(ind(1:n2)==0);
   k = find(ind(j(1)+1:n2)==1);
end;


if nargin > 1,
  [q,r] = qr([e*z(1:n,1:n);z(n+(1:n),1:n)]);
  x1=q(1:n,1:n);  x2=q(n+(1:n),1:n);
else
  x1=z(1:n,1:n);  x2=z(n+(1:n),1:n);
end


% check that  X1'*X2 is symmetric
x12=x1'*x2;
if norm(x12-x12',1) > macheps^(1/4),
   x1=[], x2=[]; return
end


% Solve for X or make X1,X2 real  via ``QZ symmetrization trick''
[d1,d2,u,v] = qz(x1,x2,'complex');
d1=diag(d1);d2=diag(d2);

if nargout==1,
   if min(abs(d1)) < macheps,
     x1=[];
   else
     x1 = real(u'*diag(d2./d1)*u);
   end
else
   % make X1,X2 real
   rot=zeros(size(d1));
   ix1=find(abs(d1)>=abs(d2)); rot(ix1)=conj(d1(ix1))./abs(d1(ix1));
   ix2=find(abs(d1)<abs(d2));  rot(ix2)=conj(d2(ix2))./abs(d2(ix2));
   x1=real(u'*diag(d1.*rot)*u);
   x2=real(u'*diag(d2.*rot)*u);
end


% *** last line of ricpen.m ***
