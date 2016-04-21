function iddmtab(number)
%IDDMTAB Creates additional data/model Summary Board tables.
%   This function is invoked by iduiinsm and iduiinsd as well as by
%   iduiedit (clear/delete) to make sure that all models/data are
%   represented in visible Summary Boards.
%   NUMBER is the number on the summary board.

%   L. Ljung 4-4-94
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.9.4.3 $  $Date: 2004/04/10 23:19:22 $

sstat = get(0,'showhiddenhandles');
set(0,'showhiddenhandles','on')
Xsum = findobj(get(0,'children'),'flat','tag','sitb16');
set(0,'showhiddenhandles',sstat)
XID = get(Xsum,'Userdata');
% XIDposd1 and XIDposm1 are used only in iduisess

if nargin<1
number=1;create=0;
while ~create
   number=number+1;
   eval(['if ~(strcmp(get(XID.sumb(number),''tag''),''sitb30'')',...
              '&get(XID.sumb(number),''userdata'')==number),create=1;end'],...
               'create=1;')
end  
end
number=fix(number);
pos1=get(0,'ScreenSize');
posXY=[20 pos1(4)-350];
name=get(XID.sumb(1),'name');
figname=[name ' (',int2str(number),')'];
       iduistat('Opening an extra summary board ...')
layout
mStdButtonWidth=0.7*mStdButtonWidth;
H0 = mEdgeToFrame;                % Mimimum measurement
Voff = 5*mEdgeToFrame;            % Uicontrol vertical/horizontal offset
CBWH = [1.8*mStdButtonWidth mStdButtonHeight];
PUWH = [1.8*mStdButtonWidth CBWH(2)];
etf = mEdgeToFrame;
% Make axes have appealling "golden" ratio
AxisW = (CBWH(1)-Voff)/2;
AWH = AxisW*[1 2/(1+sqrt(5))];

% Define figure width and height
FigW = 3*CBWH(1)  +  4*mFrameToText;
FigH = 5*AWH(2) + 3*mFrameToText ;

DefUIBgC = get(0,'DefaultUIcontrolBackgroundColor');
Plotcolors=idlayout('plotcol');
axescolor=Plotcolors(5,:);
textcolor=Plotcolors(6,:);
fz=idlayout('fonts',50);
fig = figure('Unit','pix','Position',[number*10 number*10 FigW FigH], ...
 'Color',DefUIBgC,'MenuBar','none','ColorMap',[],...
 'HandleVisibility','callback', ...
 'NumberTitle','off','Name',figname,'backingstore','on',...
 'DefaultAxesBox','on','DefaultAxesColor',DefUIBgC, ...
 'DefaultAxesDrawMode','fast','DefaultAxesUnit','pixel', ...
 'DefaultAxesYTick',[],'DefaultAxesYTickLabel',[], ...
 'DefaultAxesXTick',[],'DefaultAxesXTickLabel',[], ...
 'DefaultTextFontSize',fz,'Integerhandle','off', ...
 'DefaultTextColor',textcolor, ...
 'DefaultTextHorizontalAlignment','center', ...
 'DefaultAxesXColor',axescolor, 'DefaultAxesYColor',axescolor, ...
 'DefaultAxesZColor',axescolor, ...
 'CloseRequestFcn',['iduipoin(1);',...
      'iduistat(''Putting data and models in Trash Can...'');',...
      'iduiwast(''clexbo'');iduipoin(2);'],...
 'Visible','off','tag','sitb30','userdata',number);     
XID.sumb(number)=fig;

% Define a bunch of constants for offsets
H1 = mFrameToText;                % Left corner of Data Views checkbox
H2 = H1 + AxisW + Voff;           % Left corner of right axis under Data
H3 = H2 + AxisW + mFrameToText;   % Left corner of center column popup
H4 = H3 + mFrameToText; % Left corner of Model Views checkbox
H5 = H4 + AxisW + Voff;           % Left corner of 2nd axis under Models
H6 = H5 + AxisW + Voff;           % Left corner of 3rd axis under Models
H7 = H6 + AxisW + Voff;           % Left corner of 4th axis under Models

% Preallocate some memory
Axis     = zeros(24,1);

V1 = H0;


% Create the data and model axes
V2 =  mFrameToText;
kd=XID.counters(1)+8;km=XID.counters(2)+16;
XID.counters([1,2])=[kd,km];
map=idlayout('colors');
HPOS=[H1 H2 H3 H4 H5 H6 H7];
for i=4:-1:1,
   Axis(6*(i-1)+1) = axes('Position',[H2 V2 AWH],'NextPlot','add',...
      'tag',['data ',int2str(kd)]);kd=kd-1;
   text('pos',[0.5 0],'units','norm','tag','name',...
                      'verticalalignment','bottom');
   line('color',map(rem(kd,20)+1,:),'vis','off','erasemode','normal','tag',...
             'dataline0');
   Axis(6*(i-1)+2) = axes('Position',[H1 V2 AWH],'NextPlot','add',...
      'tag',['data ',int2str(kd)]);kd=kd-1;
   text('pos',[0.5 0],'units','norm','tag','name',...
                      'verticalalignment','bottom');
   line('color',map(rem(kd,20)+1,:),'vis','off','erasemode','normal','tag',...
             'dataline0');
   for kpos=3:6
      Axis(6*(i-1)+kpos) = axes('Position',[HPOS(kpos+1) V2 AWH],...
        'NextPlot','add','tag',['model',int2str(km)]);km=km-1;
      text('pos',[0.5 0],'units','norm','tag','name',...
                      'verticalalignment','bottom');
      line('color',map(rem(km,20)+1,:),'vis','off','erasemode','normal','tag',...
             'modelline0');
   end
   V2 = V2 + AWH(2) + Voff;
end
hu1=uicontrol(fig,'pos',[4*etf FigH-AWH(2)/2-3*etf AWH(1)+8*etf AWH(2)/2],'style',...
    'text','string','Notes:');
hu3=uicontrol(fig,'pos',[4*etf FigH-AWH(2)-3*etf-etf ...
    AWH(1)+8*etf AWH(2)/2],'style','push','string','Close','callback',...
    ['iduipoin(1);iduistat(''Putting data and models in Trash Can...'');',...
     'iduiwast(''clexbo'');iduipoin(2);']);
hu2=uicontrol(fig,'pos',...
    [H2 FigH-AWH(2)-3*etf H7-H2+AWH(1) AWH(2)],'style',...
    'edit','max',2, ...
    'BackgroundColor','w', ...
    'HorizontalAlignment','left', ...
    'tag','notes');

set([Axis;hu1;hu2;hu3],'Unit','norm')
XID.posd1=[];XID.posm1=[];
for ka=0:3
   XID.posd1=[XID.posd1;get(Axis(ka*6+1),'pos');get(Axis(ka*6+2),'pos')];
   for kk=3:6, XID.posm1=[XID.posm1;get(Axis(ka*6+kk),'pos')];end
end

% Make the figure visible

set(fig,'windowbuttondownfcn',...
    ['iduipoin(1);idmwwb;iduipoin(2);'])

if length(XID.layout)>29
   if XID.layout(30,3)
      eval('set(fig,''pos'',XID.layout(30,1:4));','')
   end
end
set(fig,'vis','on')

iduistat('')
set(Xsum,'UserData',XID)
