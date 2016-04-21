function map=colormapeditor(varargin)
%COLORMAPEDITOR starts colormap editor ui
%
%   When started the colormap editor displays the current figure's colormap
%   as a strip of rectangluar cells. Nodes, displayed as rectangles(end
%   nodes) or carrots below the strip, separate regions of uniform slope in
%   R,G and B.   The grays colormap, for example, has only two nodes since
%   R,G and B increase at a constant slope from the first to last index in
%   the map. Most of the other standard colormaps have additional nodes where
%   the slopes of the R,G or B curves change.
% 
%   As the mouse is moved over the color cells the colormap index, CData
%   value r,g,b and h,s,v values for that cell are displayed in the Current
%   Color Info box of the gui.
%
%   To add a node: 
%       Click below the cell where you wish to add the node
%
%   To delete a node:
%       Select the node by clicking on it and hit the Delete key or
%       Edit->Delete, or Ctrl-X
%
%   To move a node:
%       Click and drag or select and use left and right arrow keys.
%
%   To change a node's color:
%       Double click or click to select and Edit->Set Node Color. If multiple
%       nodes are selected the color change will apply to the last node
%       selected (current node).
%
%   To select this node, that node and all nodes between:
%       Click on this node, then Shift-Click on that node.
%
%   To select this, that and the other node:
%       Click on this, Ctrl-Click on that and the other.
%
%   To move multiple nodes at once: 
%       Select multiple nodes then use left and right arrow keys to move them
%       all at once.  Movement will stop when one of the selected nodes bumps
%       into an unselected node or end node. 
%
%   To delete multiple nodes:
%       Select the nodes and hit the Delete key, or Edit->Delete, or Ctrl-X.
%
%   To avoid flashing while editing the colormap set the figures DoubleBuffer
%   property to 'on'.
%
%   The "Interpolating Colorspace" selection determines what colorspace is
%   used to calculate the color of cells between nodes.  Initially this is
%   set to RGB, meaning that the R,G and B values of cells between nodes are
%   linearly interpolated between the R,G and B values of the nodes. Changing
%   the interpolating colorspace to HSV causes the cells between nodes to be
%   re-calculated by interpolating their H,S and V values from  the H,S and V
%   values of the nodes.  This usually produces very different results.
%   Because Hue is conceptually mapped about a color circle, the
%   interpolation between Hue values could be ambiguous.  To minimize
%   ambiguity the shortest distance around the circle is used.  For example,
%   if two  nodes have Hues of 2(slightly orange red) and 356 (slightly
%   magenta red), the cells between them would not have hues 3,4,5 ....
%   353,354,355  (orange/red-yellow-green-cyan-blue-magenta/red) but 357,
%   358, 1, 2  (orange/red-red-magenta/red).
%
%   The "Color Data Min" and "Color Data Max" editable text areas contain 
%   the values that correspond to the current axes "Clim" property.  These
%   values may be set here and are useful for selecting a range of data
%   values to which the colormap will map.  For example, your CData values
%   might range from 0 to 100, but the range of interest may be between 40 
%   and 60.  Using Color Data Min and Max (or the Axes Clim property) the
%   full variation of the colormap can be placed between the values 40 and 60
%   to improve visual/color resolution in that range.   Color Data Min
%   corresponds to Clim(0) and is the CData value to which the first Colormap
%   index is mapped.  All CData Values below this will display in the same
%   color as the first index.  Color Data Max corresponds to Clim(1) and is
%   the CData value to which the last Colormap index is mapped.  All CData 
%   values greater than this will display the same color as the last index.
%   Setting Color Data Min and Max (or Clim) will only affect the display of
%   objects (Surfaces, Patches, Images) who's CDataMapping Property is set to
%   'Scaled'.  e.g.  imagesc(im) but not image(im).
%
%   Immediate Apply is checked by default, and applies changes as they are
%   made.  If Immediate Apply is unselected, changes in the colormap editor
%   will not be applied until the apply or OK button is selected, and any
%   changes made will be lost if the Cancel button is selected.
%
%   see also COLORMAP


