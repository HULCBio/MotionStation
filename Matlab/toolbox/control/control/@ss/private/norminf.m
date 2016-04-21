function [gpeak,fpeak] = norminf(a,b,c,d,e,tol)
%NORMINF  Compute the peak gain GPEAK of the continuous-time frequency 
%   response
%                                   -1
%             G (s) = D + C (sE - A)  B .
%
%   The norm is finite if and only if (A,E) has no eigenvalue on the 
%   imaginary axis.  TOL is the desired relative accuracy on GPEAK, 
%   and FPEAK is the frequency such that:
%
%                 || G ( j * PEAKF ) ||  =  GPEAK .
%
%   See  NORM.

%    Based on the algorithm described in
%        Bruisma, N.A., and M. Steinbuch, ``A Fast Algorithm to Compute
%        the Hinfinity-Norm of a Transfer Function Matrix,'' Syst. Contr. 
%        Letters, 14 (1990), pp. 287-293.

%       Author(s):  P. Gahinet, 5-13-95.
%       Copyright 1986-2004 The MathWorks, Inc.
%	$Revision: 1.12.4.3 $  $Date: 2004/04/10 23:13:44 $


% Tolerance for jw-axis mode detection
toljw1 = 100 * eps;       % for simple roots
toljw2 = 10 * sqrt(eps);  % for double root

% Problem dimensions
[ny,nu] = size(d);
ZeroD = ~any(d(:));
nx = size(a,1);
if isempty(e),
   desc = 0;
   e = eye(nx);
else
   desc = 1;
end

% Quick exit in limit cases
if nx==0 | norm(b,1)==0 | norm(c,1)==0,
   gpeak = norm(d);  fpeak = 0;
   return
end

% Look for jw-axis modes (infinite norm)
if desc
    r = eig(a,e);
else
    r = eig(a);
end
ar2 = abs(real(r));  % mag. of real part
w0 = abs(r);         % fundamental frequency
[rmin,i] = min(ar2);
if rmin < eps*(1000 + max(w0)),
   gpeak = Inf;  fpeak = abs(imag(r(i)));
   return
end

% Reduce (A,E) to (generalized) upper-Hessenberg form for
% fast frequency response computation and compute the poles
% REVISIT: need generalized Hessenberg form
if norm(a,1)+desc*norm(e,1)>1e3*max(w0),
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
% Add frequency w=0 and set GMIN = || D || and FPEAK to infinity 
ikeep = find(imag(r)>=0 & w0>0);
offset2 = max(0.25,1-2*(ar2(ikeep)./w0(ikeep)).^2);
testfrq = [0; w0(ikeep).*sqrt(offset2)];  % test frequencies
gmin = norm(d);
fpeak = Inf;


% Compute lower estimate GMIN as max. gain over selected frequencies
j = sqrt(-1);
for w=testfrq',
   gw = norm(d+cc*(((j*w)*ee-aa)\bb));
   if gw > gmin,
      gmin = gw;   fpeak = w;
   end
end
if gmin==0,
   gpeak = 0; fpeak = 0; 
   return
end

% Modified gamma iterations (Bruisma-Steinbuch algorithm) start:
OK = 1;
while OK,
   % Test if G = (1+TOL)*GMIN qualifies as upper bound
   g = (1+tol) * gmin;
   % Compute finite eigenvalues of Hamiltonian pencil
   heigs = hpeig(a,b,c/g,d/g,e);
   mag = abs(heigs);
   % Detect jw-axis modes.  Test is based on a round-off level of 
   % eps*rho(H) (after balancing) resulting in worst-case 
   % perturbations of order sqrt(eps*rho(H)) on the real part
   % of poles of multiplicity two (typical as g->norm(sys,inf))
   jweig = heigs(abs(real(heigs)) < toljw2*(1+mag)+toljw1*max(mag));
   
   % Compute frequencies where gain G is attained and 
   % generate new test frequencies
   ws = imag(jweig);
   ws = unique(max(eps,ws(ws>0)));
   lws = length(ws);
   if lws<=1,
      % No jw-axis eigenvalues for G = GMIN*(1+TOL): we're done
      gpeak = gmin;
      return
   end

   % Form the vector of mid-points and compute
   % gain at new test frequencies
   gmin0 = gmin;   % save current lower bound
   ws = sqrt(ws(1:lws-1).*ws(2:lws));
   for ct=1:lws-1
      w = ws(ct);
      gw = norm(d+cc/((j*w)*ee-aa)*bb);
      if gw > gmin,
         gmin = gw;  fpeak = w;
      end
   end

   % If lower bound has not improved, exit (safeguard against undetected 
   % jw-axis modes of Hamiltonian matrix)
   if gmin < gmin0 * (1+tol/10), 
      gpeak = gmin;
      return
   end
end %while
