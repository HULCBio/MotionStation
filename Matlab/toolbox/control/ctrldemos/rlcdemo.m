function rlcdemo
%RLCDEMO  RLC Circuit Response Demo.
%
%   RLCDEMO is an interactive demo showing the relationship
%   between the physical parameters of common RLC circuits
%   and the time and frequency responses of those circuits.
%
%   Four standard circuit configurations may be investigated,
%   each in either a series or parallel topology:
%
%       * Low-pass RLC network
%       * High-pass RLC network
%       * Band-pass RLC network
%       * Band-stop RLC network
%
%   The network under investigation is represented as a
%   transfer function, G(s), which is displayed below the
%   drawn schematic.  This network is stored as an LTI
%   object and its time and frequency responses are plotted
%   using the Control System Toolbox.
%
%   In all cases, the RLC circuit can be expressed as a
%   delay-free 2nd-order system, which is stable for real,
%   positive values of the component parameters R, L, and C.

%   Author(s): A. DiVergilio
%              P. Gahinet (@resppack)
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.12.4.2 $  $Date: 2004/04/10 23:14:01 $

% Figure
pos = get(0,'DefaultFigurePosition');
fg = figure(...
   'Name','RLC Circuit Response Demo',...
   'Position',pos+pos(3)*[-.1 0 .2 0],...
   'IntegerHandle','off',...
   'NumberTitle','off',...
   'DoubleBuffer','on',...
   'DefaultUIControlFontSize',8,...
   'DefaultAxesFontSize',8,...
   'DefaultTextFontSize',8,...
   'DefaultAxesBox','on',...
   'DefaultAxesDrawMode','fast',...
   'HandleVisibility','callback',...
   'Visible','off',...
   'DockControls', 'off');

if isunix
   set(fg,'DefaultUIControlFontSize',10);
end


%---Data structure
ud = struct(...
   'Type',1,...
   'R',1.5,...
   'L',2.0,...
   'C',2.0,...
   'Response',[],...
   'System',[],...
   'Resonance',[],...
   'Diagram',[]);

%---Plot layout parameters
xmax = 0.68;
xmin = 0.06;
ymin = 0.08;
ymax = 0.99;
xsp  = 0.07;
ysp  = 0.1;
ysp2 = 0.025;
axw  = (xmax-xmin-xsp)/2;
axh  = (ymax-ymin-ysp)/2;
axh2 = (axh-ysp2)/2;
AFC  = [.3 .3 .3];

%---Bode plot
ax = axes('Parent',fg,'Position',[xmin ymax-2*axh2-ysp2 axw 2*axh2+ysp2],...
   'XColor',AFC,'YColor',AFC);
BodePlot = resppack.bodeplot(ax, [1 1]);
BodePlot.AxesGrid.YUnits = {'abs';'deg'};
r11 = BodePlot.addresponse;  
r11.setstyle('LineWidth',2)

%---Pole-Zero Plot
ax = axes('Parent',fg,'Position',[xmin+axw+xsp ymin+axh+ysp axw axh],...
   'XColor',AFC,'YColor',AFC,'Xlim',[-1 1],'Ylim',[-1 1]);
PZPlot = resppack.pzplot(ax, [1 1]);
r12 = PZPlot.addresponse(1,1);
r12.setstyle('LineWidth',2,'Color','m')

%---Step Plot
ax = axes('Parent',fg,'Position',[xmin ymin axw axh],'XColor',AFC,'YColor',AFC,...
   'XLim',[0 100],'XTick',[0 20 40 60 80 100],'YTick',[-.5:.5:2]);
gridline('Parent',ax,'Type','y','Value',1,'Color',AFC);
StepPlot = resppack.timeplot(ax, [1 1]);
StepPlot.AxesGrid.Title = 'Step Response';
r21 = StepPlot.addresponse(1,1);;
r21.setstyle('LineWidth',2,'Color','r')

