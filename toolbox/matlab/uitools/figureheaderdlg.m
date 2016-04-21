function figureheaderdlg(fig)
% FIGUREHEADERDLG Show figure header dialog
%    FIGUREHEADERDLG edits the print header for the current figure.
%    FIGUREHEADERDLG(FIG) edits the print header for figure FIG.
%
%    See also PRINT

%   Copyright 1984-2003 The MathWorks, Inc.

if nargin == 0,
  fig = gcf;
end

uh = 22; % uicontrol space per text row
fus = 8; % figure/uicontrol spacing
uus = 8; % uicontrol/uicontrol spacing
lys = 2; % label/uicontrol y spacing
lyd = -10; % label y displacement

% DIALOG FIGURE
fpos    = get(0,'DefaultFigurePosition');
fpos(3) = 300;
fpos(4) =  250;
fpos    = getnicedialoglocation(fpos, get(0,'DefaultFigureUnits'));

dlg = dialog(                                    ...
    'Visible'         ,'off'                      , ...
    'Name'            ,'Figure Page Header'         , ...
    'Pointer'         ,'arrow'                    , ...
    'Position'        ,fpos                     , ...
    'Resize'          ,'on'                       , ...
    'IntegerHandle'   ,'off'                      , ...
    'WindowStyle'     ,'normal'                   , ...
    'HandleVisibility','callback'                 , ...
    'Tag'             ,'FigurePageHeaderDialog'     ...
    );

set(dlg,'KeyPressFcn',{@doFigureKeyPress, dlg});

utop = fpos(4) - fus;
uleft = fus;

% get header information
hs = getappdata(fig,'PrintHeaderHeaderSpec');
if isempty(hs)
  hs = struct('dateformat','none',...
              'string','',...
              'fontname','Times',...
              'fontsize',12,...          % in points
              'fontweight','normal',...
              'fontangle','normal',...
              'margin',72);            % in points
end

% String text box 
% label
HeaderStringLabel = uicontrol(dlg,...
    'style','text',...
    'position',[uleft, utop-uh+lyd, 120, uh],...
    'horizontalalignment','left',...
    'string','Header String:');
utop = utop - uh - lys;
% edit box
HeaderStringEdit = uicontrol(dlg,...
    'style','edit',...
    'position',[uleft, utop-uh, fpos(3) - 2*(fus), uh ],...
    'horizontalalignment','left',...
    'backgroundcolor',[1 1 1],...
    'callback',{@doHeaderStringEditCallback, dlg},...
    'string',hs.string);
utop = utop - uh - uus;

% Date format
% label
DateComboLabel = uicontrol(dlg,...
    'style','text',...
    'position',[uleft, utop-uh+lyd, 120, uh],...
    'horizontalalignment','left',...
    'string','Date Format:');
utop = utop - uh - lys;
liststring = {...
    'none',...
    'dd-mmm-yyyy HH:MM:SS',...   01-Mar-2000 15:45:17
    'dd-mmm-yyyy',...            01-Mar-2000
    'mm/dd/yy',...               03/01/00
    'mm/dd',...                  03/01
    'ddd',...                    Wed
    'yyyy',...                   2000
    'HH:MM:SS',...               15:45:17
    'HH:MM:SS PM',...            3:45:17 PM
    'HH:MM PM',...               3:45 PM
    'dd/mm/yy',...               01/03/00
    'mm/dd/yyyy',...             03/01/2000
    'yyyy-mm-dd',...             2000-03-01
    'yyyy-mm-dd HH:MM:SS'}; %    2000-03-01 15:45:17
DateCombo = uicontrol(dlg,...
    'style','popupmenu',...
    'position',[uleft, utop-uh, 180, uh],...
    'string',liststring,...
    'backgroundcolor','w',...
    'max',1,...
    'tag','listbox',...
    'value',find(strcmp(hs.dateformat,liststring)), ...
    'callback', {@doDateComboClick, dlg});