%   G. DeLoid 03/04/2002
%
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.2.4.5 $  $Date: 2004/04/10 23:26:48 $

import com.mathworks.page.cmapeditor.*;

nargs = nargin;

fig = [];
% look for figure input
if nargs > 0 && ...
        ~all(isempty(varargin{1})) && ...
        length(varargin{1})==1 && ...
        ishandle(varargin{1}) && ...
        strcmp(get(varargin{1},'type'),'figure')
    fig = varargin{1}(1);
    set(0,'CurrentFigure',fig);
    varargin(1) = [];
    nargs = nargs - 1;
end

if nargs==0
    j=version('-java');
    if ~strncmpi(j,'Java 1.3',8) & ~strncmpi(j,'Java 1.4',8)
        error('MATLAB:COLORMAPEDITOR:wrongjvm','Java 1.3 or greater required.');
        return;
    elseif isappdata(0,'CMEditor')
        cmeditor = getappdata(0,'CMEditor');
        cmeditor.bringToFront(1);
        cmeditor.setVisible;
        return;
    end
    
    % start colormapeditor
    
    % get figure if not provided
    if isempty(fig)
        fig = get(0,'CurrentFigure');
        if isempty(fig)
            fig=figure;
        end
    end
    
    cmeditor = CMEditor;
    cmeditor.init;
    cmap = get(fig,'Colormap');
    % cmeditor.getModel.setColorMapModel(cmap);
    cmeditor.getModel.setBestColorMapModel(cmap);
    
    ax = get(fig,'CurrentAxes');
    if isempty(ax)
        cmeditor.getFrame.setColorLimitsEnabled(0);
    else
        clim = get(ax,'Clim');
        cmeditor.getFrame.setColorLimitsEnabled(1);
        cmeditor.getModel.setColorLimits(clim,0);
    end
    
    setappdata(0,'CMEditor',cmeditor);
    
    cmeditor.setVisible;
    start_listeners(cmeditor,fig,ax);
    
else
    funcode = varargin{1};
    switch funcode(1)
        case 1
            cmap_update(nargs-1,varargin);
        case 2
            clim_update(nargs-1,varargin);
        case 3
            map=cmedit_rgb2hsv(nargs-1,varargin);
        case 4
            map=cmedit_hsv2rgb(nargs-1,varargin);
        case 5
            cmapbright(varargin);
        case 6
            map=stdcmap(varargin);
        case 7
            matlab_cmeditor_off;
        case 8
            map=choosecolor(varargin);
    end
end 

%----------------------------------------------------------------------%
%FUNCTIONS CALLED BY FEVAL/EVAL FROM JAVA EDITOR
%----------------------------------------------------------------------%
function cmap_update(n,map)

cmap_listen_enable('off');
newcmap=zeros(n,3);
for i=1:n
    newcmap(i,:) = map{i+1};
end
fig = get(0,'CurrentFigure');
if isempty(fig) || strcmpi('on',get(fig,'BeingDeleted'))
    return;
end
set(fig,'Colormap',newcmap);
cmap_listen_enable('on');

%----------------------------------------------------------------------%
function clim_update(n,lims)

cmap_listen_enable('off');
newclim=zeros(1,2);
newclim(:) = lims{2};

fig = get(0,'CurrentFigure');
if isempty(fig) || strcmpi('on',get(fig,'BeingDeleted'))
    return;
end
ax = get(fig,'CurrentAxes');
if isempty(ax) || strcmpi('on',get(ax,'BeingDeleted'))
    return;
end
set(ax,'clim',newclim);
cmap_listen_enable('on');

%----------------------------------------------------------------------%
function hsv=cmedit_rgb2hsv(n,rgb)

rgbmap=zeros(n,3);
hsv=zeros(n,3);
for i=1:n
    rgbmap(i,:) = rgb{i+1};
end
hsv=rgb2hsv(rgbmap);


%----------------------------------------------------------------------%
function rgb=cmedit_hsv2rgb(n,hsv)