%---Nyquist Plot
ax = axes('Parent',fg,'Position',[xmin+axw+xsp ymin axw axh],'XColor',AFC,'YColor',AFC);
NyqPlot = resppack.nyquistplot(ax, [1 1]);
r22 = NyqPlot.addresponse(1,1);;
r22.setstyle('LineWidth',2,'Color','g')

% All response
r = [r11 r12;r21 r22];
ud.Responses = r;

% No data tips
cleartip(r)

%---Control panel layout parameters
CC = [.7 .7 .7];
xl = 0.71;
xr = 0.99;
yb = 0.08;
yt = 0.98;
axes('Parent',fg,'Position',[xl yb xr-xl yt-yb],'Color',CC,'XTick',[],'YTick',[]);

%---Info/Close buttons
uicontrol('Parent',fg,'Style','pushb','String','Info','Units','normalized',...
   'Position',[xl .01 (xr-xl-.02)/2 yb-2*.01],'Callback',['helpwin ' mfilename]);
uicontrol('Parent',fg,'Style','pushb','String','Close','Units','normalized',...
   'Position',[xl+(xr-xl-.02)/2+.02 .01 (xr-xl-.02)/2 yb-2*.01],'Callback','close(gcbf)');

%---Sliders
y = yb+.06;
dy = 0.11;
uicontrol('Parent',fg,'Style','text','String','System Parameters:','Units','normalized',...
   'Position',[xl+.01 y+2*dy+.045 xr-xl-.02 .045],'Background',CC,'HorizontalAlignment','left');
BDF = {@localBeginScan,ud.Responses};
BUF = {@localEndScan,ud.Responses};
rtslider('Parent',fg,'Position',[xl+.07 y+2*dy xr-xl-.1 .04],'Range',[0.5 5],'Value',ud.R,'Label','R',...
   'ButtonDownFcn',BDF,'Callback',{@localUpdate,fg,'R'},'ButtonUpFcn',BUF);
rtslider('Parent',fg,'Position',[xl+.07 y+1*dy xr-xl-.1 .04],'Range',[0.5 5],'Value',ud.L,'Label','L',...
   'ButtonDownFcn',BDF,'Callback',{@localUpdate,fg,'L'},'ButtonUpFcn',BUF);
rtslider('Parent',fg,'Position',[xl+.07 y+0*dy xr-xl-.1 .04],'Range',[0.5 5],'Value',ud.C,'Label','C',...
   'ButtonDownFcn',BDF,'Callback',{@localUpdate,fg,'C'},'ButtonUpFcn',BUF);

%---System/Topology
x1 = xl+.01;
y1 = yt-.02-.05;
y2 = y1-.01-.05;
tmp1 = uicontrol('Parent',fg,'Style','text','String','System:','Units','norm',...
   'Position',[x1 y1 .08 .05],'Background',CC,'HorizontalAlignment','left');
tmp2 = uicontrol('Parent',fg,'Style','text','String','Topology:','Units','norm',...
   'Position',[x1 y2 .08 .05],'Background',CC,'HorizontalAlignment','left');
ext1 = get(tmp1,'Extent');
ext2 = get(tmp2,'Extent');
maxw = max(ext1(3),ext2(3));
set(tmp1,'Position',[x1 y1 maxw .05]);
set(tmp2,'Position',[x1 y2 maxw .05]);
x2 = x1+maxw+.01;
ud.System = uicontrol('Parent',fg,'Style','popup','Units','normalized',...
   'Position',[x2 y1+.01 xr-.01-x2 .05],...
   'String',{'low-pass','high-pass','band-pass','band-stop'},'Callback',@localSelectSystem,'Value',1);
ud.Resonance = uicontrol('Parent',fg,'Style','popup','Units','normalized',...
   'Position',[x2 y2+.01 xr-.01-x2 .05],...
   'String',{'parallel','series'},'Callback',@localSelectSystem,'Value',1);
