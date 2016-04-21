function edit(h)
%EDIT
%
% Author(s): James G. Owen
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.6 $ $Date: 2004/04/19 01:31:26 $

data = h.Datasets(h.Position).Data(:,h.Column);
time = h.Datasets(h.Position).Time;

% If the figure already exists bring it to front

if ishandle(h.Window)
   % Rest the popup menu since the headings may have changed since the 
   % editor was last opened
   set(h.Controls(10),'String',h.datasets(h.Position).Headings);
   figure(h.Window)
   return
else % Make a figure to receive graph
    figcolor = get(0,'defaultuicontrolbackgroundcolor');
    h.Window = figure('IntegerHandle','off','Units','pixels',...
                    'HandleVisibility','callback',...
                    'name','Select Points for Preprocessing Rule',...
                    'numbertitle','off',...
                    'color',figcolor,...
                    'Tag','cfexcludegraph',...
                    'UserData',{0 0},...
                    'doublebuffer','on',...
                    'Menubar','none',...
                    'Position',[360 504 616 462]);
     centerfig(h.Window,0);
     setcallbacks([],[],h.Window);
     
     % Create empty axes panel
     
     gap = 10;
     axpanel = uipanel('Parent',h.Window,'Units','Pixels', ...
         'Position',[132+18+gap 0 616-(132+18)-gap 462],'Units', ...
         'Normalized','BorderType','None');     
     ax = axes('Parent',axpanel,'Box','on','Tag','rawdata','Units', ...
         'normalized','Position',[0.1 .6 .8 .3]);
     axlegend = axes('Parent',axpanel,'Box','off','Tag','legend', ...
         'Units','normalized','Position',[.1, 0.45, .8, .1],'Visible','off');   
     axmoddata = axes('Parent',axpanel,'Box','on','XColor','k','Tag', ...
         'moddata','Units','normalized','Position',[0.1, 0.1, .8, .3]);
     xlabel(ax,'Time (sec)');
     xlabel(axmoddata,'Position');
     title(axmoddata,'Output Data');
     title(ax,'Input Data');
 
     % Manipulate legend axes
     createlegend(axlegend);
     
     % Add lines 
     h.Lines = createlines(ax,axmoddata,figcolor);
     
     % Create buttons
     [h.Controls, btnpanel] = createbuttonpanel(h);
   
     % Restore toolbar but keep only zoom tools
     set(h.Window,'toolbar','figure');
     tb = findall(h.Window,'Type','uitoolbar');
     h1 = findall(tb);        % Get all children
     h1(h1==tb) = [];         % Not including the toolbar itself
     h2 = findall(h1,'flat','TooltipString','Zoom In');
     h1(h2==h1) = [];
     h2 = findall(h1,'flat','TooltipString','Zoom Out');
     h1(h2==h1) = [];
     delete(h1);

     
     % Position axes 
    set(h.Window,'ResizeFcn',{@resizeselect, btnpanel, axpanel});
    resizeselect([],[], btnpanel, axpanel);


end
     
% Establish and set raw data limits
xlim = [min(time) max(time)];
xlim = xlim + .05 * [-1 1] * diff(xlim);
ylim = [min(data) max(data)];
ylim = ylim + .05 * [-1 1] * diff(ylim);
ylim(2) = max(ylim(2),ylim(1)+100*eps);
if ~any(isnan([xlim ylim]))
    set(axmoddata,'XLim',xlim,'YLim',ylim);
end

% Stash everything for callback
set(ax,'Userdata',h);
set(h.Window,'HandleVisibility','callback');

% Draw everything
h.update(h.ManExcludedpts{h.Position},false);


% ------------- function to initiate graphical selection
function startselect(varargin)

% Save mouse position and start a rubber band operation
subfig = gcbf;
ax = utgetaxes(subfig,'rawdata');
pt0 = get(ax, 'CurrentPoint');
ud = get(subfig,'UserData');
ud{1} = pt0;
set(subfig,'Userdata',ud);
rbbox;

% ------------- function to complete graphical selection
function endselect(varargin)
 
% Get mouse position at button down and button up
subfig = gcbf;
ax = utgetaxes(subfig,'rawdata');

% Check for right axes
if ~strcmp(get(ax,'Tag'),'rawdata')
    return
end

ud = get(subfig,'Userdata');
pt0 = ud{1};
pt1 = get(ax, 'CurrentPoint');
swapped = ud{2};

% Check that we've had a button down
if size(pt0,1)<2 | size(pt0,2)<2
   return;
end
set(subfig,'UserData',ud);   

% Force inside axis limits
xlim = get(ax, 'XLim');
ylim = get(ax, 'YLim');
x0 = min(pt0(1,1), pt1(1,1));
y0 = min(pt0(1,2), pt1(1,2));
x1 = max(pt0(1,1), pt1(1,1));
y1 = max(pt0(1,2), pt1(1,2));
if x1<xlim(1) | x0>xlim(2) | y1<ylim(1) | y0>ylim(2)
   return