hsvmap=zeros(n,3);
rgb=zeros(n,3);
for i=1:n
    hsvmap(i,:) = hsv{i+1};
end
rgb=hsv2rgb(hsvmap);

%----------------------------------------------------------------------%
function cmapbright(brval)

%----------------------------------------------------------------------%
function map=choosecolor(vals)

r = vals{2}(1);
g = vals{3}(1);
b = vals{4}(1);
map=uisetcolor([r,g,b],'Select Marker Color');

%----------------------------------------------------------------------%
function map=stdcmap(mapix)

maptype = zeros(1,2);
mapsiz = zeros(1,2);
maptype(:) = mapix{2};
mapsiz(:) = mapix{3};


switch maptype(1) 
    case 0
        map = autumn(mapsiz(1));
    case 1
        map = bone(mapsiz(1));
    case 2
        map = colorcube(mapsiz(1));
    case 3
        map = cool(mapsiz(1));
    case 4
        map = copper(mapsiz(1));
    case 5
        map = flag(mapsiz(1));
    case 6
        map = gray(mapsiz(1));
    case 7
        map = hot(mapsiz(1));
    case 8
        map = hsv(mapsiz(1));
    case 9
        map = jet(mapsiz(1));
    case 10
        map = lines(mapsiz(1));
    case 11
        map = pink(mapsiz(1));
    case 12
        map = prism(mapsiz(1));
    case 13
        map = spring(mapsiz(1));
    case 14
        map = summer(mapsiz(1));
    case 15
        map = vga;  % special case takes no size
    case 16
        map = white(mapsiz(1));
    case 17
        map = winter(mapsiz(1));
end

%----------------------------------------------------------------------%
function matlab_cmeditor_off()

kill_listeners;
if isappdata(0,'CMEditor')
    rmappdata(0,'CMEditor');
end

%----------------------------------------------------------------------%
%   MATLAB listener callbacks
%----------------------------------------------------------------------%
function currentFigureChanged(hProp, eventData, cmeditor, oldfig, oldax)

fig = eventData.NewValue;
set_current_figure(cmeditor,fig,oldfig,oldax);

%----------------------------------------------------------------------%
%   Figure listener callbacks
%----------------------------------------------------------------------%
function cmapChanged(hProp, eventData, cmeditor, fig)
cmap = get(fig,'Colormap');
cmeditor.getModel.setBestColorMapModel(cmap);

%----------------------------------------------------------------------%
function currentAxesChanged(hProp, eventData, cmeditor, oldfig, oldax)
ax = eventData.NewValue;
set_current_axes(cmeditor,ax,oldfig,oldax);

%----------------------------------------------------------------------%
function figureDestroyed(hProp,eventData,cmeditor,oldfig,oldax)

nfigs=length(findobj(0,'type','figure'));
if nfigs<=1 % the one being destroyed
    destroy_matlab_listeners;
    destroy_figure_listeners(oldfig);
    destroy_axes_listeners(oldax);
    cmeditor.close;
    kill_listeners;
else fig=get(0,'currentfigure');
    set_current_figure(cmeditor,fig,oldfig,oldax);
end

%----------------------------------------------------------------------%
%   Axes Listener Callbacks
%----------------------------------------------------------------------%
function climChanged(hProp, eventData, cmeditor, ax)

clim = get(ax,'Clim');
% cmeditor.printstring('clim changed');
cmeditor.getModel.setColorLimits(clim,0);

%----------------------------------------------------------------------%
function axesDestroyed(hProp, eventData, cmeditor, oldfig, oldax)

% if ax and oldax are same, do nothing, go home
fig = get(0,'currentfigure');
if isempty(fig) || ~ishandle(fig) || strcmpi('on',get(fig,'BeingDeleted'))
    return;
end
ax = get(fig,'currentaxes');
set_current_axes(cmeditor,ax,oldfig,oldax);

%----------------------------------------------------------------------%
%   Helpers
%----------------------------------------------------------------------%
function set_current_figure(cmeditor,fig,oldfig,oldax)

