function [g,dceq] = dcgain(sys)
%DCGAIN  DC gain of LTI models.
%
%   K = DCGAIN(SYS) computes the steady-state (D.C. or low frequency)
%   gain of the LTI model SYS.
%
%   If SYS is an array of LTI models with dimensions [NY NU S1 ... Sp],
%   DCGAIN returns an array K with the same dimensions such that
%      K(:,:,j1,...,jp) = DCGAIN(SYS(:,:,j1,...,jp)) .  
%
%   See also NORM, EVALFR, FREQRESP, LTIMODELS.

%	Andy Potvin  12-1-95
%	Clay M. Thompson  7-6-90
%	Copyright 1986-2002 The MathWorks, Inc. 
%	$Revision: 1.16 $  $Date: 2002/04/10 06:02:40 $

% RE: DCEQ(i,j) = m  if  Hij(s) ~ s^m as s->0
%     For state-space models, m is set to 0 when g=0.
%     Used in BODERESP to determine true phase at s=0

error(nargchk(1,1,nargin));

% Loop over each model:
sizes = size(sys.d);
g = zeros(sizes);
dceq = struct('factor',zeros(sizes),'power',zeros(sizes));

for k=1:prod(sizes(3:end)),
   [g(:,:,k),dceq.factor(:,:,k),dceq.power(:,:,k)] = ...
      dcg(subsref(sys,substruct('()',{':' ':' k})));
end


%%%%%%%%%%%%%% Local functions %%%%%%%%%%%%%%%%%%%%%%%%

function [g,factor,power] = dcg(sys)
%DCG   DC gain of a single state-space model

[a,b,c,d,e,Ts] = dssdata(sys);
[ny,nu] = size(d);
nx = size(a,1);
power = zeros(ny,nu);

if isempty(a) | ~any(b(:)) | ~any(c(:)),
   % Static gain
   g = d;
   factor = d;

else
   if Ts==0,
      % Continuous-time: evaluate at s = 0
      aa = -a;
   else
      % Discrete-time: evaluate at z = 1
      aa = e - a;
   end
   
   % Compute response at DC
   % RE: Do not attempt detecting singularity of AA (AA can be poorly conditioned 
   %     while the DC gain is finite, e.g., for ss(zpk(1e10,[1e11 -1e11 1 -1],1e12))
   lwarn = lastwarn;warn = warning('off');
   if ny>nu,
       g = d + c * (aa\b);
   else
       g = d + (c/aa) * b;
   end
   factor = g;
   warning(warn);lastwarn(lwarn);
   
   % Seek local equivalent when DC gain is not finite
   if nx<100 & ~all(isfinite(factor(:)))
      % Poles at s=0 or z=1
      % Compute DC gain as limit for s->0 of D+C*inv(sI-A)*B
      tolzer = 1e3*eps;  % rel. tolerance for zero detection
       
      % Perform staircase reduction of sI+AA to
      %    [ sI+Ai    0  ]
      %    [   As   sI-L ]
      % with Ai invertible and L strictly lower triangular (nilpotent)
      % RE: L -> inv. subspace for s=0
      [aa,b,c,nxi] = staircase(aa,b,c,tolzer);
      
      % Block diagonalize to decouple the finite (sI+Ai) 
      % and infinite (sI-L) contributions to G(s) near s=0
      Ai = aa(1:nxi,1:nxi);
      L = -aa(nxi+1:nx,nxi+1:nx);
      T = lyap(L,Ai,aa(nxi+1:nx,1:nxi));
      b(nxi+1:nx,:) = b(nxi+1:nx,:) + T * b(1:nxi,:);
      c(:,1:nxi) = c(:,1:nxi) - c(:,nxi+1:nx) * T;
      
      % The gain near s=0 is 
      %    G(s) = D + Ci*(Ai\Bi) + Cs*Q(s) + o(s)
      % where 
      %    Q(s) = (sI-L)\Bs = Bs/s + L*Bs/s^2 + ... L^(n-1)*Bs/s^n
      % First evaluate finite part
      g = d + c(:,1:nxi)*(Ai\b(1:nxi,:));
      factor = g;
      
      % Add infinite contribution of Cs*Q(s) = G1/s +... Gn/s^n
      cs = c(:,nxi+1:nx);
      tol = tolzer * norm(c,1);
      q = b(nxi+1:nx,:);  % q = bs
      nq = norm(b,1);     % scale of q
      k = 1;   % power of 1/s
      while any(q(:)),
         gk = cs*q;                     % Gk = Cs*L^(k-1)*Bs
         nzk = (abs(gk) > tol * nq);    % non zero entries in Gk
         g(nzk) = Inf;                  % G(i,j)=Inf if Gk(i,j)~=0
         factor(nzk) = gk(nzk);
         power(nzk) = -k;
         % k -> k+1 update
         q = L * q;
         nq = max(nq,norm(q,1));
         k = k+1;
      end
   end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [a,b,c,nxi] = staircase(a,b,c,tolzer)
%STAIRCASE  Reduction to staircase form.
%
%   Reduces (A,B) to the lower triangular staircase form
%
%          [  Ai 0   ...  0  ]        [ B1 ]
%          [  *  0   ...  0  ]        [ B2 ]
%     A -> [  *  *  0     0  ]   B -> [ :  ]
%          [  :  :    ..  :  ]        [ :  ]
%          [  *  *        0  ]        [ :  ]
%
%   with Ai invertible of size NXI.

nxi = size(a,1);

% Column compression A -> [V'*A*V1 , 0]
[u,s,v] = svd(a);
s = diag(s);
nzsv = (s>tolzer*max(s));  % nonzero singular values

% Iterative reduction to staircase form
while ~all(nzsv),
   % Perform compression A(1:NXI,1:NXI) -> [V'*A(1:NXI,1:NXI)*V1,0]
   v1 = v(:,nzsv);
   a(1:nxi,1:nxi) = [v'*a(1:nxi,1:nxi)*v1 , zeros(nxi,nxi-size(v1,2))];
   a(nxi+1:end,1:nxi) = a(nxi+1:end,1:nxi) * v;
   b(1:nxi,:) = v'*b(1:nxi,:);
   c(:,1:nxi) = c(:,1:nxi)*v;
   
   % New "A" block is A(1:NXI,1:NXI) where NXI = col. size of V1
   nxi = size(v1,2);
   [u,s,v] = svd(a(1:nxi,1:nxi));
   s = diag(s);
   nzsv = (s>tolzer*max(s));  % invertible singular values
end







