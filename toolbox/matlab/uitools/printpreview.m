function varargout = printpreview(varargin)
%PRINTPREVIEW  Display preview of figure to be printed
%    PRINTPREVIEW(FIG) Display preview of FIG

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.29.4.7 $  $Date: 2004/04/10 23:34:06 $

ppv_debug=false;

if nargout==1,
  varargout{1}=[];
end

% get figure
if nargin==1
  fig = varargin{1};
  if isempty(fig) || ~ishandle(fig)
    error('Invalid Figure handle.');
  end
else
  fig = gcf;
end
% save ptr
oldPtr = get(fig,'Pointer');
try
  % find or create print preview for figure
  ppwindows = findobj(allchild(0),'flat',...
                      'Tag','TMWFigurePrintPreview',...
                      'Type','Figure');
  fFound = 0;
  for p = ppwindows'
    d = getappdata(p,'PrintPreviewData');
    if ~isempty(d) && ishandle(d.fig) && d.fig==fig
      % make sure it's visible
      set(p,'Visible','on');
      d.rerender = true;
      setappdata(p,'PrintPreviewData',d);
      LRefresh(p);
      figure(p);
      fFound = 1;
    end
  end
  if ~fFound
    set(fig,'Pointer','watch');
    Dlg = LInitDlg(fig,ppv_debug);
    if nargout==1,
      varargout{1}=Dlg;
    end
    set(fig,'Pointer',oldPtr);
  end
catch
  errordlg(lasterr);
  set(fig,'Pointer',oldPtr);
end

%-----------------------------------------------------------------%
function dlg = LInitDlg(fig,ppv_debug)

dlg = figure('Name','Print Preview',...
             'IntegerHandle','off',...
             'Tag','TMWFigurePrintPreview',...
             'DoubleBuffer','on',...
             'Renderer','painters',...
             'DeleteFcn','',...
             'MenuBar','none',...
             'ToolBar','none',...
             'WindowStyle','normal',...
             'Units','pixels',...
             'Resize','on',...
             'Visible','off',...
             'NumberTitle','off');
if ~ppv_debug
  set(dlg,'Interruptible','off');
end

