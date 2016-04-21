function n = dtimscale(a,b,c,d,x0,Ts)
%DTIMSCALE  Returns the simulation horizon for discrete time response 
%     simulations.
%
%     N = DTIMSCALE(A,B,C,D,X0,TS) returns the number N of simulation
%     samples needed to reach adequate settling of the time response
%     of a discrete state-space systems (A,B,C,D).  Set X0 = [] for the 
%     step response, and B = [] for the undriven response with initial 
%     state X0.
%
%     DTIMSCALE attempts to produce a simulation time N that ensures the
%     output responses have decayed to approximately 1% of their initial
%     or peak values. 

%       Author: P. Gahinet, 5-7-96
%	Copyright 1986-2003 The MathWorks, Inc.
%	$Revision: 1.1.4.1 $  $Date: 2004/04/10 23:20:14 $


% Parameters
tol = sqrt(eps);
toldelay = 1e-5;
st = 0.01;
minpts = 20;

% Compute eigendecomposition
[v,r] = eig(a);
r = diag(r);    % system modes 
r1 = r - 1;
ndelays = sum(abs(r)<toldelay);  % count pure delays

% Treat unstable and marginally stable cases first:
rns = r(abs(r) >= 1-tol);
magrns = abs(rns);
if any(magrns>1+tol),
   % Unstable system: simulate until maxmod^n>100
   n = max(5,ceil(log(10)/log(max(magrns))));  
   return
elseif ~isempty(rns),
   % Marginally stable
   n = 50*max(1,1/(1+max(abs(log(rns)))/Ts));  
   return
end

% Get initial condition for equivalent free response
if isempty(x0),  
   x0 = (eye(size(a))-a)\b;  
end

% Quick exit if A = [], B = 0, or C = 0
if ~any(x0(:)) | ~any(c(:)),
   n = minpts;
   return
end

% Stable cases:
if rcond(v) > eps^(2/3),
   % Eigenvector-based estimation of N
   [ny,nx] = size(c);
   c =  c * v;
   x0 = v\x0;
   
   % Eliminate poles at zero and compute equivalent frequencies
   % RE: Ts is left out (normalized time scale for Ts = 1)
   idx = find(abs(r)>toldelay);
   r = r(idx);   c = c(:,idx);   x0 = x0(idx,:);    r1 = r1(idx);
   if isempty(r),
      n = minpts;  return
   end
   sr = log(r);  % equivalent s-domain poles

   % Estimate peak deviation from DC value for each output channel based on
   %     yij(t) - yij(inf) = sum_k c(i,k) x0(k,j) exp(rk*t)
   % RE: The impulse response at t=0 is d!
   ax0 = max(abs(x0),[],2);
   rpeak = abs(c)' .* ax0(:,ones(1,ny));  % max_j |c(i,k) x0(k,j)|,  nx-by-ny'
   peak = eps + max(rpeak,[],1);          % max_j,k |c(i,k) x0(k,j)|,  1-by-ny
   if any(d(:)),  peak = max([peak ; abs(d)'],[],1);  end
   contrib = max(rpeak ./ peak(ones(1,length(r)),:),[],2);    % contribution of each mode
   resfact = ((2/pi)*atan2(abs(imag(sr)),abs(real(sr)))).^2;  % resonance factor

   % Identify dominant modes
   idom = find(contrib>=st./(1+9*resfact) | contrib>=0.99*max(contrib));
   domr = r(idom);  resfact = resfact(idom);
   contrib = max(1.5*st,contrib(idom));    % so that st/contrib<1 & Ts>0...
   
   % N is function of the longest settling time for stable dominant modes
   n = max(log(st./contrib./(1+1.5*contrib)) ./ log(abs(domr)));
      
else
   % Non diagonalizable case: use powers of a to estimate Tf
   n = 1;   ak = a;   
   k = 0;

   % Double Tf until response has settled
   peak = norm(c*x0,1);
   kset = 0;   
   while k<30 & kset<3,
      nyt = norm(c*ak*x0,1);
      if nyt < max(100*eps,st*peak),
         % Increment KSET (counts iterates within settling tolerance)
         kset = kset + 1;
      else
         kset = 0;
      end
      peak = max(peak,nyt);  % update peak response value
      n = 2*n;
      ak = ak * ak;
      k = k+1;
   end
   n = n/2^kset;  

end


% Increase N when smaller than MINPTS
if n<minpts,  
   n = max(10,1.5*n);
end
n = ndelays+ceil(n);  % add contribution of pure delays
