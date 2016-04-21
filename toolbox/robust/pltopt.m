%PLTOPT Preparing plots for evaluating H2 or H-inf design performance.
%
%             Inputs: ag,bg,cg,dg, nuw1i,dnw1i, nuw3i,dnw3i
%

% R. Y. Chiang & M. G. Safonov 6/86
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.9.4.3 $
% All Rights Reserved.
% ----------------------------------------------------------------
clc
disp('  ')
disp('     ..... Evaluating performance ..... Please wait .....')
flagga = exist('Gam');
if flagga < 1
   Gam = input('   Input cost function coefficient "Gam" = ');
end
% -------------------------------------------------------------------
[rdg,cdg] = size(dg);
%
[al,bl,cl,dl] = series(acp,bcp,ccp,dcp,ag,bg,cg,dg);
if rdg == 1 & cdg == 1
  disp('  ')
  disp('     ..... Computing Bode plot of the cost function .....')
  svtt = sigma(acl,bcl,ccl,dcl,1,w); svtt = 20*log10(svtt);
  maxsvtt = max(svtt(1,:));  minsvtt = min(svtt(size(svtt)*[1;0],:));
  deltasv = abs(maxsvtt-minsvtt);
  disp(' ')
  disp('  ')
  disp('      (strike a key to see the plot of the cost function (Ty1u1) ...)')
  pause
  clf
  semilogx(w,svtt)
  title(['COST FUNCTION Ty1u1 (Gam = ' num2str(Gam) ')'])
  xlabel('Frequency - Rad/Sec')
  ylabel('SV - db')
  text(0.01,maxsvtt-deltasv/4,'Is this design close enough ?');
  text(0.01,maxsvtt-deltasv/2,'(if not, adjust the cost function and try again..)');
  grid on
  pause
  disp('  ')
  disp(' ')
  disp('               (strike a key to continue or hit <CTRL-C> to quit ...)')
  pause
  disp(' ')
  disp('     ..... Computing Bode plots of Sens. & Comp. Sens. functions .....')
  [als,bls,cls,dls] = feedbk(al,bl,cl,dl,1);
  [at,bt,ct,dt] = feedbk(al,bl,cl,dl,2);
  svs = bode(als,bls,cls,dls,1,w); svs = 20*log10(svs);
  svt = bode(at,bt,ct,dt,1,w); svt = 20*log10(svt);
  svw1i = bode(nuw1i,Gam*dnw1i,w); svw1i = 20*log10(svw1i);
  svw3i = bode(nuw3i,dnw3i,w); svw3i = 20*log10(svw3i);
  disp(' ')
  disp(' ')
  disp('           (strike a key to see the plots of Sens. & Comp. Sens. ...)')
  pause
  clf
  semilogx(w,svw1i,w,svs)
  title('SENSITIVITY FUNCTION AND 1/W1');
  xlabel('Frequency - Rad/Sec')
  ylabel('Gain - db')
  grid on
  pause
  semilogx(w,svw3i,w,svt)
  title('COMP. SENSITIVITY FUNCTION AND 1/W3');
  xlabel('Frequency - Rad/Sec')
  ylabel('Gain - db')
  grid on
  pause
  disp(' ')
  disp('     ..... Computing Nichols plot & stability margin .....')
  [gal,phl] = bode(al,bl,cl,dl,1,w);
  [Gmarg,Pmarg,Wcg,Wcp] = margin(gal,phl,w);
  Gmarg = 20*log10(Gmarg);
  gal = 20*log10(gal);
  disp(' ')
  disp(' ')
  disp('                 (strike a key to see the Nichols plot of L(s) ...)')
  pause
  clf
  plot(phl,gal)
  maxphl = max(phl);  minphl = min(phl);  delphl = abs(maxphl-minphl);
  maxgal = max(gal);  mingal = min(gal);  delgal = abs(maxgal-mingal);
  text(minphl,mingal+delgal/2,...
  [' GAIN MARGIN  = ' num2str(Gmarg) ' db at ' num2str(Wcg) ' rad/sec'])
  text(minphl,mingal+delgal/4,...
  [' PHASE MARGIN = ' num2str(Pmarg) ' deg at ' num2str(Wcp) ' rad/sec'])
  title('NICHOLS PLOT')
  xlabel('Phase -- deg')
  ylabel('Gain -- db')
  grid on
  pause
