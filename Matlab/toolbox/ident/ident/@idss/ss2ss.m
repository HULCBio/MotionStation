function sys = ss2ss(sys,T)
%SS2SS  Change of state coordinates for state-space models.
%
%   MOD = SS2SS(MOD,T) performs the similarity transformation 
%   z = Tx on the state vector x of the state-space model SYS.  
%   The resulting state-space model is described by:
%
%               .       -1        
%               z = [TAT  ] z + [TB] u + [TK] e
%                       -1
%               y = [CT   ] z + D u + e
%
%
%   SS2SS is applicable to both continuous- and discrete-time 
%   models.
%
%   Covariance information is lost in the transformation.

%       Copyright 1986-2001 The MathWorks, Inc.
%    $Revision: 1.3 $  $Date: 2001/04/06 14:22:24 $

error(nargchk(2,2,nargin))

% Check dimensions
 [A,B,C,D,K,X0] = ssdata(sys);
asizes = size(A);  Nx = asizes(1);
tsizes = size(T);
if length(tsizes)>2 | tsizes(1)~=tsizes(2),
   error('T must be a square 2D matrix.')
elseif Nx~=tsizes(1),
   error('MOD must have as many states as rows in T.')
end

% LU decomposition of T
[l,u,p] = lu(T);
if rcond(u)<eps,
   error('State similarity matrix T is singular.')
end

% Perform coordinate transformation
 
 sys = pvset(sys,'A',T*((A/u)/l)*p,'B',T*B,'K',T*K,'X0',T*X0,...
	     'C',((C/u)/l)*p);
 
  sys.As = T*((sys.As/u)/l)*p;
   sys.Bs = T*sys.Bs;
   sys.Ks = T*sys.Ks;
   sys.Cs = ((sys.Cs/u)/l)*p;
   sys.X0s = T*sys.X0s;
 
%sys.StateName(1:Nx) = {''};



