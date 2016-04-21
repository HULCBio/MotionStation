function h=annotationlayer(varargin)
%ANNOTATIONLLAYER creates an annotation layer
%  H=GRAPH2D.ANNOTATIONLAYER creates an annotation layer for drawing
%  arrows, lines, and text
%
%  See also PLOTEDIT

%   Copyright 1984-2002 The MathWorks, Inc.  
%   $Revision: 1.8 $  $Date: 2002/04/15 03:59:24 $ 

if (~isempty(varargin))
    h = graph2d.annotationlayer(varargin{:}); % Calls built-in constructor
else
    h = graph2d.annotationlayer;
end

jpropeditutils('jforcenavbardisplay',h,0);

% Make sure that Xlabel, YLabel, etc are created before
% child added listeners are created.

childHandles=[get(h,'XLabel')
	      get(h,'YLabel')
	      get(h,'ZLabel')
	      get(h,'Title')];

% initialize property values -----------------------------

%set up listeners-----------------------------------------

%cls = classhandle(h);

l       = handle.listener(h, ...
			  'ObjectChildAdded',@changedChildren);
l(end+1)= handle.listener(h, ...
			  'ObjectChildRemoved',@changedChildren);

h.PropertyChangedListeners = l;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function changedChildren(hProp,ChildEventData)

hAxes=ChildEventData.Source;
hChildren=get(double(hAxes),'Children');
hChildren=findobj(hChildren,'flat','beingdeleted','off');

jpropeditutils('jforcenavbardisplay',...
    hAxes,...
    length(hChildren)>0);