ay = y+2*dy+.105;
ah = y2-.01-ay;
ud.Diagram = axes('Parent',fg,'Position',[xl+.01 ay xr-xl-.02 ah],...
   'Color',[.7 .7 .75],'XColor',[.5 .5 .75],'YColor',[.5 .5 .75],'XTick',[],'YTick',[]);

%---Store data structure and show figure
set(fg,'UserData',ud)

%---Initialize simulation
localSelectSystem(ud.System);

%---Make figure visible
set(fg,'Visible','on')

%-----------------------------------%
%---------- Live Graphics ----------%
%-----------------------------------%

function localBeginScan(eventSrc,eventData,r)
%---Sets EraseMode to 'xor' for all lines being updated
set(r,'RefreshMode','quick')

function localEndScan(eventSrc,eventData,r)
%---Sets EraseMode back to 'normal'
set(r,'RefreshMode','normal')
for ct=1:4
   draw(r(ct))  % update plots
end

function localUpdate(eventSrc,eventData,fg,param)
%---Change parameter value (eventData = new value)
%---Change RLC
ud = get(fg,'UserData');
switch param
case 'R', 
   ud.R = eventData;
case 'C', 
   ud.C = eventData;
case 'L', 
   ud.L = eventData;
end
%---Update transfer fcn based on system type
switch ud.Type
case 1
   %---RLC lowpass (parallel resonant)
   Num = 1/(ud.L*ud.C);
   Den = [1 1/(ud.R*ud.C) 1/(ud.L*ud.C)];
case 2
   %---RLC lowpass (series resonant)
   Num = 1/(ud.L*ud.C);
   Den = [1 ud.R/ud.L 1/(ud.L*ud.C)];
case 3
   %---RLC highpass (parallel resonant)
   Num = [1 0 0];
   Den = [1 1/(ud.R*ud.C) 1/(ud.L*ud.C)];
case 4
   %---RLC highpass (series resonant)
   Num = [1 0 0];
   Den = [1 ud.R/ud.L 1/(ud.L*ud.C)];
case 5
   %---RLC bandpass (parallel resonant)
   Num = [1/(ud.R*ud.C) 0];
   Den = [1 1/(ud.R*ud.C) 1/(ud.L*ud.C)];
case 6
   %---RLC bandpass (series resonant)
   Num = [ud.R/ud.L 0];
   Den = [1 ud.R/ud.L 1/(ud.L*ud.C)];
case 7
   %---RLC bandstop (parallel resonant)
   Num = [1 0 1/(ud.L*ud.C)];
   Den = [1 1/(ud.R*ud.C) 1/(ud.L*ud.C)];
case 8
   %---RLC bandstop (series resonant)
   Num = [1 0 1/(ud.L*ud.C)];
   Den = [1 ud.R/ud.L 1/(ud.L*ud.C)];
end
sys = tf(Num,Den);

%---Data source and responses
w = logspace(-2,1,128);
t = [0:.5:100];
r = ud.Responses;

% Time and frequency response
y = step(sys,t);
h = freqresp(sys,w);

% Bode
d = r(1,1).Data;
d.Frequency = w(:);
d.Magnitude = abs(h(:));
d.Phase = unwrap(angle(h(:)));
d.Focus = [0.01 10];

% Nyquist
d = r(2,2).Data;
d.Frequency = w(:);
d.Response = h(:);
d.Focus = [0.01 10];

% Step response
d = r(2,1).Data;
d.Time = t(:);
d.Amplitude = y;
d.Focus = [0 100];

% Pole/zero
d = r(1,2).Data;
[d.Zero,d.Pole] = zpkdata(sys);

% Redraw
for ct=1:4
   draw(r(ct))
end

%-------------------------------------------------%
%---------- Slider to transfer function ----------%
%-------------------------------------------------%

