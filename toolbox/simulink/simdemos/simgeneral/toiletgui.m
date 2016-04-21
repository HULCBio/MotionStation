function varargout=toiletgui(action)
%TOILETGUI GUI for TOILET model.
%   TOILETGUI manages the animation UI for the Simulink toilet demo.
%   
%   See also TOILET.

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.19 $

%
% set the default action (do nothing...)
%
if nargin~=1
  action='none';
end   

%
% locate the primary toilet gui window
%
figs(1) = LocalGetFigure(1);
h = [];
if ishandle(figs(1)),
  h = get(figs(1),'UserData');
end

if isempty(h)
  [h,g]=LocalStartFromScratch;
end

switch action
case 'update'
  inflow = str2num(get(h.edit(1),'string'));
  outflow = str2num(get(h.edit(2),'string'));
  lolim = str2num(get(h.edit(3),'string'));
  hilim = str2num(get(h.edit(4),'string'));
  area = str2num(get(h.edit(5),'string'));
   
  if inflow<0 | outflow<0 | lolim<0 | hilim<0 | area<0
    set(h.text(6),'String','All parameters must be greater than zero')
    set(h.edit(1),'String',num2str(evalin('base','inflow')))
    set(h.edit(2),'String',num2str(evalin('base','outflow')))
    set(h.edit(3),'String',num2str(evalin('base','lolim')))
    set(h.edit(4),'String',num2str(evalin('base','hilim')))
    set(h.edit(5),'String',num2str(evalin('base','area')))
  elseif inflow>outflow
    set(h.text(6),'String','Inflow Rate must be less than Outflow Rate')
    set(h.edit(1),'String',num2str(evalin('base','inflow')))
    set(h.edit(2),'String',num2str(evalin('base','outflow')))
  elseif hilim<lolim
    set(h.text(6),'String','High Limit must be greater than Low Limit')
    set(h.edit(3),'String',num2str(evalin('base','lolim')))
    set(h.edit(4),'String',num2str(evalin('base','hilim')))
  else
    for i=1:length(h.edit)
      assignin('base',get(h.edit(i),'Tag'),str2num(get(h.edit(i),'string')));
    end % for i
    set(h.text(6),'String','Push Start to begin')
    LocalDrawToilet(hilim, lolim, inflow, outflow, area);
  end %end idiot chex
   
case 'stop'
  %halt sim if it is running
  if strcmp(get_param('toilet','SimulationStatus'),'running')
    set_param('toilet','SimulationCommand','stop')
    return
  end
  %change button to START
  set(h.push.stop, ...
      'String','START SIM'      , ...
      'Callback','toiletgui start');
  set(h.push.flush,'Enable','off')
  %turn on parameter changes
  set(h.text(6),'String','Push Start to begin')
  set(h.edit,'Enable','on');
  LocalFinalPlot
  
case 'start'
  set(figs(1),'visible','on')

  if strcmp(get_param('toilet','SimulationStatus'),'stopped')
    set_param('toilet','SimulationCommand','start')
    return
  end

  %switch button to STOP
  set(h.push.stop, ...
      'String'  ,'STOP SIM'      , ...
      'Callback','toiletgui stop');
  set(h.push.flush,'Enable','on');
  set(h.text(6),'String','Push "Flush" button to activate')  
  %turn off parameter changes    
  set(h.edit,'Enable','off');
  
case 'close'
  LocalClosePlot
   
case 'flush'
  set(h.push.flush,'Enable','off')
  LocalFlushMe
   
case 'lastplot'
  LocalFinalPlot
   
case 'done'
  try
    set(h.text(6),'String','Goodbye')
  end   
  LocalDone
  
case 'figures'
  varargout{1} = [LocalGetFigure(1) LocalGetFigure(2)];
  
end

%
%==============================================================
% LocalStartFromScratch
% Initialize from the ground up.
%==============================================================
%
function [h,g]=LocalStartFromScratch

%Setup functions
[hilim, lolim, inflow, outflow, area]=LocalInitialize;
figs = LocalInitFigures;
h=LocalInitButtons(hilim, lolim, inflow, outflow, area);
g=LocalDrawToilet(hilim, lolim, inflow, outflow, area);

