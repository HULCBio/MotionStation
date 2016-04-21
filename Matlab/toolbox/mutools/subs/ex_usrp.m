% file: ex_usrp.m

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.8.2.3 $

 K1 = nd2sys([0.9 1],[1 0],-10);
 K2 = nd2sys([2.8 1],[1 0],-1);
 om = logspace(-2,2,80);
 M1 = starp(P,K1); 
 M2 = starp(P,K2);
 M1g = frsp(M1,om);
 M2g = frsp(M2,om);
 uncblk = [1 1];
 fictblk = [1 1];
 deltaset = [uncblk;fictblk];
 subplot(121)
     vplot('liv,m',vnorm(sel(M1g,2,2)),'-',...
                   vnorm(sel(M2g,2,2)),'--',...
		   vnorm(sel(M1g,1,1)),'.',1,'-.')
     axis([.1 1000 0 2])
     xlabel('Frequency (rad/sec)')
     title('Nominal Performance')
pause(1)
 bnds1 = mu(M1g,deltaset);
 bnds2 = mu(M2g,deltaset);
 subplot(122)
     vplot('liv,m',bnds1,'-',bnds2,'--',1,'-.')
     axis([.1 1000 0 2])
     xlabel('Frequency (rad/sec)')
     title('Robust Performance')