% Header Font
HeaderStringEdit = uicontrol(dlg,...
    'style','pushbutton',...
    'position',[fpos(3) - fus - 80, utop-uh, 80, uh],...
    'string','Header Font...',...
    'callback', {@doFontClick, dlg});
utop = utop - uh - uus;

% Header Preview
% label
PreviewLabel = uicontrol(dlg,...
    'style','text',...
    'position',[uleft, utop-uh, 100, 12],... 
    'horizontalalignment','left',...
    'string','Preview:');
utop = utop - uh - lys;
% preview area
pwid =  fpos(3) - 2*(fus);
pht = (2*uh)+4;

PreviewAxes = hg.axes(...
    'parent',dlg,...
    'xtick',[],'ytick',[],...
    'xlim',[0 1],'ylim',[0 1],...
    'xcolor','w','ycolor','w',...  
    'units','pixels',...
    'position',[uleft, utop-pht, pwid, pht ]);
PreviewDateText = hg.text(...
    'parent',PreviewAxes,...
    'verticalalignment','middle',...
    'horizontalalignment','right',...
    'clipping','on');
PreviewStringText = hg.text(...
    'parent',PreviewAxes,...
    'verticalalignment','middle',...
    'horizontalalignment','left',...
    'clipping','on');
utop = utop - pht - uus;

% OK, Cancel Buttons
Btn1 = 'OK';
Btn2 = 'Cancel';

BtnYOffset  = 10;
DefBtnWidth = 56;
BtnHeight   = uh;
BtnWidth    = DefBtnWidth;
BtnMargin   = 1.4;

% Find the max extents of the button texts, and use those:
ExtControl=uicontrol(dlg     , ...
    'Style'    ,'pushbutton', ...
    'String'   ,' '           ...
    );
set (ExtControl, 'String', Btn1);
BtnExtent = get (ExtControl, 'Extent');
BtnWidth = max (BtnWidth, BtnExtent(3)+8);
set (ExtControl, 'String', Btn2);
BtnExtent = get (ExtControl, 'Extent');
BtnWidth = max (BtnWidth, BtnExtent(3)+8);
BtnHeight = max (BtnHeight, BtnExtent(4)*BtnMargin);
delete (ExtControl);

DefOffset = 10;
BtnXOffset = [fpos(3)*0.5 - BtnWidth - DefOffset*0.5
    fpos(3)*0.5 + DefOffset*0.5];


% Define the actual buttons:
Button1 = uicontrol (dlg                 , ...
    'Style'              ,'pushbutton', ...
    'Position'           ,[ BtnXOffset(1) BtnYOffset BtnWidth BtnHeight ]  , ...
    'KeyPressFcn'        ,{@doControlKeyPress, dlg} , ...
    'CallBack'           ,{@doOK, dlg}   , ...
    'String'             ,Btn1        , ...
    'HorizontalAlignment','center'    , ...
    'Tag'                ,Btn1          ...
    );
Button2 = uicontrol (dlg                 , ...
    'Style'              ,'pushbutton', ...
    'Position'           ,[ BtnXOffset(2) BtnYOffset BtnWidth BtnHeight ]  , ...
    'KeyPressFcn'        ,{@doControlKeyPress, dlg} , ...
    'CallBack'           ,{@doCancel, dlg}   , ...
    'String'             ,Btn2        , ...
    'HorizontalAlignment','center'    , ...
    'Tag'                ,Btn2          ...
    );

% make sure we aren't off screen
movegui (dlg);

set (dlg ,'WindowStyle','modal','Visible','on');
        
d = struct(...
    'PreviewAxes',PreviewAxes,...
    'PreviewDateText',PreviewDateText,...
    'PreviewStringText',PreviewStringText,...
    'OKButton',Button1,...
    'SourceFig',fig,...
    'HeaderSpec',hs);    
setappdata(dlg,'HeaderDlgData',d);

LDrawPreviewHeader(dlg);

drawnow

uiwait (dlg);
if ishandle (dlg)
    delete (dlg);
end

%------------------------------------------------------------%
function LDrawPreviewHeader(dlg)

