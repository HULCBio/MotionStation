function moveaxis(arg)
%MOVEAXIS Used by LEGEND to enable dragging of legend.
%   This function is for private use of LEGEND, and is
%   not intended for use by other programs.  It is
%   automatically installed as the ButtonDownFcn of the
%   legend axes and its children, enabling dragging of
%   legends with the mouse.
%
%   To allow dragging and resizing of any other axes,
%   use SELECTMOVERESIZE.
%
%   See also LEGEND, SELECTMOVERESIZE.

%   10/5/93  D.Thomas
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.19 $  $Date: 2002/04/15 04:07:35 $

% get the figure handle in a way that's robust to hidden handles
fig = gcbf;
% don't do anything if we're not called from a callback:
if isempty(fig)
    return;
end
% don't do anything if we're supposed to be zooming
tmp = zoom(fig,'getmode');
if (isequal(tmp,'in') | isequal(tmp,'on')), return; end

if nargin==0, % we're getting called as a result of the ButtonDownFcn:
	lax = find_legend_axes(gcbo);
    % if we can't identify a legend as the ancestor of the object
    % that was clicked on, bail out.
    if isempty(lax)
        return;
    end
    st=get(fig,'SelectionType');
    if (strcmp(st,'normal'))
        moveaxis(1);
    elseif strcmp(st,'open') & strcmp(get(gcbo,'Type'),'text')
        legend('EditLegend',gcbo)
    end
    
elseif arg==1, % set up for a drag
    mad.oldFigUnits = get(fig,'units');             set(fig,'units','pixels');
	mad.oldFigPointer = get(fig,'pointer');         set(fig,'pointer','fleur');
	mad.legendAxes = find_legend_axes(gcbo);
    mad.oldAxesUnits = get(mad.legendAxes,'units'); set(mad.legendAxes,'units','pixels');
    pnt=get(fig,'currentpoint');
	pos = get(mad.legendAxes,'position');
    mad.DELTA = pos(1:2) - pnt;
    mad.oldWindowButtonMotionFcn = get(fig,'windowbuttonmotionfcn');
    set(fig,'windowbuttonmotionfcn','moveaxis(2)');
    mad.oldWindowButtonUpFcn = get(fig,'windowbuttonupfcn');
    set(fig,'windowbuttonupfcn','moveaxis(3)');
 	setappdata(fig,'moveaxisData',mad);
    
elseif arg==2, % mouse motion during a drag
	mad = getappdata(fig,'moveaxisData');
    pos=get(mad.legendAxes,'position');
	set(mad.legendAxes,'position',[get(fig,'currentpoint')+mad.DELTA pos(3:4)]);
   
elseif arg==3, % mouse release - done dragging
	mad = getappdata(fig,'moveaxisData');
    set(fig,'WindowButtonMotionfcn',mad.oldWindowButtonMotionFcn,...
            'WindowButtonUpFcn',mad.oldWindowButtonUpFcn,...
            'pointer', mad.oldFigPointer,...
            'units', mad.oldFigUnits);
	set(mad.legendAxes, 'units', mad.oldAxesUnits);
    legend('ShowLegendPlot', mad.legendAxes)
    rmappdata(fig,'moveaxisData');
end

function lax = find_legend_axes(obj)
lax = [];
while ~isempty(obj)
    if strcmp(get(obj,'type'),'axes') & strcmp(get(obj,'tag'),'legend')
        lax = obj;
        break;
    end
    obj = get(obj,'parent');
end
