function str = maketip(this,tip,info)
%MAKETIP  Build data tips for @rlview curves.
%
%   INFO is a structure built dynamically by the data tip interface
%   and passed to MAKETIP to facilitate construction of the tip text.

%   Author(s): Kamesh Subbarao
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:22:20 $

r = info.Carrier;
h = r.Parent;  % @respplot
AxGrid = info.View.AxesGrid;

% Create tip text
% Pole location
x = tip.Position(1);
y = tip.Position(2);
z = complex(x,y);
if (info.type == 'x')
    polestr = xlate('Pole');
else
    polestr = xlate('Zero');
end         
if y>0
    pstr = sprintf('%s : %0.3g + %0.3gi',polestr,x,y);
elseif y<0
    pstr = sprintf('%s : %0.3g - %0.3gi',polestr,x,-y);
else
    pstr = sprintf('%s : %0.3g',polestr,x);
end
% Damping/Frequency values
[wn,zeta] = damp(z,abs(info.Data.Ts));
wn = unitconv(wn,'rad/sec',h.FrequencyUnits);

% Percentage Peak Overshoot
if abs(zeta)==1
    ppo = 0;
else
    ppo = exp(-pi*zeta/sqrt((1-zeta)*(1+zeta))); % equiv to exp(-z*pi/sqrt(1-z^2))
    ppo = round(1e6*ppo)/1e4; % round off small values
end

% Build string
str{1} = sprintf('Response: %s', r.Name);
[iotxt,ShowFlag] = rcinfo(r,info.Row,info.Col);
if any(AxGrid.Size(1:2)>1) | ShowFlag
   % Show if MIMO or non trivial
   str{end+1,1} = iotxt;
end
str = [str ; {pstr;...
         sprintf('Damping: %0.3g',zeta);...
         sprintf('Overshoot (%%): %0.3g',ppo);...
         sprintf('Frequency (%s): %0.3g',h.FrequencyUnits,wn)}];