d = getappdata(dlg,'HeaderDlgData');
ax = d.PreviewAxes;
dt = d.PreviewDateText;
st = d.PreviewStringText;
hs = d.HeaderSpec;

set(ax,'units','points');
axpos = get(ax,'position');
datestring = ''; headerstring = '';

if ~strcmp(hs.dateformat,'none')
  datestring = datestr(now,hs.dateformat);
end
ymargin = .5;
xmargin = .1;
fontsize = hs.fontsize;
% date string
set(dt,...
    'string',datestring,...
    'fontname',hs.fontname,...
    'fontsize',fontsize,...
    'fontweight',hs.fontweight,...
    'fontangle',hs.fontangle,...
    'position',[1 - xmargin, ymargin, 0]);
% header string
hstring = hs.string;
set(st,...
    'string',hstring,...
    'fontname',hs.fontname,...
    'fontsize',fontsize,...
    'fontweight',hs.fontweight,...
    'fontangle',hs.fontangle,...
    'position',[xmargin, ymargin, 0]);
drawnow

%------------------------------------------------------------%
function doFigureKeyPress(obj, evd, f)

switch(evd.Key)
    case 'return'
        d = getappdata(f,'HeaderDlgData');
        if isequal(gcbo,d.OKButton)
            setappdata(d.SourceFig,'PrintHeaderHeaderSpec',d.HeaderSpec);            
        end
        uiresume(f);
    case 'escape'
        delete(f)
end

%------------------------------------------------------------%
function doControlKeyPress(obj, evd, f)

switch(evd.Key)
    case 'return'
        d = getappdata(f,'HeaderDlgData');
        if isequal(obj,d.OKButton)
            setappdata(d.SourceFig,'PrintHeaderHeaderSpec',d.HeaderSpec);
        end
        uiresume(f);
    case 'escape'
        delete(f);
    otherwise

end

%------------------------------------------------------------%
function doOK(obj, evd, f)

d = getappdata(f,'HeaderDlgData');
setappdata(d.SourceFig,'PrintHeaderHeaderSpec',d.HeaderSpec);
uiresume(f);

%------------------------------------------------------------%
function doCancel(obj, evd, f)

uiresume(f);

%------------------------------------------------------------%
function doDateComboClick(obj, evd, f)

d=getappdata(f,'HeaderDlgData');
hs = d.HeaderSpec;
string = get(obj,'string');
val = get(obj,'value');
hs.dateformat = string{val};
d.HeaderSpec = hs;
setappdata(f,'HeaderDlgData',d);
LDrawPreviewHeader(f);

%------------------------------------------------------------%
function doShowCheckboxCallback(obj, evd, f)

d=getappdata(f,'HeaderDlgData');
hs = d.HeaderSpec;
val = get(obj,'value');
if isequal(val,1)
    hs.show = 'on';
else
    hs.show = 'off';
end
d.HeaderSpec = hs;
setappdata(f,'HeaderDlgData',d);
LDrawPreviewHeader(f);

%------------------------------------------------------------%
function doHeaderStringEditCallback(obj, evd, f)

d=getappdata(f,'HeaderDlgData');
hs = d.HeaderSpec;
hs.string = get(obj,'string');
d.HeaderSpec = hs;
setappdata(f,'HeaderDlgData',d);
LDrawPreviewHeader(f);

%------------------------------------------------------------%
function doFontClick(obj, evd, f)

props = {'FontName','FontSize','FontUnits','FontWeight','FontAngle'};
d=getappdata(f,'HeaderDlgData');
hs = d.HeaderSpec;
s.FontName = hs.fontname;
s.FontSize = hs.fontsize;
s.FontUnits = 'points';
s.FontWeight = hs.fontweight;
s.FontAngle = hs.fontangle;
s = uisetfont(s);
if ~isequal(s,0)
  hs.fontname = s.FontName;
  hs.fontsize = s.FontSize;
  hs.fontweight = s.FontWeight;
  hs.fontangle = s.FontAngle;
  d.HeaderSpec = hs;
  setappdata(f,'HeaderDlgData',d);
  LDrawPreviewHeader(f);
end

