%DINTEVA Script file for computing singular value plots for DINTDEMO.
%

% R. Y. Chiang & M. G. Safonov
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.7.4.3 $
% All Rights Reserved.

w = logspace(-3,3);
%
disp(' ')
disp(' - - Computing the SV Bode plot of the plant open loop - -');
svg = sigma(ag,bg,cg,dg,1,w);
svg = 20*log10(svg);
%
disp(' ')
disp(' - - Computing the SV Bode plot of Ty1u1 - -');
svtt = sigma(acl,bcl,ccl,dcl,1,w);
svtt = 20*log10(svtt);
%
svw1i = bode(w1(2,:),w1(1,:),w); svw1i = 20*log10(svw1i);
svw3i = bode(w3(2,:),w3(1,:),w); svw3i = 20*log10(svw3i);
%
disp(' ')
disp(' - - Computing the SV Bode plot of Controller - -')
svcp = sigma(acp,bcp,ccp,dcp,1,w); svcp = 20*log10(svcp);
%
[al,bl,cl,dl] = series(acp,bcp,ccp,dcp,ag,bg,cg,dg);
%
[as,bs,cs,ds] = feedbk(al,bl,cl,dl,1);
disp(' ')
disp(' - - Computing the SV Bode plot of S - - ')
svs = sigma(as,bs,cs,ds,1,w);
%[svs,temp] = sort(-svs); svs = -svs;
svs = 20*log10(svs);
%
[at,bt,ct,dt] = feedbk(al,bl,cl,dl,2);
disp(' ')
disp(' - - Computing the SV Bode plot of I-S - - ')
svt = sigma(at,bt,ct,dt,1,w);
svt = 20*log10(svt);
%
disp(' ')
disp(' - - Computing the time response - - ')
t = 0:0.1:5;
y = step(at,bt,ct,dt,1,t);
%
% -------- End of DINTEVA.M --- RYC/MGS %