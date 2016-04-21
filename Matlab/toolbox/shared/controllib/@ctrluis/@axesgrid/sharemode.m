function sharemode(h,XYFlag)
%SHAREMODE  Enforces common X or Y limit modes.
%
%   Used when switching to uniform X or Y limits, e.g., by 
%   setting XLimSharing='all' or AxesGrouping='input'.

%   Author(s): P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:16:58 $

% Turn off backdoor listeners
h.LimitManager = 'off';

% Read current limit modes
Xaxis = strcmpi(XYFlag,'x');
if Xaxis
    LimMode = h.XLimMode;
    LimSharing = h.XLimSharing;
    stride = h.Size(4);
else
    LimMode = h.YLimMode;
    LimSharing = h.YLimSharing;
    stride = h.Size(3);
end

% Harmonize limit modes
switch LimSharing
case 'all'
   if any(strcmp(LimMode,'auto'))
      LimMode = 'auto';
   else
      LimMode = 'manual';
   end
case 'peer'    
   for ct=1:stride
      if any(strcmp(LimMode(ct:stride:end,:),'auto'))
         LimMode(ct:stride:end,:) = {'auto'};
      else
         LimMode(ct:stride:end,:) = {'manual'};
      end
   end
end
 
% Save new modes
if Xaxis
    h.XLimMode = LimMode;
else
    h.YLimMode = LimMode;
end

% Turn backdoor listeners back on
h.LimitManager = 'on';


