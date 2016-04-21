function sys = mtimes(sys1,sys2)
%MTIMES  Multiplication of IDMODELS.
%   Requires the Control Systems Toolbox.
%
%   MOD = MTIMES(MOD1,MOD2) performs MOD = MOD1 * MOD2.
%   Multiplying two LTI models is equivalent to
%   connecting them in series as shown below:
%
%         u ----> MOD2 ----> MOD1 ----> y
%
%
%   NOTE: MTIMES  only deals with the measured input channels.
%   To interconnect also the noise input channels, first convert
%   them to measured channels by NOISECNV.
%
%   The covariance information is lost.
%   See also SERIES, INV.


%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.3.4.2 $  $Date: 2004/04/10 23:17:31 $

try
    syss1 = ss(sys1('m'));
    syss2 = ss(sys2('m'));
catch
    error(lasterr)
end
try
    syss = syss1 * syss2;
catch
    error(lasterr)
end
names = [syss.InputName;syss.OutputName];
if length(unique(names))<length(names)
    syss.InputName = defnum([],'u',size(syss,2));
    syss.OutputName = defnum([],'y',size(syss,1));
end
switch class(sys1)
    case {'idss','idarx','idgrey','idproc'}
        sys = idss(syss);
    case{'idpoly'}
        sys = idpoly(syss);
end