%
%==============================================================
% LocalInitialize
% Initializes the toilet simulation parameters.
%==============================================================
%
function [hilim, lolim, inflow, outflow, area]=LocalInitialize

hilim=10;
lolim=2;
inflow=10;
outflow=50;
area=100;

assignin('base','hilim',hilim);
assignin('base','lolim',lolim);
assignin('base','inflow',inflow);
assignin('base','outflow',outflow);
assignin('base','area',area);

%clear out primary data vectors
assignin('base','tout',[]);
assignin('base','tankheight',[]);
assignin('base','Outvalve',[]);
assignin('base','invalve',[]);
assignin('base','flushpulse',[]);

%
%==============================================================
% LocalInitButtons
% Creates the buttons in the main toilet GUI figure.
%==============================================================
%
function h=LocalInitButtons(hilim, lolim, inflow, outflow, area)

figs(1) = LocalGetFigure(1);
delete(allchild(figs(1)))


%define button positioning parameters
width.edit = .07;
width.text = .20;
width.push = width.edit+width.text;
height.edit = .05;
height.text = height.edit;
height.push = .07;

pos.push.x=0.02;
pos.push.y=.6;
pos.edit.x=0.02;
pos.edit.y=.2;
pos.text.x=width.edit+.03;
pos.text.y=pos.edit.y;

color.bg = [.8 .8 .8];

%create pushbuttons

ui.all.Parent = figs(1);
ui.all.Units = 'Normalized';

ui.push = ui.all;
ui.push.BackgroundColor = color.bg;
ui.push.Style = 'pushbutton';

h.push.stop = uicontrol(ui.push, ...
    'String'    ,'START SIM'    , ...
    'Position', [pos.push.x pos.push.y+(3-1)*height.push ...
                 width.push height.push] , ...
    'Callback'  ,'toiletgui start');
h.push.flush = uicontrol(ui.push, ...
    'String'    ,'FLUSH'        , ...
    'Enable'    ,'off'        , ...
    'Position', [pos.push.x pos.push.y+(2-1)*height.push ...
                 width.push height.push], ...
    'Callback'  ,'toiletgui flush');
h.push.close=uicontrol(ui.push, ...
    'String'    ,'CLOSE FIG'     , ...
    'Position', [pos.push.x pos.push.y+(1-1)*height.push ...
                 width.push height.push] , ...
    'Callback'  ,'toiletgui close');

if isempty(findobj(0,...
      'type','figure',...
      'Tag','fig 2',...
      'Visible','on'))
  set(h.push.close,'Enable','off')
end

%create edit and text buttons
ui.edit = ui.all;
ui.edit.Style = 'edit';
ui.edit.BackgroundColor = 'white';
ui.edit.Callback = 'toiletgui update';

ui.text = ui.all;
ui.text.Style='text';
ui.text.BackgroundColor = color.bg;
ui.text.HorizontalAlignment = 'left';

tags = {'inflow';'outflow';'lolim';'hilim';'area'};
tstring = { 'Flow Rate - In'      ; ...
            'Flow Rate - Out'      ; ...
            'Minimum Height Limit'  ; ...
            'Maximum Height Limit'  ; ...
            'Tank Base Area'};

siz = size(tags,1);
for i=siz:-1:1
  h.edit(i)=uicontrol(ui.edit,...
              'Tag',tags{i}                        ,...
              'String',eval(sprintf('num2str(%s)',tags{i}))  ,...
              'Position', [pos.edit.x pos.edit.y+(i-1)*height.edit...
                           width.edit height.edit]);
  h.text(i)=uicontrol(ui.text, ...
              'String',tstring(i)  , ...
              'Position', [pos.text.x ...
                           pos.text.y+(i-1)*height.text ...
                           width.text height.text] ...
              );
end

h.text(siz+1) = uicontrol(ui.text, ...
                          'FontSize',12     , ...
                          'FontWeight','bold', ...
                          'String','Push Start to begin',...
                          'Units','Normalized',...
                          'Position',[.01 .01 .95 .08] ...
                          );


set(figs(1),'UserData',h,'visible','on')

%END FUNCTION create buttons

%
%==============================================================
% LocalDrawToilet
% Creates the graphic objects in the main toilet GUI figure.
%==============================================================
%
function g=LocalDrawToilet(hilim, lolim, inflow, outflow, area)

