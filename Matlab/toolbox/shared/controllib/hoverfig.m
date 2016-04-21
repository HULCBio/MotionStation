function hoverfig(varargin);
%HOVERFIG  Use HOVERFIG as the figure's WindowButtonMotionFcn to
%          dynamically modify pointer shape and activate data
%          markers where appropriate.  

%   Author: John Glass
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:27:45 $

persistent LM HBF Point

if nargin<3
    fig = varargin{1};    
elseif nargin>3
    %% This is the case where the stick callback function is executed.
    fig = ancestor(LM,'figure');
    hTool = datacursormode(fig);
    set(Point, 'ButtonDownFcn', HBF);
    set(LM.MarkerHandle,'ButtonDownFcn',[]);
    LM = [];Point = [];
    return;
end

hoverobj = handle(hittest(fig));
objtype = hoverobj.type;
objtag  = hoverobj.tag;

switch objtype
case {'figure';'uicontrol';'axes';'line'}
    if ~any(strcmpi(objtag,{'CharPoint','PZ_Zero','PZ_Pole','DataTipMarker'}))        
        if isa(LM,'graphics.datatip')
            hTool = datacursormode(fig);
            removeDataCursor(hTool,LM);
            set(Point, 'ButtonDownFcn', HBF);            
            LM = []; Point = [];
            return;
        elseif ~isa(LM,'graphics.datatip') 
            LM = []; Point = [];            
            return
        end
    end
end

switch objtag
case {'CharPoint','PZ_Zero','PZ_Pole'}
    %---Workaround for non-moveable markers
    if isa(LM,'graphics.datatip') 
        return
    end    
    HBF = get(hoverobj,'ButtonDownFcn');
    if ~isempty(HBF)
        if isa(HBF,'cell')
            hoverbdf = {HBF{1},hoverobj,[],HBF{2:end}};
        else
            hoverbdf = {HBF,hoverobj,[]};
        end
        LM = feval(hoverbdf{:});
        if isempty(LM), return, end
        %% Set the line marker properties to match those on the points
        %% below.
        FaceColor = get(hoverobj,'MarkerFaceColor');
        Color = get(hoverobj,'Color');  
        LineWidth = get(hoverobj,'LineWidth');  
        Marker = get(hoverobj,'Marker');
        MarkerSize = get(hoverobj,'MarkerSize'); 
        MarkerEdgeColor = get(hoverobj,'MarkerEdgeColor');
        set(LM.MarkerHandle,'Marker',Marker,'Color',Color,...
                            'LineWidth',LineWidth,...
                            'MarkerFaceColor',FaceColor,...
                            'MarkerSize',MarkerSize,...
                            'MarkerEdgeColor',MarkerEdgeColor,...
                            'ButtonDownFcn',{@localStick,fig});
        hTool = datacursormode(fig);
        addDataCursor(hTool,LM);
    end
    return;
end

%%%%%%%%%%%%%%
% localStick %
%%%%%%%%%%%%%%
function localStick(eventSrc,eventData,fig)

hoverfig([],[],fig,'stick');