%%%%%%%%%%%%%%%%%%%%%
% localSelectSystem %
%%%%%%%%%%%%%%%%%%%%%
function localSelectSystem(eventSrc,eventData)
%---Select system/topology
fg = get(eventSrc,'Parent');
ud = get(fg,'UserData');
delete(allchild(ud.Diagram));
sysType = get(ud.System,'Value');
sysRes  = get(ud.Resonance,'Value');
ud.Type = (2*sysType-1)+(sysRes==2);
set(fg,'UserData',ud);
switch ud.Type
case 1
   localLowPass(ud.Diagram,'parallel');
case 2
   localLowPass(ud.Diagram,'series');
case 3
   localHighPass(ud.Diagram,'parallel');
case 4
   localHighPass(ud.Diagram,'series');
case 5
   localBandPass(ud.Diagram,'parallel');
case 6
   localBandPass(ud.Diagram,'series');
case 7
   localBandStop(ud.Diagram,'parallel');
case 8
   localBandStop(ud.Diagram,'series');
end
%---Initialize simulation
localUpdate([],[],fg,'');


%-------------------------------------------------%
%---------- Circuit Rendering Functions ----------%
%-------------------------------------------------%

%%%%%%%%%%%%%%%%
% localLowPass %
%%%%%%%%%%%%%%%%
function localLowPass(ax,topology)
%---Draw a low-pass RLC filter
if strcmpi(topology,'parallel')
   localParallelRLC(ax,'LRC');
else
   localSeriesRLC(ax,'RLC');
end

%%%%%%%%%%%%%%%%%
% localHighPass %
%%%%%%%%%%%%%%%%%
function localHighPass(ax,topology)
%---Draw a high-pass RLC filter
if strcmpi(topology,'parallel')
   localParallelRLC(ax,'CRL');
else
   localSeriesRLC(ax,'RCL');
end

%%%%%%%%%%%%%%%%%
% localBandPass %
%%%%%%%%%%%%%%%%%
function localBandPass(ax,topology)
%---Draw a band-pass RLC filter
if strcmpi(topology,'parallel')
   localParallelRLC(ax,'RLC');
else
   localSeriesRLC(ax,'LCR');
end

%%%%%%%%%%%%%%%%%
% localBandStop %
%%%%%%%%%%%%%%%%%
function localBandStop(ax,topology)
%---Draw a band-stop RLC filter
if strcmpi(topology,'parallel')
   set(ax,'XLim',[-0.05 1.85],'YLim',[0.35 2.1]);
   inductor('Parent',ax,'Position',[0.5 1.9],'Size',0.5,'Angle',0);
   capacitor('Parent',ax,'Position',[0.5 1.5],'Size',0.5,'Angle',0);
   resistor('Parent',ax,'Position',[1.4 1.6],'Size',0.5,'Angle',-90);
   wire('Parent',ax,'XData',[0.2 0.5 NaN 0.5 0.5 NaN 1.0 1.0 NaN 1.0 1.6 NaN 1.4 1.4 NaN 1.4 1.4 NaN 0.2 1.6],...
      'YData',[1.7 1.7 NaN 1.5 1.9 NaN 1.5 1.9 NaN 1.7 1.7 NaN 1.7 1.6 NaN 1.1 1.0 NaN 1.0 1.0]);
   port('Parent',ax,'XData',[0.2 0.2],'YData',[1.7 1.0],'Name','Vin');
   port('Parent',ax,'XData',[1.6 1.6],'YData',[1.7 1.0],'Name','Vout');
   text('Parent',ax,'String','L','Position',[0.75 1.78 0],...
      'FontSize',10,'FontWeight','bold','HorizontalAlignment','right','VerticalAlignment','top');
   text('Parent',ax,'String','C','Position',[0.75 1.38 0],...
      'FontSize',10,'FontWeight','bold','HorizontalAlignment','right','VerticalAlignment','top');
   text('Parent',ax,'String','R','Position',[1.25 1.30 0],...
      'FontSize',10,'FontWeight','bold','HorizontalAlignment','right','VerticalAlignment','top');
   equation('Parent',ax,'Position',[mean(get(ax,'XLim')) 0.74],'FontSize',8+isunix,'Anchor','center',...
      'Name','G(s)','Num','s^2 + 1/LC','Den','s^2 + s\cdot1/RC + 1/LC');
