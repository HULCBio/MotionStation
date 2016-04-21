function Gain = getgain(CompData,flag)
%GETGAIN  Gets the formatted gain data.
%
%   Gain = getgain(CompData)
%   Gain = getgain(CompData,'mag')
%   Gain = getgain(CompData,'sign')
%
%   The formatted gain is the ZPK gain divided by the format factor 
%   (see FORMATFACTOR for details).

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.7 $ $Date: 2002/04/10 04:54:37 $

if nargin==1
    % Getting gain value
    Gain = CompData.Gain.Sign * CompData.Gain.Magnitude;
elseif strcmpi(flag(1),'m')
    % Getting just magnitude
    Gain = CompData.Gain.Magnitude;
else
    % Getting just sign
    Gain = CompData.Gain.Sign;
end