try
  DlgName = [xlate('Print Preview - ') LGetFigName(fig)];
  set(dlg,'Name',DlgName);
  dlgPos = LInitializeDialogPos(fig,dlg);
  % pushbuttons
  buttons(1) = uicontrol(dlg,'String','Print','Callback',{@LPrintCallback, dlg});
  buttons(2) = uicontrol(dlg,'String','Page Setup...','Callback',{@LPageSetupCallback, dlg});
  buttons(3) = uicontrol(dlg,'String','Header...','Callback',{@LHeaderCallback, dlg});
  buttons(4) = uicontrol(dlg,'String','Refresh','Callback',{@LRefreshCallback, dlg});
  buttons(5) = uicontrol(dlg,'String','Close','Callback',{@LCloseCallback, dlg});
  
  set(buttons,'Visible','off');
  scrPix = get(0,'ScreenPixelsPerInch');
  scrollW = 12 * scrPix/72;
  border = 2;
  extent = get(buttons(2),'Extent');
  buttonW = max(73.3,extent(3)+6);
  buttonH = max(24,extent(4)+4);
  headerH = buttonH + 3*border;
  % need to set the axis position explicitly the first time so
  % that the limits and page patch are set correctly
  axPos =  [ border ...
             border+scrollW ...
             dlgPos(3)-scrollW-border ...
             dlgPos(4)-scrollW-border-headerH];
  % the axes with the scrollable area holding the paper. The paper
  % is the unit square.
  a = axes(...
      'Units', 'pixels',...
      'Parent',dlg,...
      'Position', axPos,...
      'Box','on',...
      'XTick',[],...
      'YTick',[],...
      'XLimMode','manual',...
      'YLimMode','manual',...
      'Layer','bottom',...
      'Color',[.7 .7 .7],...
      'NextPlot','add',...
      'ButtonDownFcn','',...
      'Tag','PageViewAxes');
  % setting all modes to manual is faster than auto
  set(a,'ALimMode','manual','CLimMode','manual','ZLimMode','manual');

  % scrollbars
  panx = uicontrol('Parent',dlg, ...
                   'Callback',{@LPanxCallback, dlg}, ...
                   'Style','slider', ...
                   'Tag','panx', ...
                   'Value',0.5,...
                   'Visible','off');
  pany = uicontrol('Parent',dlg, ...
                   'Callback',{@LPanyCallback, dlg}, ...
                   'Style','slider', ...
                   'Tag','pany', ...
                   'Value',0.5,...
                   'Visible','off');

  % Create two lines around the edges of the page to show the "shadow".
  % They need to be created in order so that the shadow
  % doesn't extend all the way to the edge of the paper.
  shadowLine1 = line([0 1 1],[0 0 1],...
                     'LineWidth',10,...
                     'Color',[.3 .3 .3],...
                     'EraseMode','normal',...
                     'Parent',a);
  shadowLine2 = line([0 0 2],[-1 1 1],...
                     'LineWidth',10,...
                     'Color',[.7 .7 .7],...
                     'EraseMode','normal',...
                     'Parent',a);

  % Create patch for the paper background
  pagePatch = patch([0 0 1 1],[0 1 1 0],'w',...
                    'LineWidth',1,...
                    'EdgeColor',[0 0 0],...
                    'EraseMode','normal',...
                    'Parent',a);
  % the image for the printed figure
  imHG = image([0 1],[0 1],[],...
               'EraseMode','normal',...
               'Parent',a);
  % add a line to mark the edge of the paper in case the figure
  % image runs over
  pageEdge = line(...
      [0 0 1 1 0],[0 1 1 0 0],...
      'LineWidth',0.5,...
      'LineStyle',':',...
      'EraseMode','none',...
      'Color',[0 0 0],...
      'Visible','off',...
      'Parent',a);        
  % header text objects
  hdText = text('Parent',a,...
                'verticalalignment','top',...
                'horizontalalignment','right',...
                'clipping','on');
  hsText = text('Parent',a,...
                'verticalalignment','top',...
                'horizontalalignment','left',...
                'clipping','on');
  
  d = struct(...
      'dlg',dlg,...
      'fig',fig,...
      'ax',a,...        
      'border',border,...
      'scrollW',scrollW,...
      'headerH',headerH,...
      'buttonH',buttonH,...
      'buttonW',buttonW,...
      'buttons',buttons,...
      'panx',panx,...
      'pany',pany,...
      'shadowLines',[shadowLine1 shadowLine2],...
      'pagePatch',pagePatch,...
      'pageEdge',pageEdge,...
      'fit',[],...  % matrix for fit-to-window image
      'zoom',[],... % matrix for zoomed-in image
      'imHG',imHG,...
      'headerStringText',hsText,...
      'headerDateText',hdText,...
      'fitToWindowScale',0,...
      'zoomScale',2,...
      'viewMode','fit',... % 'fit' or 'zoom'
      'pan','off',...
      'last_drag_point',[],...
      'rerender',true);    
  setappdata(dlg,'PrintPreviewData',d);
  
  set(dlg,'ResizeFcn',{@LResizeCallback, dlg},...
          'HandleVisibility','callback');
  % set pointer to +mag glass
  setptr(dlg,'glassplus');
  % set windowbuttondownfcn to zoom
  set(dlg,'WindowButtonDownFcn',{@LWButtonDown, dlg});
  % set windowbuttonmotionfcn to wbmotion
  set(dlg,'WindowButtonMotionFcn',{@LWButtonMotion, dlg});
  % set windowbuttonupfcn
  set(dlg,'WindowButtonUpFcn',{@LWButtonUp, dlg});
  % add beingdestroyed listener to source figure
  if ~isprop(fig,'PrintpreviewListeners')
    l = schema.prop(fig,'PrintpreviewListeners','MATLAB array');
    l.AccessFlags.Serialize = 'off';
    l.Visible = 'off';
  end
  cls = classhandle(handle(fig));
  lis.deleted = handle.listener(handle(fig), 'ObjectBeingDestroyed', {@LSourceFigureBeingDestroyed,dlg});
  set(handle(fig),'PrintpreviewListeners',lis);    

  LRefresh(dlg);
  
