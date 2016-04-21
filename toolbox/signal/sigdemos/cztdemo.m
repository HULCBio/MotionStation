function cztdemo(action,s);
%CZTDEMO Demonstrates the FFT and CZT in the Signal Processing Toolbox.
%
% This demo lets you explore two different transform algorithms and examine
% their performance. They are
%    FFT      - the Fast Fourier Transform
%    CZT      - the Chirp-Z Transform
%
% The upper plot shows the z-plane, and the lower plot shows the transform of
% a bandpass elliptic digital filter on the points within the wedge shown on
% the upper plot. The filter has a passband from .4 to .7 of the Nyquist
% frequency (Nyquist = Fs/2).
% 
% The FFT computes the Z-transform on equally spaced points around the unit circle.
% 
% The CZT computes the Z-transform on a spiral or "chirp" contour.  The
% contour is defined by initial frequency Fmin and radius R1, and final
% frequency Fmax and radius R2. Fs is the sampling frequency.
% 
% Fmin and Fmax define a "wedge" of the unit  circle.
% 
% Npoints is the number of Z-transform points computed on the unit circle in
% the wedge defined by Fmin and Fmax.
% 
% With FFT, the length of the transform is Npoints*Fs/(Fmax-Fmin), which
% computes Npoints points in the range Fmin to Fmax. If you are interested in
% a small frequency range, the CZT is more efficient because it "zooms in" on
% the range you are interested in and only computes Npoints.
%
% See also SOSDEMO, FILTDEMO, MODDEMO.

%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.8 $  $Date: 2002/11/21 15:47:30 $

% Possible actions:
% initialize
% Fs
% Wmin
% Wmax
% points
% radius1
% radius2
% design

% button callbacks:
% radio
% infobtn
% close


if nargin<1,
    action='initialize';
end;
if nargin <= 1,
	feval(action);
else
	feval(action,s);
end

function design
% evaluate fft or czt
set(gcf,'Pointer','watch');
ud=get(gcf,'Userdata');
hndlList=ud.hndlList;
b=ud.filter.num;
a=ud.filter.den;
zplaneHndl = findobj(hndlList,'Tag','z-Plane');
responseHndl = findobj(hndlList,'Tag','response');
FsHndl = findobj(hndlList,'Tag','Fs'); 
Fs = get(FsHndl,'UserData');
WminHndl = findobj(hndlList,'Tag','Fmin'); 
Wmin = get(WminHndl,'UserData');
WmaxHndl = findobj(hndlList,'Tag','Fmax'); 
Wmax = get(WmaxHndl,'UserData');
pointsHndl = findobj(hndlList,'Tag','points'); 
Npoints = get(pointsHndl,'UserData');
radius1Hndl = findobj(hndlList,'Tag','Radius1'); 
R1 = get(radius1Hndl,'UserData');
radius2Hndl = findobj(hndlList,'Tag','Radius2'); 
R2 = get(radius2Hndl,'UserData');
btn1Hndl = findobj(hndlList,'Tag','FFT');
btn2Hndl = findobj(hndlList,'Tag','CZT');
closeHndl = findobj(hndlList,'Tag','Close');  

