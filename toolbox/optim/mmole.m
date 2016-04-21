function[val,grad,H] = mmole(x,DM)
%MMOLE	Molecular distance problem
%   
%   This is used by MOLECULE.
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   INPUT:
%     x -  Current positions of the atoms (on real line)
%    DM -  Sparse `distance matrix'.
%        
%   OUTPUT:
%   val -  The value of the distance function:
%          Sum over (i,j) in DM: [(x(i)-x(j))^2 -dist^2]^2 and
%          add the term (x(1)-1)^2) to force x(1) to 1 (arbitrarily)
%          and thereby remove the singularity due to translation.
%  grad -  The gradient of the distance function. 
%  H    -  Sparse Hessian matrix of distance function. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%

% Javier Pena, 8-18-95
% Copyright 1990-2004 The MathWorks, Inc.
% $Revision: 1.6.4.1 $  $Date: 2004/02/07 19:13:15 $

% Evaluate the distance function.
[I,J,dist] = find(DM);
[n,dumm] = size(x) ;
N = n/2 ;
soln = reshape(x,N,2) ;

soln = [[.25 .25]; [.25 .75]; [.75 .25]; soln] ; 
term1 = soln(I,:) - soln(J,:);
term1sq = term1.*term1 ;
term2 = (term1.*term1)*[1 1]';
term3 = term2 - dist.*dist;
val = term3'*term3;
N = N + 3 ;
n = n + 6 ;

% Evaluate gradient
if nargout > 1
   ndist = length(dist) ;
   grad = zeros(N,2) ;
   for k = 1:ndist
      i = I(k) ; j = J(k) ;
      if i > j
         grad(i,:) = grad(i,:) + 4*term3(k)*term1(k,:) ;  
         grad(j,:) = grad(j,:) - 4*term3(k)*term1(k,:) ;  
      end ;
   end ;
   
   % Let's keep points 1, 2 and 3 fixed
   grad(3,:) = [] ;
   grad(2,:) = [] ;
   grad(1,:) = [] ;
   grad = reshape(grad,n-6,1) ;
end ;

% Evaluate hessian
if nargout > 2
   H = sparse(n,n) ;
   for k = 1:ndist
      i = I(k); j = J(k);
      if i > j
         H(i,j) = H(i,j) -8*term1sq(k,1)-4*term3(k);
         H(j,i) = H(i,j);
         H(i,N+i) = H(i,N+i)+ 8*term1(k,1)*term1(k,2); 
         H(N+i,i) = H(i,N+i);
         H(i,N+j) = H(i,N+j) - 8*term1(k,1)*term1(k,2); 
         H(N+j,i) = H(i,N+j);
         H(j,N+i) = H(j,N+i) - 8*term1(k,1)*term1(k,2); 
         H(N+i,j) = H(j,N+i);
         H(j,N+j) = H(j,N+j) + 8*term1(k,1)*term1(k,2); 
         H(N+j,j) = H(j,N+j);
         H(N+i,N+j) = H(N+i,N+j) -8*term1sq(k,2) - 4*term3(k); 
         H(N+j,N+i) = H(N+i,N+j);
         H(i,i) = H(i,i) + 8*term1sq(k,1) + 4*term3(k); 
         H(j,j) = H(j,j) + 8*term1sq(k,1) + 4*term3(k); 
         H(N+i,N+i) = H(N+i,N+i) + 8*term1sq(k,2) + 4*term3(k); 
         H(N+j,N+j) = H(N+j,N+j) + 8*term1sq(k,2) + 4*term3(k);
      end ; 
   end ;
   % Recall we're keeping points 1, 2 and 3 fixed
   H(N+3,:) = [] ;
   H(N+2,:) = [] ;
   H(N+1,:) = [] ;
   H(3,:) = [] ;
   H(2,:) = [] ;
   H(1,:) = [] ;
   H(:,N+3) = [] ;
   H(:,N+2) = [] ;
   H(:,N+1) = [] ;
   H(:,3) = [] ;
   H(:,2) = [] ;
   H(:,1) = [] ;
end


