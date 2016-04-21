function [gpeak,fpeak] = dnorminf(a,b,c,d,e,tol)
%DNORMINF  Compute the peak gain GPEAK of the discrete-time frequency 
%      response:
%                                        -1
%                  G (z) = D + C (zE - A)  B .
%
%      The norm is finite if and only if (A,E) has no eigenvalue on the 
%      unit circle.  TOL is the desired relative accuracy on GPEAK, 
%      and FPEAK is the frequency such that:
%
%                               j*FPEAK
%                       || G ( e        ) ||  =  GPEAK
%
%      See  NORM.

%    Based on the algorithm described in
%        Bruisma, N.A., and M. Steinbuch, ``A Fast Algorithm to Compute
%        the Hinfinity-Norm of a Transfer Function Matrix,'' Syst. Contr. 
%        Letters, 14 (1990), pp. 287-293.

%   Author(s):  P. Gahinet, 5-13-95.
%   Copyright 1986-2004 The MathWorks, Inc.
%	 $Revision: 1.11.4.3 $  $Date: 2004/04/10 23:13:43 $


% Tolerance for detection of unit circle modes 
toluc1 = 100 * eps;       % for simple roots
toluc2 = 10 * sqrt(eps);  % for double root

% Problem dimensions
[ny,nu] = size(d);
nx = size(a,1);
if isempty(e),
   desc = 0;
   e = eye(nx);
else
   desc = 1;
end

% Quick exits
if nx==0 | norm(b,1)==0 | norm(c,1)==0,
   gpeak = norm(d); fpeak = 0;
   return
end

% Look for unit-circle modes (infinite norm)
if desc
    r = eig(a,e);
else
    r = eig(a);
end
[ucdist,i] = min(abs(1-abs(r)));
if ucdist < 1000*eps,
   gpeak = Inf;  fpeak = abs(angle(r(i)));
   return
end

% Reduce (A,E) to (generalized) upper-Hessenberg form for
% fast frequency response computation and compute the poles
% REVISIT: need generalized Hessenberg form
if norm(a,1)+desc*norm(e,1)>1e3*max(abs(r)),
   % Use preliminary balancing to prevent loss of accuracy
   % in Hessenberg reduction
   [aa,ee,sx,px] = aebalance(a,e);
   bb(px,:) = lrscale(b,1./sx,[]);
   cc(:,px) = lrscale(c,[],sx);
else
   aa = a;  ee = e;  bb = b; cc = c;
end

if desc,
   % Descriptor case
   [aa,ee,q,z] = qz(aa,ee);
   bb = q*bb;     
   cc = cc*z;
else
   [u,aa] = hess(aa);
   bb = u'*bb;    
   cc = cc*u;
end


% Build a vector TESTFRQ of test frequencies containing the peaking 
% frequency for each mode (or an appx thereof for non-resonant modes).
sr = log(r(r~=0));                           % equivalent jw-axis modes:
asr2 = abs(real(sr));                        % magnitude of real part
w0 = abs(sr);                                % fundamental frequency
ikeep = find(imag(sr)>=0 & w0>0);
testfrq = w0(ikeep).*sqrt(max(0.25,1-2*(asr2(ikeep)./w0(ikeep)).^2));

% Back to unit circle, and add z = exp(0) and z = exp(pi)
testz = [exp(sqrt(-1)*testfrq) ; -1 ; 1];

% Compute lower estimate GMIN as max. gain over test frequencies
% RE: the norm is always greater then norm(d) (cf. LMI characterization
%     requires B'*X*B+D'*D-g^2*I < 0).  However the value norm(d) may
%     not be achieved at any frequency, so we don't include it.
gmin = 0;
for z=testz.',
   gw = norm(d+(cc/(z*ee-aa))*bb);
   if gw > gmin,
      gmin = gw;  fpeak = abs(angle(z));   
   end
end
if gmin==0,
   gpeak = 0;  fpeak = 0; 
   return
end

% Modified gamma iterations (Bruisma-Steinbuch algorithm) start:
OK = 1;
while OK,
   % Test if G = (1+TOL)*GMIN qualifies as upper bound
   g = (1+tol) * gmin;
   % Compute finite eigenvalues of symplectic pencil
   heigs = speig(a,b,c/g,d/g,e);
   mag = abs(heigs);
   % Detect unit-circle eigenvalues
   uceig = heigs(abs(1-mag) < toluc2+toluc1*max(mag));
  
   % Compute frequencies where gain G is attained and 
   % generate new test frequencies
   ang = angle(uceig);
   ang = unique(max(eps,ang(ang>0)));
   lan = length(ang);
   if lan<=1,
      % No unit-circle eigenvalues for G = GMIN*(1+TOL): we're done
      gpeak = gmin; return
   end

   % Form the vector of mid-points and compute
   % gain at new test frequencies
   gmin0 = gmin;   % save current lower bound
   testz = exp(sqrt(-1)*(ang(1:lan-1)+ang(2:lan))/2);
   for ct=1:lan-1
      z = testz(ct);
      gw = norm(d+(cc/(z*ee-aa))*bb);
      if gw > gmin,
         gmin = gw;  fpeak = abs(angle(z));
      end
   end

   % If lower bound has not improved, exit (safeguard against undetected
   % unit-circle eigenvalues).
   if gmin < gmin0 * (1+tol/10),
      gpeak = gmin; return
   end
end %while