%set up the background graphics/lines for the toilet

figs(1) = LocalGetFigure(1);

ax=findobj(figs(1),'type','axes');

if isempty(ax)
  ax=axes('Parent',figs(1));
end

delete(get(ax,'children'))

edge=sqrt(area);
outwidth = sqrt(outflow)/pi;
inwidth = sqrt(inflow)/pi;
len=max(1,max(edge,hilim)/5);
top=1.25*max(hilim, lolim+outwidth);
ref.a = (edge/2-inwidth/2);
ref.b = ref.a+inwidth;
ref.c = ref.a-len/2;
ref.d = top+2*len+inwidth;

set(ax,'Position'  ,[.2 .1 .9 .9]    , ...
       'Visible'  ,'off'              , ...
       'Tag'      ,'picture'          , ...
       'DataAspectRatio',[1 1 1]      , ...
       'Parent'    , figs(1)          , ...
       'DrawMode'  ,'fast'              ...
       );

hg.all.parent = ax;
hg.all.erasemode = 'xor';


maintank.x = [0 edge edge 0 0];
maintank.y = [0 0 top top 0];

%DRAW LINES

in.horiz.x=[-len  ref.a ref.a -len -len];
in.horiz.y=[top+2*len top+2*len top+2*len+inwidth top+2*len+inwidth...
            top+2*len];
in.vert.x=[ref.a ref.b ref.b ref.a ref.a];
in.vert.y=[top+len top+len top+2*len+inwidth top+2*len+inwidth top+len];

out.horiz.x=[edge edge+len edge+len edge edge];
out.horiz.y=[lolim lolim lolim+outwidth lolim+outwidth lolim];
out.vert.x=[edge+len edge+len+outwidth edge+len+outwidth edge+len edge+len];
out.vert.y=[-len -len lolim+outwidth lolim+outwidth -len];

hg.line = hg.all;
hg.line.LineWidth = 3;
hg.line.Color = 'black';
hg.line.Marker = '.';
hg.line.MarkerEdgeColor = 'black';
hg.line.MarkerFaceColor = 'black';
hg.line.MarkerSize = 2;

g.line.tank =     line(maintank.x,maintank.y,hg.line);
g.line.invert =   line(in.vert.x,in.vert.y,hg.line);
g.line.inhoriz =   line(in.horiz.x,in.horiz.y,hg.line);
g.line.outvert =   line(out.vert.x,out.vert.y,hg.line);
g.line.outhoriz = line(out.horiz.x,out.horiz.y,hg.line);

%Make valves

oncolor=-.5;
offcolor=-.9;

in.valve.x=[ref.c  ref.a ref.a ref.c ref.c];
in.open.y = [ref.d ref.d ref.d+inwidth ref.d+inwidth ref.d];
out.valve.x=[edge+len/2 edge+len edge+len edge+len/2 edge+len/2];
out.open.y = [lolim+1*outwidth lolim+1*outwidth lolim+2*outwidth ...
              lolim+2*outwidth lolim+1*outwidth];


hg.valve = hg.all;
hg.valve.EdgeColor = 'black';

g.valve.in.off=patch(in.valve.x,in.horiz.y,offcolor,...
    'Tag','In Valve - Closed',hg.valve);
g.valve.in.on=patch(in.valve.x,in.open.y,oncolor,...
    'Tag','In Valve - Open',hg.valve);
g.valve.out.off=patch(out.valve.x,out.horiz.y,offcolor,...
    'Tag','Out Valve - Closed',hg.valve);
g.valve.out.on=patch(out.valve.x,out.open.y,oncolor,...
    'Tag','Out Valve - Open',hg.valve);

%Make drip-indicators

lin.x(1,1:4) = [-.45 -.35 -.25 -.35];
lin.x(2,1:4) = [-.25 -.15 -.05 -.15];
lin.x(3,1:4) = [-.05 .05 .025 -.025];
lin.x(4,1:4) = -lin.x(1,1:4);
lin.x(5,1:4) = -lin.x(2,1:4);

lin.y(1,1:4) = [-.9 -.9 -.1 -.1];
lin.y(2,1:4) = [-.9 -.9 -.5 -.5];

tdrip.x = lin.x*inwidth+edge/2;
tdrip.y = lin.y*len+top+len;

