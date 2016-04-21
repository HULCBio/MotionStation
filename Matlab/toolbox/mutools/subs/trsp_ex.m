% trsp_ex

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

 timedata = [0 1 2 3];
 stepdata = [0 1 2 -1];
 u = step_tr(timedata,stepdata,0.02,6);
 minfo(u)
 sys = nd2sys([4],[1 4]);
 minfo(sys)
 % see(sys)
 yout = trsp(sys,u,6);
 vplot(yout,u,'--')
pause
%print -deps trsp_p1.eps

 a = diag([-.4 -1 -10 -100]);
 b = -a;
 c = eye(4);
 mvsys = pck(a,b,c);
 minfo(mvsys);
 % see(mvsys);
 in = sin_tr(10,1,0.02,1.4);
 in = siggen('sin(10*t)',[0:0.02:1.4]);
 in4 = mmult(ones(4,1),in);
 minfo(in4)
 mvyout = trsp(mvsys,in4,1.4,0.002);
 minfo(mvyout)
 vplot(sel(mvyout,1,1),'-',sel(mvyout,2,1),'--',...
   sel(mvyout,3,1),'-.',sel(mvyout,4,1),'.',in,'+')
% print -deps trsp_p2.eps