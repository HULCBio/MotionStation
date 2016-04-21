function h = labelstyle(hlab)
% Returns instance of @labelstyle class

%   Author: P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:18:14 $

% RE: Optimized for speed

% Create @labelstyle instance 
h = ctrluis.labelstyle;

% Initialize with properties of supplied axes
if nargin
   hlab = handle(hlab);
   h.Color = hlab.Color;
   h.FontAngle = hlab.FontAngle;
   h.FontSize = hlab.FontSize;
   h.FontWeight = hlab.FontWeight;
   h.Interpreter = hlab.Interpreter;
end

% Listener to style changes
c = classhandle(h);
h.Listener = handle.listener(h,c.Properties(1:6),'PropertyPostSet',@LocalUpdateStyle);


%---------------------- Local Functions --------------------

function LocalUpdateStyle(eventsrc,eventdata)
% Evaluate the update fcn
h = eventdata.AffectedObject;
if ~isempty(h.UpdateFcn)
   feval(h.UpdateFcn{1},eventsrc,eventdata,h.UpdateFcn{2:end});
end