wc = -1.5;      % water color
bc = [.8 .8 .8];           % background color
hg.drip = hg.all;
hg.drip.EdgeColor = 'none';


tdrip2.x = lin.x*outwidth+edge+len+outwidth/2;
tdrip2.y = lin.y*len-len;

trans = [1 1 2 1 1];  %indicates which tdrip.y to use in for loop

for j=5:-1:1
  g.drip.in(j) = patch(tdrip.x(j,1:4), tdrip.y(trans(j),1:4),wc,hg.drip);
  g.drip.out(j) = patch(tdrip2.x(j,1:4), tdrip2.y(trans(j),1:4),wc,hg.drip);
end


%Make water level patches

z1 = [1 1 1 1 1];
zn1 = [-1 -1 -1 -1 -1];
firsty=mean(hilim,lolim);

mp.x= maintank.x;
mp.y = [0 0 firsty firsty 0];
gp.y = [firsty firsty top top firsty];

firsty=min(lolim+outwidth,firsty);

op.x = out.horiz.x;
op.y=[lolim lolim firsty firsty lolim];
gp.y=[firsty firsty lolim+outwidth lolim+outwidth firsty];
op.y2=[-len -len firsty firsty -len];
gp.y2=[firsty firsty lolim+outwidth lolim+outwidth firsty];

hg.water = hg.all;
hg.water.EdgeColor = 'none';
hg.water.EraseMode = 'none';

g.grey.main = patch(mp.x,gp.y,zn1,bc,hg.water);
g.water.main = patch(mp.x,mp.y,z1,wc,hg.water);

g.grey.outh = patch(op.x,gp.y,zn1,bc,hg.water);
g.water.outh = patch(op.x,op.y,z1,wc,hg.water);

g.grey.outv = patch(out.vert.x,gp.y2,zn1,bc,hg.water);
g.water.outv = patch(out.vert.x,op.y2,z1,wc,hg.water);

g.grey.inv = patch(in.vert.x,[-len -len -len -len -len], zn1, bc, hg.water);
g.water.inv = patch(in.vert.x,in.vert.y,z1,wc,hg.water);

g.water.inh = patch(in.horiz.x,in.horiz.y,z1,wc,hg.water);

%Final visual bits

set(ax,'UserData',g,...
    'XLim'    ,[-2*len edge+2*len+outwidth]  , ...
    'YLim'    ,[-3*len top+3*len+inwidth])

set(figs(1),'Visible','on','BackingStore','on');
drawnow
set(figs(1),'BackingStore','off');
%END FUNCTION LocalDrawToilet

%
%==============================================================
% LocalFinalPlot
% Create the post-run summary plot.
%==============================================================
%
function LocalFinalPlot

tout=evalin('base','tout');

tankheight=evalin('base','tankheight');
Outvalve=evalin('base','Outvalve');
invalve=evalin('base','invalve');
flushpulse=evalin('base','flushpulse');

if isempty(tankheight) | isempty(Outvalve)...
      | isempty(invalve) | isempty(flushpulse)
  LocalClosePlot
  return
end

hilim=evalin('base','hilim');
lolim=evalin('base','lolim');

figs(1) = LocalGetFigure(1);
h=get(figs(1),'UserData');
set(h.push.close,'Enable','on')

figs(2) = LocalGetFigure(2);
delete(findobj(figs(2),'type','axes'))

maxy=[11 1.1 1.1 1.1];

axname.y = {'Water Height';'Out Valve';'In Valve';'Flush'};
axname.x = {'';'';'';'Elapsed Time (sec)'};

if length(tout)~=length(tankheight)
  tout=1:length(tankheight);
  axname.x{4}='Simulation Step';
end
lastime=max(tout);


hg.ax.Xgrid = 'on';
hg.ax.Parent = figs(2);
hg.ax.XLim = [0 lastime];


for i=4:-1:1
  ax(i)=axes('Parent', figs(2), hg.ax,...
             'Position', [.15 .1+.2*(4-i) .8 .15],...
             'YLim',[0 maxy(i)]);
  set(get(ax(i),'ylabel'), 'string', axname.y(i));
  set(get(ax(i),'xlabel'), 'string', axname.x(i));
end

