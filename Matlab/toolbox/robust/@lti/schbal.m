function [ahed,bhed,ched,dhed,aug,hsv,slbig,srbig] = schbal(varargin)
%SCHBAL Schur balanced truncation (stable plant).
%
% [SS_H,AUG,HSV,SLBIG,SRBIG] = SCHBAL(SS_,MRTYPE,NO) or
% [AHED,BHED,CHED,DHED,AUG,HSV,SLBIG,SRBIG]=SCHBAL(A,B,C,D,MRTYPE,NO) performs
%    Schur method model reduction on G(s):=(a,b,c,d) such that the infinity-
%    norm of the error (Ghed(s) - G(s)) <= sum of the 2(n-k) smaller Hankel
%    singular values.
%
%         (ahed,bhed,ched,dhed) = (slbig'*a*srbig,slbig'*b,c*srbig,d)
%
%   Based on the "MRTYPE" selected, you have the following options:
%
%    1). mrtype = 1  --- no: size "k" of the reduced order model.
%
%    2). mrtype = 2  --- find k-th order model such that the total error
%                      is less than "no".
%
%    3). mrtype = 3  --- display all the Hankel SV prompt for "k" (in this
%                      case, no need to specify "no").
%
%    AUG = [No. of state(s) removed, Error bound], HSV = Hankel SV's.

% R. Y. Chiang & M. G. Safonov 9/11/87
% Copyright 1988-2004 The MathWorks, Inc.
% $Revision: 1.7.4.3 $
%------------------------------------------------------------------------

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
      disp(' ')
      disp('                              (strike a key to see the plot ...)')
      pause
      subplot
      plot(20*log10(hsvp),'--');hold
      plot(20*log10(hsvp),'*');grid on;hold
      ylabel('DB')
      title('Hankel Singular Values')
      pause
      no = input('Please assign the k-th index for k-th order model reduction: ');
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
      no = input('Please assign the k-th index for k-th order model reduction: ');
   end
   format loose
   kk = no + 1;
end
%
% ------ Save all the states:
%
if kk > na
   ahed = a; bhed = b; ched = c; dhed = d;
   slbig = eye(na); srbig = eye(na);
   aug = [0 0];
   if xsflag
      ahed = mksys(ahed,bhed,ched,dhed);
      bhed = aug;
      ched = hsv;
      dhed = slbig;
      aug  = srbig;
   end
   return
end
%
% ------ Disgard all the states:
%
if kk == 1
   ma = 0; na = 0;
   ahed = zeros(ma,na);   bhed = zeros(ma,nd);
   ched = zeros(md,na);   dhed = d;
   slbig = []; srbig = [];
   bnd = 2*sum(hsv);
   aug = [na bnd];
   if xsflag
      ahed = mksys(ahed,bhed,ched,dhed);
      bhed = aug;
      ched = hsv;
      dhed = slbig;
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
% ------ Find the left-eigenspace basis :
%
ro = (hsv(kk-1)^2+hsv(kk)^2)/2.;
gammaa = p*q-ro*eye(na);
[va,ta,msa] = blkrsch(gammaa,1,na-kk+1);
vlbig = va(:,(na-kk+2):na);
%
% ------ Find the right-eigenspace basis :
%
gammad = -gammaa;
[vd,td,msd] = blkrsch(gammad,1,kk-1);
vrbig = vd(:,1:kk-1);
%
% ------ Find the similarity transformation :
%
ee = vlbig'*vrbig;
[ue,se,ve] = svd(ee);
%
seih = diag(ones(kk-1,1)./sqrt(diag(se)));
slbig = vlbig*ue*seih;
srbig = vrbig*ve*seih;
%
ahed = slbig'*a*srbig;
bhed = slbig'*b;
ched = c*srbig;
dhed = d;
%
if xsflag
   ahed = mksys(ahed,bhed,ched,dhed);
   bhed = aug;
   ched = hsv;
   dhed = slbig;
   aug  = srbig;
end
%
% ------ End of SCHBAL.M --- RYC/MGS 9/11/87 %
