function c=colorbar(varargin)
%COLORBAR creates a colorbar axes object
%  H=GRAPH3D.COLORBAR creates a colorbar object.
%
%  See also COLORBAR

%   Copyright 1984-2002 The MathWorks, Inc.  
%   $Revision: 1.8 $  $Date: 2002/04/15 04:26:43 $ 

a=findpackage('graph3d');
hgA=findpackage('hg');

if (~isempty(varargin))
    c = graph3d.colorbar(varargin{:}); % Calls built-in constructor
else
    c = graph3d.colorbar;
end

%set up listeners-----------------------------------------
cls = findclass(a,'colorbar');

l       = handle.listener(c,cls.findprop('Orientation'),...
    'PropertyPreSet',...
    @changedOrientation);

l(end+1)= handle.listener(c,cls.findprop('Visible'),...
    'PropertyPostSet',@changedVisible);

c.SinglePropertyListener = l;

vp=getVirtualProperties;
virtualProperties = find(cls.properties,{'name'}, vp);
vpl = handle.listener(c, virtualProperties, 'PropertyPostSet', @changedVirtualProperty);

c.VirtualPropertyListeners = vpl;

shadowedProperties = find(cls.properties, {'name'}, getShadowedProperties);
spl = handle.listener(c, shadowedProperties, 'PropertyPostSet', @changedShadowedProperty); 

c.ShadowedPropertyListeners = spl;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function changedOrientation(hProp,eventData)

%----------set new positions ------------------

ud = get(eventData.affectedObject,'userdata');
if isstruct(ud) & ...
        isfield(ud,'PlotHandle') & ...
        ishandle(ud.PlotHandle) & ...
        isfield(ud,'origPos') & ...
        ~isempty(ud.origPos)
    
    units = get(ud.PlotHandle,'units');
else
    units = 'normalized';
    ud.PlotHandle = [];
    ud.origPos = [0 0 1 1];
end

if isempty(get(eventData.affectedObject,'Orientation'))
    %if Orientation is unset, it means that we don't have
    %to recalculate any axes positions.  We do have to
    %initialize the virtual properties, though.
    propAx=watchAxis(eventData.affectedObject,eventData.newValue);
    vp=getVirtualProperties;
    for i=1:length(vp)
        set(eventData.affectedObject,...
            vp{i},...
            get(eventData.affectedObject,sprintf('%s%s',propAx,vp{i})));        
    end
