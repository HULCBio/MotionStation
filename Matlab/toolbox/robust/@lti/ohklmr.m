function [am,bm,cm,dm,totbnd,hsv] = ohklmr(varargin)
%OHKLMR Optimal Hankel norm approximation (unstable plant).
%
% [SS_M,TOTBND,HSV] = OHKLMR(SS_,MRTYPE,IN) or
% [AM,BM,CM,DM,TOTBND,HSV] = OHKLMR(A,B,C,D,MRTYPE,IN) produces an optimal
%    Hankel model reduction of an given unstable plant G(s) such that
%    the inf-norm of the error (Ghed(s) - G(s)) <= sum of the k+1 to n
%    Hankel singular value of G(s) times 2. NO BALANCING IS REQUIRED.
%
%   mrtype = 1, in = order "k" of the reduced model.
%
%   mrtype = 2, find a reduced order model such that the total error is less
%             than "in".
%
%   mrtype = 3, display Hankel singular values, prompt for order "k" (in this
%             case, no need to specify "in").
%
%   TOTBND = Error bound, HSV = Hankel singular values.

% R. Y. Chiang & M. G. Safonov 4/12/87
% Copyright 1988-2004 The MathWorks, Inc.
% $Revision: 1.6.4.3 $
% ----------------------------------------------------------------------
%
disp('  ')
disp('        - - Working on Optimal Descriptor Hankel Model Reduction - -');

nag1=nargin;
[emsg,nag1,xsflag,Ts,a,b,c,d,mrtype,in]=mkargs5x('ss',varargin); error(emsg);
if Ts, error('LTI inputs must be continuous time (Ts=0)'), end

if mrtype == 3
   in = 0;
end
[ra,ca] = size(a);
[ee,dd] = eig(a);
%
% ------ Find the no. of stable roots :
%
indstab = find(real(dd) < 0);
m = length(indstab);
%
% ------ If completely stable :
%
if m == ra
   [alf,blf,clf,dlf,arf,brf,crf,drf,augl] = ohkapp(a,b,c,d,mrtype,in);
   am = alf; bm = blf; cm = clf; dm = d;
   augr = [0 0 0];
   totbnd = augl(1,3);
   hsv = augl(4:4+ra-1)';
end
%
% ------ If completely unstable :
%
if m == 0
   [alf,blf,clf,dlf,arf,brf,crf,drf,augr] = ohkapp(-a,-b,c,d,mrtype,in);
   alf = -alf;
   blf = -blf;
   am = alf; bm = blf; cm = clf; dm = d;
   augl = [0 0 0];
   totbnd = augr(1,3);
   hsv = augr(4:4+ra-1)';
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
      for i = 1:in
          if index(i) > msat
             nor = nor + 1;
          end
      end
     nol = in-nor;
   end
   if mrtype == 2
      tol = in;
      tails = 0;
      for i = ra:-1:1
          tails = tails + hsv(i);
          if 2*tails > tol
             no = i;
             break
          end
      end
      nor = 0;
      for i = 1:in
          if index(i) > msat
             nor = nor + 1;
          end
      end
      nol = in-nor;
      mrtype = 1;
   end
   if mrtype == 3
      nol = in; nor = in;
   end
   [alf,blf,clf,dlf,aalf,bblf,cclf,ddlf,augl] = ohkapp(al,bl,cl,dl,mrtype,nol);
   dlf = dl;
   [arf,brf,crf,drf,aarf,bbrf,ccrf,ddrf,augr] = ohkapp(-ar,-br,cr,dr,mrtype,nor);
   drf = dr;   arf = -arf;   brf = -brf;
   totbnd = augl(1,3)+augr(1,3);
   hsv = [augl(1,4:4+msat-1)';augr(1,4:4+(ra-msat)-1)'];
   [am,bm,cm,dm] = addss(alf,blf,clf,dlf,arf,brf,crf,drf);
   [ral,cal] = size(al); [rar,car] = size(ar);
   if augl(1,2) == ral
      am = arf; bm = brf; cm = crf; dm = d;
   end
   if augr(1,2) == rar
      am = alf; bm = blf; cm = clf; dm = d;
   end
end
%
if xsflag
   am = mksys(am,bm,cm,dm);
   bm = totbnd;
   cm = hsv;
end
%
nn = augl(1,2) + augr(1,2);
disp(' ')
disp(['               ' int2str(nn), '    states removed !!'])
%
% ------- End of OHKLMR.M --- RYC/MGS 4/12/87 %