set(ax(2:3),'Ytick',[0 1],'Yticklabel',{'off','on'});
set(ax(4),'Ytick',[0 1],'Yticklabel',{'',''});

h.height = line(tout,tankheight,'color','blue','parent',ax(1));
h.hilim = line([0 lastime],[hilim hilim],'color','cyan','parent',ax(1));
h.lolim = line([0 lastime],[lolim lolim],'color','cyan','parent',ax(1));

h.Outvalve = line(tout,Outvalve,'color','red','parent',ax(2));
h.invalve = line(tout,invalve,'color','green','parent',ax(3));
h.flushpulse = line(tout,flushpulse,'color','yellow','parent',ax(4));

set(get(ax(1),'title'), 'string', 'Plumbing Simulation');

set(figs(2),'visible','on')

%
%==============================================================
% LocalFlushMe
% Initiate a toilet flush.
%==============================================================
%
function LocalFlushMe

oldDirty=get_param('toilet','Dirty');

if strcmp(get_param('toilet','SimulationStatus'),'stopped')
   toiletgui('start');
end

fname = 'toiletsfun';
a = which(fname);
a = a(1:end-length(fname)-2);

if strncmpi(computer,'PC',2)
   try
      [noise,fs,bits]=wavread(fullfile(a,'toilet.wav'));
      sound(noise,fs,bits);
   end
end

a=1-str2num(get_param('toilet/Flush Pulse/PulseConst','Value'));
set_param('toilet/Flush Pulse/PulseConst','Value',num2str(a));
set_param('toilet','Dirty',oldDirty);

%
%==============================================================
% LocalClosePlot
% Close the post-run summary figure.
%==============================================================
%
function LocalClosePlot

figs(2) = LocalGetFigure(2);
figs(1) = LocalGetFigure(1);

h=get(figs(1),'UserData');
set(h.push.close,'Enable','off')
set(figs(2),'Visible','off')

%
%==============================================================
% LocalInitFigures
% Creates the figures for the toilet GUI demo.
%==============================================================
%
function figs=LocalInitFigures

for i=1:2
  figs(i) = LocalGetFigure(i);
  if ~ishandle(figs(i)),
    figs(i)=LocalMakeFigure(i);
  end
end

%
%==============================================================
% LocalGetFigureTagStrings
% Returns a cell array with the tag strings used in the
% toiletgui figure windows.
%==============================================================
%
function tagStrings = LocalGetFigureTagStrings

tagStrings = { 'ToiletGUIFigure', 'ToiletPostRunSummaryFigure' };

%
%==============================================================
% LocalGetFigure
% Return the handle of the index Toilet GUI figure
%==============================================================
%
function fig=LocalGetFigure(num)

tagStrings = LocalGetFigureTagStrings;
fig=findall(0,'type','figure','Tag',tagStrings{num});

if isempty(fig)
  fig = -1;
end

%
%==============================================================
% LocalMakeFigure
% Creates the specified Toilet GUI figure
%==============================================================
%
function handle=LocalMakeFigure(num)

tagStrings       = LocalGetFigureTagStrings;
closeRequestFcns = {'toiletgui done',   'toiletgui close'};
figNames         = {'Toilet Model GUI', 'Post-Run Summary'};

handle=figure('Visible',         'off',...
              'Tag',             tagStrings{num},...
              'BackingStore',    'off',....
              'NumberTitle',     'off',...
              'HandleVisibility','off',...
              'Name',            figNames{num},...
              'CloseRequestFcn', closeRequestFcns{num},...
              'MenuBar',         'none');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%
%==============================================================
% LocalDone
% LocalDone is called upon closing the Simulink model (via the
% CloseFcn) or when the 'close' box of the main Toilet GUI
% figure is clicked.
%==============================================================
%
function LocalDone

%
% delete the post-run summary figure
%
f = LocalGetFigure(2);
if ishandle(f)
  delete(f)
end

%
% delete the main toilet GUI figure
%
f = LocalGetFigure(1);
if ishandle(f),
  h = get(f,'UserData');
  mystring = get(h.push.stop,'String');
  if mystring(1:4) == 'STOP'
    set_param('toilet','SimulationCommand','stop')
    set(h.push.stop,'String','START SIM')
  end
   
  delete(f)
end


