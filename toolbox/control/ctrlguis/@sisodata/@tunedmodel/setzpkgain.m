function setzpkgain(CompData,Gain,flag)
%SETZPKGAIN   Sets ZPK model gain.
%
%   SETZPKGAIN(MODEL,GAIN) sets the gain of the ZPK representation of MODEL.
%   SETZPKGAIN(MODEL,GAIN,'mag') sets the magnitude of the ZPK gain.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.2 $  $Date: 2002/04/10 04:54:55 $
Gain = Gain/formatfactor(CompData);  % scale to current format
if nargin==1
   setgain(CompData,Gain);
else
   setgain(CompData,abs(Gain),'mag');
end