catch
  lasterr
  if ishandle(dlg)
    delete(dlg)
  end
end

%-----------------------------------------------------------------%
function LRefresh(dlg)

if ~ishandle(dlg) || strcmp(get(dlg,'BeingDeleted'),'on')
    return;
end
d = getappdata(dlg,'PrintPreviewData');
if ~ishandle(d.fig), return; end
set(dlg,'Pointer','watch');

dlgPos = get(dlg,'Position'); % in pixels

border = d.border;
scrollW = d.scrollW;
headerH = d.headerH;

% calculate Axes Position
axPos =  [ border ...
    border+scrollW ...
    dlgPos(3)-scrollW-border ...
    dlgPos(4)-scrollW-border-headerH];
% enforce minimum height
if axPos(4)<10 || axPos(3)<20
    return
end
% calculate button positions
btnPos = [border axPos(2)+axPos(4)+border d.buttonW d.buttonH];
nBtns = length(d.buttons);
btnPosV = ones(length(d.buttons),1)*btnPos;
% distribute
btnPosV(:,1) = btnPosV(:,1) + (d.buttonW+border)*[0:nBtns-1]';
btnPosV = num2cell(btnPosV,2);

% calculate and set fit-to-window scale
axPosInch = hgconvertunits(dlg,axPos,'pixels','inches',dlg);
paperInch = LGetPaperInch(d.fig);
paperAspect = paperInch(2)/paperInch(1);
dlgAspect = axPosInch(4)/axPosInch(3);
gap = 1.2; % empty gap around paper
if paperAspect < dlgAspect
  % x direction is tight
  d.fitToWindowScale = axPosInch(3)/(gap*paperInch(1));
  xlim = [.5-.5*gap .5+.5*gap];
  height = gap*dlgAspect/paperAspect;
  ylim = [.5-.5*height, .5+.5*height];
else
  % y direction is tight
  d.fitToWindowScale = axPosInch(4)/(gap*paperInch(2));
  ylim = [.5-.5*gap .5+.5*gap];
  width = gap*paperAspect/dlgAspect;
  xlim = [.5-.5*width, .5+.5*width];
end
setappdata(dlg,'PrintPreviewData',d);

% note LRenderer calls drawnow so do not change any visible HG
% properties before this point.
if d.rerender
%  d.fit = LRerender(d.fig,d.fitToWindowScale);
  d.zoom = LRerender(d.fig,d.zoomScale);
  d.rerender = false;
end
d.fit = subsamplemex(d.zoom,d.fitToWindowScale,d.zoomScale);
setappdata(dlg,'PrintPreviewData',d);
if strcmp(d.viewMode,'fit')
  % calculate new x and ylim
  set(d.ax,'XLim',xlim,'YLim',ylim);
  set([d.panx d.pany],'Enable','off');
else
  % set the axis limits to display things at the right scale
  LSetPaper(dlg, get(d.panx,'Value'), get(d.pany,'Value'),...
            axPosInch, paperInch);
  set([d.panx d.pany],'Enable','on');
end

% set the image position
paperPos = LGetPaperPosInch(d.fig);
xdata = [paperPos(1),paperPos(1)+paperPos(3)];
ydata = [paperPos(2),paperPos(2)+paperPos(4)];
set(d.imHG,'XData',xdata./paperInch(1),'YData',ydata./paperInch(2));

