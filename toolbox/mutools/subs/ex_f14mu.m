% file: ex_f14mu.m

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

	om = logspace(-2,2,60);
	clp1 = starp(F14IC,K1);
	clp4 = starp(F14IC,K4);
	clp1g = frsp(clp1,om);
	clp4g = frsp(clp4,om);
	deltsaet = [2 2; 5 6];
	mubnds1 = mu(clp1g,deltaset);
	mubnds4 = mu(clp4g,deltaset);
	vplot('liv,lm',mubnds1,'-',mubnds4,'--')
	xlabel('Frequency (rad/sec)')