end
x0 = max(xlim(1), x0);
y0 = max(ylim(1), y0);
x1 = min(xlim(2), x1);
y1 = min(ylim(2), y1);

% Get stored information
this = get(ax,'Userdata');


x = this.Datasets(this.Position).Time;
y = this.Datasets(this.Position).Data(:,this.Column);

excluding = ~isequal(get(subfig,'SelectionType'),'alt');
rectangular = (x0 ~= x1) & (y0 ~= y1); % a rubber band selection?

% Get distance from each symbol to selection (box or point)
xrange = diff(get(ax,'Xlim'));
yrange = diff(get(ax,'Ylim'));
xd = max(0, (x0-x)/xrange) + max(0, (x-x1)/xrange) + ~isfinite(x);
yd = max(0, (y0-y)/yrange) + max(0, (y-y1)/yrange) + ~isfinite(y);
d = xd.*xd + yd.*yd;
d1 = min(d);
if (rectangular)
   % Select points inside rectangle
%    idx = find(this.Inbounds & d<=0);
    idx = find(d<=0);
else
    idx = find(d<=d1);
end

% Update exclusion vector
if swapped
   excluding = ~excluding;
end
if (length(idx) > 0)
   thisexcl = this.ManExcludedpts{this.Position};
   if excluding
      thisexcl(idx,this.Column) = true;
   else
      thisexcl(idx,this.Column) = false;
   end   
  
   % Update stored results and graph
   if ~isequal(this.ManExcludedpts{this.Position},thisexcl)
      update(this,thisexcl(:),false);
   end
end


% ------------- function to perform callback functions for buttons
function buttonselect(varargin)

subfig = gcbf;
action = varargin{3};
switch action
 % Close button, delete figure
 case 'close'
   set(subfig,'Visible','off');

 % Radio button, update other button and save state
 case {'mouseinclude' 'mouseexclude'}
   if isequal(action,'mouseinclude')
      otherbutton = findobj(get(gcbo,'Parent'),'Tag','mouseexclude');
      newstate = 1;
   else
      otherbutton = findobj(get(gcbo,'Parent'),'Tag','mouseinclude');
      newstate = 0;
   end
   set(otherbutton,'Value',0);
   ud = get(subfig,'UserData');
   ud{2} = newstate;
   set(subfig,'UserData',ud);
  
 % Push button, include or exclude everything
 otherwise
   % Get stored information
   ax = utgetaxes(subfig,'rawdata');
   h = get(ax,'Userdata');
   
   thisexcl = h.ManExcludedpts{h.Position};
   if isequal(action,'exclude')
      thisexcl(:,h.Column) = true;
   else
      thisexcl(:,h.Column) = false;
   end
   % Update stored results and graph
   update(h,thisexcl(:),false);
end


% ------------- function to implement change in y variable selection
function changey(es,ed,this)

% Update graph through column property listeners

this.Column = get(this.Controls(10),'Value');

% ----------- Layout items in figure after resize
function resizeselect(eventSrc, eventData, btnpanel, axpanel)
 
% Get info, check for premature resize during figure creation
axraw = utgetaxes(eventSrc,'rawdata');
axmoddata = utgetaxes(eventSrc,'moddata');
axlegend = utgetaxes(eventSrc,'legend');
h = get(axraw,'Userdata');
if isempty(h), return; end

% Get new figure width
figpos = get(eventSrc,'Position');
figwidth = figpos(3);
figheight = figpos(4);
if figwidth<616 | figheight<462
   figwidth = max(figwidth, 616);
   figheight = max(figheight, 462);
   %c = [figpos(1)+figpos(3)/2; figpos(2)+figpos(4)/2];
   screensize = get(0,'ScreenSize');   
   figpos(1) = screensize(3)/2 - figwidth/2;
   figpos(2) = screensize(4)/2 - figheight/2;
   figpos(3) = figwidth;
   figpos(4) = figheight;
   set(eventSrc,'Position',figpos);
end

% The left hand border of the axis panel should touch the right hand
% border of the button panel
set(btnpanel, 'Units', 'Normalized');
btnpnlpos = get(btnpanel, 'Position');
axpnlpos = get(axpanel, 'Position');
if axpnlpos(1)<btnpnlpos(1)+btnpnlpos(3)
   gap = 10/figwidth;
   set(axpanel,'Position',[btnpnlpos(1)+btnpnlpos(3)+gap axpnlpos(2) ...
       1-btnpnlpos(1)-btnpnlpos(3) axpnlpos(4)]);
end
        
% ------------- Set the callback functions
function setcallbacks(varargin)
if nargin<3
   subfig = gcbf;
else
   subfig = varargin{3};
end

set(subfig, 'WindowButtonDownFcn',@startselect, ...
            'WindowButtonUpFcn',@endselect);


% ------------- Update the exclusion graph legend
function createlegend(ax)

