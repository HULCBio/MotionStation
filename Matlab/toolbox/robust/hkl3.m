%HKL3 2-block H-inf problem.
%

% R. Y. Chiang & M. G. Safonov 8/85
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.7.4.3 $
% All Rights Reserved.
% ------------------------------------------------------------------
disp('  ')
disp('      << Working on Phase III: Interpolation problem >>')
disp('  ')
disp('   2-block H-inf problem (HKL3: T21 nonsquare, T12 square)')
disp('  ')
disp('            ..... Working ..... Please wait .....')
if MReye == 2
   flagtol = exist('tol');
   if flagtol < 1
      tol = input('Input error bound for model reduction: ');
   end
   no = tol;
end
seraug = [MRtype no];
[ag1s,bg1s,cg1s,dg1s,ag1u,bg1u,cg1u,dg1u,mg1] = stabproj(ag1,bg1,cg1,dg1);
[ag1m,bg1m,cg1m,dg1m,augm1,hsvgm] = schmr(...
-ag1u,-bg1u,cg1u,dg1u,MRtype,no);
[rrg1,rrg1] = size(ag1m);
if rrg1 > twoN
   disp('- - - - WARNING: THERE ARE STATES MORE THAN 2N ...')
   disp('                 RESULTS MAY BE INCORRCT !!')
end
ag1m = -ag1m; bg1m = -bg1m;
[am1,bm1,cm1,dm1] = sfr(ag1m,bg1m,cg1m,dg1m);
[ahtl,bhtl,chtl,dhtl,hsvhtl] = sershbl(ahtt,bhtt,chtt,dhtt,...
                    am1-bm1*inv(dm1)*cm1,-bm1*inv(dm1),...
                    inv(dm1)*cm1,inv(dm1),seraug);
[rrhtl,rrhtl] = size(ahtl);
if rrhtl > twoN
   disp('- - - - WARNING: THERE ARE STATES MORE THAN 2N ...')
   disp('                 RESULTS MAY BE INCORRCT !!')
end
%
%  IV). Zeroth order Hankel Approximation:
%
[a11h,B1h,C1h,d1h,a22h,B2h,C2h,d2h,msat] = stabproj(-ahtl',-chtl',bhtl',dhtl');
[ay,by,cy,dy,ayu,byu,cyu,dyu,aughsv] = ohkapp(a11h,B1h,C1h,d1h,1,0);
hsvmx = aughsv(1,1)
if  aughsv(1,1) <= 1.0
         [axt1,bxt1,cxt1,dxt1] = addss(ayu,byu,cyu,dyu,a22h,B2h,C2h,d2h);
         [mahtl,nahtl] = size(ahtl);
         if msat == mahtl
            axt1 = ayu; bxt1 = byu; cxt1 = cyu; dxt1 = dyu+d2h;
         end
         axtl = -axt1';
         bxtl = -cxt1';
         cxtl =  bxt1';
         dxtl =  dxt1';
         [aq,bq,cq,dq,hsvq] = sershbl(am1,bm1,cm1,dm1,...
                               axtl,bxtl,-cxtl,-dxtl,seraug);
         [raq,caq] = size(aq);
         if raq > twoN
            disp('- - - - WARNING: THERE ARE STATES MORE THAN 2N ...')
            disp('                 RESULTS MAY BE INCORRCT !!')
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
         ccp  = [f zeros(rf,caq)] + [zeros(rf,cdq) eye(rf)] *...
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
% ----- End of HKL3.M ---- RYC/MGS %