else
  disp('  ')
  disp('     ..... Computing the SV Bode plot of Ty1u1 .....')
  svtt = sigma(acl,bcl,ccl,dcl,1,w); svtt = 20*log10(svtt);
  maxsvtt = max(svtt(1,:));  minsvtt = min(svtt(size(svtt)*[1;0],:));
  deltasv = abs(maxsvtt-minsvtt);
  disp(' ')
  disp('  ')
  disp('      (strike a key to see the plot of the cost function (Ty1u1) ...)')
  pause
  clf
  semilogx(w,svtt)
  title(['COST FUNCTION Ty1u1 (Gam = ' num2str(Gam) ')'])
  xlabel('Frequency - Rad/Sec')
  ylabel('SV - db')
  text(0.01,maxsvtt-deltasv/4,'Is this design close enough ?');
  text(0.01,maxsvtt-deltasv/2,'(if not, adjust the cost function and try again..)');
  grid on
  pause
  disp('  ')
  disp(' ')
  disp('               (strike a key to continue or hit <CTRL-C> to quit ...)')
  pause
  disp(' ')
  disp('     ..... Computing the SV Bode plots of Sens. & Comp. Sens. .....')
  svs = sigma(al,bl,cl,dl,3,w); svs = -20*log10(svs);
  [at,bt,ct,dt] = feedbk(al,bl,cl,dl,2);
  svt = sigma(at,bt,ct,dt,1,w); svt = 20*log10(svt);
  svw1i = bode(nuw1i,Gam*dnw1i,w); svw1i = 20*log10(svw1i);
  svw3i = bode(nuw3i,dnw3i,w); svw3i = 20*log10(svw3i);
  disp(' ')
  disp(' ')
  disp('           (strike a key to see the plots of Sens. & Comp. Sens. ...)')
  pause
  clf
  semilogx(w,svw1i,w,svs)
  title('SENSITIVITY FUNCTION AND 1/W1');
  xlabel('Frequency - Rad/Sec')
  ylabel('SV - db')
  grid on
  pause
  semilogx(w,svw3i,w,svt)
  title('COMP. SENSITIVITY FUNCTION AND 1/W3');
  xlabel('Frequency - Rad/Sec')
  ylabel('SV - db')
  grid on
  pause
end
%
if rdg == 1 & cdg == 1
   disp('  ')
   disp('                 << Plot variable names >>')
   disp('---------------------------------------------------------------')
   disp(' w ------ frequency (rad/sec)')
   disp(' gal, phl ---- gain & phase of L(jw) (loop transfer function)')
   disp(' svs ---- Bode plot of S(jw) (sensitivity)')
   disp(' svt ---- Bode plot of I-S(jw) (complementary sensitivity)')
   disp(' svtt --- Bode plot of the cost function (Ty1u1(jw))')
   disp(' svw1i --- Bode plot of 1/W1(jw) weighting function')
   disp(' svw3i --- Bode plot of 1/W3(jw) weighting function')
   disp('---------------------------------------------------------------')
else
   disp(' ')
   disp('                 << Plot variable names >>')
   disp('---------------------------------------------------------------')
   disp(' w ------ freqeuncy (rad/sec)')
   disp(' svs ---- singular values of S(jw) (sensitivity)')
   disp(' svt ---- singular values of I-S(jw) (complementary sensitivity)')
   disp(' svtt --- singular values of the cost function (Ty1u1(jw))')
   disp(' svw1i --- singular values of 1/W1(jw) weighting function')
   disp(' svw3i --- singular values of 1/W3(jw) weighting function')
   disp('---------------------------------------------------------------')
end
%
% -------- End of PLTOPT.M --- RYC/MGS