if isempty(fig) || ...
        ~ishandle(fig) || ...
        strcmpi('on',get(fig,'BeingDeleted')) || ...
        isequal(fig,oldfig)
    return;
end

ax = get(fig,'CurrentAxes');
% get rid of old figure listeners
destroy_figure_listeners(oldfig);
% get rid of old axes listeners
destroy_axes_listeners(oldax);
create_matlab_listeners(cmeditor,fig,ax);
cmap = get(fig,'Colormap');
cmeditor.getModel.setBestColorMapModel(cmap);
create_figure_listeners(cmeditor,fig,ax);
if isempty(ax)
    cmeditor.getFrame.setColorLimitsEnabled(0);
else
    clim = get(ax,'Clim');
    cmeditor.getFrame.setColorLimitsEnabled(1);
    cmeditor.getModel.setColorLimits(clim,0);
    create_axes_listeners(cmeditor,fig,ax);
end

%----------------------------------------------------------------------%
function set_current_axes(cmeditor,ax,oldfig,oldax)

if isempty(ax) || ...
        ~ishandle(ax) || ...
        strcmpi('on',get(ax,'BeingDeleted')) || ...
        isequal(ax,oldax)
            return;
end
fig = ancestor(ax,'figure');
% get rid of old axes listeners
destroy_axes_listeners(oldax);

if isempty(ax) || ...
        ~ishandle(ax) || ...
        ~strcmpi('on',get(ax,'BeingDeleted'))
    cmeditor.close;
    kill_listeners;
    return;
end

create_matlab_listeners(cmeditor,fig,ax);
create_figure_listeners(cmeditor,fig,ax);
if isempty(ax)
    cmeditor.getFrame.setColorLimitsEnabled(0);
else
    clim = get(ax,'Clim');
    cmeditor.getFrame.setColorLimitsEnabled(1);
    cmeditor.getModel.setColorLimits(clim,0);
    create_axes_listeners(cmeditor,fig,ax);
end

%----------------------------------------------------------------------%
function cmap_listen_enable(onoff)

% figure listeners
fig = get(0,'CurrentFigure');
if isempty(fig) || strcmpi('on',get(fig,'BeingDeleted'))
    return;
end
% just cmap
if isappdata(fig,'CMEditFigListeners')
    fl = getappdata(fig,'CMEditFigListeners');
    set(fl.cmapchanged,'Enabled',onoff);
    setappdata(fig,'CMEditFigListeners',fl);
end

% axes listeners
ax = get(fig,'CurrentAxes');
if isempty(ax) || strcmpi('on',get(ax,'BeingDeleted'))
    return;
end
% just clim
if isappdata(ax,'CMEditAxListeners')
    al = getappdata(ax,'CMEditAxListeners');
    set(al.climchanged,'Enabled',onoff);
    setappdata(ax,'CMEditAxListeners',al);
end

%----------------------------------------------------------------------%
function start_listeners(cmeditor,fig,ax)

create_matlab_listeners(cmeditor,fig,ax);
create_figure_listeners(cmeditor,fig,ax);
if isempty(ax)
    cmeditor.getFrame.setColorLimitsEnabled(0);
else
    clim = get(ax,'Clim');
    cmeditor.getFrame.setColorLimitsEnabled(1);
    cmeditor.getModel.setColorLimits(clim,0);
    create_axes_listeners(cmeditor,fig,ax);
end

%----------------------------------------------------------------------%
function kill_listeners

% matlab
destroy_matlab_listeners

% figure
fig = get(0,'CurrentFigure');
% return if no current fig or it is being destroyed
if isempty(fig) || ~ishandle(fig) || strcmpi('on',get(fig,'BeingDeleted'))
    return;
end
destroy_figure_listeners(fig);

% axes
ax = get(fig,'CurrentAxes');
% return if no current axes or it is being destroyed
if isempty(ax) || strcmpi('on',get(ax,'BeingDeleted'))
    return;
end
destroy_axes_listeners(ax);

