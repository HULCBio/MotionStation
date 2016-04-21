function gridline(varargin)
%GRIDLINE  Draw a gridline

%   Author(s): A. DiVergilio
%   Copyright 1986-2002 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2002/04/10 06:41:48 $

%---Default properties
p = struct(...
   'Parent',[],...
   'LineWidth',0.5,...
   'LineStyle',':',...
   'Color','k',...
   'Value',1,...
   'Type','x',...
   'Tag','',...
   'EraseMode','normal');
plist = fieldnames(p);

%---Merge user-specified properties
for i=1:2:nargin-1
   Property = pnmatch(varargin{i},plist);
   Value = varargin{i+1};
   p.(Property) = Value;
end
if isempty(p.Parent), p.Parent = gca; end

switch lower(p.Type)
case 'x'
   xdata = [p.Value p.Value];
   ydata = get(p.Parent,'YLim');
   tracklim = 'YLim';
otherwise
   xdata = get(p.Parent,'XLim');
   ydata = [p.Value p.Value];
   tracklim = 'XLim';
end

%---Draw a line
h = line(...
   'Parent',p.Parent,...
   'XData',xdata,...
   'YData',ydata,...
   'LineWidth',p.LineWidth,...
   'LineStyle',p.LineStyle,...
   'Color',p.Color,...
   'HandleVisibility','off',...
   'HitTest','off',...
   'EraseMode',p.EraseMode,...
   'Tag',p.Tag,...
   'Clipping','on');

%---Add listener
 lstn = handle.listener(p.Parent,findprop(handle(p.Parent),tracklim),'PropertyPostSet',@localGridLineCallback);
 lstn.CallbackTarget = h;
 set(h,'UserData',lstn);


%%%%%%%%%%%%%%%%%%%%%%%%%
% localGridLineCallback %
%%%%%%%%%%%%%%%%%%%%%%%%%
function localGridLineCallback(eventSrc,eventData)
 %---Listener callback for grid lines
  switch eventData.Source.Name
  case 'XLim'
     set(eventSrc,'XData',eventData.newValue);
  case 'YLim'
     set(eventSrc,'YData',eventData.newValue);
  end