set(gcf,'nextplot','add')
if (get(btn1Hndl,'Value')==1), % FFT button checked?
	n = (ceil(Npoints*Fs / max(Wmax-Wmin,eps)));
	if n>2048, n = 2^nextpow2(n); end
	ww = (0:min(n,400)-1)'/min(n,400)*2*pi;
	axes(zplaneHndl)
    [domainHndl,h2,h3] = zplane(exp(j*ww),[],zplaneHndl);
	if length(h3)>1, delete(h3(2:length(h3))), end
	rcolor = get(gcf,'defaultaxescolororder');
	rcolor = rcolor(min(2,size(rcolor,1)),:);
	domainHndl(2) = line('xdata',[0 cos(Wmin*2*pi/Fs)],...
		'color',rcolor,'ydata',[0 sin(Wmin*2*pi/Fs)]);
	domainHndl(3) = line('xdata',[0 cos(Wmax*2*pi/Fs)],...
		'color',rcolor,'ydata',[0 sin(Wmax*2*pi/Fs)]);
	set(closeHndl,'UserData',domainHndl)
	%title('Domain of FFT')
    title('z-Plane')
	axes(responseHndl)
	F = fft(b,n)./fft(a,n);
    nreplicas=ceil(Wmax/Fs)-floor(Wmin/Fs);
    f=linspace(floor(Wmin/Fs)*Fs,ceil(Wmax/Fs)*Fs-1/n,nreplicas*n);
    F=repmat(F,1,nreplicas);
    subplot(212);
	plot(f,20*log10(abs(F)),'.');
    set(gca,'Tag','response');
	if n<=Npoints,            %(Wmin == 0)&(Wmax>=Fs*(1-1/n))
		title(sprintf('%g point FFT of elliptic bandpass filter',n));
	else
		title(sprintf('Close-up of %g point FFT of elliptic bandpass filter',n));
	end
