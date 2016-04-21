% function ex_unc(p,ptilde,wu,omega)

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function ex_unc(p,ptilde,wu,omega)
        pg = frsp(p,omega);
        ptildeg = frsp(ptilde,omega);
        wug = frsp(wu,omega);
        percdiff = vabs(vrdiv(msub(ptildeg,pg),pg));
	dd = vrdiv(percdiff,wug);
        vplot('liv,m',dd,1);
	pkvnorm(dd)