set(ax,'xtick',[],'xlim',[0 1],'ylim',[0 1],'ytick',[],'ycolor',[1 1 1],'xcolor',[1 1 1]);

line('XData',.051,'YData',.5,'Color','r','Marker','x','LineStyle','none',...
          'Parent',ax);
text(.1,.5,'Manually excluded','Parent',ax);
line('XData',.6,'YData',.5,'Color','k','Marker','o','LineStyle','none',...
          'Parent',ax);
text(.65,.5,'Excluded by rule','Parent',ax);


function lines = createlines(ax,axmoddata,figcolor)

gr = [.9 .9 .9];
lines  = [line('Color','b','LineStyle','-','Parent',ax); 
           line('Color','r','Marker','x','LineStyle','none',...
              'Parent',ax,'Tag','excluded');
           line('Color',figcolor/2,'Marker','o','LineStyle','none',...
              'Parent',ax);
           line('Color',figcolor/2,'Marker','x','LineStyle','none',...
              'Parent',ax);  
           line('Color','k','Parent',axmoddata,'Tag','modified','Marker','.');
           patch([NaN NaN NaN NaN],[NaN NaN NaN NaN],gr,'LineStyle',...
               'none','Tag','xlo','Parent',ax);
           patch([NaN NaN NaN NaN],[NaN NaN NaN NaN],gr,'LineStyle',...
               'none','Tag','xhi','Parent',ax);
           patch([NaN NaN NaN NaN],[NaN NaN NaN NaN],gr,'LineStyle',...
               'none','Tag','ylo','Parent',ax);
           patch([NaN NaN NaN NaN],[NaN NaN NaN NaN],gr,'LineStyle',...,
               'none','Tag','yhi','Parent',ax)];
set(ax,'Child',lines([1:4 6:9]));         
               
function [buttons,pnl] = createbuttonpanel(h)



pnl = uipanel('Parent',h.Window,'Units','Pixels', 'Position', [18 69 132 180]);

b10 = uicontrol('Parent',pnl,...
'Position',[0 0 132 180],...
'Style','frame',...
'Tag','frame1');


b11 = uicontrol(...
'Parent',pnl,...
'Position',[18 172 51 15],...
'String','Selection',...
'Style','text');


b12 = uicontrol(...
'Parent',pnl,...
'Position',[0 202 133 90],...
'String',{  'Frame' },...
'Style','frame');


b13 = uicontrol('Parent',pnl,...
'Position',[7 286 91 15],...
'String','Specify Axes',...
'Style','text');


b0 = uicontrol('Parent',h.Window,...
'Position',[28 10 94 23],...
'String','Close',...
'TooltipString','Close Selection Window', ...
'Callback',{@buttonselect 'close'},...
'Tag','close');

b1 = uicontrol('Parent',pnl,...
'Position',[14 49 94 23],...
'String','Include All',...
'TooltipString','Include All Points', ...
'Callback',{@buttonselect 'include'}, ...
'Tag','include');


b2 = uicontrol('Parent',pnl,...
'Position',[14 15 94 23],...
'String','Exclude All',...
'TooltipString','Exclude All Points', ...
'Callback',{@buttonselect 'exclude'}, ...
'Tag','exclude');

b3 = uicontrol('Parent',pnl,...
'Position',[26 95 105 15],...
'String','Includes them',...
'Style','radiobutton',...
'TooltipString','Mouse Selection Includes Points',...
'CallBack',{@buttonselect 'mouseinclude'},...
'Tag','mouseinclude'); 

b5 = uicontrol('Parent',pnl,...
'Position',[14 130 96 26],...
'String','Selecting points:',...
'Style','text');


b4 = uicontrol('Parent',pnl,...
'Position',[26 117 96 17],...
'String','Excludes them',...
'Style','radiobutton',...
'TooltipString','Mouse Selection Excludes Points',...
'CallBack',{@buttonselect 'mouseexclude'},...
'Tag','mouseexclude','Value',true);


b6 = uicontrol('Parent',pnl,...
'Position',[2 293-67 27 15],...
'String','Y:',...
'Style','text',...
'Tag','xlabel');


b7 = uicontrol('Parent',pnl,...
'Position',[2 246 27 22],...
'String','X:',...
'Style','text',...
'TooltipString','Select Y Variable or Residuals',...
'Tag','ylabel');

b8 = uicontrol('Parent',pnl,...
'Position',[22 253  51 15],...
'String','Time',...
'Style','text',...
'Tag','xname');

b9 = uicontrol('parent',pnl,'Style','popupmenu',...
'Position',[37 224 91 22],...
'String',h.datasets(h.Position).Headings,...
'Units','Pixels',...
'BackgroundColor','w',...
'Callback',{@changey h},...
'TooltipString','Select Y Variable or Residuals',...
'Tag','yname');


buttons =[b0 b1 b2 b3 b4 b5 b6 b7 b8 b9 b10 b11 b12 b13];                  
