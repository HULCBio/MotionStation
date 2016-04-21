function scribefiglisten(fig,onoff)
%SCRIBEFIGLISTEN listeners for figures and their axes children.

% SCRIBEFIGLISTEN(fig,onoff) creates child added/removed listeners 
% (if they do not already exist) for fig and its non-legend,
% non-colorbar axes children, and enables (onoff=true) or 
% disables(onoff=false)them. Firing listeners turns off zoom and 
% rotate3d for the figure.
% Called by zoom and rotate3d

%   Copyright 1984-2004 The MathWorks, Inc. 

% create listeners if they don't already exist
if isempty(findprop(handle(fig),'ScribeFigListeners'))
    % create listeners property
    pl = schema.prop(handle(fig),'ScribeFigListeners','MATLAB array');
    pl.AccessFlags.Serialize = 'off';
    % create listeners array
    l.chadd = handle.listener(fig,'ObjectChildAdded',...
        {@scribeFigChildAdded, fig});
    l.chremove = handle.listener(fig,'ObjectChildRemoved',...
        {@scribeFigChildRemoved, fig});
    % set listeners property to listeners array
    set(handle(fig),'ScribeFigListeners',l);
end

% set figure listeners enabled/disabled
l = get(handle(fig),'ScribeFigListeners');
set(l.chadd,'Enabled',onoff);
set(l.chremove,'Enabled',onoff);

% get list of axes children
ax = findobj(fig,'type','axes');

if ~isempty(ax)
    % create listeners for axes if they don't exist
    for i=1:length(ax)
        % don't create them for axes that are legends or colorbars
        if ~isa(handle(ax(i)),'scribe.colorbar') && ~isa(handle(ax(i)),'scribe.legend') && ...
                ~any(strcmp(get(get(ax(i),'children'),'tag'),'TMW_COLORBAR')) && ...
                ~strcmp(get(ax(i),'tag'),'legend')
            if isempty(findprop(handle(ax(i)),'ScribeFigAxListeners'))
                % create listeners property
                pl = schema.prop(handle(ax(i)),'ScribeFigAxListeners','MATLAB array');
                pl.AccessFlags.Serialize = 'off';
                % create listeners array
                l.chadd = handle.listener(ax(i),'ObjectChildAdded',...
                    {@scribeFigAxChildAdded, fig});
                l.chremove = handle.listener(ax(i),'ObjectChildRemoved',...
                    {@scribeFigAxChildRemoved, fig});
                % set listeners property to listeners array
                set(handle(ax(i)),'ScribeFigAxListeners',l);
            end
            % set figure axes listeners enabled/disabled
            l = get(handle(ax(i)),'ScribeFigAxListeners');
            set(l.chadd,'Enabled',onoff);
            set(l.chremove,'Enabled',onoff);
        end
    end
end

%------------------------------------------------------------------------%
% figure add child callback
% if the added child is an axes
% or is a uicontextmenu or uicontrol
% turn off zoom and rotate3d
function scribeFigChildAdded(src,event,fig)

chh = handle(event.child);
tag = get(chh,'tag');
type = get(chh,'type');

if isa(chh,'scribe.legend') || ...
      isa(chh,'scribe.colorbar') || ...
        strcmpi(tag,'ScribeOverlay') || ...
        strcmpi(tag,'ScribeLegendContextMenu') || ...
        strcmpi(tag,'ScribeColorbarContextMenu')
    if isappdata(fig,'Rotate3dOnState')
        rotate3d(fig,'off');
        rotate3d(fig,'on');
    elseif strcmpi('out',zoom(fig,'getmode'))
        zoom(fig,'off');
        zoom(fig,'outmode');
    elseif isappdata(fig,'ZoomOnState')
        zoomstate = getappdata(fig,'ZoomOnState');
        zoom(fig,'off');
        zoom(fig,zoomstate);
    end
elseif strcmp(get(chh,'HandleVisibility'),'off')
    % otherwise if object is an axes, uicontextmenu or uicontrol
    % turn zoom and rotate3d off.
elseif  isa(chh,'hg.axes') | ...
        isa(chh,'hg.uicontextmenu') | ...
        isa(chh,'hg.uicontrol')    
    zoom(fig,'off');
    rotate3d(fig,'off');
end

%------------------------------------------------------------------------%
% figure remove child callback
% if the child is an axes
% or is a uicontextmenu or uicontrol
% turn off zoom and rotate3d
function scribeFigChildRemoved(src,event,fig)

chh = handle(event.child);
tag = get(chh,'tag');
type = get(chh,'type');

if isa(chh,'scribe.legend') || ...
      isa(chh,'scribe.colorbar') || ...
        strcmpi(tag,'ScribeOverlay') || ...
        strcmpi(tag,'ScribeLegendContextMenu') || ...
        strcmpi(tag,'ScribeColorbarContextMenu')
    if isappdata(fig,'Rotate3dOnState')
        rotate3d(fig,'off');
        rotate3d(fig,'on');
    elseif strcmpi('out',zoom(fig,'getmode'))
        zoom(fig,'off');
        zoom(fig,'outmode');
    elseif isappdata(fig,'ZoomOnState')
        zoomstate = getappdata(fig,'ZoomOnState');
        zoom(fig,'off');
        zoom(fig,zoomstate);
    end
elseif strcmp(get(chh,'HandleVisibility'),'off')
    
    % otherwise if object is an axes, uicontextmenu or uicontrol
    % turn zoom and rotate3d off.
elseif  isa(chh,'hg.axes') | ...
        isa(chh,'hg.uicontextmenu') | ...
        isa(chh,'hg.uicontrol')
    zoom(fig,'off');
    rotate3d(fig,'off');
end

%------------------------------------------------------------------------%
% axes add child callback
% turn off zoom and rotate3d
function scribeFigAxChildAdded(src,event,fig)

chh = handle(event.child);
if strcmp(get(chh,'HandleVisibility'),'on')
    zoom(fig,'off');
    rotate3d(fig,'off');
end


%------------------------------------------------------------------------%
% axes remove child callback
% turn off zoom and rotate3d
function scribeFigAxChildRemoved(src,event,fig)

chh = handle(event.child);
if strcmp(get(chh,'HandleVisibility'),'on')
    zoom(fig,'off');
    rotate3d(fig,'off');
end

%------------------------------------------------------------------------%