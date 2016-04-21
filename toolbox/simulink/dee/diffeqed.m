function diffeqed(),
%DIFFEQED The DEE editor.
%   DIFFEQED constructs and manages the DEE editor dialog.

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.24 $
%   Revised Karen D. Gondoly 7-12-96

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get name of system and make it the title for the system editor
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figtitle = gcb;

bh = get_param(figtitle,'Handle');

% check to see if there is already a DEE control panel up.
% If there is a figure and it has a good handle just bring if forward.
% If it has a stale handle, then close it.
[flag,fig]  = deeflag(figtitle,'1');
if flag,
 figUD       = get(fig,'UserData');
 if ~isempty(figUD),                 % Check if DEE editor was deleted
   StaleHandle = (bh ~= figUD(12));
   if StaleHandle,
     close(fig);
   else
    figure(fig);
    return
  end
 end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get the current system
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[sestring,icstring,sostring,nistring,numse,numso,numni] = getsys(figtitle);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get current system's name
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
currentname = get_param(figtitle,'Mask Display');
indquote=findstr('''',currentname);
currentname=currentname(indquote(1)+1:indquote(2)-1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Setup control panel
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% get stanvdardized parameters for text and button sizes
params = [ 3 3 270 25];
xmargin = params(1);
ymargin = params(2);
butheight = params(4);
grey = [ .75 .75 .75];
darkgrey = [ .5 .5 .5];
titlebartextcolor = 'w';

% create figure window for control panel
figl = 100; figb = 100; figw = 390; figh = 430;
panelposi = [ figl figb figw figh];
fig = figure('Numbertitle','off',...
             'Name',figtitle,...
             'Position',panelposi,...
             'Visible','off',...
             'Menubar','none',...
             'Color',grey);

xmargin = xmargin/figw;
ymargin = ymargin/figh;

% setup Revert, Rebuild and Done buttons for control panel
% normalize position coords for buttons
framex = xmargin;
framew = 1-2*(xmargin);

w = .16;
h = butheight/figh;

%---UnComment next lines when returning Linearize function
%butmarg = (1-5*w-3*butspace)/2
%butspace = .01;
%x = butmarg;
%x2 = x+w+butspace;
%x3 = x2+w+butspace;
%x4 = x3+w+butspace;
%x5 = x4+w+butspace;
%---End, uncomment

%---Comment out next lines when returning Linearize function
x = (figw/13-1)/figw;
x2 = ((figw/13-1)*4)/figw;
x3 = ((figw/13-1)*7)/figw;
x5=((figw/13-1)*10)/figw;
%---End, comment out

y = .1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%setup edit windows for state equations, outputs, # inputs, and initial
%  conditions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% the differences of Min and Max need to be greater than 1 so that the edit
% windows are multiple lines

% editcolor = background color for the edit blocks.
editcolor = 'w';

% first define parameters

texth = .04;
xtext = .02;
textw = framew-2*xmargin;

namew = .2;
nameh = texth;
namex = xtext;
namey = 1-3*texth-2*ymargin;

nameeditw = 1-namex-namew-4*xmargin;
nameedith = texth+.01;
nameeditx = namex+namew;
nameedity = namey;

inputx = xtext;
inputy = namey - texth - 2*ymargin;
inputw = namew;
inputh = nameh;

inputeditx = inputx+inputw;
inputedity = inputy;
inputeditw = .2;
inputedith = texth+.01;

sex = .13;
sey = .45;
sew = .6;
seh = .3;

icx = sex + sew + 4*xmargin;
icy = sey;
icw = inputeditw;
ich = seh;

soh = .15;
sox = sex;
soy = sey-soh-2*texth-2*ymargin;
%sow = 1-sox-14*xmargin;
sow  = icx+icw-sox;

maxlines = 1e10;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% setup axes and text associated with edit objects and the status field
%     and define textcolor
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
textaxes = axes('posi',[0 0 1 1],'vis','off');
textcolor = 'black';

statusx = xtext;
statusy = .02;
statusw = framew-2*xmargin;
statush = texth;

tsetox = sex;
tsetoy = sey-texth;
tsetow = sew;
tsetoh = texth;

tictox = icx;
tictoy = icy-texth;
tictow = icw;
tictoh = texth;

framey = ymargin;
frameh = .07;

tsex = xtext;
tsey = sey+seh/2;
tsew = sex-.025-2*xmargin;
tseh = texth;

tsox = xtext;
tsoy = soy+soh/2;
tsow =  tsew;
tsoh = texth;


ticy = icy+ich;
ticw = tsow;
tich = texth;
ticx = icx+icw/2-ticw/2;

setitx = sex;
setity = sey+seh;
setitw = sew;
setith = texth;

sotitx = sox;
sotity = soy+soh;
sotitw = sow;
sotith = texth;

deetitx = xtext;
deetity = 1-texth-3*ymargin;
deetitw = textw;
deetith = texth;

deetitxf = framex;
deetityf = deetity-2*ymargin;
deetitwf = framew;
deetithf = frameh;

mainx = framex;
mainy = y+h+(y-framey-frameh);
mainw = framew;
mainh = deetityf-mainy;

main2x = framex;
main2y = mainy;
main2w = sex+sew+(icx-(sex+sew))/2;
main2h = deetityf-mainy;

main3x = framex;
main3y = soy+soh+(sey-(soy+soh))/2;
main3w = framew;
main3h = inputy-(inputy-(setity+setith))/2-main3y;

mainframe = uicontrol('Style','Frame',...
                      'Units','Normal',...
                      'BackGroundColor',grey,...
                      'Position',[ mainx mainy mainw mainh ]);

%mainframe2 = uicontrol('Style','Frame',...
%                       'Units','Normal',...
%                       'BackGroundColor',grey,...
%                       'Position',[ main2x main2y main2w main2h ]);

mainframe3 = uicontrol('Style','Frame',...
                       'Units','Normal',...
                       'BackGroundColor',grey,...
                       'Position',[ main3x main3y main3w main3h ]);

% se = handle to system equations edit block
se = uicontrol('Style','Edit',...
               'BackgroundColor',editcolor,...
               'Units','Normal',...
               'Callback','deeupdat',...
               'String',sestring,...
               'Min',0,...
               'Max',maxlines,...
               'horiz','left',...
               'Position',[ sex sey sew seh ]);

% so = handle to system outputs edit block
so = uicontrol('Style','Edit',...
               'BackgroundColor',editcolor,...
               'Units','norm',...
               'Callback','deeupdat',...
               'String',sostring,...
               'Min',0,...
               'Max',maxlines,...
               'horiz','left',...
               'Position',[ sox soy sow soh ]);

% ic = handle to system initial conditions edit block
ic = uicontrol('Style','Edit',...
               'Backgroundcolor',editcolor,...
               'Units','Normal',...
               'Callback','deeupdat',...
               'String',icstring,...
               'Min',0,...
               'Max',maxlines,...
               'horiz','left',...
               'Position',[ icx icy icw ich ]);

%tni = handle to text associated with ni handle
tni = uicontrol('Style','Text',...
                'Units','Normal',...
                'HorizontalAlignment','Left',...
                'BackGroundColor',grey,...
                'String','# of inputs: ',...
                'Position',[ inputx inputy inputw inputh]);

%ni = handle to number of inputs edit block
ni = uicontrol('Style','Edit',...
               'BackgroundColor',editcolor,...
               'Units','Normal',...
               'HorizontalAlignment','Left',...
               'String',nistring,...
               'Callback','deeupdat',...
               'Tag','NUM_OF_INPUTS',...
               'horiz','left', ...
               'Position',[ inputeditx inputedity ...
                            inputeditw inputedith ]);

%nh = handle to name field
nh = uicontrol('Style','Edit',...
               'Units','Normal',...
               'BackgroundColor',editcolor,...
               'HorizontalAlignment','Left',...
               'String',currentname,...
               'Callback','deechgnm',...
               'horiz','left',...
               'Position',[ nameeditx nameedity ...
                            nameeditw nameedith ]);

% hb = handle for Help Button
hb = uicontrol('Style','Push',...
               'Units','Normal',...
               'String','Help',...
               'CallBack','deehelp',...
               'Position',[x y w h]);

% tb = handle for toasting the system and rebuilding from sratch
tb = uicontrol('Units','Normal',...
               'Position',[x2,y,w,h],...
               'String','Rebuild',...
               'Callback','toast');

% rb = handle for Undo button
rb = uicontrol('Units','Normal',...
          'Position',[x3,y,w,h],...
          'String','Undo',...
          'Callback','revertit');

%---Uncomment the following lines to add the Linearize option.
%---Make sure to search for "Linearize" and make all necessary code changes

% linb = handle for setting the system to linear or nonlinear
%DefaultStr = 'mat2str(zeros(1,str2num(get(findobj(gcf,''Tag'',''NUM_OF_INPUTS''),''String''))))';
%LMCB = ['if (get(gco,''UserData'')), fevaldlg(''DEE Linearization Dialog'',''Enter initial input vector, u0 (operating point):'',',DefaultStr,',''deelin''); else, deerestr; end'];
%linb   = uicontrol('Units','Normal',...
%                 'Position',[x4,y,w,h],...
%                 'String','Linearize',...
%                 'UserData',1,...
%                 'Callback',LMCB);

%---Comment out the next line when returning the Linearzie option
linb=-1;

% State Equation and Output Equation restore objects.
blah = uicontrol(...
                 'Style','Text',...
                 'Visible','Off',...
                 'Tag','SE_Restore');

blah = uicontrol(...
                 'Style','Text',...
                 'Visible','Off',...
                 'Tag','SO_Restore');

% db = handle for Done button
db = uicontrol('Units','Normal',...
          'Position',[x5,y,w,h],...
          'String','Done',...
          'Callback','set(gcf,''Visible'',''Off'')');


% setup status text field which displays the status of the current system
%     arguments

fst = uicontrol('Style','Frame',...
                'Units','Normal',...
                'BackGroundColor',darkgrey,...
                'Position',[framex framey framew frameh]);

% st = handle to status text
st = uicontrol('Style','Text',...
               'Units','Normal',...
               'String','Status: Initializing...',...
               'HorizontalAlignment','Left',...
               'BackGroundColor',darkgrey,...
               'ForeGroundColor','white',...
               'Position',[ statusx statusy statusw statush ]);


% setup totals readout text handles for state equations and initial
%    conditions
tseto = uicontrol('Style','Text',...
                  'Units','Normal',...
                  'String','Number of States = ',...
                  'BackGroundColor',grey,...
                  'HorizontalAlignment','Left',...
                  'Position',[ tsetox tsetoy tsetow tsetoh ]);

ticto = uicontrol('Style','Text',...
                  'Units','Normal',...
                  'String','Total = ',...
                  'BackGroundColor',grey,...
                  'HorizontalAlignment','Left',...
                  'Position',[ tictox tictoy tictow tictoh]);

% tse = handle to text associated with se handle
tse = uicontrol('Style','Text',...
                'Units','Normal',...
                'String','dx/dt= ',...
                'BackGroundColor',grey,...
                'HorizontalAlignment','Left',...
                'Position',[ tsex tsey tsew tseh ]);

% tso = handle to text associated with so handle
tso = uicontrol('Style','Text',...
                'Units','Normal',...
                'String','y = ',...
                'BackGroundColor',grey,...
                'HorizontalAlignment','Left',...
                'Position',[ tsox tsoy tsow tsoh ]);

%tic = handle to text associated with ic handle
tic = uicontrol('Style','Text',...
                'Units','Normal',...
                'String','x0',...
                'BackGroundColor',grey,...
                'HorizontalAlignment','Center',...
                'Position',[ ticx ticy ticw tich ]);

% tnh = handle to the name
tnh = uicontrol('Style','Text',...
                'Units','Normal',...
                'String','Name: ',...
                'HorizontalAlignment','Left',...
                                'BackGroundColor',grey,...
                'Position',[ namex namey ...
                             namew nameh] );

setit = uicontrol('Style','Text',...
                  'Units','Normal',...
                  'String','First order equations, f(x,u):',...
                  'HorizontalAlignment','Left',...
                  'BackGroundColor',grey,...
                  'Position',[ setitx setity setitw setith ]);

sotit = uicontrol('Style','Text',...
                  'Units','Normal',...
                  'String','Output Equations, f(x,u):',...
                  'HorizontalAlignment','Left',...
                  'BackGroundColor',grey,...
                  'Position',[ sotitx sotity sotitw sotith ]);

deetitf = uicontrol('Style','Frame',...
                    'Units','Normal',...
                   'BackGroundColor',darkgrey,...
                   'Position',[ deetitxf deetityf deetitwf deetithf ]);

deetit = uicontrol('Style','Text',...
                   'Units','Normal',...
                   'String','Differential Equation Editor     (Fcn block syntax)',...
                   'HorizontalAlignment','Left',...
                   'ForeGroundColor',titlebartextcolor,...
                   'BackGroundColor',darkgrey,...
                   'Position',[ deetitx deetity deetitw deetith ]);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% initialize UserData in edit block objects to the current string values
%     within them
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sestring = get(se,'String');
set(se,'UserData',sestring);

sostring = get(so,'String');
set(so,'UserData',sostring);

icstring = get(ic,'String');
set(ic,'UserData',icstring);

nistring = get(ni,'String');
set(ni,'UserData',nistring);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set UserData parameter to contain the handles to the edit windows
%     and the status text field for callbacks from deeupdat
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(fig,'UserData',[se so ic ni st tseto ticto rb tb db nh bh linb]);

set(fig,'vis','on');
set(st,'String','Status: READY');
drawnow;
deeupdat;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Turn the Handlevisibility callback so as not to draw on the DEE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(fig,'HandleVisibility','callback')