elseif (get(btn2Hndl,'Value')==1),% CZT button checked.
	M = Npoints; 
	A = R1*exp(j*Wmin*2*pi/Fs);
	W = ( R2/R1 )^(-1/(M-1)) * exp(-j*(Wmax-Wmin)*2*pi/Fs/(M-1)) ;
	axes(zplaneHndl)
	z = A*W.^(-(0:M-1)');
	[domainHndl,h2,h3] = zplane(z,[],zplaneHndl);
	if length(h3)>1, delete(h3(2:length(h3))), end
	rcolor = get(gcf,'defaultaxescolororder');
	rcolor = rcolor(min(2,size(rcolor,1)),:);
	domainHndl(2) = line('xdata',[0 R1*cos(Wmin*2*pi/Fs)],...
		'color',rcolor,'ydata',[0 R1*sin(Wmin*2*pi/Fs)]);
    text(R1/2*cos(Wmin*2*pi/Fs),R1/2*sin(Wmin*2*pi/Fs),' R1',...
        'VerticalAlignment','top');
	domainHndl(3) = line('xdata',[0 R2*cos(Wmax*2*pi/Fs)],...
		'color',rcolor,'ydata',[0 R2*sin(Wmax*2*pi/Fs)]);
    text(R2/2*cos(Wmax*2*pi/Fs),R2/2*sin(Wmax*2*pi/Fs),'R2 ',...
        'HorizontalAlignment','right','VerticalAlignment','top');
	set(closeHndl,'UserData',domainHndl)
	%title('Domain of CZT')
    title('z-Plane')
	axes(responseHndl)
	w = unwrap(angle(z));
	w = linspace(Wmin,Wmax,M)*2*pi/Fs;
	
	Ga = czt(a,M,W,A);
	Gb = czt(b,M,W,A);       
	% If any elements of Ga or Gb are zero set to eps
	zeroIndxs_a=find(Ga==0);
	zeroIndxs_b=find(Gb==0);
	Ga(zeroIndxs_a)=eps; 
	Gb(zeroIndxs_b)=eps;        
	F = Gb./Ga;
	
	cla
	subplot(212);           
	plot(w*Fs/2/pi,20*log10(abs(F)),'.')
    set(gca,'Tag','response');
	title(sprintf('%g point CZT of elliptic bandpass filter',M));
end
xlabel('Frequency')
ylabel('Magnitude (dB)')
set(gca,'xlim',[Wmin Wmax])
ylim = get(gca,'ylim');
set(gca,'ylim',[max(-350,ylim(1)) ylim(2)])
set(gcf,'Pointer','arrow');

function initialize
shh = get(0,'showhiddenhandles');
set(0,'showhiddenhandles','on')
figNumber=figure( ...
	'Name','CZT and FFT Demo', ...
	'handlevisibility','callback',...
	'integerhandle','off',...
	'NumberTitle','off');

%[b,a]=ellip(9,3,50,[.4 .7]);   % design filter - store in btn2 userdata
% inline filter coeffs for speed:
num = [ 1.036215553331465e-02
	2.103525287321029e-02
	4.618180706244246e-02
	6.626949942636884e-02
	1.047645705817928e-01
	1.135461439917620e-01
	1.182161372812089e-01
	9.184711304310156e-02
	5.839803125783760e-02
	-5.115907697472721e-13
	-5.839803125883236e-02
	-9.184711304391158e-02
	-1.182161372818484e-01
	-1.135461439921812e-01
	-1.047645705820628e-01
	-6.626949942649851e-02
	-4.618180706250907e-02
	-2.103525287323005e-02
	-1.036215553332198e-02]';
den = [ 1.000000000000000e+00
	2.616784951166920e+00
	9.010794557412463e+00
	1.664491445555174e+01
	3.429175523852171e+01
	4.935300363227517e+01
	7.526259700870287e+01
	8.775364685258239e+01
	1.063920847920586e+02
	1.018212388254725e+02
	1.008239318769620e+02
	7.874570918388088e+01
	6.397972011971305e+01
	3.962383394162555e+01
	2.603920255580061e+01
	1.187892654523706e+01
	6.065579909513929e+00
	1.633745653505110e+00
	5.883332413893858e-01]';
ud.filter.den=den;
ud.filter.num=num;

%==================================
% Set up the image axes
axes( ...
	'Units','normalized', ...
	'Position',[0.10 0.35 0.60 0.6], ...
	'XTick',[],'YTick',[], ...
	'Box','on');
set(figNumber,'defaultaxesposition',[0.10 0.1 0.60 0.80])
zplaneHndl = subplot(2,1,1);
set(zplaneHndl,'Tag','z-Plane');
set(gca, ...
	'Units','normalized', ...
	'XTick',[],'YTick',[], ...
	'Box','on');
responseHndl = subplot(2,1,2);
set(gca, ...
	'Units','normalized', ...
	'XTick',[],'YTick',[], ...
	'Box','on');
set(responseHndl,'Tag','response');

%====================================
% Information for all buttons (and menus)
labelColor=[0.8 0.8 0.8];
yInitPos=0.90;
menutop=0.95;
btnTop = 0.6;
top=0.75;
left=0.785;
btnWid=0.175;
btnHt=0.06;
textHeight = 0.05;
textWidth = 0.07;

% Spacing between the button and the next command's label
spacing=0.019;

%====================================
% The CONSOLE frame
frmBorder=0.019; frmBottom=0.04; 
frmHeight = 0.92; frmWidth = btnWid;
yPos=frmBottom-frmBorder;
frmPos=[left-frmBorder yPos frmWidth+2*frmBorder frmHeight+2*frmBorder];
h=uicontrol( ...
	'Style','frame', ...
	'Units','normalized', ...
	'Position',frmPos, ...
	'BackgroundColor',[0.5 0.5 0.5]);

%====================================
% fft radio button
btnTop = menutop-spacing;
btnNumber=1;
yPos=btnTop-(btnNumber-1)*(btnHt+spacing);
labelStr='FFT';
callbackStr='cztdemo(''radio'',1);';

% Generic button information
btnPos=[left yPos-btnHt btnWid btnHt];
btn1Hndl=uicontrol( ...
	'Style','radiobutton', ...
	'Units','normalized', ...
	'Position',btnPos, ...
	'String',labelStr, ...
	'value',0, ...
	'Callback',callbackStr,...
    'Tag',labelStr,...
    'TooltipString','Fast Fourier Transform');

%====================================
% czt radio button
btnTop = menutop-spacing;
btnNumber=2;
yPos=btnTop-(btnNumber-1)*(btnHt+spacing);
labelStr='CZT';
callbackStr='cztdemo(''radio'',2);';

% Generic button information
btnPos=[left yPos-btnHt btnWid btnHt];
btn2Hndl=uicontrol( ...
	'Style','radiobutton', ...
	'Units','normalized', ...
	'Position',btnPos, ...
	'String',labelStr, ...
	'value',1, ...
	'Callback',callbackStr,...
    'Tag',labelStr,...
    'TooltipString','Chirp z-Transform');

yPos = yPos - spacing;

%===================================
% Sampling Frequency
top = yPos - btnHt - spacing;
labelWidth = frmWidth-textWidth-.01;
labelBottom=top-textHeight;
labelLeft = left;
labelRight = left+btnWid;
labelPos = [labelLeft labelBottom labelWidth textHeight];
h = uicontrol( ...
	'Style','text', ...
	'Units','normalized', ...
	'Position',labelPos, ...
	'Horiz','left', ...
	'String','Fs', ...
	'Interruptible','off', ...
	'BackgroundColor',[0.5 0.5 0.5], ...
	'ForegroundColor','white',...
    'TooltipString','Sampling Frequency');
% Text field
textPos = [labelRight-textWidth labelBottom textWidth textHeight];
callbackStr = 'cztdemo(''Fs'')';
FsHndl = uicontrol( ...
	'Style','edit', ...
	'Units','normalized', ...
	'Position',textPos, ...
	'Horiz','right', ...
	'Background','white', ...
	'Foreground','black', ...
	'String','1000','Userdata',1000, ...
	'callback',callbackStr,...
    'Tag','Fs');

%===================================
% Wmin frequency (1) label and text field
labelBottom=top-2*textHeight-spacing;
labelLeft = left;
labelPos = [labelLeft labelBottom labelWidth textHeight];
h = uicontrol( ...
	'Style','text', ...
	'Units','normalized', ...
	'Position',labelPos, ...
	'String','Fmin', ...
	'Horiz','left', ...
	'Interruptible','off', ...
	'Background',[0.5 0.5 0.5], ...
	'Foreground','white',...
    'TooltipString','Lower Frequency Bound');
% Text field
textPos = [labelRight-textWidth labelBottom textWidth textHeight];
callbackStr = 'cztdemo(''Wmin'')';
WminHndl = uicontrol( ...
	'Style','edit', ...
	'Units','normalized', ...
	'Position',textPos, ...
	'Horiz','center', ...
	'Background','white', ...
	'Foreground','black', ...
	'String','200','Userdata',200, ...
	'Callback',callbackStr,...
    'Tag','Fmin');

%===================================
% Wmax frequency label and text field
labelBottom=top-3*textHeight-2*spacing;
labelLeft = left;
labelPos = [labelLeft labelBottom labelWidth textHeight];
h = uicontrol( ...
	'Style','text', ...
	'Units','normalized', ...
	'Position',labelPos, ...
	'String','Fmax', ...
	'Horiz','left', ...
	'Interruptible','off', ...
	'Background',[0.5 0.5 0.5], ...
	'Foreground','white',...
    'TooltipString','Upper Frequency Bound');
% Text field
textPos = [labelRight-textWidth labelBottom textWidth textHeight];
callbackStr = 'cztdemo(''Wmax'')';
WmaxHndl = uicontrol( ...
	'Style','edit', ...
	'Units','normalized', ...
	'Position',textPos, ...
	'Horiz','center', ...
	'Background','white', ...
	'Foreground','black', ...
	'String','350','Userdata',350, ...
	'Callback',callbackStr,...
    'Tag','Fmax');

%===================================
% Number of points label and text field
labelBottom=top-4*textHeight-3*spacing;
labelLeft = left;
labelPos = [labelLeft labelBottom labelWidth textHeight];
h = uicontrol( ...
	'Style','text', ...
	'Units','normalized', ...
	'Position',labelPos, ...
	'String','Npoints', ...
	'Horiz','left', ...
	'Interruptible','off', ...
	'Background',[0.5 0.5 0.5], ...
	'Foreground','white',...
     'TooltipString','Number of Points of Interest');
% Text field
textPos = [labelRight-textWidth labelBottom textWidth textHeight];
callbackStr = 'cztdemo(''points'')';
pointsHndl = uicontrol( ...
	'Style','edit', ...
	'Units','normalized', ...
	'Position',textPos, ...
	'Horiz','center', ...
	'Background','white', ...
	'Foreground','black', ...
	'String','300','Userdata',300, ...
	'Callback',callbackStr,...
    'Tag','points');

%===================================
% Radius (1) label and text field
labelBottom=top-5*textHeight-4*spacing;
labelLeft = left;
labelPos = [labelLeft labelBottom labelWidth textHeight];
h = uicontrol( ...
	'Style','text', ...
	'Units','normalized', ...
	'Position',labelPos, ...
	'String','R1', ...
	'Horiz','left', ...
	'Interruptible','off', ...
	'Background',[0.5 0.5 0.5], ...
	'Foreground','white',...
     'TooltipString','Radius 1');
% Text field
textPos = [labelRight-textWidth labelBottom textWidth textHeight];
callbackStr = 'cztdemo(''radius1'')';
radius1Hndl = uicontrol( ...
	'Style','edit', ...
	'Units','normalized', ...
	'Position',textPos, ...
	'Horiz','center', ...
	'Background','white', ...
	'Foreground','black', ...
	'String','1','Userdata',1, ...
    'Tag','Radius1',...
	'Callback',callbackStr);

%===================================
% Radius (2) label and text field
labelBottom=top-6*textHeight-5*spacing;
labelLeft = left;
labelPos = [labelLeft labelBottom labelWidth textHeight];
h = uicontrol( ...
	'Style','text', ...
	'Units','normalized', ...
	'Position',labelPos, ...
	'String','R2', ...
	'Horiz','left', ...
	'Interruptible','off', ...
	'Background',[0.5 0.5 0.5], ...
	'Foreground','white',...
     'TooltipString','Radius 2');
% Text field
textPos = [labelRight-textWidth labelBottom textWidth textHeight];
callbackStr = 'cztdemo(''radius2'')';
radius2Hndl = uicontrol( ...
	'Style','edit', ...
	'Units','normalized', ...
	'Position',textPos, ...
	'Horiz','center', ...
	'Background','white', ...
	'Foreground','black', ...
	'String','1','Userdata',1, ...
    'Tag','Radius2',...
	'Callback',callbackStr);

%====================================
% The INFO button
labelStr='Info';
callbackStr='cztdemo(''infobtn'')';
helpHndl=uicontrol( ...
	'Style','pushbutton', ...
	'Units','normalized', ...
	'Position',[left frmBottom+btnHt+spacing btnWid btnHt], ...
	'String',labelStr, ...
	'Callback',callbackStr,...
    'Tag',labelStr);

%====================================
% The CLOSE button
labelStr='Close';
callbackStr='close(gcf)';
closeHndl=uicontrol( ...
	'Style','pushbutton', ...
	'Units','normalized', ...
	'Position',[left frmBottom btnWid btnHt], ...
	'String',labelStr, ...
	'Callback',callbackStr,...
    'Tag',labelStr);

ud.hndlList=[zplaneHndl responseHndl FsHndl WminHndl WmaxHndl pointsHndl ...
		radius1Hndl radius2Hndl btn1Hndl btn2Hndl helpHndl closeHndl];
	
set(figNumber, ...
		'Visible','on', ...
		'UserData',ud);
	
design
set(0,'showhiddenhandles',shh);
	
function Fs
ud = get(gcf,'UserData');
hWmax = findobj(ud.hndlList,'Tag','Fmax');
Wmax = get(hWmax,'UserData');
v = get(gco,'Userdata');
s = get(gco,'String');
vv = eval(s,num2str(v));
if vv<Wmax*2, vv = v; end
vv = round(vv*100)/100;
set(gco,'Userdata',vv,'String',num2str(vv))
design

function Wmin
ud = get(gcf,'UserData');
hWmax = findobj(ud.hndlList,'Tag','Fmax');
Wmax = get(hWmax,'UserData');
v = get(gco,'Userdata');
s = get(gco,'String');
vv = eval(s,num2str(v));
if vv>=Wmax, vv = v; end
vv = round(vv*100)/100;
set(gco,'Userdata',vv,'String',num2str(vv))
design

function Wmax
ud = get(gcf,'UserData');
hWmin = findobj(ud.hndlList,'Tag','Fmin');
Wmin = get(hWmin,'UserData');
v = get(gco,'Userdata');
s = get(gco,'String');
vv = eval(s,num2str(v));
if vv<=Wmin, vv = v; end
vv = round(vv*100)/100;
set(gco,'Userdata',vv,'String',num2str(vv))
design

function points
v = get(gco,'Userdata');
s = get(gco,'String');
vv = eval(s,num2str(v));
ud=get(gcf,'Userdata');  
if vv<length(ud.filter.den), vv = v; end
vv = round(vv*100)/100;
set(gco,'Userdata',vv,'String',num2str(vv))
design

function radius1
v = get(gco,'Userdata');
s = get(gco,'String');
vv = eval(s,num2str(v));
if vv<=0 | vv>10, vv = v; end
vv = round(vv*1000)/1000;
set(gco,'Userdata',vv,'String',num2str(vv))
design

function radius2
v = get(gco,'Userdata');
s = get(gco,'String');
vv = eval(s,num2str(v));
if vv<=0 | vv > 10, vv = v; end
vv = round(vv*1000)/1000;
set(gco,'Userdata',vv,'String',num2str(vv))
design

function radio(s)
hFig=gcf;
ud=get(hFig,'Userdata');
axHndl=gca;
rbtnHndl=findobj(ud.hndlList,'style','radiobutton');
set(rbtnHndl,'value',0) % Disable all the buttons
set(rbtnHndl(s),'value',1) % Enable selected button
radiusHndl(1)=findobj(ud.hndlList,'style','edit','Tag','Radius1');
radiusHndl(2)=findobj(ud.hndlList,'style','edit','Tag','Radius2');
if strcmp('CZT',get(rbtnHndl(s),'String')),
   set(radiusHndl,'Enable','on','BackgroundColor','white');
else
   parentHndl=get(radiusHndl(1),'Parent');
   bgcolor=get(parentHndl,'Color');
   set(radiusHndl,'Enable','off','BackgroundColor',bgcolor);
end
drawnow
design

function infobtn
    set(gcf,'pointer','arrow')
	ttlStr = get(gcf,'Name');
	hlpStr= [...
         'This demo lets you explore two different transform algorithms and examine  '
         'their performance. They are                                                '
         '   FFT      - the Fast Fourier Transform                                   '
         '   CZT      - the Chirp-Z Transform                                        '
         '                                                                           '
         'The upper plot shows the z-plane, and the lower plot shows the transform of'
         'a bandpass elliptic digital filter on the points within the wedge shown on '
         'the upper plot. The filter has a passband from .4 to .7 of the Nyquist     '
         'frequency (Nyquist = Fs/2).                                                '
         '                                                                           '
         'The FFT computes the Z-transform on equally spaced points around the unit  '
         'circle.                                                                    '
         '                                                                           '
         'The CZT computes the Z-transform on a spiral or "chirp" contour.  The      '
         'contour is defined by initial frequency Fmin and radius R1, and final      '
         'frequency Fmax and radius R2. Fs is the sampling frequency.                '
         '                                                                           '
         'Fmin and Fmax define a "wedge" of the unit  circle.                        '
         '                                                                           '
         'Npoints is the number of Z-transform points computed on the unit circle in '
         'the wedge defined by Fmin and Fmax.                                        '
         '                                                                           '  
         'With FFT, the length of the transform is Npoints*Fs/(Fmax-Fmin), which     '
         'computes Npoints points in the range Fmin to Fmax. If you are interested in'
         'a small frequency range, the CZT is more efficient because it "zooms in" on' 
         'the range you are interested in and only computes Npoints.                 '
        ];

    myFig = gcf;
    helpwin(hlpStr,ttlStr);
    
    

% [EOF]