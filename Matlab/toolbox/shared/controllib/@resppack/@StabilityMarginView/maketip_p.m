function str = maketip(this,tip,info,fUnits,mUnits,pUnits)
%MAKETIP  Build data tips for StabilityMarginView Characteristics.

%   Author(s): John Glass
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:19:39 $

% REVISIT: rename to MAKETIP when superclass::method call available
r = info.Carrier;
AxGrid = info.View.AxesGrid;
str{1,1} = sprintf('Response: %s',r.Name);

%% Get the UserData from the host to get the marker index
MarkerIndex = tip.Host.UserData;
if info.MarginType == 1
   % Convert Gain Margin Frequency from rad/s to Axis Grid XUnits
   XData = unitconv(info.Data.GMFrequency(MarkerIndex),'rad/sec',fUnits);
   XData = sprintf('%0.3g, ',XData);
   % Convert Gain Margin from abs to Axis Grid YUnits{1}
   YData = unitconv(info.Data.GainMargin(MarkerIndex),'abs',mUnits);
   YData = sprintf('%0.3g, ',YData);
   str{end+1,1} = sprintf('Gain Margin (%s): %s', mUnits, YData(1:end-2));
   str{end+1,1} = sprintf('At frequency (%s): %s', fUnits, XData(1:end-2));
   
else
   % Convert Phase Margin Frequency from rad/s to Axis Grid XUnits
   XData = unitconv(info.Data.PMFrequency(MarkerIndex),'rad/sec',fUnits);
   XData = sprintf('%0.3g, ',XData);
   % Convert Phase Margin from deg to Axis Grid YUnits{2}
   YData = unitconv(info.Data.PhaseMargin(MarkerIndex),'deg',pUnits);
   YData = sprintf('%0.3g, ',YData);
   % Delay margins
   DelayData = info.Data.DelayMargin(MarkerIndex);
   DelayData = sprintf('%0.3g, ',DelayData);
   str{end+1,1} = sprintf('Phase Margin (%s): %s',pUnits,YData(1:end-2));
   % If the system is discrete, then display the units to be samples.
   % Otherwise use seconds.
   if info.Data.Ts
       str{end+1,1} = sprintf('Delay Margin (samples): %s', DelayData(1:end-2));
   else
       str{end+1,1} = sprintf('Delay Margin (sec): %s', DelayData(1:end-2));
   end   
   str{end+1,1} = sprintf('At frequency (%s): %s', fUnits, XData(1:end-2));
end


if isempty(info.Data.Stable) || isnan(info.Data.Stable) 
   Stable = 'Not known';
elseif info.Data.Stable
   Stable = 'Yes';
else
   Stable = 'No';
end
str{end+1,1} = sprintf('Closed Loop Stable? %s', Stable);