%----------------------------------------------------------------------%
function create_matlab_listeners(cmeditor,fig,ax)

cls = classhandle(handle(0));
ml.cfigchanged = handle.listener(0, cls.findprop('CurrentFigure'),'PropertyPostSet', {@currentFigureChanged, cmeditor, fig, ax});
setappdata(0,'CMEditMATLABListeners',ml);

%----------------------------------------------------------------------%
function enable_matlab_listeners(onoff)

if isappdata(0,'CMEditMATLABListeners');
    ml = getappdata(0,'CMEditMATLABListeners');
    set(ml.cfigchanged,'Enabled',onoff);
    setappdata(0,'CMEditMATLABListeners',ml);
end

%----------------------------------------------------------------------%
function destroy_matlab_listeners

enable_matlab_listeners('off');
if isappdata(0,'CMEditMATLABListeners');
    rmappdata(0,'CMEditMATLABListeners');
end

%----------------------------------------------------------------------%
function create_figure_listeners(cmeditor,fig,ax)

if ~isempty(fig) && ishandle(fig) && ~strcmpi('on',get(fig,'BeingDeleted'))
    cls = classhandle(handle(fig));
    fl.deleting = handle.listener(fig,'ObjectBeingDestroyed',{@figureDestroyed,cmeditor,fig, ax});
    fl.cmapchanged = handle.listener(fig, cls.findprop('Colormap'),'PropertyPostSet', {@cmapChanged, cmeditor, fig});
    fl.caxchanged = handle.listener(fig, cls.findprop('CurrentAxes'),'PropertyPostSet', {@currentAxesChanged, cmeditor, fig, ax});
    setappdata(fig,'CMEditFigListeners',fl);
end

%----------------------------------------------------------------------%
function enable_figure_listeners(fig,onoff)

if ~isempty(fig) && ishandle(fig) && ...
        isappdata(fig,'CMEditFigListeners') && ...
        ~strcmpi('on',get(fig,'BeingDeleted'))
    fl = getappdata(fig,'CMEditFigListeners');
    set(fl.cmapchanged,'Enabled',onoff);
    set(fl.caxchanged,'Enabled',onoff);
    set(fl.deleting,'Enabled',onoff);
    setappdata(fig,'CMEditFigListeners',fl);
end

%----------------------------------------------------------------------%
function destroy_figure_listeners(fig)

enable_figure_listeners(fig,'off');
if ~isempty(fig) && ishandle(fig) && ...
        ~strcmpi('on',get(fig,'BeingDeleted')) && ...
        isappdata(fig,'CMEditFigListeners')
    rmappdata(fig,'CMEditFigListeners');
end

%----------------------------------------------------------------------%
function create_axes_listeners(cmeditor,fig,ax)

cls = classhandle(handle(ax));
al.deleting = handle.listener(ax,'ObjectBeingDestroyed',{@axesDestroyed,cmeditor,fig,ax});
al.climchanged = handle.listener(ax, cls.findprop('Clim'),'PropertyPostSet', {@climChanged, cmeditor, ax});
setappdata(ax,'CMEditAxListeners',al);

%----------------------------------------------------------------------%
function enable_axes_listeners(ax,onoff)

if ~isempty(ax) && ishandle(ax) && ...
        ~strcmpi('on',get(ax,'BeingDeleted')) && ...
                isappdata(ax,'CMEditAxListeners')
    al = getappdata(ax,'CMEditAxListeners');
    set(al.climchanged,'Enabled',onoff);
    set(al.deleting,'Enabled',onoff);
    setappdata(ax,'CMEditAxListeners',al);
end

%----------------------------------------------------------------------%
function destroy_axes_listeners(ax)

enable_axes_listeners(ax,'off');
if ~isempty(ax) && ishandle(ax) && ...
        ~strcmpi('on',get(ax,'BeingDeleted')) && ...
                isappdata(ax,'CMEditAxListeners')
    rmappdata(ax,'CMEditAxListeners');
end

%----------------------------------------------------------------------%