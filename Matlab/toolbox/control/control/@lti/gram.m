function W = gram(sys,type)
%GRAM  Controllability and observability gramians.
%
%   Wc = GRAM(SYS,'c') computes the controllability gramian of 
%   the state-space model SYS (see SS).  
%
%   Wo = GRAM(SYS,'o') computes its observability gramian.
%
%   In both cases, the state-space model SYS should be stable.
%   The gramians are computed by solving the Lyapunov equations:
%
%     *  A*Wc + Wc*A' + BB' = 0  and   A'*Wo + Wo*A + C'C = 0 
%        for continuous-time systems        
%               dx/dt = A x + B u  ,   y = C x + D u
%
%     *  A*Wc*A' - Wc + BB' = 0  and   A'*Wo*A - Wo + C'C = 0 
%        for discrete-time systems   
%           x[n+1] = A x[n] + B u[n] ,  y[n] = C x[n] + D u[n].
%
%   For arrays of LTI models SYS, Wc and Wo are double arrays 
%   such that 
%      Wc(:,:,j1,...,jN) = GRAM(SYS(:,:,j1,...,jN),'c') .  
%      Wo(:,:,j1,...,jN) = GRAM(SYS(:,:,j1,...,jN),'o') .  
%
%   Rc = GRAM(SYS,'cf') and Ro = GRAM(SYS,'of') return the Cholesky
%   factors of gramians (Wc = Rc'*Rc and Wo = Ro'*Ro).
%
%   See also SS, BALREAL, CTRB, OBSV.

%   J.N. Little 3-6-86
%   P. Gahinet  6-27-96
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.13.4.1 $  $Date: 2002/09/01 23:06:33 $

%   Laub, A., "Computation of Balancing Transformations", Proc. JACC
%     Vol.1, paper FA8-E, 1980.

if nargin~=2,
   error('GRAM requires two input arguments.')
elseif ~isa(sys,'ss'),
   error('SYS must be a state-space model.')
elseif ~isstr(type) || ~any(lower(type(1))=='co')
   error('Second input must be either ''c'' or ''o''.');
end
FactorFlag = any(type=='f');

% Extract data
try
   [a,b,c,d] = ssdata(sys);
catch
   error('Not applicable to arrays of models with variable number of states.')
end
sizes = size(d);
Nx = size(a,1);
W = zeros([Nx Nx sizes(3:end)]);

% Handle various cases
if sys.Ts==0,
   LyapSolver = 'lyapchol';
else
   LyapSolver = 'dlyapchol';
end

% Loop over each model
for k=1:prod(sizes(3:end)),
   try
      switch lower(type(1))
         case 'c'
            R = feval(LyapSolver,a(:,:,k),b(:,:,k));
         case 'o'
            R = feval(LyapSolver,a(:,:,k)',c(:,:,k)');
      end
   catch
      error('System SYS must be stable.')
   end
   
   if FactorFlag
      W(:,:,k) = R;
   else
      W(:,:,k) = R' * R;
   end
end
