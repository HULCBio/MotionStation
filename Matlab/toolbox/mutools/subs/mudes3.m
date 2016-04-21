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

fitdim=[.26,.1,0,3];
sysabcd=pck(a,b,c,d);
%uncertainty model
wdel = daug(nd2sys(num_i1,den_i1),nd2sys(num_i2,den_i2));
%perturbation model
wp = daug(nd2sys(num_o1,den_o1),nd2sys(num_o2,den_o2));
systemnames = 'sysabcd wdel wp';
inputvar = '[pert(2); dist(2); control(2)]';
outputvar = '[ wdel ; wp; sysabcd + dist ]';
input_to_sysabcd = '[ control + pert ]';
input_to_wdel = '[ control ]';
input_to_wp = '[ sysabcd + dist ]';
sysoutname = 'sysabcd_ic';
cleanupsysic = 'yes';
sysic
 blk=[2 2;2 2];
 om2=logspace(0,4,32);
 [k1,g1,gf1]=hinfsyn(sysabcd_ic,2,2,0.8,6,0.05,2);
n_it = 0;
if gf1>0.9999
 n_it = 1;
 g1g=frsp(g1,om2);
 [bnds1,dv1,sens1,rp1]=mu(g1g,blk);
 [dsysl,dsysr]=muftbtch('first',dv1,sens1,blk,2,2,fitdim);
 sysabcd_ic2=mmult(dsysl,mmult(sysabcd_ic,minv(dsysr)));
 [k1,g1,gf1]=hinfsyn(sysabcd_ic2,2,2,min(0.8,.6*gf1),1.05*gf1,.05,2);
end;

while gf1>0.9999 & n_it < 10,
 n_it = n_it + 1;
 g1g = frsp(g1,om2);
 [bnds1,dv1,sens1,rp1]=mu(g1g,blk);
 [dsysl,dsysr]=muftbtch(dsysl,dv1,sens1,blk,2,2,fitdim);
 sysabcd_ic2=mmult(dsysl,sysabcd_ic,minv(dsysr));
 [k1,g1,gf1]=hinfsyn(sysabcd_ic2,2,2,min(0.7,.6*gf1),1.05*gf1,.05,2);
end;

if gf1>1, display('designed failed after 10 iterations'); end;
clear blk gf1 om2 sysabcd_ic dsysl dsysr g1g sens1 rp1 dv1 n_it
clear bnds1 sysabcd_ic2 sysabcd

disp('Finally, balanced model reduce the system');
k1=sysbal(k1,0.0001);
[ak,bk,ck,dk]=unpck(k1);
[ac,bc,cc,dc]=series(ak,bk,ck,dk,a,b,c,d);
[ac,bc,cc,dc]=cloop(ac,bc,cc,dc,1);
g1=pck(ac,bc,cc,dc);

disp('Done.');
