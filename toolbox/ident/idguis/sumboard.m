function sumboard(XID)
%SUMBOARD Creates the ident figure.

%	L. Ljung 4-4-94
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.26.4.3 $  $Date: 2004/04/10 23:20:05 $

XID.plotw=-ones(16,3);
XID.counters(1:2)=[8,16];
XID.names.ynames ={};
XID.names.yynames ={};
XID.names.uynames ={};
XID.names.unames ={};
XID.names.exp={};
XID.names.ts =[];
layout
s1='iduipoin(1);';s2='iduipoin(1);iduistat(''Compiling ...'');eval(''';
s3='iduipoin(2);';s4='''),iduipoin(2);';
mStdButtonWidth=0.8*mStdButtonWidth;
mStdButtonHeight=mStdButtonHeight/0.85;
H0 = mEdgeToFrame;                % Mimimum measurement
Voff = 5*mEdgeToFrame;            % Uicontrol vertical/horizontal offset
CBWH = [1.8*mStdButtonWidth mStdButtonHeight];
PUWH = [1.8*mStdButtonWidth CBWH(2)];

% Make axes have appealling "golden" ratio
AxisW = (CBWH(1)-Voff)/2;
AWH = AxisW*[1 2/(1+sqrt(5))];

% Define figure width and height
FigW = 3*CBWH(1) + PUWH(1) + Voff + 4*mFrameToText;
FigH = 4*AWH(2) + 8*CBWH(2) + mFrameToText + 13*H0 + 7*Voff;

DefUIBgC = get(0,'DefaultUIcontrolBackgroundColor');
comp = computer;
%if all(comp(1:2)=='PC'),
%   DefUIBgC = [.7 .7 .7];
%end
figname=idlaytab('figname',16);
set(0,'units','pixels')
scrsize=get(0,'screensize');

fprintf('.') 
Plotcolors=idlayout('plotcol');
axescolor=Plotcolors(4,:);
framecolor=Plotcolors(5,:);
textcolor=Plotcolors(6,:);
fz=idlayout('fonts',50);
fz2=idlayout('fonts',100); % Larger fonts for the arrows
fig = figure('Unit','pix','Position',[10 scrsize(4)-FigH-45 FigW FigH], ...
    'Color',DefUIBgC,'MenuBar','none','ColorMap',[], ...
    'NumberTitle','off','Name',figname,'backingstore','on',...
    'DefaultAxesBox','on','DefaultAxesColor',DefUIBgC, ...
    'DefaultAxesDrawMode','fast','DefaultAxesUnit','pixel', ...
    'DefaultAxesYTick',[],'DefaultAxesYTickLabel',[], ...
    'DefaultAxesXTick',[],'DefaultAxesXTickLabel',[], ...
    'DefaultTextFontSize',fz,'Integerhandle','off', ...
    'DefaultTextHorizontalAlignment','center',...
    'DefaultAxesXColor',framecolor, 'DefaultAxesYColor',framecolor, ...
    'DefaultAxesZColor',framecolor,...
    'Defaulttextcolor',textcolor,...
    'CloseRequestFcn',[s1,'iduiedit(''close_all'');',s3], ...
    'Visible','off','tag','sitb16');     
XID.sumb(1)=fig;
fprintf('.') 
[label,acc]=menulabel('&File');
f = uimenu(fig,'Label',label);
[label,acc]=menulabel('&Open session... ^o');
XID.sbmen(1)=uimenu(f,'Label',label,'Accel',acc,'callback',...
    [s2,'iduisess(''''load'''');',s4],'tag','open');
[label,acc]=menulabel('&Close session');
XID.sbmen(3)=uimenu(f,'Label',label,'Accel',acc,'callback',...
    [s2,'iduiedit(''''new'''');',s4],'interruptible','On',...
    'enable','off'); 
[label,acc]=menulabel('&Save session ^s');
XID.sbmen(4)=uimenu(f,'Label',label,'Accel',acc,'tag','save',...
    'callback',[s2,'iduisess(''''save'''');',s4],'enable','off','separator','on');
[label,acc]=menulabel('Save session &as...');
XID.sbmen(5)=uimenu(f,'Label',label,'tag','saveas',... 
    'callback',[s2,'iduisess(''''save_as'''');',s4],'enable','off');
[label,acc]=menulabel(['&1 ',deblank(XID.sessions(1,:))]);
XID.sbmen(6)=uimenu(f,'Label',label,...
    'userdata',deblank(XID.sessions(1,:)),'tag',deblank(XID.sessions(2,:)),...
    'separator','on',... 
    'callback',[s2,'iduisess(''''direct'''',6);',s4],'enable','on' );
[label,acc]=menulabel(['&2 ',deblank(XID.sessions(3,:))]);
XID.sbmen(7)=uimenu(f,'Label',label,...
    'userdata',deblank(XID.sessions(3,:)),'tag',deblank(XID.sessions(4,:)),...
    'callback',[s2,'iduisess(''''direct'''',7);',s4],'enable','on' );
[label,acc]=menulabel(['&3 ',deblank(XID.sessions(5,:))]);
XID.sbmen(8)=uimenu(f,'Label',label,...
    'userdata',deblank(XID.sessions(5,:)),'tag',deblank(XID.sessions(6,:)),...
    'callback',[s2,'iduisess(''''direct'''',8);',s4],'enable','on' );
[label,acc]=menulabel(['&4 ',deblank(XID.sessions(7,:))]);
XID.sbmen(9)=uimenu(f,'Label',label,...
    'userdata',deblank(XID.sessions(7,:)),'tag',deblank(XID.sessions(8,:)),...
    'callback',[s2,'iduisess(''''direct'''',9);',s4],'enable','on' );

[label,acc]=menulabel('&Exit ident^w');
uimenu(f,'Label',label,'Accel',acc,'callback',...
    [s1,'iduiedit(''close_all'');',s3],'interruptible','On','separator','on'); 

[label,acc]=menulabel('&Options');
XID.citer(1)=f;
set(f,'UserData',str2mat('[]','[]','[]','[]'))
o = uimenu(fig,'Label',label);
[label,acc]=menulabel('E&xtra model/data board ^x');
uimenu(o,'Label',label,'Accel',acc,'callback',...
    [s1,'iddmtab;',s3]);
[label,acc] = menulabel('Warnings ^A');
cbw = ['Xsum = findobj(get(0,''children''),''flat'',''tag'',''sitb16'');',...
'XID = get(Xsum,''Userdata'');if strcmp(get(XID.warning,''checked''),''on''),',...
'set(XID.warning,''checked'',''off'');else set(XID.warning,''checked'',''on'');',...
'end, set(Xsum,''Userdata'',XID);'];


XID.warning = uimenu(o,'Label',label,'Accel',acc,'checked','on',...
    'callback',cbw);
[label,acc]=menulabel('&Empty trash');
XID.sbmen(10)=uimenu(o,'label',label,'enable','off',...
    'callback',[s1,'iduiwast(''kill'');',s3],'tag','trashmenu');
[label,acc]=menulabel('&Save preferences');
uimenu(o,'Label',label,'separator','on','interruptible','On',...
    'callback',[s1,'idlaytab(''save'');idlaytab(''savepf'');',s3]);
[label,acc]=menulabel('&Default preferences');
uimenu(o,'label',label,'callback',[s1,'idlaytab(''def'');',s3],...
    'interruptible','On');
[label,acc]=menulabel('&Window');    
w = uimenu(fig,'Label',label,'callback','winmenu','Tag','winmenu');
winmenu(fig);
[label,acc]=menulabel('&Help');
h = uimenu(fig,'Label',label);
[label,acc]=menulabel('Ident &GUI Help ^G');
uimenu(h,'Label',label,'Accel',acc,'callback',...
    'iduihelp(''idmw.hlp'',''Help: ident'');')
[label,acc]=menulabel('S&ystem Identification ^Y');
uimenu(h,'Label',label,'Accel',acc,'callback',...
    'iduihelp(''sitbgui.hlp'',''Help: The Big Picture'');')
[label,acc]=menulabel(['System Identification',...
        ' Toolbox &Help ^H']);
uimenu(h,'Label',label,'Accel',acc,'callback',...
    'doc ident/;')
[label,acc]=menulabel('GUI Help &topics ^T');
uimenu(h,'Label',label,'Accel',acc,'Separator','on','callback',...
    'iduihelp(''idhtop.hlp'',''Help: File menu'');')



[label,acc]=menulabel('Don''t &miss this');
uimenu(h,'Label',label,'Accel',acc,'callback',...
    'iduihelp(''iduidmt.hlp'',''Help: Do not miss this'');')

[label,acc]=menulabel('&Technical support web page ^I');
uimenu(h,'Label',label,'Accel',acc,'callback',...
    'web(''http://www.mathworks.com/support/author/sysid.shtml'');')
[label,acc]=menulabel('I&nteractive demo of the GUI');
uimenu(h,'Label',label,'Accel',acc,'separator','on','callback','iduidemo(0);') 
[label,acc]=menulabel('&Demo of the Toolbox ^D');
uimenu(h,'Label',label,'Accel',acc,'callback','demo toolbox system') 
[label,acc]=menulabel('&About the System Identification Toolbox');
uimenu(h,'Label',label,'Accel',acc,'separator','on','callback',...
    'aboutidenttbx') 

% Define a bunch of constants for offsets
H1 = mFrameToText;                % Left corner of Data Views checkbox
H2 = H1 + AxisW + Voff;           % Left corner of right axis under Data
H3 = H2 + AxisW + mFrameToText;   % Left corner of center column popup
H4 = H3 + PUWH(1) + mFrameToText; % Left corner of Model Views checkbox
H5 = H4 + AxisW + Voff;           % Left corner of 2nd axis under Models
H6 = H5 + AxisW + Voff;           % Left corner of 3rd axis under Models
H7 = H6 + AxisW + Voff;           % Left corner of 4th axis under Models

% Preallocate some memory
Text     = zeros(6,1);
CheckBox = zeros(8,1);
Axis     = zeros(28,1);
Popup    = zeros(4,1);
V1 = H0;

% Create the status line
StatusW = FigW -2*H0;
Text(1) = uicontrol(fig,'Style','text','String','Status line is here.', ...
    'BackgroundColor',DefUIBgC, ...
    'Position',[H0 V1 StatusW CBWH(2)]);
XID.status(16)=Text(1);
% Make Checkboxes and Popups
V3 = V1 + CBWH(2) + 10*H0;;
V4 = V3 + CBWH(2) + Voff;
V5 = V4 + CBWH(2) + Voff;
V6 = V5 + CBWH(2) + Voff;
CheckBox(1) = uicontrol('Style','check','String','Time plot', ...
    'HorizontalAlignment','left','BackgroundColor',DefUIBgC, ...
    'Position',[H1 V6 CBWH],...
    'Tooltip',['Plot data. Select sets by single',...
        ' clicks on the data icons.']);
CheckBox(2) = uicontrol('Style','check','String','Data spectra', ...
    'HorizontalAlignment','left','BackgroundColor',DefUIBgC, ...
    'Position',[H1 V5 CBWH],...
    'Tooltip',['Plot data spectra. Select sets by single',...
        ' clicks on the data icons.']);
CheckBox(9) = uicontrol('Style','check','String','Frequency function', ...
    'HorizontalAlignment','left','BackgroundColor',DefUIBgC, ...
    'Position',[H1 V4 CBWH]+[0 0 20 0],...
    'Tooltip',['Plot frequency function. Select sets by single',...
        ' clicks on the data icons.']);


CheckBox(3) = uicontrol('Style','check','String','Model output', ...
    'HorizontalAlignment','left','BackgroundColor',DefUIBgC, ...
    'Position',[H4 V6 CBWH],...
    'Tooltip',['Compare Model and Measured Output. Select models',...
        ' by clicking the model icons.']); 
CheckBox(4) = uicontrol('Style','check','String','Model resids', ...
    'HorizontalAlignment','left','BackgroundColor',DefUIBgC, ...
    'Position',[H4 V5 CBWH],...
    'Tooltip',['Examine the residuals from the models. Select models',...
        ' by clicking the model icons.']);

CheckBox(5) = uicontrol('Style','check','String','Transient resp', ...
    'HorizontalAlignment','left','BackgroundColor',DefUIBgC, ...
    'Position',[H6 V6 CBWH],...
    'Tooltip',['Model impulse and step response. Select models',...
        ' by clicking the model icons.']);
CheckBox(6) = uicontrol('Style','check','String','Frequency resp', ...
    'HorizontalAlignment','left','BackgroundColor',DefUIBgC, ...
    'Position',[H6 V5 CBWH],...
    'Tooltip',['Model Bode plots. Select models',...
        ' by clicking the model icons.']);
CheckBox(7) = uicontrol('Style','check','String','Zeros and poles', ...
    'HorizontalAlignment','left','BackgroundColor',DefUIBgC, ...
    'Position',[H6 V4 CBWH],...
    'Tooltip',['Zeros and poles of the models. Select models',...
        ' by clicking the model icons.']);
CheckBox(8) = uicontrol('Style','check','String','Noise spectrum', ...
    'HorizontalAlignment','left','BackgroundColor',DefUIBgC, ...
    'Position',[H6 V3 CBWH],...
    'Tooltip',['Spectrum of additive noise at outputs. Select models',...
        ' by clicking the model icons.']);
XID.plotw([1 13 3 6 5 2 4 7 40],2)=CheckBox(1:9);
% Make a Close button.  Actually adds some symmetry
Push = uicontrol('Style','push','String','Exit','Position',[H1 V3 CBWH], ...
    'Callback',[s1,'iduiedit(''close_all'');',s3],'interruptible','On',...
    'backgroundcolor',DefUIBgC);

% Make Data Views and Model Views text
V7 = V6 + CBWH(2) + H0;
% This is to compute the platforms text ratios, to be used later in
% displays
test = uicontrol(fig,'style','text','string','1+2*Zeta*Tw*s+(Tw*s)^2','vis','off');
ex1 = get(test,'extent');
set(test,'string',repmat('-',1,20))
ex2 = get(test,'extent');
set(test,'string',repmat(' ',1,20))
ex3 = get(test,'extent');

XID.dash(1) = ex1/ex2;
XID.dash(2) = ex1/ex3;

% end size test
Text(2) = uicontrol(fig,'Style','text','String','Data Views', ...
    'BackgroundColor',DefUIBgC, ...
    'Position',[H1 V7 CBWH]);
Text(3) = uicontrol(fig,'Style','text','String','Model Views', ...
    'BackgroundColor',DefUIBgC, ...
    'Position',[H5 V7 CBWH]);
SpecialAWH = AWH;%[(1+sqrt(5))/2 1]*(2*CBWH(2)+Voff);

Axis(26) = axes('Position',...
    [H4 V5-SpecialAWH(2)-H0 SpecialAWH],'tag','selva','color',axescolor);
Text(4)=get(Axis(26),'xlabel');
set(Text(4),'string','Validation Data','color','k')

text('pos',[0.5 0],'units','norm','tag','name',...
    'verticalalignment','bottom');
line('color',textcolor,'vis','off','erasemode','normal','tag',...
    'selline');
XID.hw(4,1)=Axis(26);

% Make To Workspace icon
ToWSBottom = V6;
ToWSLeft = H3+(CBWH(1)-AWH(1))/2;
if ~exist('ltiview')
    pos27=[ToWSLeft-0.15*AWH(1) ToWSBottom 1.3*AWH(1) AWH(2)];
    axlist = [];
else
    pos27=[H3 ToWSBottom AWH];
    pos32=[H3+AWH(1)+Voff ToWSBottom AWH];
    Axis(32) = axes('Position',pos32,'Color',DefUIBgC, ...
        'XColor','k','YColor','k','Zcolor','k', ...
        'DefaultTextColor','k','tag','ltivi');
    text(0.5,0.5,{'To','LTI Viewer'});
    axlist = Axis(32);
end
Axis(27) = axes('Position',pos27,'Color',DefUIBgC, ...
    'XColor','k','YColor','k','Zcolor','k', ...
    'DefaultTextColor','k','tag','expor');
text(0.5,0.5,{'To','Workspace'});
idresizefont([axlist Axis(27)]);

% Make empty trashcan icon

TrashWH = 1.5*[20 30];
TrashLeft = H3 + (CBWH(1)-TrashWH(1))/2;
TrashBottom = V3 + 3*Voff;
Axis(28) = axes('Position',[TrashLeft TrashBottom TrashWH], ...
    'Box','off','Color',DefUIBgC,'xcolor',DefUIBgC,'ycolor',DefUIBgC, ...
    'zcolor','k',...
    'Xlim',[0 50],'Ylim',[0 100],'tag','waste');
text(25,-25,'Trash','Color','k')
xd = [18  18  32 32  0  0 50 50 32 NaN  1 1 49 49 NaN 10 12 12 10 NaN ...
        20 22 22 20 NaN 30 32 32 30 NaN 40 42 42 40];
yd = [95 100 100 95 95 90 90 95 95 NaN 90 0  0 90 NaN 80 75 15 10 NaN ...
        80 75 15 10 NaN 80 75 15 10 NaN 80 75 15 10];
lem = line(xd,yd,'Color','k','tag','empty');
% Here's a non-empty trashcan
xd = [18  18  32 32  0  0 50 50 32 NaN 10  0  0 10 40 50 50 40 NaN ...
        12  7  7 12 NaN ...
        22 17 17 22 NaN 28 33 33 28 NaN 38 43 43 38];
yd = [95 100 100 95 95 90 90 95 95 NaN 90 70 20  0  0 20 70 90 NaN ...
        80 70 20 10 NaN ...
        80 70 20 10 NaN 80 70 20 10 NaN 80 70 20 10];
lf = line(xd,yd,'Color','k','vis','off','tag','full');
set(Axis(28),'HandleVisibility','Callback');
fprintf('.') 

% Create the data and model axes
V2 = V7 + CBWH(2) + Voff + mFrameToText/2;
VVL = V2; % Level of lowermost axes
kd=8;km=16;map=idlayout('colors');
HPOS=[H1 H2 H3 H4 H5 H6 H7];
for i=4:-1:1,
    Axis(6*(i-1)+1) = axes('Position',[H2 V2 AWH],'NextPlot','add',...
        'tag',['data ',int2str(kd)]);
    text('pos',[0.5 0],'units','norm','tag','name',...
        'verticalalignment','bottom');
    line('color',map(kd,:),'vis','off','erasemode','normal','tag',...
        'dataline0');kd=kd-1;
    Axis(6*(i-1)+2) = axes('Position',[H1 V2 AWH],'NextPlot','add',...
        'tag',['data ',int2str(kd)]);
    text('pos',[0.5 0],'units','norm','tag','name',...
        'verticalalignment','bottom');
    line('color',map(kd,:),'vis','off','erasemode','normal','tag',...
        'dataline0');kd=kd-1;
    for kpos=6:-1:3
        Axis(6*(i-1)+kpos) = axes('Position',[HPOS(kpos+1) V2 AWH],...
            'NextPlot','add','tag',['model',int2str(km)]);
        text('pos',[0.5 0],'units','norm','tag','name',...
            'verticalalignment','bottom');
        line('color',map(km,:),'vis','off','erasemode','normal','tag',...
            'modelline0');km=km-1;
    end
    V2 = V2 + AWH(2) + Voff;
end
VVU = V2 - AWH(2) - Voff; % Level of uppermost icon axes
fprintf('.') 

avert = V2-Voff+H0; asize = [CBWH(2) CBWH(2)]-H0;
apos = [H6-Voff/2-CBWH(2)/2 V2-Voff+H0 asize];
Axis(30) = axes('position',apos,'vis','off');
a1 = iddrawarrow(Axis(30),-90);
apos = [H2-Voff/2-CBWH(2)/2 V2-Voff+H0 asize];
Axis(31) = axes('position',apos,'vis','off');
a1 = iddrawarrow(Axis(31),-90);

% Make Data and Model popup and Operations text
V2 = V2 - Voff + 4*H0 + CBWH(2);

Popup(1) = uicontrol(fig,'Style','popup', ...
    'backgroundcolor','white',...
    'String','Import data|Time domain data...|Freq. domain data...|Data object...|Example...', ...
    'Position',[H1 V2 CBWH],'tag','sitbdatapop', ...
    'Callback',[s2,'XIDh=findobj(0,''''tag'''',''''sitbdatapop'''');',...
        'if get(XIDh,''''value'''')==5,load dryer2,end,clear XIDh,',...
        'iduipop(''''data'''');',s4],...
    'Tooltip',['Import input/output data matrices',...
        ' or IDDATA/IDFRD objects from workspace.']);
Popup(2) = uicontrol(fig,'Style','popup','String','Import models|Import...', ...
    'backgroundcolor','white',...
    'Position',[H5 V2 CBWH], ...
    'Callback',[s2,'iduipop(''''model'''');',s4],...
    'ToolTip',['Import IDMODEL and IDFRD models from Workspace.']);
Voper = V2-CBWH(2)-H0;
Text(6) = uicontrol(fig,'Style','text','String','Operations', ...
    'BackgroundColor',DefUIBgC, ...
    'Position',[H3 Voper CBWH]);

% Make popups and Current data axis
Vpop1   = VVU + AWH(2)/4;%Voper - H0 - AWH(2);
VCDaxes = Vpop1 - CBWH(2) - 1.25*AWH(2);
%Vpop2   = VVL + AWH(2)/4;%VCDaxes -3*CBWH(2);
Vpop2   = VVL;
Pop3Str = {'<-- Preprocess','Select channels...','Select experiments...','Merge experiments...',...
        'Select range...','Remove means','Remove trends','Filter...','Resample...',...
        'Transform data...','Quick start'};
popusd{1}=Pop3Str;popusd{2}=[1:10];
XID.pop = popusd;
Popup(3) = uicontrol('Style','popup','String',Pop3Str, ...
    'backgroundcolor','white',...
    'HorizontalAlignment','left', ...
    'Position',[H3 Vpop1 CBWH], ...
    'Tag','sitbpreppop', ...
    'Callback',[s2,'iduipop(''''preprocess'''');',s4],...
    'Tooltip','Create new data sets by processing the Working Data set.');
Pop4Str = [' Estimate -->|Parametric models...|Process models...|' ...
        'Spectral model...|Correlation model...|Quick start'];
Popup(4) = uicontrol('Style','popup','String',Pop4Str, ...
    'backgroundcolor','white',...
    'HorizontalAlignment','left','Tag','sitbestpop',...
    'Position',[H3 Vpop2 CBWH], ...
    'Callback',[s2,'iduipop(''''estimate'''');',s4],...
    'Tooltip',['Estimate models from Working Data']);
XID.plotw(16,1)=Popup(4); % This will house userdata for iteration control and corr. analysis
XID.plotw(15,2)=Popup(3);
XID.plotw(14,2)=Popup(2);
set(XID.plotw(16,1),'userdata',str2mat('[]','[]',int2str(1)));
% usd(1) is cra-filter order usd(2) is spa-M usd(3) is spa-method
Axis(25) = axes('Position',[H3+(CBWH(1)-AWH(1))/2 VCDaxes AWH], ...
    'NextPlot','add','tag','seles','color',axescolor);
text('pos',[0.5 0],'units','norm','tag','name',...
    'verticalalignment','bottom','color',textcolor);
line('vis','off','erasemode','normal','tag',...
    'selline');
Text(5)=get(Axis(25),'xlabel');
set(Text(5),'string','Working Data','color','k')
XID.hw(3,1) =Axis(25);


apos = [H3 VCDaxes+Voff asize];
Axis(29) = axes('position',apos,'vis','off');
t1 = iddrawarrow(Axis(29), 0);
apos = [H3+CBWH(1)/2-CBWH(2)/2 VVU-CBWH(2)+Voff asize];
Axis(33) = axes('position',apos,'vis','off');
t2 = iddrawarrow(Axis(33), 90);
apos = [H3+CBWH(1)/2-CBWH(2)/2 VVL+CBWH(2) asize];
Axis(34) = axes('position',apos,'vis','off');
t3 = iddrawarrow(Axis(34),-90);

if isempty(XID.plotprefs)
    pd=idlayout('plotdefs');pd=pd(:);
    pd=pd*ones(1,15);
else
    pd=XID.plotprefs;
end 

set(XID.plotw(1,2),'callback',[s2,'iduipw(1);',s4],'userdata',int2str(pd(12,1)));
set(XID.plotw(14,2),'userdata',int2str(pd(12,14)));
set(XID.plotw(2,2),'callback',[s2,'iduipw(2);',s4],...
    'UserData',str2mat(int2str(pd(2,2)),int2str(pd(3,2)),int2str(pd(1,2)),'[]'));
set(XID.plotw(40,2),'callback',[s2,'iduipw(40);',s4],...
    'UserData',str2mat(int2str(pd(2,2)),int2str(pd(3,2)),int2str(pd(1,2)),'[]'));

set(XID.plotw(3,2),'callback',[s2,'iduipw(3);',s4],...
    'UserData',str2mat(int2str(pd(4,3)),int2str(pd(5,3)),'[]',int2str(pd(6,3))));
set(XID.plotw(4,2),'callback',[s2,'iduipw(4);',s4]);
set(XID.plotw(5,2),'callback',[s2,'iduipw(5);',s4],...
    'UserData',str2mat(int2str(pd(8,5)),num2str(pd(9,5)),int2str(pd(7,5))));
set(XID.plotw(6,2),'callback',[s2,'iduipw(6);',s4],...
    'UserData',num2str(pd(10,6)));
set(XID.plotw(7,2),'callback',[s2,'iduipw(7);',s4],...
    'UserData',str2mat(int2str(pd(2,7)),int2str(pd(3,7)),int2str(pd(1,7)),'[]'));
set(XID.plotw(13,2),'userdata',...
    str2mat(int2str(pd(2,13)),int2str(pd(3,13)),...
    int2str(pd(1,13)),'[]',int2str(pd(11,13))),...
    'callback',[s2,'iduipw(13);',s4]);
set(XID.plotw(15,2),'userdata',...
    str2mat(int2str(pd(2,15)),int2str(pd(3,15)),int2str(pd(1,15)),'[]',...
    int2str(pd(11,15))));

set(XID.plotw([1:7,13,40],2),'visible','on','enable','off');


fprintf('.') 
% Make all the uicontrols and axes normalized

set([Text; CheckBox; Axis; Popup; Push],'Unit','norm')
set(0,'Unit','Pixel')
XID.posd=[];XID.posm=[];
for ka=0:3
    XID.posd=[XID.posd;get(Axis(ka*6+1),'pos');get(Axis(ka*6+2),'pos')];
    for kk=3:6, XID.posm=[XID.posm;get(Axis(ka*6+kk),'pos')];end
end

% Make the figure visible

fprintf('.')
fprintf(' done. \n')
iduistat('Ready to start. Try the Data popup.')
set(XID.sumb(1),'windowbuttondownfcn',...
    ['iduipoin(1);idmwwb;iduipoin(2);'],...
    'KeyPressfcn',[s2,'iduikeyp;',s4])
 %['iduipoin(1);[dat,dat_n,dat_i,do_com]=',...
  %      'idmwwb;eval(do_com);clear dat dat_n dat_i do_com,iduipoin(2);'],...

FigW=0.85*FigW;
FigH=0.85*FigH;
set(fig,'Position',[10 scrsize(4)-FigH-45 FigW FigH]);
if length(XID.layout)>15
    if XID.layout(16,3)
        eval('set(fig,''pos'',XID.layout(16,1:4))','')
    end
end

set(XID.sumb(1),'vis','on')
set(fig,'HandleVisibility','Callback');

set(fig,'Userdata',XID);
% begin local functions
%------------------------------------------------------------------------
function fsize = idresizefont(a)
% This function expects to find a single text object within
% each axes.  This text object is centered, and font-scaled
% to be (roughly) as large as possible without exceeding the
% axes boundaries.

if nargin < 1 | isempty(a)
    a = gca;
end

fontlist=[12 10 8 7 6 5 4];
xlist = [];
findex = 1;		% find one font for all axes

for j=1:length(a)
    aj = a(j);
    x = findobj(aj,'type','text');
    xlist = [xlist; x(:)];
    for k=1:length(x)
        xk = x(k);
        oldunits = get(xk,'units');
        set(xk,'units','normalized');
        done = 0;
        while ~done
            set(xk,'fontsize', fontlist(findex));
            set(xk,'position',[0.5 0.5 0]);
            ek = get(xk,'extent');
            done = (ek(3) < 0.85) & (ek(4) < 0.85) | (findex == length(fontlist));
            if ~done
                findex = findex + 1;
            end
        end
        set(xk,'units',oldunits);
    end
end

fsize = fontlist(findex);
set(xlist,'fontsize',fsize);

%------------------------------------------------------------------------
function ahan = iddrawarrow(a,rot)
% Given an axes handle, draw an arrow in the axes
% possibly rotated by rot degrees.

if nargin < 1 | isempty(a)
    a = gca;
end

if nargin < 2 | isempty(rot)
    rot = 0;
end

rot = pi*rot/180;
R = [cos(rot) -sin(rot); sin(rot) cos(rot)];

x0 = -0.4;
x1 =  0.1;
x2 =  0.4;
dy =  0.075;

% xy points defining a normalized arrow at
% the origin, pointing east
xy = [ x0  x1    x1  x2    x1  x1  x0  x0;...
        -dy -dy -3*dy   0  3*dy  dy  dy -dy];

z = R*xy + 0.5;
ahan = patch(z(1,:),z(2,:),[0.5 0.5 0.5]);

%------------------------------------------------------------------------

% end sumboard