% set button positions
set([d.ax d.buttons],{'Position'},{axPos, btnPosV{:}}');
set(d.buttons,'Visible','on');
% set scrollbar positions
set([d.panx d.pany],{'Position'},...
    {[border border axPos(3) scrollW] ...
    [axPos(1)+axPos(3) border+scrollW scrollW axPos(4)]}');
LDrawHeader(dlg,paperInch);
% make everything visible and set image data
set([d.pagePatch,d.shadowLines,d.pageEdge],'Visible','on');
set(d.imHG,'CData',d.(d.viewMode),'Visible','on');
set([d.headerDateText d.headerStringText d.panx,d.pany],'Visible','on');
set(dlg,'Visible','on');

%-----------------------------------------------------------------%
function LDrawHeader(dlg,paperInch)

d = getappdata(dlg,'PrintPreviewData');
if ~ishandle(d.fig), return; end
hs = getappdata(d.fig,'PrintHeaderHeaderSpec');
if isempty(hs)
  % clear string if headerspec has been removed
  set(d.headerStringText,'string','');
  set(d.headerDateText,'string','');
  return;
end
gap = hs.margin/72; % inches
topleft = [gap/paperInch(1), (paperInch(2)-gap)/paperInch(2)];
set(d.headerStringText,'Position', topleft,...
                  'units','data',...
                  'FontUnits','points');
topright = [(paperInch(1)-gap)/paperInch(1), (paperInch(2)-gap)/paperInch(2)];
set(d.headerDateText,'Position', topright,...
                  'units','data',...
                  'FontUnits','points');
if strcmp(d.viewMode,'fit')
  scale = d.fitToWindowScale;
else
  scale = d.zoomScale;
end
fontsize = hs.fontsize*scale;

datestring = '';
if ~strcmp(hs.dateformat,'none')
  datestring = datestr(now,hs.dateformat);
end
set(d.headerDateText,...
    'string',datestring,...
    'fontname',hs.fontname,...
    'fontsize',fontsize,...
    'fontweight',hs.fontweight,...
    'fontangle',hs.fontangle);
set(d.headerStringText,...
    'string',hs.string,...
    'fontname',hs.fontname,...
    'fontsize',fontsize,...
    'fontweight',hs.fontweight,...
    'fontangle',hs.fontangle);

%-----------------------------------------------------------------%
function LSetPaper(fig,x,y,axPosInch,paperInch)
% sets xlim and ylim for ppv axes at current papersize, paperposition, axes
% position, zoom scale and slider x and y.

d = getappdata(fig,'PrintPreviewData');
xLimRange = axPosInch(3)/(paperInch(1)*d.zoomScale);
yLimRange = axPosInch(4)/(paperInch(2)*d.zoomScale);
xlim = [x x] + [-xLimRange/2  xLimRange/2];
ylim = [y y] + [-yLimRange/2  yLimRange/2];
set(d.ax,'XLim',xlim,'YLim',ylim);

%-----------------------------------------------------------------%
function imap = LRerender(fig,scale)
% return print preview image for figure

pj = printjob;
pj.DriverColor = defaultprtcolor;
warnMode = warning('backtrace', 'off');
fRenderError = 0;
try
  pt = getprinttemplate(fig);
  if isempty(pt)
    pj.DriverColorSet = 1;	% Use color from print job
  else
    pj.DriverColorSet = 0;	% Use color from print template
  end
  pj.DriverClass = 'IM';
  pj.Driver = '-dzbuffer';
  % get image resolution
  res = LCalculateRenderImageSizeRes(fig,scale);
  pj.DPI = ceil(res);
  DPISwitch = ['-r' num2str(pj.DPI)];
  pj = printprepare(pj,fig);
  db = get(fig,'DoubleBuffer');
  set(fig,'DoubleBuffer','on');
  try
    if strcmpi(get(fig,'renderer'),'opengl')
      hcform = '-dopengl';
    else
      hcform = '-dzbuffer';
    end
    imap = flipdim(hardcopy(fig,hcform,DPISwitch),1);
  catch
    fRenderError = 1;
  end
  set(fig,'DoubleBuffer',db);
  pj = printrestore(pj,fig);
  if strcmp(db,'on') % need to refresh on Unix if double-buffered
    refresh(fig);
  end
catch
  fRenderError = 1;
end

warning(warnMode);
if fRenderError
  imap = [];
  f = errordlg(lasterr,'Error','modal');
  waitfor(f);
end

%-----------------------------------------------------------------%
function res = LCalculateRenderImageSizeRes(fig,scale)

res = get(0,'ScreenPixelsPerInch')*scale;
% check to see if we're about to generate a huge image
paperPos = LGetPaperPosInch(fig);
imsize = prod(res * paperPos(3:4));
alreadywarned = false;
while imsize > 8000000
  res = res/1.25;
  imsize = prod(res * paperPos(3:4));
  if ~alreadywarned
    warning(['Print Preview is rendering this page on screen at a lower ' ...
             'resolution to' sprintf('\n') 'conserve memory. ' ...
             'The quality of the printed page will not be ' ...
             'affected.']);
    alreadywarned = true;
  end
end

%-----------------------------------------------------------------%
function FigName = LGetFigName(Fig)

FigName = get(Fig,'Name');

if strcmp(get(Fig,'NumberTitle'),'on')
  if (length(FigName)>0)
    FigName = [': ' FigName];
  end
  if strcmp(get(Fig,'IntegerHandle'),'on'),
    FigName = ['Figure ' sprintf('%d',Fig) FigName];
  else
    FigName = ['Figure ' sprintf('%.16g',Fig) FigName];
  end
end
if isempty(FigName)   % no name, number title off
  if strcmp(get(Fig,'IntegerHandle'),'on'),
    FigName = ['Figure ' sprintf('%d',Fig)];
  else
    FigName = ['Figure ' sprintf('%.16f',Fig)];
  end
end

%-----------------------------------------------------------------%
function DlgPos = LInitializeDialogPos(Fig,Dlg)

fpos = hgconvertunits(Fig,get(Fig,'Position'),...
                      get(Fig,'Units'),'pixels',0);
papersize = get(Fig,'PaperSize');
orient = get(Fig,'PaperOrientation');
DlgPos = fpos;
if isequal(orient,'portrait')
  DlgPos(3) = fpos(3) * .8;
  DlgPos(1) = fpos(1) - DlgPos(3);
  DlgPos(4) = DlgPos(3) * papersize(2)/papersize(1);
else
  DlgPos(4) = fpos(4) * .8;
  DlgPos(3) = DlgPos(4) * papersize(2)/papersize(1);
  DlgPos(1) = fpos(1) - DlgPos(3);
end
DlgPos(2) = fpos(2) + fpos(4) - DlgPos(4);
for k=1:2
  if DlgPos(k)<40
    DlgPos(k)=40;
  end
end
scrsize = get(0,'ScreenSize');
for k=3:4
  if DlgPos(k)>scrsize(k)-80
    DlgPos(k) = scrsize(k)-80;
  end
end

set(Dlg,'Position',DlgPos);

%-----------------------------------------------------------------%
function LSetLim(action,dlg)
% scroll(pan) mousepan and zoom

d = getappdata(dlg,'PrintPreviewData');
uictrl = gcbo;
im = d.imHG;
a = d.ax;
switch action
 case 'panx'
  xlim = get(a,'XLim');
  val = get(uictrl,'Value');
  xhalfrange = (xlim(2)-xlim(1))/2;
  set(a,'XLim',[val-xhalfrange val+xhalfrange]);
 case 'pany'
  ylim = get(a,'YLim');
  val = get(uictrl,'Value');
  yhalfrange = (ylim(2)-ylim(1))/2;
  set(a,'YLim',[val-yhalfrange val+yhalfrange]);
 case 'mousepan'
  xlim = get(a,'xlim'); ylim = get(a,'ylim');
  xhalfrange = (xlim(2)-xlim(1))/2;
  yhalfrange = (ylim(2)-ylim(1))/2;
  apos = get(a,'position');
  yperpix = diff(ylim)/apos(4);
  xperpix = diff(xlim)/apos(3);
  curpt = get(dlg,'currentpoint');
  lastpt = d.last_drag_point;
  dxpix = curpt(1) - lastpt(1);
  dypix = curpt(2) - lastpt(2);
  dxlim = -xperpix*dxpix;
  dylim = -yperpix*dypix;
  xlim = xlim + dxlim;
  ylim = ylim + dylim;
  panxval = xlim(1) + xhalfrange;
  panyval = ylim(1) + yhalfrange;
  % check pan is within limits
  if panxval<0
    xlim = xlim - panxval;
    panxval = 0;
  elseif panxval>1
    xlim = xlim - (panxval - 1);
    panxval = 1;
  end
  if panyval<0
    ylim = ylim - panyval;
    panyval = 0;
  elseif panyval>1
    ylim = ylim - (panyval - 1);
    panyval = 1;
  end
  set(d.panx,'Value',panxval);
  set(d.pany,'Value',panyval);
  set(a,'xlim',xlim,'ylim',ylim);
  d.last_drag_point = curpt;
  setappdata(dlg,'PrintPreviewData',d);
 case 'zoom'
  if isequal(d.viewMode,'zoom')
    % zoom out
    set(dlg,'Pointer','watch');
    d.viewMode = 'fit';
    set([d.panx d.pany],{'Enable','Visible'},{'off','on'});
    set(d.panx,'Value',.5);
    set(d.pany,'Value',.5);
    setappdata(dlg,'PrintPreviewData',d);
    LRefresh(dlg);
    setptr(dlg,'glassplus');
  else
    % zoom in
    set(dlg,'Pointer','watch');
    point = get(a,'CurrentPoint');
    point = point(1,1:2);
    range = d.zoomScale/2;
    set(a,'XLim', [point(1)-range point(1)+range],...
          'YLim', [point(2)-range point(2)+range]);
    set(im,'CData', d.zoom);
    d.viewMode = 'zoom';
    setappdata(dlg,'PrintPreviewData',d);
    set([d.panx d.pany],{'Enable','Visible'},{'on','on'});
    set(d.panx,'Value',point(1));
    set(d.pany,'Value',point(2));
    LRefresh(dlg);
    setptr(dlg,'glassminus');
  end
end

%-----------------------------------------------------------------%
function LEditHeader(dlg)

d = getappdata(dlg,'PrintPreviewData');
if ~ishandle(d.fig), return; end
try
  set(dlg,'Pointer','watch');
  figureheaderdlg(d.fig);
  LRefresh(dlg);
  set(dlg,'Pointer','arrow');
catch
end

%-----------------------------------------------------------------%
function LPageSetup(dlg)

d = getappdata(dlg,'PrintPreviewData');
if ~ishandle(d.fig), return; end
try
  set(dlg,'Pointer','watch');
  pagesetupdlg(d.fig);
  d.rerender = true;
  setappdata(dlg,'PrintPreviewData',d);
  LRefresh(dlg);
  set(dlg,'Pointer','arrow');
catch
end

%-----------------------------------------------------------------%
function LPrintCallback(obj, evd, dlg)

d = getappdata(dlg,'PrintPreviewData');
if ~ishandle(d.fig), return; end
try
  printdlg(d.fig);
  % make sure ppv window is on top
  figure(dlg);
catch
  disp(lasterr);
end

%-----------------------------------------------------------------%
function LPageSetupCallback(obj, evd, dlg)

LPageSetup(dlg);

%-----------------------------------------------------------------%
function LHeaderCallback(obj, evd, dlg)

LEditHeader(dlg);

%-----------------------------------------------------------------%
function LRefreshCallback(obj, evd, dlg)

d = getappdata(dlg,'PrintPreviewData');
d.rerender = true;
setappdata(dlg,'PrintPreviewData',d);
LRefresh(dlg);

%-----------------------------------------------------------------%
function LCloseCallback(obj, evd, dlg)

% close so that user code that has uiwait(preview_window) returns
close(dlg)

%-----------------------------------------------------------------% 
function LPanxCallback(obj, evd, dlg)

LSetLim('panx',dlg);

%-----------------------------------------------------------------%
function LPanyCallback(obj, evd, dlg)

LSetLim('pany',dlg);

%-----------------------------------------------------------------%
function LResizeCallback(obj, evd, dlg)

% refresh once without rendering just to get everything in place
LRefresh(dlg);
% the refresh again with rendering to get the picture sharp
%LRefreshCallback(obj,evd,dlg);

%-----------------------------------------------------------------%
function LWButtonDown(obj, evd, dlg)

d = getappdata(dlg,'PrintPreviewData');
cmod=get(dlg,'CurrentModifier');
if ~isempty(cmod) && any(strcmp(cmod,'shift')) && isequal(d.viewMode,'zoom')
  obj = get(dlg,'currentobject');
  if any(obj==[d.imHG, d.pagePatch])
    % start mouse pan
    d.pan = 'on';
    d.last_drag_point = get(dlg,'currentpoint');
    setappdata(dlg,'PrintPreviewData',d);
  end
else
  % zoom
  obj = get(dlg,'currentobject');
  if any(obj==[d.imHG, d.pagePatch, d.headerStringText, d.headerDateText])
    LSetLim('zoom',dlg);
  end
end

%-----------------------------------------------------------------%
function LWButtonMotion(obj, evd, dlg)

d = getappdata(dlg,'PrintPreviewData');
cmod=get(dlg,'CurrentModifier');
if ~isempty(cmod) && any(strcmp(cmod,'shift'))
  if isequal(d.pan,'on') && isequal(d.viewMode,'zoom')
    LSetLim('mousepan',dlg);
  end
else
  if ~isequal(d.pan,'off')
    d.pan = 'off';
    setappdata(dlg,'PrintPreviewData',d);
  end
end
% set dialog pointer
obj = hittest(dlg);
if ~isempty(obj)
  if any(obj==[d.imHG,d.pagePatch,d.headerStringText,d.headerDateText])
    if isequal(d.pan,'on') || ...
          (~isempty(cmod) && any(strcmp(cmod,'shift')) && ...
           isequal(d.viewMode,'zoom'))
      setptr(dlg,'hand');
    else
      if isequal(d.viewMode,'fit')
        setptr(dlg,'glassplus');
      else
        setptr(dlg,'glassminus');
      end
    end
  else
    setptr(dlg,'arrow');
  end
end

%-----------------------------------------------------------------%
function LWButtonUp(obj, evd, dlg)

d = getappdata(dlg,'PrintPreviewData');
if isequal(d.pan,'on');
  d.pan = 'off';
  setappdata(dlg,'PrintPreviewData',d);
end

%-----------------------------------------------------------------%
function LSourceFigureBeingDestroyed(obj, evd, dlg)

if ishandle(dlg) && ~strcmp(get(dlg,'beingdeleted'),'on')
  delete(dlg);
end

%-----------------------------------------------------------------%
function paperSize = LGetPaperInch(fig)

oldPaperUnits = get(fig,'PaperUnits');
set(fig,'PaperUnits','inch');
paperSize = get(fig,'PaperSize');
set(fig,'PaperUnits',oldPaperUnits);

%-----------------------------------------------------------------%
function paperPos = LGetPaperPosInch(fig)

if strcmp(get(fig,'PaperPositionMode'),'auto')
  paperPos = hgconvertunits(fig,get(fig,'Position'),...
                       get(fig,'Units'),'inches',0);
  paperInch = LGetPaperInch(fig);
  paperPos(1:2) = .5*(paperInch - paperPos(3:4));
else
  oldPaperUnits = get(fig,'PaperUnits');
  set(fig,'PaperUnits','inch');
  paperPos = get(fig,'PaperPosition');
  set(fig,'PaperUnits',oldPaperUnits);
end

