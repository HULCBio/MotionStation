%HKL4 4-block H-inf problem.
%

% R. Y. Chiang & M. G. Safonov 8/85
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.8.4.3 $
% All Rights Reserved.
% ----------------------------------------------------------------
disp('  ')
disp('      << Working on Phase III: Interpolation problem >>')
disp('  ')
disp('  4-block H-inf problem (HKL4: T21 nonsquare, T12 nonsquare)')
disp('  ')
disp('             ..... Working ..... Please wait .....')
if MRtype == 2
   flagtol = exist('tol');
   if flagtol < 1
      tol = input('Input error bound for model reduction: ');
   end
   no = tol;
end
seraug = [MRtype no];
[ag1,bg1,cg1,dg1,hsvg1] = sershbl(-at2p',-ct2p',...
                   bt2p',dt2p', at11,bt11,ct11,dt11,seraug);
[rrg1,rrg1] = size(ag1);
if rrg1 > twoN
   disp('- - - - WARNING: THERE ARE STATES MORE THAN 2N ...')
   disp('                 RESULTS MAY BE INCORRECT !!')
end
[ah1,bh1,ch1,dh1,hsvh1] = sershbl(-at21',-ct21',bt21',...
                   dt21', at11,bt11,ct11,dt11,seraug);
[rrh1,rrh1] = size(ah1);
if rrh1 > twoN
   disp('- - - - WARNING: THERE ARE STATES MORE THAN 2N ...')
   disp('                 RESULTS MAY BE INCORRECT !!')
end
[am1,bm1,cm1,dm1] = sfr(ag1,bg1,cg1,dg1);
[aj,bj,cj,dj,hsvj] = sershbl(at12,bt12,ct12,dt12,...
                   am1-bm1*inv(dm1)*cm1,-bm1*inv(dm1),...
                   inv(dm1)*cm1,inv(dm1),seraug);
[rrj,rrj] = size(aj);
if rrj > twoN
   disp('- - - - WARNING: THERE ARE STATES MORE THAN 2N ...')
   disp('                 RESULTS MAY BE INCORRECT !!')
end
%
% ------ Inner-outer factorization:
%
[jin,jinp,jout,dimj] = iofr(aj,bj,cj,dj);
[ath,bth,cth,dth] = sys2ss(jin,dimj(1,1));
[athp,bthp,cthp,dthp] = sys2ss(jinp,dimj(1,2));
[am3,bm3,cm3,dm3] = sys2ss(jout,dimj(1,3));
%
[aag2,bbg2,ccg2,ddg2,hsvgg2] = sershbl(ah1,bh1,ch1,dh1,...
        am1-bm1*inv(dm1)*cm1,-bm1*inv(dm1),inv(dm1)*cm1,inv(dm1),seraug);
[rrag2,rrag2] = size(aag2);
if rrag2 > twoN
   disp('- - - - WARNING: THERE ARE STATES MORE THAN 2N ...')
   disp('                 RESULTS MAY BE INCORRECT !!')
end
[ag2,bg2,cg2,dg2,hsvg2] = sershbl(aag2,bbg2,ccg2,ddg2,...
                       -athp',-cthp',bthp',dthp',seraug);
[rrg2,rrg2] = size(ag2);
if rrg2 > twoN
   disp('- - - - WARNING: THERE ARE STATES MORE THAN 2N ...')
   disp('                 RESULTS MAY BE INCORRECT !!')
end
[am2,bm2,cm2,dm2] = sfl(ag2,bg2,cg2,dg2);
[ahhh,bhhh,chhh,dhhh,hsvhhh] = sershbl(...
                   am2-bm2*inv(dm2)*cm2,-bm2*inv(dm2),...
                   inv(dm2)*cm2,inv(dm2), ah1,bh1,ch1,dh1,seraug);
[rrhhh,rrhhh] = size(ahhh);
if rrhhh > twoN
   disp('- - - - WARNING: THERE ARE STATES MORE THAN 2N ...')
   disp('                 RESULTS MAY BE INCORRECT !!')
end
[ahh,bhh,chh,dhh,hsvhh] = sershbl(ahhh,bhhh,chhh,dhhh,...
        am1-bm1*inv(dm1)*cm1,-bm1*inv(dm1),inv(dm1)*cm1,inv(dm1),seraug);
[rrhh,rrhh] = size(ahh);
if rrhh > twoN
   disp('- - - - WARNING: THERE ARE STATES MORE THAN 2N ...')
   disp('                 RESULTS MAY BE INCORRECT !!')
end
[ahtl,bhtl,chtl,dhtl,hsvhtl] = sershbl(ahh,bhh,chh,dhh,...
                              -ath',-cth',bth',dth',seraug);
[rrhtl,rrhtl] = size(ahtl);
if rrhtl > twoN
   disp('- - - - WARNING: THERE ARE STATES MORE THAN 2N ...')
   disp('                 RESULTS MAY BE INCORRECT !!')
end
%
%  IV). Zeroth order Hankel Approximation:
%
[a11h,B1h,C1h,d1h,a22h,B2h,C2h,d2h,msat] = stabproj(...
                                     -ahtl',-chtl',bhtl',dhtl');
