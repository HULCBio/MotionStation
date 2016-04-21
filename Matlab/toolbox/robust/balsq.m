function [aq,bq,cq,dq,aug,hsv,slbig,srbig] = balsq(varargin)
%BALSQ Square-root balanced truncation (stable plant).
%
% [SS_Q,AUG,SVH,SLBIG,SRBIG] = BALSQ(SS_,MRTYPE,NO) or
% [AQ,BQ,CQ,DQ,AUG,SVH,SLBIG,SRBIG] = BALSQ(A,B,C,D,MRTYPE,NO) performs
%    balanced-truncation model reduction on G(s):=(a,b,c,d) via the
%    square-root of PQ such that the infinity-norm of the error
%    (Ghed(s) - G(s))<=sum of the 2(n-k) smaller Hankel singular
%    values (SVH).
%
%           (aq,bq,cq,dq) = (slbig'*a*srbig,slbig'*b,c*srbig,d)
%
%   Based on the "MRTYPE" selected, you have the following options:
%
%    1). MRTYPE = 1  --- no: order "k" of the reduced order model.
%
%    2). MRTYPE = 2  --- find a k-th order model such that the total error
%                      is less than "no"
%
%    3). MRTYPE = 3  --- display Hankel SV and prompt for "k".
%
%    AUG = [No. of state(s) removed, Error bound], SVH = Hankel SV's.

% R. Y. Chiang & M. G. Safonov 9/11/87 (rev. 9/21/97)
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.10.4.3 $
% All Rights Reserved.

nag1=nargin;
[emsg,nag1,xsflag,Ts,a,b,c,d,mrtype,no]=mkargs5x('ss',varargin); error(emsg);
if Ts, error('LTI inputs must be continuous time (Ts=0)'), end

[ma,na] = size(a);
[md,nd] = size(d);
[hsv,p,q] = hksv(a,b,c);
%
% ------ Model reduction based on your choice of mrtype:
%
if mrtype == 1
   kk = no+1;
end
%
if mrtype == 2
   tails = 0;
   kk = 1;
   for i = ma:-1:1
       tails = tails + hsv(i);
       if 2*tails > no
          kk = i + 1;
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
      disp('                              (strike a key to see the plot ...)')
      pause
      subplot
      plot(20*log10(hsvp),'--');hold
      plot(20*log10(hsvp),'*');grid on;hold
      ylabel('DB')
      title('Hankel Singular Values')
      pause
      no = input('Please assign the k-th index for k-th order model reduction:');
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
      disp('                              (strike a key to see the plot ...)')
      pause
      subplot
      plot(20*log10(hsvp),'--');hold
      plot(20*log10(hsvp),'*');grid on;hold
      ylabel('DB')
      title('Hankel Singular Values')
      no = input('Please assign the k-th index for k-th order model reduction:');
   end
   format loose
   kk = no + 1;
end
%
% ------ Save all the states:
%
if kk > na
   aq= a; bq= b; cq= c; dq= d;
   slbig = eye(na); srbig = eye(na);
   aug = [0 0];
   if xsflag
      aq = mksys(aq,bq,cq,dq);
      bq = aug;
      cq = hsv;
      dq = slbig;
      aug  = srbig;
   end
   return
end
%
% ------ Disgard all the states:
%
if kk < 1
   ma = 0; na = 0;
   aq= zeros(ma,na);   bq= zeros(ma,nd);
   cq= zeros(md,na);   dq= d;
   slbig = []; srbig = [];
   bnd = 2*sum(hsv);
   aug = [na bnd];
   if xsflag
      aq = mksys(aq,bq,cq,dq);
      bq = aug;
      cq = hsv;
      dq = slbig;
      aug  = srbig;
   end
   return
end
%
% ------ k-th order Schur balanced model reduction:
%
bnd = 2*sum(hsv(kk:na));
strm = na-kk+1;
aug = [strm bnd];
%
% ----- Find the square root for the basis of left/right eigenspace :
%
[up,sp,vp] = svd(p);
lr = up*diag(sqrt(diag(sp)));
[uq,sq,vq] = svd(q);
lo = uq*diag(sqrt(diag(sq)));
%
[uc,sc,vc] = svd(lo'*lr);
%
% ------ Find the similarity transformation :
%
s1 = sc(1:(kk-1),1:(kk-1));
scih = diag(ones(kk-1,1)./sqrt(diag(s1)));
uc = uc(:,1:(kk-1));
vc = vc(:,1:(kk-1));
slbig = lo*uc*scih;
srbig = lr*vc*scih;
%
aq = slbig'*a*srbig;
bq = slbig'*b;
cq = c*srbig;
dq = d;
%
if xsflag
  aq = mksys(aq,bq,cq,dq);
  bq = aug;
  cq = hsv;
  dq = slbig;
  aug = srbig;
end
%
% ------ End of BALSQ.M --- RYC/MGS 9/11/87 %
