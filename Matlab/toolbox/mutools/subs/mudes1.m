%musyndem3 function is self-contained m-file. It is called by musyndm3
%which is a MuSyn demo in simulink.
%The users can change the parameters of plant [A,B,C,D] and the weighting
%functions wdel and wp to modify the m-file for controller design parameters for
%your example.
%

%function: design controller using Mu-Syn
%input: A, B, C, D ---- the plant model;
%       wp         ---- the performance weighting function;
%       wdel       ---- the input weighting function.

%   Wes Wang 4/21/1992 at The MathWorks, Inc.
%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
%   $Revision: 1.8.2.3 $

gammam=0.9999;
fitdim=[.26,.1,0,3];

disp('use PCK to convert [A,B,C,D] to system format')
sysabcd = pck(a,b,c,d);
wp = nd2sys(num,den);
wdel = nd2sys(0.0001*[1,1.02],[1,9.9]);
systemnames = 'sysabcd wdel wp';
inputvar = '[pert; dist; control]';
outputvar = '[ wdel ; wp; sysabcd + dist ]';
input_to_sysabcd = '[ control + pert ]';
input_to_wdel = '[ control ]';
input_to_wp = '[ sysabcd + dist ]';
sysoutname = 'sysabcd_ic';
cleanupsysic = 'yes';
disp('use SYSIC to construct linear fractional transformation structure')
sysic
 n_it = 0;
 blk=[1,1;1,1];
 om2=logspace(-2,2,32);
disp('use HINFSYN to design H_infinity controller')
 [k1,g1,gf1]=hinfsyn(sysabcd_ic,1,1,0.5,6,0.05,2);
 if gf1>gammam
 n_it = 1;
 g1g=frsp(g1,om2);
disp('use MU to calculate structure singular value of designed controller')
 [bnds1,dv1,sens1,rp1]=mu(g1g,blk);
disp('use MUFTBTCH to fit the d-scale of the output of MU function')
 [dsysl,dsysr]=muftbtch('first',dv1,sens1,blk,1,1,fitdim);
disp('use MMULT to multiply the d-scale fitting function to original LFT')
 sysabcd_ic2=mmult(dsysl,mmult(sysabcd_ic,minv(dsysr)));
disp('use HINFSYN to design H_infinity controller again')
 [k1,g1,gf1]=hinfsyn(sysabcd_ic2,1,1,min(0.8,.6*gf1),1.05*gf1,.05,2);
end;

if gf1>gammam
  disp('iteratively use MU MUFTBTCH MMULT HINFSYN to do further D-K iteration')
end;
while gf1>gammam & n_it < 10,
 n_it = n_it + 1;
 g1g = frsp(g1,om2);
 [bnds1,dv1,sens1,rp1]=mu(g1g,blk);
 [dsysl,dsysr]=muftbtch(dsysl,dv1,sens1,blk,1,1,fitdim);
 sysabcd_ic2=mmult(dsysl,sysabcd_ic,minv(dsysr));
 [k1,g1,gf1]=hinfsyn(sysabcd_ic2,1,1,min(0.7,.6*gf1),1.05*gf1,.05,2);
end;

if gf1>1, display('designed failed after 10 iterations'); end;
clear blk gf1 om2 sysabcd wp sysabcd_ic dsysl dsysr g1g sens1 rp1 dv1 n_it wdel
clear bnds1
disp('Finally, balanced model reduce the system');
k1=sysbal(k1,0.001);
[ak,bk,ck,dk]=unpck(k1);
[ac,bc,cc,dc]=series(ak,bk,ck,dk,a,b,c,d);
[ac,bc,cc,dc]=cloop(ac,bc,cc,dc,1);
g1=pck(ac,bc,cc,dc);
clear ac bc cc dc
disp('Done.');