else
   set(ax,'XLim',[-0.05 1.85],'YLim',[0.25 2.0]);
   resistor('Parent',ax,'Position',[0.3 1.7],'Size',0.5,'Angle',0);
   inductor('Parent',ax,'Position',[1.2 1.7],'Size',0.5,'Angle',-90);
   capacitor('Parent',ax,'Position',[1.2 1.3],'Size',0.5,'Angle',-90);
   wire('Parent',ax,'XData',[0.2 0.3 NaN 0.8 1.6 NaN 1.2 1.2 NaN 0.2 1.6],...
      'YData',[1.7 1.7 NaN 1.7 1.7 NaN 1.7 1.6 NaN 0.8 0.8]);
   port('Parent',ax,'XData',[0.2 0.2],'YData',[1.7 0.8],'Name','Vin');
   port('Parent',ax,'XData',[1.6 1.6],'YData',[1.7 0.8],'Name','Vout');
   text('Parent',ax,'String','R','Position',[0.55 1.555 0],...
      'FontSize',10,'FontWeight','bold','HorizontalAlignment','right','VerticalAlignment','top');
   text('Parent',ax,'String','L','Position',[1.05 1.45 0],...
      'FontSize',10,'FontWeight','bold','HorizontalAlignment','right','VerticalAlignment','top');
   text('Parent',ax,'String','C','Position',[1.05 1.05 0],...
      'FontSize',10,'FontWeight','bold','HorizontalAlignment','right','VerticalAlignment','top');
   equation('Parent',ax,'Position',[mean(get(ax,'XLim')) 0.55],'FontSize',8+isunix,'Anchor','center',...
      'Name','G(s)','Num','s^2 + 1/LC','Den','s^2 + s\cdotR/L + 1/LC');
end

%%%%%%%%%%%%%%%%%%%%
% localParallelRLC %
%%%%%%%%%%%%%%%%%%%%
function localParallelRLC(ax,type)
set(ax,'XLim',[-0.05 1.85],'YLim',[0.25 2.0]);
switch type
case 'LRC'
   inductor('Parent',ax,'Position',[0.3 1.7],'Size',0.5,'Angle',0);
   resistor('Parent',ax,'Position',[1.0 1.6],'Size',0.5,'Angle',-90);
   capacitor('Parent',ax,'Position',[1.4 1.6],'Size',0.5,'Angle',-90);
   numstr = '1/LC';
   denstr = 's^2 + s\cdot1/RC + 1/LC';
case 'CRL'
   capacitor('Parent',ax,'Position',[0.3 1.7],'Size',0.5,'Angle',0);
   resistor('Parent',ax,'Position',[1.0 1.6],'Size',0.5,'Angle',-90);
   inductor('Parent',ax,'Position',[1.4 1.6],'Size',0.5,'Angle',-90);
   numstr = 's^2';
   denstr = 's^2 + s\cdot1/RC + 1/LC';
case 'RLC'
   resistor('Parent',ax,'Position',[0.3 1.7],'Size',0.5,'Angle',0);
   inductor('Parent',ax,'Position',[1.0 1.6],'Size',0.5,'Angle',-90);
   capacitor('Parent',ax,'Position',[1.4 1.6],'Size',0.5,'Angle',-90);
   numstr = 's\cdot1/RC';
   denstr = 's^2 + s\cdot1/RC + 1/LC';
end
equation('Parent',ax,'Position',[mean(get(ax,'XLim')) 0.74],'FontSize',8+isunix,'Anchor','center',...
   'Name','G(s)','Num',numstr,'Den',denstr);
wire('Parent',ax,'XData',[0.2 0.3 NaN 0.8 1.6 NaN 1.0 1.4 NaN 1.0 1.4 NaN 1.2 1.2 NaN 1.2 1.2 NaN 0.2 1.6],...
   'YData',[1.7 1.7 NaN 1.7 1.7 NaN 1.6 1.6 NaN 1.1 1.1 NaN 1.7 1.6 NaN 1.1 1.0 NaN 1.0 1.0]);