[ay,by,cy,dy,ayu,byu,cyu,dyu,aughsv] = ohkapp(a11h,B1h,C1h,d1h,1,0);
hsvmx = aughsv(1,1)
if aughsv(1,1) <= 1.0
         [axt1,bxt1,cxt1,dxt1] = addss(ayu,byu,cyu,dyu,a22h,B2h,C2h,d2h);
         [mahtl,nahtl] = size(ahtl);
         if msat == mahtl
            axt1 = ayu; bxt1 = byu; cxt1 = cyu; dxt1 = dyu+d2h;
         end
         axtl = -axt1';
         bxtl = -cxt1';
         cxtl =  bxt1';
         dxtl =  dxt1';
         [aqq,bqq,cqq,dqq,hsvqq] = sershbl(am2,bm2,cm2,dm2,...
                             axtl,bxtl,cxtl,dxtl,seraug);
         [rrqq,rrqq] = size(aqq);
         if rrqq > twoN
            disp('- - - - WARNING: THERE ARE STATES MORE THAN 2N ...')
            disp('                 RESULTS MAY BE INCORRECT !!')
         end
         [aq,bq,cq,dq,hsvq] = sershbl(aqq,bqq,-cqq,-dqq,...
                        am3-bm3*inv(dm3)*cm3,-bm3*inv(dm3),...
                        inv(dm3)*cm3,inv(dm3),seraug);
         [raq,caq] = size(aq);
         if raq > twoN
            disp('- - - - WARNING: THERE ARE STATES MORE THAN 2N ...')
            disp('                 RESULTS MAY BE INCORRECT !!')
         end
         [rdq,cdq] = size(dq);
         [rC2,cC2] = size(C2);
         [rf,cf]   = size(f);
         [rh,ch]   = size(h);
         bqq = -bq * inv(ml);
         cqq = inv(mr) * cq;
         dqq = -inv(mr) * dq * inv(ml);
         dq22 = inv([eye(rdq) -D22;-dqq eye(rdq)]);
         cq22 = [C2+D22*f zeros(rC2,caq);zeros(rdq,cC2) cqq];
         bq2h = [h B2;bqq zeros(raq,rf)];
         acp  = [at12 zeros(cf,caq);zeros(raq,cf) aq] + ...
                 bq2h * dq22 * cq22;
         bcp  = -bq2h*dq22 * [eye(rdq);zeros(rdq)];
         ccp  = [f zeros(rf,caq)] + [zeros(rf,cdq) eye(rf)] * ...
                 dq22 * cq22;
         dcp  = -dqq * inv(eye(rdq)-D22*dqq);
         acl  = [at12 bt12*dq*ct21-B2*f bt12*cq;...
                 zeros(rat0,cat1) at21 zeros(rat0,caq);...
                 zeros(raq,cat1) bq*ct21 aq];
         bcl  = [bt12*dq*dt21+B1;bt21;bq*dt21];
         ccl  = [ct12 dt12*dq*ct21-D12*f dt12*cq];
         dcl  = dt11+dt12*dq*dt21;
         disp('  ')
         disp('  ')
         disp(' ----------------------------------------------------------');
         disp('   LINF computation is done .....');
         disp('      state-space of the controller: (acp,bcp,ccp,dcp)');
         disp('      state-space of the CLTF Ty1u1: (acl,bcl,ccl,dcl)');
         disp('   Plots of S & (I-S) problem ---> run script file: pltopt');
         disp(' ----------------------------------------------------------');
else
         disp('  ')
         disp('  ')
         disp(' ----------------------------------------------------------');
         disp('    NO STABILIZING CONTROLLER MEETS THE SPEC. !!')
         disp('    ADJUST "Gam" AND REDO PHASE I, II AND III.')
         disp(' ----------------------------------------------------------');
end
%
% ------ End of HKL4.M ---- RYC/MGS %