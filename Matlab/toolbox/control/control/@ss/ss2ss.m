function sys = ss2ss(sys,T)
%SS2SS  Change of state coordinates for state-space models.
%
%   SYS = SS2SS(SYS,T) performs the similarity transformation 
%   z = Tx on the state vector x of the state-space model SYS.  
%   The resulting state-space model is described by:
%
%               .       -1        
%               z = [TAT  ] z + [TB] u
%                       -1
%               y = [CT   ] z + D u
%
%   or, in the descriptor case,
%
%           -1  .       -1        
%       [TET  ] z = [TAT  ] z + [TB] u
%                       -1
%               y = [CT   ] z + D u  .
%
%   SS2SS is applicable to both continuous- and discrete-time 
%   models.  For LTI arrays SYS, the transformation T is 
%   performed on each individual model in the array.
%
%   See also CANON, SSBAL, BALREAL.

%	 Clay M. Thompson  7-3-90,  P. Gahinet 5-9-96
%	 Copyright 1986-2002 The MathWorks, Inc. 
%	 $Revision: 1.17 $  $Date: 2002/04/10 06:00:29 $

error(nargchk(2,2,nargin))

% Check dimensions
Nx = size(sys,'order');
tsizes = size(T);
if length(tsizes)>2 | tsizes(1)~=tsizes(2),
   error('T must be a square 2D matrix.')
elseif length(Nx)>1
   error('Not defined for state-space arrays with varying number of states.')
elseif Nx~=tsizes(1),
   error('State-space model SYS must have as many states as rows in T.')
end

% LU decomposition of T
[l,u,p] = lu(T);

% Perform coordinate transformation
lwarn = lastwarn;warn = warning('off');
AllFinite = 1;
for i=1:prod(size(sys.a)),
   sys.a{i} = T*((sys.a{i}/u)/l)*p;
   sys.b{i} = T*sys.b{i};
   sys.c{i} = ((sys.c{i}/u)/l)*p;
   if ~isempty(sys.e{i}),
      sys.e{i} = T*((sys.e{i}/u)/l)*p;
   end
   AllFinite = AllFinite & all(isfinite(sys.a{i}(:))) & ...
      all(isfinite(sys.c{i}(:))) & all(isfinite(sys.e{i}(:)));
end
warning(warn);lastwarn(lwarn);

% Check for singular T
if ~AllFinite,
   error('State similarity matrix T is singular to working precision.')
elseif rcond(u)<eps & ~isequal(T,diag(diag(T))),
   warning('State similarity matrix T is close to singular or badly scaled.')
end

% Delete state names
sys.StateName(1:Nx,1) = {''};



