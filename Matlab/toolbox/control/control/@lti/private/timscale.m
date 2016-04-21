function [Ts,Tf] = timscale(a,b,c,x0,Tf)
%TIMSCALE  Returns the sampling time and simulation horizon for
%     continuous-time response simulations.
%
%     [TS,TF] = TIMSCALE(A,B,C,X0)  returns adequate step size TS 
%     and duration time TF to simulate the time response of continuous
%     state-space systems (A,B,C).  Set X0 = [] for the step response
%     and  B = [] for the undriven response with initial state X0.
%
%     TS = TIMSCALE(A,B,C,X0,TF) estimates the step size TS given
%     the simulation time TF.
%
%     TIMSCALE attempts to produce a simulation time TF that ensures the
%     output responses have decayed to approximately 1% of their initial
%     or peak values. 

%       Author: P. Gahinet, 4-18-96
%	Copyright 1986-2002 The MathWorks, Inc. 
%	$Revision: 1.16 $  $Date: 2002/04/10 05:53:23 $


% Parameters
toljw = sqrt(eps);
st = 0.01;  % settling time parameter
minpts = 100;

if nargin<5,  Tf = [];  end
NoTf = isempty(Tf);

% Compute eigendecomposition
[v,r] = eig(a);
r = diag(r);    % system modes 

% Treat unstable or marginally stable cases first:
rns = r(real(r) >= -toljw);   % all (nearly) unstable modes
realns = real(rns);
if any(realns>toljw),
   % Unstable system: simulate until exp(m*t)>10
   if NoTf,  
      Tf = log(10)/max(realns);  
   end
   Ts = Tf/50;
   return
elseif ~isempty(rns),
   % Marginally stable system
   if NoTf,
      if all(abs(rns)<1e-5),   %  only integrators
         rs = (real(r)<-1e-3);
         Tf = [ones(~any(rs),1) , -10./max(real(r(rs)))];
      else
         Tf = 75/(1+max(abs(rns)));
      end
   end
   Ts = Tf/100;
   return
end


% Get initial condition for equivalent free response
if isempty(x0),  
   x0 = a\b;  
end

% Quick exit if A = [], B = 0, or C = 0
if ~any(x0(:)) | ~any(c(:)),
   Ts = 0.1;
   if NoTf,  Tf = 1;  end
   return
end

% Stable cases:
if rcond(v) > eps^(2/3),
   % Eigenvector-based estimation: apply diagonalizing change of coordinates
   [ny,nx] = size(c);
   c =  c * v;
   x0 = v\x0;

   % Estimate peak deviation from DC value for each output channel based on
   %     yij(t) - yij(inf) = sum_k c(i,k) x0(k,j) exp(rk*t)
   ax0 = max(abs(x0),[],2);
   rpeak = abs(c)' .* ax0(:,ones(1,ny));   % max_j |c(i,k) x0(k,j)|, nx-by-ny
   peak = eps + max(rpeak,[],1);           % max_j,k |c(i,k) x0(k,j)|, 1-by-ny
   contrib = max(rpeak ./ peak(ones(1,nx),:),[],2);         % contribution of each mode
   resfact = ((2/pi)*atan2(abs(imag(r)),abs(real(r)))).^2;  % resonance factor

   % Identify dominant modes
   % contrib>=0.99*max(contrib) added so that idom is always nonempty
   idom = find(contrib>=st./(1+9*resfact) | contrib>=0.99*max(contrib));
   domr = r(idom);  resfact = resfact(idom);
   contrib = max(1.5*st,contrib(idom));  % so that st/contrib<1 and Tf>0...
   
   % Final time TF is function of the longest settling time for stable 
   % dominant modes as determined by
   %             contrib(k) * exp(-Re(rk)*t) < st
   [Tfmax,i] = max(log(st./contrib./(1+1.5*contrib)) ./ real(domr));
   tfmod = abs(domr(i));
   if NoTf,  Tf = Tfmax;   end

   % Sample time TS is determined by fastest dominant mode with significant 
   % contribution to peak output
   fastmod = max(abs(domr(contrib>0.1)));    % fastest mode with >10% contrib
   fastres = max(abs(domr(resfact>0.8)));    % fastest resonant mode
   npts = (1+4*any(fastmod*Tf>minpts)) * minpts; 
   Ts = min([0.2./tfmod , 0.3./fastres , Tf/npts]);

elseif NoTf,
   % Non diagonalizable case: use powers of exp(Tf0*a) to estimate Tf
   Tf = -0.05/min(real(r));   % initial (conservative) guess for Tf
   exptfa = expm(Tf*a);
   k = 0;

   % Double Tf until response has settled
   peak = norm(c*x0,1);
   kset = 0;   
   while k<30 & kset<3,
      nyt = norm(c*exptfa*x0,1);
      if nyt < max(100*eps,st*peak),
         % Increment KSET (counts iterates within settling tolerance)
         kset = kset + 1;
      else
         kset = 0;
      end
      peak = max(peak,nyt);
      Tf = 2*Tf;
      exptfa = exptfa * exptfa;
      k = k+1;
   end
   Tf = Tf/2^kset;  
   Ts = 0.01*Tf;
   Ts = sqrt(Ts * min(Ts,1/max(abs(r))));
   
else
   % Non diagonalizable case with specified Tf
   Ts = sqrt(0.01*Tf/max(abs(r)));
   
end


% There should be at least MINPTS samples
Ts = Tf/max(minpts,floor(Tf/Ts));

% end timscale


