function initialize(this)
% Initializes editor graphics

%   Author: Kamesh Subbarao 
%   Copyright 1986-2004 The MathWorks, Inc.
Fig = this.Parent;

% Font settings
if isunix
    FontSize  = 10;
else
    FontSize  = 8;
end

% Create and position axes
ax = axes('Parent',Fig,'Visible','off','FontSize',FontSize);
set([get(ax,'Title'),get(ax,'XLabel'),get(ax,'YLabel')],'FontSize',FontSize,'Interpreter','none')

% Create @axes object
Axes = ctrluis.axes(ax, ...
    'LimitFcn',  {@updatelims this}, ...
    'XLabel',  'Time',...
    'YLabel',  'Amplitude',...
    'XUnit',  'sec');
this.Axes = Axes;

% Set position
localResize([],[],Fig,Axes)

% Set custom properties for the @axes object
set(Axes.AxesStyle,'Color',[.5 .5 .5])
set(getaxes(Axes),'Zlim',[-1 3])

% Show reference 
refplot(this)

% Make axes visible
Axes.Visible = 'on';

% Add context menus
addmenus(this)

% Add check boxes
localAddCheck(this,Fig)

% Set Resize fcn and WBM for cursor control 
Fig.ResizeFcn = {@localResize Fig Axes};
Fig.WindowButtonMotion = {@LocalHover this};


%------------- Local Functions -----------------------------------

function LocalHover(eventsrc,eventdata,this);
% Dynamically modifies pointer shape when hovering above movable object
fig = this.Parent;
hoverobj = handle(hittest(fig));
constrobjs = [this.LowerBound.Surf...
        this.LowerBound.Line...
        this.UpperBound.Surf...
        this.UpperBound.Line];
if any(find(hoverobj == constrobjs))
    setptr(fig,'hand');
else
   setptr(fig,'arrow');
end


function localAddCheck(this,Fig)
% Adds check boxes to control CostEnable and ConstrEnable flags
UIColor = get(0,'DefaultUIControlBackgroundColor');
ConstrTip = ['Check to force signal inside red bounds during optimization, ',...
   'uncheck to ignore these bounds.'];
X0 = 2;  Y0 = .5;
c1 = uicontrol('Parent',Fig, ...
   'Style','checkbox', ...
   'Tooltip',ConstrTip,...
   'BackgroundColor',UIColor,...
   'Units','character',...
   'Position',[X0 Y0 3 1.4]);
X0 = X0+4;  TW = 22;
uicontrol('Parent',Fig, ...
   'BackgroundColor',UIColor,...
   'Style','text', ...
   'String','Enforce signal bounds', ...
   'Tooltip',ConstrTip,...
   'HorizontalAlignment','left', ...
   'Units','character',...
   'Position',[X0 Y0 TW 1.2]);
X0 = X0+TW+3;
CostTip = ['Check to minimize mismatch with reference signal. ',...
   'Use "Desired Response..." dialog to specify reference.'];
c2 = uicontrol('Parent',Fig, ...
   'Style','checkbox', ...
   'Tooltip',CostTip,...
   'BackgroundColor',UIColor,...
   'Units','character',...
   'Position',[X0 Y0 3 1.4]);
X0 = X0+4;  TW = 25;
uicontrol('Parent',Fig, ...
   'BackgroundColor',UIColor,...
   'Style','text', ...
   'Tooltip',CostTip,...
   'String','Track reference signal', ...
   'HorizontalAlignment','left', ...
   'Units','character',...
   'Position',[X0 Y0 TW 1.2]);
% Wire up listeners
addGoalSelectors(this,c1,c2)


function localResize(eventsrc,eventdata,Fig,Axes)
% Update outer position for axes
ax = getaxes(Axes);
u = get(Fig,'Units');
set(Fig,'Units','character');
OuterPos = get(Fig,'Position');
set(Fig,'Units',u);
% Workaround missing support for non-nomalized units in @axes
set(ax,'Units','character','Position',[11 4.5 OuterPos(3)-15 OuterPos(4)-7],'Units','normalized')
Axes.Position = get(ax,'Position');


