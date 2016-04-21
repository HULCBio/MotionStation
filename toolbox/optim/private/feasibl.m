function [x, flag]  = feasibl(A,bvec,xstart,R,p,RP,pp,D,tol);
%FEASIBL Find nearest feasible point.
%	 x  = FEASIBL(A,bvec,xstart,R,p,RP,pp,D,tol) determines
%   the point nearest to xstart satisfying A*x-bvec = 0.
%
%       Should we require A to be m-by-n where m <= n ?
%     if dep rows, shouldn't we pass tol on to the next call?

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.5.4.3 $  $Date: 2004/02/07 19:13:36 $

% Initialization
flag = 1;
ttol = 1e-12;
if nargin < 2
   error('optim:feasibl:NotEnoughInputs', ...
         'Function feasible expects at least 2 input arguments.')
end
[t,n] = size(A);
if ~issparse(A)
   A=sparse(A);
end

if nargin < 3, 
   xstart = zeros(n,1);
end
if isempty(xstart), 
   xstart = zeros(n,1); 
end
if nargin < 4, 
   R = []; 
end
if nargin < 5, 
   p = (1:n); 
end
if isempty(p), 
   p = (1:n); 
end
if nargin < 6, 
   RP = []; 
end
if nargin < 7, 
   pp = (1:n);
end 
if isempty(pp), 
   pp = (1:n);
end
if nargin < 8, 
   D = speye(n); 
end, 
if isempty(D),  
   D = speye(n); 
end
if nargin <9, 
   tol = (10^7)*eps; 
end
if isempty(tol), 
   tol = (10^7)*eps; 
end
% Check if xstart satifies the constraints
b = bvec - A*xstart;
normb = norm(b);
if norm(b) <= tol*norm(bvec)
   x = xstart;
   return;
end
xinit = xstart;  % store in xinit 

% Compute R; also, check for singularity and resolve
if isempty(R)
   p = colamd(A'); 
   R = qr((A(p,:))',0);
   rmin = min(abs(diag(R)));
   if rmin < ttol
      flag = -1;
      x = xstart;
      %%disp('FEASIBL has determined singularity in A.')
      %%disp('Removing dependent rows and solving modified system.')
      %%[AA,bb] = dep(A,[],bvec);
      %%x = feasibl(AA,bb,xstart,[],[],[],[],D,tol);
      return
   end
end

% Compute the feasible point.
if isempty(RP), 
   RP = speye(n); 
end
[x,b,normb2] = solvesystem(A,bvec,xstart,R,b,p,D,RP,pp);

if normb2 <= tol*norm(bvec);
   return
else
   xstart = x;
   [x,b,normb3] = solvesystem(A,bvec,xstart,R,b,p,D,RP,pp);
end
if normb2 <= min(normb3,normb),
   x = xstart; 
end
if normb <= min(normb2,normb3), 
   x = xinit;
end

function [x,b,normb] = solvesystem(A,bvec,xstart,R,b,p,D,RP,pp)
 
v(p,1) = R\(R'\b(p));

s = D*(A'*v); 
ss = RP'\s(pp); 
s(pp,1) = RP\ss;
s = full(D*s);  

x = xstart + s;
b = bvec - A*x;
normb = norm(b);
