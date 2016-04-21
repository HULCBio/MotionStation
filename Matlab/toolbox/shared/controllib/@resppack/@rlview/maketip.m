function str = maketip(this,tip,info)
%MAKETIP  Build data tips for @rlview curves.
%
%   INFO is a structure built dynamically by the data tip interface
%   and passed to MAKETIP to facilitate construction of the tip text.

%   Author(s): John Glass
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:23:06 $

r = info.Carrier;
h = r.Parent;
AxGrid = h.AxesGrid;

% Create tip text

% Pole location
x = tip.Position(1);
y = tip.Position(2);
z = complex(x,y);
if y>0
    pstr = sprintf('Pole: %0.3g + %0.3gi',x,y);
elseif y<0
    pstr = sprintf('Pole: %0.3g - %0.3gi',x,-y);
else
    pstr = sprintf('Pole: %0.3g',x);
end

% Gain value
data = info.Data;
den = data.SystemGain*prod(data.SystemZero-z);
if den==0
    g = Inf;
else
    g = abs(prod(data.SystemPole-z)/den);
end

% Damping/Frequency values
[wn,zeta] = damp(z,data.Ts);
wn = unitconv(wn,'rad/sec',h.FrequencyUnits);

% Percentage Peak Overshoot
if abs(zeta)==1
    ppo = 0;
else
    ppo = exp(-pi*zeta/sqrt((1-zeta)*(1+zeta))); % equiv to exp(-z*pi/sqrt(1-z^2))
    ppo = round(1e6*ppo)/1e4; % round off small values
end

str = {sprintf('Response: %s',r.Name);...
      sprintf('Gain: %0.3g',g);...
      pstr;...
      sprintf('Damping: %0.3g',zeta);...
      sprintf('Overshoot (%%): %0.3g',ppo);...
      sprintf('Frequency (%s): %0.3g',h.FrequencyUnits,wn)};