else
    if strncmpi(eventData.NewValue,'h',1)
        %horizontal
        stripe = 0.075; space = 0.1;
        plotBounds=[ud.origPos(1),...
                ud.origPos(2)+(stripe+space)*ud.origPos(4),...
                ud.origPos(3),...
                (1-stripe-space)*ud.origPos(4)];
        cbarBounds=[ud.origPos(1),...
                ud.origPos(2),...
                ud.origPos(3),...
                stripe*ud.origPos(4)];
        
    else
        stripe = 0.075;
        edge = 0.02; 
        vPoint = get(ud.PlotHandle,'View');
        if ~isempty(vPoint) & all(vPoint==[0 90])
            space = 0.05;
        else
            space = .1;
        end
        
        plotBounds=[ud.origPos(1),...
                ud.origPos(2),...
                ud.origPos(3)*(1-stripe-edge-space),...
                ud.origPos(4)];
        cbarBounds=[ud.origPos(1)+(1-stripe-edge)*ud.origPos(3),...
                ud.origPos(2),...
                stripe*ud.origPos(3),...
                ud.origPos(4)];
    end
    
    set(eventData.affectedObject,...
        'units','normalized',...
        'position',cbarBounds);
    set(ud.PlotHandle,...
        'units','normalized',...
        'position',plotBounds);
    set(ud.PlotHandle,'units',units);
    
    if ~isempty(ud.PlotHandle)
        legend('RecordSize',ud.PlotHandle);
        legend(ud.PlotHandle);
    end
    
    %---------- swap X/Y properties ---------------
    
    oldXLimMode=get(eventData.affectedObject,'XLimMode');
    oldYLimMode=get(eventData.affectedObject,'YLimMode');
    
    oldXTickMode=get(eventData.affectedObject,'XTickMode');
    oldYTickMode=get(eventData.affectedObject,'YTickMode');
    
    oldXTickLabelMode=get(eventData.affectedObject,'XTickLabelMode');
    oldYTickLabelMode=get(eventData.affectedObject,'YTickLabelMode');
    
    swapProp={
        'Tick'
        'TickLabel'
        'Dir'
        'Lim'
    };
    
    isIgnoreListeners(logical(1));
    for i=1:length(swapProp)
        xVal=get(eventData.affectedObject,strcat('X',swapProp{i}) );
        set(eventData.affectedObject,...
            strcat('X',swapProp{i}),...
            get(eventData.affectedObject,strcat('Y',swapProp{i})));
        set(eventData.affectedObject,...
            strcat('Y',swapProp{i}),...
            xVal);
    end
    
    set(eventData.affectedObject,...
        'XLimMode',oldYLimMode,...
        'YLimMode',oldXLimMode,...
        'XTickMode',oldYTickMode,...
        'YTickMode',oldXTickMode,...
        'XTickLabelMode',oldYTickLabelMode,...
        'YTickLabelMode',oldXTickLabelMode);
    isIgnoreListeners(logical(0));
    
    %----------- rotate image ------------
    
    img = findall(double(eventData.affectedObject),...
        'type','image',...
        'tag','TMW_COLORBAR');
    
    if ~isempty(img)
        img=img(1);
        oldX=get(img,'XData');
        set(img,'XData',get(img,'YData'));
        set(img,'YData',oldX);
        
        set(img,'CData',get(img,'CData')');    
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function changedVisible(hProp,eventData)

%we also need to set the children's visible property

hChild = find(eventData.affectedObject);

set(hChild,hProp.name,eventData.NewValue);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function changedVirtualProperty(hProp,eventData)
%redirect property changes

propAx=watchAxis(eventData.affectedObject);
if ~isempty(propAx) & ~isIgnoreListeners
    %setting shadowed prop here will fire
    %shadowed prop listener which will again set
    %the virtual property, so ignore listeners
    %here
    isIgnoreListeners(logical(1));
    set(eventData.affectedObject,...
        sprintf('%s%s',propAx,hProp.name),...
        eventData.NewValue);
    %turn listeners back on
    isIgnoreListeners(logical(0));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function changedShadowedProperty(hProp,eventData)

if strncmpi(watchAxis(eventData.affectedObject),hProp.name,1) & ...
            ~isIgnoreListeners
    %setting virtual prop here will fire
    %virtual prop listener which will again set
    %the shadowed property, so ignore listeners
    %here
    isIgnoreListeners(logical(1));
	set(eventData.affectedObject,...
        hProp.name(2:end),...
        eventData.NewValue);
    %turn listeners back on
    isIgnoreListeners(logical(0));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ax=watchAxis(h,orient)

if nargin<2
    orient=get(h,'Orientation');
end

if isempty(orient)
    ax= '';
elseif strncmp(orient,'h',1)
    %for horizontal colorbars, we want to set XTick, XLabel, etc
    ax = 'X';
else
    ax = 'Y';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function vp = getVirtualProperties

vp={
    'Tick'
    'TickLabel'
    'Dir' %'Scale'
    'TickMode'
    'TickLabelMode'
};

%due to the way properties are changed during orientation
%switches, the Mode properties need to be last here.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sp = getShadowedProperties

sp=[strcat('X',getVirtualProperties);...
        strcat('Y',getVirtualProperties)];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tf=isIgnoreListeners(tf)

persistent COLORBAR_LISTENERS_FLAG;

if nargin>0
    COLORBAR_LISTENERS_FLAG=tf;
elseif isempty(COLORBAR_LISTENERS_FLAG)
    COLORBAR_LISTENERS_FLAG=logical(0);
end

tf=COLORBAR_LISTENERS_FLAG;