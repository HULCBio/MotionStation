function [ax,bx,cx,dx,ay,by,cy,dy,aug] = ohkapp(varargin)
%OHKAPP Optimal Hankel norm approximation (stable plant).
%
% [SS_X,SS_Y,AUG] = OHKAPP(SS_,MRTYPE,IN) or
% [AX,BX,CX,DX,AY,BY,CY,DY,AUG] = OHKAPP(A,B,C,D,MRTYPE,IN) produces
%   an optimal Hankel norm approximation via descriptor system.
%   (AX,BX,CX,DX) is the reduced model, (AY,BY,CY,DY) is the
%   anticausal part of the solution.
%   The infinity norm of (G - Ghed) <= sum of the Kth Hankel s.v. to
%   nth Hankel s.v. times 2. NO BALANCING IS REQUIRED.
%
%   mrtype = 1, in = order "k" of the reduced model.
%
%   mrtype = 2, find a reduced order model such that the total error is
%             less than "in".
%
%   mrtype = 3, display Hankel singular values, prompt for order "k" (in
%             this case, no need to specify "in").
%
%   AUG = [max. Hank SV, state(s) removed, Error Bound, Hankel SV's].

% R. Y. Chiang & M. G. Safonov 4/11/87
% Copyright 1988-2004 The MathWorks, Inc.
% $Revision: 1.6.4.3 $
%--------------------------------------------------------------------
%

nag1=nargin;
[emsg,nag1,xsflag,Ts,a,b,c,d,mrtype,in]=mkargs5x('ss',varargin); error(emsg);
if Ts, error('LTI inputs must be continuous time (Ts=0)'), end

[ma,na] = size(a);
[md,nd] = size(d);
[hsv,p,q] = hksv(a,b,c);
%
if mrtype == 1
   kk = in+1;
   r = 1;
end
%
if mrtype == 2
   tails = 0;
   kk = 1;
   r = 1;
   for i = ma:-1:1
       tails = tails + hsv(i);
       if 2*tails > in
          kk = i+1;
          break
       end
   end
end
%
if mrtype == 3
   format short e
   format compact
   [mhsv,nhsv] = size(hsv);
   if mhsv < 60
      disp('    Hankel Singular Values:')
      hsv'
      for i = 1:mhsv
        if hsv(i) == 0
           hsvp(i) = eps;
        else
           hsvp(i) = hsv(i);
        end
      end
      disp(' ')
      disp('                              (strike a key to see the plot ...)')
      pause
      subplot
      plot(20*log10(hsvp),'--');hold
      plot(20*log10(hsvp),'*');grid on;hold
      ylabel('DB')
      title('Hankel Singular Values')
      pause
      in = input('Please assign the order of the K_th Hankel MDA: ');
      r = input('Please input the Multiplicity of the (K+1)th Hankel SV: ');
   else
      disp('    Hankel Singular Values:')
      hsv(1:60,:)'
      disp('                              (strike a key for more ...)')
      pause
      hsv(61:mhsv,:)'
      for i = 1:mhsv
        if hsv(i) == 0
           hsvp(i) = eps;
        else
           hsvp(i) = hsv(i);
        end
      end
      disp(' ')
      disp('                              (strike a key to see the plot ...)')
      pause
      subplot
      plot(20*log10(hsvp),'--');hold
      plot(20*log10(hsvp),'*');grid on;hold
      ylabel('DB')
      title('Hankel Singular Values')
      pause
      in = input('Please assign the order of the K_th Hankel MDA: ');
      r = input('Please input the Multiplicity of the (K+1)th Hankel SV: ');
    end
    kk = in+1;
    format loose
end
%
% ---- Keep all the state:
%
if kk > na
   ax = a; bx = b;
   cx = c; dx = d;
   ay = zeros(ma,na);   by = zeros(ma,nd);
   cy = zeros(md,na);   dy = zeros(md,nd);
   aug = [0 0 0 hsv'];
   if xsflag
      ax = mksys(ax,bx,cx,dx);
      bx = mksys(ay,by,cy,dy);
      cx = aug;
   end
   return
end
%
ro = hsv(kk,1);
bnd = ro*r;
kp1 = 0;
for i = 1 : na
    if hsv(i,1) < ro
       kp1 = kp1 + 1;
       bnd = bnd + hsv(i,1);
    end
end
strm = r + kp1;
aug = [hsv(1,1) strm 2*bnd hsv'];
%
aa = ro^2*a' + q*a*p;
bb = q*b;
cc = c*p;
dd = d;
ee = q*p - ro*ro*eye(ma);
[u,s,v] = svd(ee);
%
u1 = u(:,1:(na-r));
u2 = u(:,(na-r+1):na);
v1 = v(:,1:(na-r));
v2 = v(:,(na-r+1):na);
%
sigi = inv(u1'*ee*v1);
a11 = u1'*aa*v1;
a12 = u1'*aa*v2;
a21 = u2'*aa*v1;
a22i = pinv(u2'*aa*v2);
b1 = u1'*bb; b2 = u2'*bb;
c1 = cc* v1; c2 = cc*v2;
%
axy = sigi * (a11 - a12*a22i*a21);
bxy = sigi * (b1  - a12*a22i*b2);
cxy = c1 - c2 * a22i * a21;
dxy = dd - c2 * a22i * b2;
%
[ax,bx,cx,dx,ay,by,cy,dy,msat] = stabproj(axy,bxy,cxy,dxy);
%
if xsflag
   ax = mksys(ax,bx,cx,dx);
   bx = mksys(ay,by,cy,dy);
   cx = aug;
end
%
% ------ End of OHKAPP.M --- RYC/MGS %