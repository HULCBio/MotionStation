function h=arrow(varargin)
%ARROW creates an annotation arrow
%  H=GRAPH2D.ARROW creates an annotation arrow
%
%  See also PLOTEDIT

%   Copyright 1984-2002 The MathWorks, Inc.  
%   $Revision: 1.9 $  $Date: 2002/04/15 03:59:30 $ 

if (~isempty(varargin))
    h = graph2d.arrow(varargin{:}); % Calls built-in constructor
else
    h = graph2d.arrow;
end

% initialize property values -----------------------------
h.DisplayLineStyle='-';
h.DisplayLineColor=[0 0 0];
h.DisplayLineWidth=[.5];
h.LineHandle=handle([]);
h.HeadHandle=handle([]);

h.StartPoint= [h.XData(1) h.YData(1)];
h.EndPoint  = [h.XData(2) h.YData(2)];


%set up listeners-----------------------------------------
l       = handle.listener(h,h.findprop('DisplayLineStyle'),...
			  'PropertyPostSet',@changedLineStyle);
l(end+1)= handle.listener(h,h.findprop('DisplayLineColor'),...
			  'PropertyPostSet',@changedLineColor);
l(end+1)= handle.listener(h,h.findprop('DisplayLineWidth'),...
			  'PropertyPostSet',@changedLineWidth);

l(end+1)= handle.listener(h,h.findprop('LineHandle'),...
			  'PropertyPostSet',@changedLineHandle);
l(end+1)= handle.listener(h,h.findprop('HeadHandle'),...
			  'PropertyPostSet',@changedHeadHandle);

l(end+1)= handle.listener(h,h.findprop('Visible'),...
			  'PropertyPostSet',@changedPassOn);
l(end+1)= handle.listener(h,h.findprop('Parent'),...
			  'PropertyPostSet',@changedPassOn);

l(end+1)= handle.listener(h,h.findprop('StartPoint'),...
			  'PropertyPostSet',@changedStartEndPoint);
l(end+1)= handle.listener(h,h.findprop('EndPoint'),...
			  'PropertyPostSet',@changedStartEndPoint);

l(end+1)= handle.listener(h,h.findprop('XData'),...
			  'PropertyPostSet',@changedXYData);
l(end+1)= handle.listener(h,h.findprop('YData'),...
			  'PropertyPostSet',@changedXYData);

% We need to recreate the scribe object on load after
% the tag has been set because it is used by the
% getorcreateobj function.
l(end+1)= handle.listener(h,h.findprop('Tag'),...
			  'PropertyPostSet',@changedTag);

h.PropertyListeners = l;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function changedLineStyle(hProp,eventData)

set(eventData.affectedObject.LineHandle,...
    'LineStyle',eventData.newValue);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function changedLineColor(hProp,eventData)

set(eventData.affectedObject.LineHandle,...
    'Color',eventData.newValue);
set(eventData.affectedObject.HeadHandle,...
    'FaceColor',eventData.newValue,...
    'EdgeColor',eventData.newValue);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function changedLineWidth(hProp,eventData)

set(eventData.affectedObject.LineHandle,...
    'LineWidth',eventData.newValue);

refresh(eventData.affectedObject);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function changedLineHandle(hProp,eventData)

%initialize display properties appropriately

hArrow=eventData.affectedObject;
hLine =handle(eventData.newValue);

set(hArrow,'DisplayLineStyle',get(hLine,'LineStyle'));
set(hArrow,'DisplayLineColor',get(hLine,'Color'));
set(hArrow,'DisplayLineWidth',get(hLine,'LineWidth'));

%set up listeners-----------------------------------------
l       = handle.listener(hLine,hLine.findprop('LineStyle'),...
    'PropertyPostSet',{@changedLineRemote,hArrow});
l(end+1)= handle.listener(hLine,hLine.findprop('Color'),...
    'PropertyPostSet',{@changedLineRemote,hArrow});
l(end+1)= handle.listener(hLine,hLine.findprop('LineWidth'),...
    'PropertyPostSet',{@changedLineRemote,hArrow});

hArrow.ArrowListeners = l;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function changedLineRemote(hProp,eventData,hArrow)

switch hProp.Name
case 'Color'
    propName=sprintf('DisplayLine%s',hProp.Name);
otherwise
    propName=sprintf('Display%s',hProp.Name);
end

set(hArrow,propName,eventData.NewValue);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function changedHeadHandle(hProp,eventData)

%instrument head in any way?


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function changedPassOn(hProp,eventData)
%when this property is changed, pass the change on to the
%line and head

set([eventData.affectedObject.LineHandle, eventData.affectedObject.HeadHandle],...
    hProp.name,...
    eventData.newValue);
refresh(eventData.affectedObject);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function changedStartEndPoint(hProp,eventData)

h=eventData.affectedObject;

if strcmp(h.LineStyle,'none')
    %only pass back if we are doing property editing
    set(h,'XData',[h.StartPoint(1),h.EndPoint(1)]);
    set(h,'YData',[h.StartPoint(2),h.EndPoint(2)]);
    
    refresh(eventData.affectedObject);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function changedXYData(hProp,eventData)

h=eventData.affectedObject;

if ~strcmp(h.LineStyle,'none')
    %only pass up if we are dragging
    set(h,'StartPoint',[h.XData(1), h.YData(1)]);
    set(h,'EndPoint'  ,[h.XData(2), h.YData(2)]);
end    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function changedTag(hProp,eventData)

refresh(eventData.affectedObject);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function refresh(h);

%recalculate head position - note that the second argument
%is nonfunctional, but arrowline/set demands a p-v pair for input
set(getorcreateobj(h),'Refresh','ArrowHead');
