function sysr = minreal(sys,tol)
%MINREAL  Minimal realization and pole-zero cancellation.
%
%   MSYS = MINREAL(SYS) produces, for a given LTI model SYS, an
%   equivalent model MSYS where all cancelling pole/zero pairs
%   or non minimal state dynamics are eliminated.  For state-space 
%   models, MINREAL produces a minimal realization MSYS of SYS where 
%   all uncontrollable or unobservable modes have been removed.
%
%   MSYS = MINREAL(SYS,TOL) further specifies the tolerance TOL
%   used for pole-zero cancellation or state dynamics elimination. 
%   The default value is TOL=SQRT(EPS) and increasing this tolerance
%   forces additional cancellations.
%
%   For a state-space model SYS=SS(A,B,C,D),
%      [MSYS,U] = MINREAL(SYS)
%   also returns an orthogonal matrix U such that (U*A*U',U*B,C*U') 
%   is a Kalman decomposition of (A,B,C). 
%
%   See also SMINREAL, BALREAL, MODRED.

%   J.N. Little 7-17-86
%   Revised A.C.W.Grace 12-1-89, P. Gahinet 8-28-96
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.16 $  $Date: 2002/04/10 06:12:26 $

ni = nargin;
error(nargchk(1,2,ni))
if ni==1,
   tol = sqrt(eps);
end

% Look for pole/zero cancellations in each channel
sysr = sys;
for j=1:prod(size(sys.k)),
   % Perform reduction (denoise multiple roots to improve cancellation rate)
   [sysr.z{j},sysr.p{j}] = ...
      reducezp(mroots(sys.z{j},'roots',tol),mroots(sys.p{j},'roots',tol),tol);
end
   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [zr,pr] = reducezp(z,p,tol)
%REDUCEZP   Cancels matching pairs of poles and zeros
%           (within the relative tolerance TOL)
%           The system is assumed to be real

% Test for complex conjugate poles and zeros
RealFlag = isconjugate(z) & isconjugate(p);

% Init
zr = zeros(0,1);
pr = p;
if RealFlag
    % Separate complex conjugate pairs from simple zeros
    ccz = z(imag(z)>0,:);
    sz = z(imag(z)==0,:);
else
    % Treat all roots as simple in complex data case
    ccz = [];
    sz = z;
end

% Process complex conjugate pairs of zeros first, making sure 
% that each cancellation preserves the symmetry of PR wrt y-axis
ikeep = ones(size(ccz));
for m=1:length(ccz),
   % Find pole in PR closest to ZM = ccz(M)
   zm = ccz(m);
   [dmin,imin] = min(abs(pr-zm));

   if dmin<tol*(1+abs(zm)),
      % Cancel pair zm,pm and monitor complex/real simplifications
      ikeep(m) = 0;
      pm = pr(imin);

      if imag(pm), 
         % PM is complex: cancel (ZM,PM) and their conjugates
         icjg = find(pr==conj(pm));
         pr([imin , icjg(1)],:) = [];
      else
         % PM is real: add Z=(PM+2*REAL(ZM))/3 to sz
         sz = [sz ; (pm+2*real(zm))/3];
         pr(imin,:) = [];
      end
   end
end
ccz = ccz(logical(ikeep),:);

% Process simple zeros
ikeep = ones(size(sz));
for m=1:length(sz),
   % Find pole closest to ZM = sz(M)
   zm = sz(m);
   [dmin,imin] = min(abs(pr-zm));

   if dmin<tol*(1+abs(zm)),
      % Cancel pair zm,pm
      ikeep(m) = 0;
      pm = pr(imin);

      if RealFlag & imag(pm), 
         % PM is complex: replace its conjugate by P=(ZM+2*REAL(PM))/3
         icjg = find(pr==conj(pm));
         pr(icjg(1)) = (zm+2*real(pm))/3;
      end
      pr(imin,:) = [];
   end
end
sz = sz(logical(ikeep),:);


% Put ZR together
ncz = length(ccz);
zr(1:2:2*ncz,1) = ccz;
zr(2:2:2*ncz,1) = conj(ccz);
zr = [zr ; sz];

