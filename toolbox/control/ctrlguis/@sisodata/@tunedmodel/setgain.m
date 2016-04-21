function setgain(CompData,NewValue,flag)
%SETGAIN  Sets the formatted gain data.
%
%   setgain(CompData,NewGain)
%   setgain(CompData,NewGain,'mag')
%   setgain(CompData,NewGain,'sign')
%
%   The formatted gain is the ZPK gain divided by the format factor 
%   (see FORMATFACTOR for details).

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.10 $ $Date: 2002/04/10 04:54:28 $

NewSign = sign(NewValue) + (~NewValue);
if nargin==2
    % Specifying new gain value
    CompData.Gain = struct('Sign',NewSign,'Magnitude',abs(NewValue));
elseif strcmpi(flag(1),'m')
    % Specifying just magnitude
    CompData.Gain = struct('Sign',CompData.Gain.Sign,'Magnitude',abs(NewValue));
else
    % Specifying just sign
    CompData.Gain = struct('Sign',NewSign,'Magnitude',CompData.Gain.Magnitude);
end
