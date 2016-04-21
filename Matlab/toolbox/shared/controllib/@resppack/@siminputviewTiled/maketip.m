function str = maketip(this,tip,info)
%MAKETIP  Build data tips for @siminputview.
%
%   INFO is a structure built dynamically by the data tip interface
%   and passed to MAKETIP to facilitate construction of the tip text.

%   Author(s): P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:23:44 $
AxGrid = info.View.AxesGrid;

% Finalize Y data
Y = tip.Position(2);
if strcmp(AxGrid.YNormalization,'on')
   ax = getaxes(info.Tip);
   Y = denormalize(info.Data,Y,get(ax,'XLim'));
end
   
% Create tip text
InputIndex = info.ArrayIndex;
iName = info.Carrier.ChannelName{InputIndex};
if isempty(iName)
   iName = sprintf('Input: In(%d)',InputIndex);
else
   iName = sprintf('Input: %s',iName);
end
str = {iName ; ...
      sprintf('Time (%s): %0.3g', AxGrid.XUnits, tip.Position(1)) ;...
      sprintf('Amplitude: %0.3g', Y)};