port('Parent',ax,'XData',[0.2 0.2],'YData',[1.7 1.0],'Name','Vin');
port('Parent',ax,'XData',[1.6 1.6],'YData',[1.7 1.0],'Name','Vout');
text('Parent',ax,'String',type(1),'Position',[0.55 1.555 0],...
   'FontSize',10,'FontWeight','bold','HorizontalAlignment','right','VerticalAlignment','top');
text('Parent',ax,'String',type(2),'Position',[0.88 1.30 0],...
   'FontSize',10,'FontWeight','bold','HorizontalAlignment','right','VerticalAlignment','top');
text('Parent',ax,'String',type(3),'Position',[1.30 1.30 0],...
   'FontSize',10,'FontWeight','bold','HorizontalAlignment','right','VerticalAlignment','top');

%%%%%%%%%%%%%%%%%%
% localSeriesRLC %
%%%%%%%%%%%%%%%%%%
function localSeriesRLC(ax,type)
set(ax,'XLim',[-0.05 1.85],'YLim',[0.25 2.0]);
switch type
case 'RLC'
   resistor('Parent',ax,'Position',[0.3 1.7],'Size',0.5,'Angle',0);
   inductor('Parent',ax,'Position',[0.8 1.7],'Size',0.5,'Angle',0);
   capacitor('Parent',ax,'Position',[1.4 1.6],'Size',0.5,'Angle',-90);
   numstr = '1/LC';
   denstr = 's^2 + s\cdotR/L + 1/LC';
case 'RCL'
   resistor('Parent',ax,'Position',[0.3 1.7],'Size',0.5,'Angle',0);
   capacitor('Parent',ax,'Position',[0.8 1.7],'Size',0.5,'Angle',0);
   inductor('Parent',ax,'Position',[1.4 1.6],'Size',0.5,'Angle',-90);
   numstr = 's^2';
   denstr = 's^2 + s\cdotR/L + 1/LC';
case 'LCR'
   inductor('Parent',ax,'Position',[0.3 1.7],'Size',0.5,'Angle',0);
   capacitor('Parent',ax,'Position',[0.8 1.7],'Size',0.5,'Angle',0);
   resistor('Parent',ax,'Position',[1.4 1.6],'Size',0.5,'Angle',-90);
   numstr = 's\cdotR/L';
   denstr = 's^2 + s\cdotR/L + 1/LC';
end
equation('Parent',ax,'Position',[mean(get(ax,'XLim')) 0.74],'FontSize',8+isunix,'Anchor','center',...
   'Name','G(s)','Num',numstr,'Den',denstr);
wire('Parent',ax,'XData',[0.2 0.3 NaN 1.3 1.6 NaN 1.4 1.4 NaN 1.4 1.4 NaN 0.2 1.6],...
   'YData',[1.7 1.7 NaN 1.7 1.7 NaN 1.7 1.6 NaN 1.1 1.0 NaN 1.0 1.0]);
port('Parent',ax,'XData',[0.2 0.2],'YData',[1.7 1.0],'Name','Vin');
port('Parent',ax,'XData',[1.6 1.6],'YData',[1.7 1.0],'Name','Vout');
text('Parent',ax,'String',type(1),'Position',[0.55 1.555 0],...
   'FontSize',10,'FontWeight','bold','HorizontalAlignment','right','VerticalAlignment','top');
text('Parent',ax,'String',type(2),'Position',[1.05 1.555 0],...
   'FontSize',10,'FontWeight','bold','HorizontalAlignment','right','VerticalAlignment','top');
text('Parent',ax,'String',type(3),'Position',[1.25 1.30 0],...
   'FontSize',10,'FontWeight','bold','HorizontalAlignment','right','VerticalAlignment','top');
