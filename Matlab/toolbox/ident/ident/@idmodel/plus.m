function sys = plus(sys1,sys2)
%PLUS  Addition of two IDMODEL models
%   Requires the Control Systems Toolbox.
%
%   MOD = PLUS(MOD1,MOD2) performs MOD = MOD1 + MOD2.
%   Adding  models is equivalent to connecting 
%   them in parallel.
%
%   NOTE: PLUS only deals with the measured input channels.
%   To interconnect also the noise input channels, first convert
%   them to measured channels by NOISECNV.
%
%   The covariance information is lost.

%
%   See also PARALLEL, MINUS, UPLUS.

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.3.4.2 $  $Date: 2004/04/10 23:17:33 $

try
syss1 = ss(sys1('m'));
syss2 = ss(sys2('m'));
catch
  error(lasterr)
end
try
syss = syss1 + syss2;
catch
  error(lasterr)
end

switch class(sys1)
 case {'idss','idarx','idgrey','idproc'}
  sys = idss(syss);
 case{'idpoly'}
  sys = idpoly(syss);
end

  