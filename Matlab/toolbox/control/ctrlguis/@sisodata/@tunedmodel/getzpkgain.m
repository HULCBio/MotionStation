function Gain = getzpkgain(CompData,flag)
%GETZPKGAIN   Get ZPK model gain.
%
%   GAIN = GETZPKGAIN(MODEL) computes the gain of the ZPK representation of MODEL.
%   GAIN = GETZPKGAIN(MODEL,'sign') computes the sign of the ZPK gain.
%   GAIN = GETZPKGAIN(MODEL,'mag') computes the magnitude of the ZPK gain.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.2 $  $Date: 2002/04/10 04:54:52 $
if nargin==1
   Gain = getgain(CompData) * formatfactor(CompData);
elseif strcmpi(flag(1),'m')
   Gain = abs(getgain(CompData) * formatfactor(CompData));
else
   Gain = sign(getgain(CompData,'sign') * formatfactor(CompData));
end