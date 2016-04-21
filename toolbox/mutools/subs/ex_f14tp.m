% file: ex_f14tp.m
%

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.8.2.3 $

A_S = pck(-25,25,[-25;1],[25; 0]);
A_R = pck(-25,25,[-25;1],[25; 0]);
load F14_nom

Gnom = mmult(F14_nom,daug(sel(A_S,2,1),sel(A_R,2,1)));
u = step_tr(0,1,.02,2);
ydstab = trsp(Gnom,abv(u,0),4,.05);
ydrud = trsp(Gnom,abv(0,u),4,.05);

w_1 = nd2sys([1 4],[1 160],2);
w_2 = nd2sys([1 20],[1 200],1.5);
W_in = daug(w_1,w_2);


for i=1:15
 delta = randn(2,2);
 delta = delta/norm(delta);
 p = mmult(Gnom,madd(eye(2),mmult(W_in,delta)));
 y1 = trsp(p,abv(u,0),4,.05);
 y2 = trsp(p,abv(0,u),4,.05);
 ydstab = sbs(ydstab,y1);
 ydrud  = sbs(ydrud,y2);
end

cold = ynum(ydrud);
index = 2:cold;
clf
 subplot(221)
   vplot(sel(ydstab,2,1),'+',sel(ydstab,2,[index]))
   title('Diff. Stabilizer to Roll Rate')
   xlabel('Time (seconds)')
   ylabel('p (degrees/sec)')
 subplot(222)
   vplot(sel(ydrud,1,1),'+',sel(ydrud,1,[index]))
   title('Diff. Rudder to Beta')
   xlabel('Time (seconds)')
   ylabel('Beta (degrees)')
 subplot(223)
   vplot(sel(ydstab,4,1),'+',sel(ydstab,4,[index]))
   title('Diff. Stabilizer to Lat. Acceleration')
   xlabel('Time (seconds)')
   ylabel('ac_y (g''s)')
 subplot(224)
   vplot(sel(ydrud,3,1),'+',sel(ydrud,3,[index]))
   title('Diff. Rudder to Yaw Rate')
   xlabel('Time (seconds)')
   ylabel('r (degrees/sec)')