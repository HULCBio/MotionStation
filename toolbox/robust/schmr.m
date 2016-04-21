function [am,bm,cm,dm,totbnd,hsv] = schmr(varargin)
%SCHMR Schur balanced truncation (unstable plant).
%
% [SS_M,TOTBND,HSV] = SCHMR(SS_,MRTYPE,NO) or
% [AM,BM,CM,DM,TOTBND,HSV]=SCHMR(A,B,C,D,MRTYPE,NO) performs Schur method
%    model reduction on G(s):=(a,b,c,d) such that the infinity-norm
%    of the error (Ghed(s) - G(s)) <= sum of the 2(n-k) smaller Hankel
%    singular values. For unstable G(s) the algorithm works by first
%    splitting G(s) into a sum of stable and antistable part.
%
%   Based on the "MRTYPE" selected, you have the following options:
%
%    1). mrtype = 1  --- no: size "k" of the reduced order model.
%
%    2). mrtype = 2  --- find a k-th order model such that the total error
%                      is less than "no".
%
%    3). mrtype = 3  --- display all the Hankel SV prompt for "k" (in this
%                      case, no need to specify "no").
%
%    TOTBND = Error bound, HSV = Hankel Singular Values.

% R. Y. Chiang & M. G. Safonov 9/13/87
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.10.4.3 $
% All Rights Reserved.
% ------------------------------------------------------------------------
%
disp('  ');
disp('        - - Working on Schur Balanced Model Reduction - -');

nag1=nargin;
[emsg,nag1,xsflag,Ts,a,b,c,d,mrtype,no]=mkargs5x('ss',varargin); error(emsg);
if Ts, error('LTI inputs must be continuous time (Ts=0)'), end

if mrtype == 3
   no = 0;
end
[ra,ca] = size(a);
dd = eig(a);
%
% ------ Find the no. of stable roots :
%
indstab = find(real(dd) < 0);
m = length(indstab);
%
% ------ If completely stable :
%
if m == ra
   [am,bm,cm,dm,augl,hsv,slbig,srbig] = schbal(a,b,c,d,mrtype,no);
   augr = [0 0];
   totbnd = augl(1,2);
end
%
% ------ If completely unstable :
%
if m == 0
   [am,bm,cm,dm,augr,hsv,slbig,srbig] = schbal(-a,-b,c,d,mrtype,no);
   am = -am; bm = -bm;
   augl = [0 0];
   totbnd = augr(1,2);
end
%
% ------ If having both stable & unstable parts :
%
if m > 0 & m < ra
  [al,bl,cl,dl,ar,br,cr,dr,msat] = stabproj(a,b,c,d);
  [hsvl,pl,ql] = hksv(al,bl,cl);
  [hsvr,pr,qr] = hksv(-ar,-br,cr);
  hsv = [hsvl;hsvr];
  [hsv,index] = sort(hsv);
  hsv = hsv(ra:-1:1,:);
  index = index(ra:-1:1,:);
  if mrtype == 1
      nor = 0;
      for i = 1:no
          if index(i) > msat
             nor = nor + 1;
          end
      end
     nol = no-nor;
   end
   if mrtype == 2
      tol = no;
      tails = 0;
      for i = ra:-1:1
          tails = tails + hsv(i);
          if 2*tails > tol
             no = i;
             break
          end
      end
      nor = 0;
      for i = 1:no
          if index(i) > msat
             nor = nor + 1;
          end
      end
      nol = no-nor;
      mrtype = 1;
   end
   if mrtype == 3
      nol = no; nor = no;
   end
   [alf,blf,clf,dlf,augl,hsvl,tll,tlr] = schbal(al,bl,cl,dl,mrtype,nol);
   [arf,brf,crf,drf,augr,hsvr,trl,trr] = schbal(-ar,-br,cr,dr,mrtype,nor);
   arf = -arf;
   brf = -brf;
   totbnd = augl(1,2)+augr(1,2);
   hsv = [hsvl;hsvr];
   [am,bm,cm,dm] = addss(alf,blf,clf,dlf,arf,brf,crf,drf);
   [ral,cal] = size(al); [rar,car] = size(ar);
   if augl(1,1) == ral
      am = arf; bm = brf; cm = crf; dm = drf;
   end
   if augr(1,1) == rar
      am = alf; bm = blf; cm = clf; dm = dlf;
   end
end
%
if xsflag
   am = mksys(am,bm,cm,dm);
   bm = totbnd;
   cm = hsv;
end
%
nn = augl(1,1) + augr(1,1);
disp(' ')
disp(['               ' int2str(nn), '    states removed !!'])
%
% ------- End of SCHMR.M --- RYC/MGS 9/13/87 %
