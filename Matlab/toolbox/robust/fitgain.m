function [a,b,c,d] = fitgain(mag,w,ord,wt,flag)
%FITGAIN Frequency response curve fit without phase information (PSD method).
%
% [SS_] = FITGAIN(MAG,W,ORD,WT,FLAG) or
% [A,B,C,D] = FITGAIN(MAG,W,ORD,WT,FLAG) produces a "stable" state-space
%    realization of the continuous magnitude curve "MAG".
%
%    Inputs:
%               mag ---- absolute magnitude array
%               w   ---- frequencies at which "mag" are evaluated (rad/sec)
%               ord ---- size of the realization
%    Optional:
%               wt  ---- weighting of the curve fit (default = ones(w))
%               flag --- display Bode plot (default), 0: no Bode plot
%
%    Outputs: (a,b,c,d) ---- stable realization of "MAG"
%
%  The algorithm uses the following 3-step procedure:
%                         2
%                   |G(s)|   = G(s) * G(-s)
%    Step 1: take the PSD of G(s), i.e. PSD = |G(s)|^2.
%    Step 2: use the MATLAB function "invfreqs.m" to fit the PSD
%            with a rational transfer function.
%    Step 3: Pull out the stable and minimum phase part of the realization.
%                          (done !!)

% R. Y. Chiang & M. G. Safonov
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.8.4.3 $
% All Rights Reserved.
% ------------------------------------------------------------------------

if exist('invfreqs')~=2,   % If the signal processing toolbox is not installed
   msg=[...
         'FITGAIN requires INVFREQS from the Signal Processing Toolbox';...         
         '    --- consider using FITD instead of FITGAIN.             ']
   error(msg)
   return
end

xyz = nargin;
if xyz < 4
   len = length(w);
   wt = ones(1,len);
   flag = 1;
end
%
psd  = mag.*mag;
[num,den] = feval('invfreqs',psd,w,2*ord,2*ord,wt);   % call invfreqs.m
k = 1;                           % strip out the leading zeros
numk = num;
while abs(num(1,k)) < 1.e-8
      numk = num(1,k+1:2*ord+1);
      k = k+1;
end
%
numk = numk/numk(1,1);           % make the polynomial monic
a1 = sqrt(numk(1,1));
[rk,ck] = size(numk);
%
if  ck > 1
   z = roots(numk);
   [rz,cz] = size(z);
   zmin = [];
   for s = 1:rz
      if real(z(s,1)) < 0
         zmin = [zmin;z(s,1)];
      end
   end
   nums = real(poly(zmin));
else
   nums = numk;
end
%
h = 1;                           % strip out the leading zeros
denk = den;
[rkd,ckd] = size(denk);
while abs(den(1,h)) < 1.e-8
      denk = den(1,h+1:2*ord+1);
      h = h+1;
end
%
b1 = sqrt(denk(1,1));
denk = denk/denk(1,1);           % make the polynomial monic
%
poo = roots(denk);
[rp,cp] = size(poo);
pstable = [];
for q = 1:rp
      if real(poo(q,1)) < 0
         pstable = [pstable;poo(q,1)];
      end
end
%
dens = real(poly(pstable));
if length(nums) > length(dens)
   error('Ill-conditioned result, try more frequency points ..');
end
[a,b,c,d] = tf2ss(a1*nums,b1*dens);
%
if nargout == 1
   ss_ = mksys(a,b,c,d);
   a = ss_;
end
%
if flag == 1
   [magfit,ph] = bode(a,b,c,d,1,w);
   loglog(w,mag,'x',w,magfit);
   title('Equation Error Method')
   xlabel('R/S (x: data; solid: fit)')
   ylabel('Log(Mag)');
end
%
% ------ End of FITGAIN.M % RYC/MGS %
