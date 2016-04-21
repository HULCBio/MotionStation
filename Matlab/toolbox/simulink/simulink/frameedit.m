function frameedit(varargin)
%FRAMEEDIT Edit Print Frame files.
%   FRAMEEDIT <FRAMEFILENAME> opens the selected file for editing.
%   FRAMEEDIT with no arguments opens a new Print Frame editor window.
%
%   Print frames enable you to print Simulink block diagrams with
%   customized headers and footers.  These can include page numbers,
%   time and date stamps, system names, file names, and other text.
%
%   To print with print frames, simply select the "Frame" option in
%   the printing dialog box at print time.  Use FRAMEEDIT to customize
%   the print frame.
%
%   For more information, type:
%
%      doc frameedit
%
%   to visit the HELPDESK for more information about print frames.

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.26 $  $Date: 2002/04/10 18:21:58 $

persistent myfig;

selectedCells = [];
global buttonhandles;

switch nargin
case 0
   command = 'newframe';
case 1
   command = 'openframe';
   parameter = varargin{1};
case {2 3}
   if ischar(varargin{1})
      fig = eval(varargin{1});
   else
      fig = varargin{1};
   end
   command = varargin{2};

   ud = getscribeobjectdata(fig);
   theFigObjH  = ud.HandleStore;

   dragBin = theFigObjH.DragObjects;
   selectedCells = dragBin.Items;
   if nargin == 3
      parameter = varargin{3};
   else % nargin == 2
      parameter = [];
   end
case 4 % Page setup dialog commands
   dlg = gcbf;
   command = varargin{2};
   action = varargin{3};
   parameter = varargin{4};

end % switch nargin

switch command
case 'setlim'
   LSetLim(gcbo,selectedCells,parameter);
case 'newframe'
   LInitFig;
case 'openframe'
   fig = LInitFig;
   LOpen(fig, parameter);
case 'close'
   close(fig);
case 'setpaper'
   LSetPaper(fig);
case 'addrow'
   LAddRow(selectedCells);
case 'deleterow'
   LDeleteRow(selectedCells);
case 'addcell'
   LAddCell(selectedCells);
case 'deletecell'
   LDeleteCell(selectedCells);
case 'align'
   LAlign(selectedCells,parameter);
case 'addtext'
   LAddText(selectedCells,parameter);
case 'save'
   LSaveFig(fig);
case 'resize'
   LResize(fig);
case 'pagesetupdlg'
   LInitPageSetupDlg(fig);
   myfig = fig;
case 'dopagesetupdlg'
   LDoPageSetupDlg(myfig, dlg,action,parameter);
case 'togglebuttons'
   if ~isempty(selectedCells)
      if isa(selectedCells(1),'framerect')
         set(buttonhandles,'Enable','on');
      else
         set(buttonhandles,'Enable','off');
      end
   end
end % switch command



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LSaveFig

function LSaveFig(fig)
CR = char(10);

% need to trap errors if the user tries to write to a
defaultpath = getappdata(fig,'FrameeditPath');
[filename, pathname] = uiputfile({'*.fig'},'Save Frame');

% cancel or error
if (filename==0)
   return
end
% remember path
setappdata(fig,'FrameeditPath',defaultpath);
set(fig, 'Name', ['PrintFrame Editor - ' filename]);

ax = findobj(fig,'Type','axes');

UD = findall(ax,'Tag','PrintFramePaperSettings');
template = get(UD,'UserData');

% set print area
modelCellText = findall(ax,'Type','text',...
      'String','%<blockdiagram>');
if isempty(modelCellText)
   % no print area is specified for the block diagram
   errordlg(['You must specify a position for the', CR, ...
             'Simulink block diagram before saving:', CR, ...
             'Select a cell and use the control panel', CR, ...
             'to add "Block Diagram".', CR ...
             ])
   return
else
   modelCell = get(getobj(modelCellText(1)),'MyBin');
   % position of the model in data units
   % (normal to the print area inside the margins)
   template.modelDataPosition = get(modelCell,'Position');
end


uicx = findall(fig,'Type','uicontextmenu');
newfig = figure(...
   'Visible','off',...
   'Color','none',...
   'MenuBar','none',...
   'ToolBar','none',...
   'Tag','PrintFrameFigure',...
   'IntegerHandle','off');

scribehandle(figobj(newfig));
set(newfig,'ResizeFcn','');
for i = LGetSelection(fig)
   set(i,'IsSelected',0);
end
set(uicx,'Parent',newfig);

pagePatch = findall(ax,'Tag','FullPagePatch');
pageColor = get(pagePatch,'FaceColor');
set(pagePatch,'FaceColor','none');

savedProps = {'Color' 'Units' 'Position' 'Parent' 'XLim' 'YLim'};
savedValues = get(ax,savedProps);

set(ax,'Parent',newfig,...
   'Units','normalized',...
   'XLim', [0 1],...
   'YLim', [0 1],...
   'Color','none',...
   'Position',[0 0 1 1]);

% get updated properties from the figure
% template.margins and template.marginUnits are already set
template.valueList = get(fig, template.propList);

set(newfig, template.propList, template.valueList);


set(UD,'UserData',template);

% scale text
axObj = getobj(ax);
oldZoomScale = get(axObj,'ZoomScale');
set(axObj,'ZoomScale', 1);
tv = findobj(ax,'Type','text');
LScaleFont(tv,1);

setappdata(newfig ,'FrameeditVersionNumber', '5.3');
LConvertTo52FrameFiles(newfig);

try
   hgsave(newfig, [pathname filename]);
catch
   errordlg('Could not save the frame file.');
end
LConvertFrom52FrameFiles(newfig);

set(ax, savedProps, savedValues);
set(pagePatch,'FaceColor',pageColor);
set(uicx,'Parent',fig);
set(axObj,'ZoomScale', oldZoomScale);
tv = findobj(ax,'Type','text');
LScaleFont(tv,oldZoomScale)

close(newfig);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LAlign

function LAlign(selectedCells, setting)

for aCell =  selectedCells
   if isa(aCell,'framerect')
      set(aCell,'HorizontalAlignment',setting);
   end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LAddCell

function LAddCell(selectedCells)

if ~isempty(selectedCells)
   selectedCell = selectedCells(1);
   if isa(selectedCell,'framerect')

      pos = get(selectedCell,'Position');
      midX = pos(1)+pos(3)/2;

      parentRect = get(selectedCell,'MyBin');
      % get rowlines
      upperLine = get(parentRect,'MaxLine');
      lowerLine = get(parentRect,'MinLine');


      newCell = scribehandle(framerect(...
      LNewCellPatch(get(selectedCell,'XData'),get(selectedCell,'YData'),'w')));
      parentRect.NewItem = newCell;

      set(newCell,'MinX',midX);

      oldMaxLine = get(selectedCell,'MaxLine');
      if ~isempty(oldMaxLine)
         set(oldMaxLine, 'LowerChild',newCell);
      end
      set(selectedCell,'MaxX',midX);

      set(selectedCell,'IsSelected',0);
      set(newCell,'IsSelected',1);
      newline = ...
      scribehandle(cellline('vertical',selectedCell,newCell));
      parentRect.NewItem = newline;

      ax = get(selectedCell,'Parent');

      LBringToFront(upperLine,ax);
      LBringToFront(lowerLine,ax);
      LBringToFront(oldMaxLine,ax);
      refresh
   end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LDeleteCell

function LDeleteCell(selectedCells)

if ~isempty(selectedCells)
   selectedCell = selectedCells(1);
   if isa(selectedCell,'framerect')

      % if anonlychild, return

      parentRect = get(selectedCell,'MyBin');
      oldMaxLine = get(selectedCell,'MaxLine');
      oldMinLine = get(selectedCell,'MinLine');

      maxX = get(selectedCell,'MaxX');
      minX = get(selectedCell,'MinX');

      leftSibling = get(oldMinLine,'LowerChild');
      if ~isempty(leftSibling)
         % has a left sibling
         set(leftSibling,'MaxX',maxX);
         if ~isempty(oldMaxLine)
            set(oldMaxLine,'LowerChild',leftSibling);
         else
            set(leftSibling,'MaxLine',[]);
         end
         if ~isempty(oldMinLine)
            delete(oldMinLine);
         end
      elseif ~isempty(oldMaxLine)
         % has no left sibling, but has a right sibling
         rightSibling = get(oldMaxLine,'UpperChild');
         if ~isempty(rightSibling)
            set(rightSibling,'MinLine',[]);
            set(rightSibling,'MinX',minX);
            % set(oldMinLine,'LowerChild',leftSibling);
            delete(oldMaxLine);
         end
      else % it's an only child: delete the row...
         LDeleteRow(selectedCell);
         return;
      end

      set(selectedCell,'IsSelected',0);
      delete(selectedCell);
      if ~isempty(leftSibling)
         set(leftSibling,'IsSelected',1);
      elseif ~isempty(rightSibling)
         set(rightSibling,'IsSelected',1);
      end
      refresh
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LAddRow

function LAddRow(selectedCells)

if ~isempty(selectedCells)
   selectedCell = selectedCells(1);
   if isa(selectedCell,'framerect')

      pos = get(selectedCell,'Position');
      midY = pos(2)+pos(4)/2;

      selectedRow = get(selectedCell,'MyBin');
      parentRect = get(selectedRow,'MyBin');

      upperLine = get(selectedRow,'MaxLine');
      lowerLine = get(selectedRow,'MinLine');

      XData = get(selectedRow,'XData');
      YData = get(selectedRow,'YData');

      newRow = scribehandle(framerect(LNewCellPatch(XData,YData,'w')));
      newCell = scribehandle(framerect(LNewCellPatch(XData,YData,'w')));
      newRow.NewItem = newCell;
      parentRect.NewItem = newRow;

      set(newRow,'MinY',midY);

      if ~isempty(upperLine)
         set(upperLine, 'LowerChild',newRow);
      end
      set(selectedRow,'MaxY',midY);

      set(selectedCell,'IsSelected',0);
      set(newCell,'IsSelected',1);
      newLine = ...
      scribehandle(cellline('horizontal',selectedRow,newRow));
      parentRect.NewItem = newLine;

      ax = get(selectedCell,'Parent');
      LBringToFront(newLine,ax);
      LBringToFront(upperLine,ax);
      LBringToFront(lowerLine,ax);
      refresh
   end
end
% end LAddRow


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LDeleteRow

function LDeleteRow(selectedCells)

if ~isempty(selectedCells)
   selectedCell = selectedCells(1);
   if isa(selectedCell,'framerect')

      % if anonlychild, return
      selectedRow = get(selectedCell,'MyBin');
      parentRect = get(selectedRow,'MyBin');
      upperLine = get(selectedRow,'MaxLine');
      lowerLine = get(selectedRow,'MinLine');

      maxY = get(selectedRow,'MaxY');
      minY = get(selectedRow,'MinY');

      lowerSibling = get(lowerLine,'LowerChild');
      upperSibling = get(upperLine,'UpperChild');
      if ~isempty(lowerSibling)
         set(lowerSibling,'MaxY',maxY);
         if ~isempty(upperLine)
            set(upperLine,'LowerChild',lowerSibling);
         else
            set(lowerSibling,'MaxLine',[]);
         end
         delete(lowerLine);
      elseif ~isempty(upperSibling)
         set(upperSibling,'MinLine',[]);
         set(upperSibling,'MinY',minY);
         if ~isempty(lowerLine)
            set(lowerLine,'UpperChild',upperSibling);
         end
         delete(upperLine);
      else
         % it's an only child, so return
         return % no delete
      end

      set(selectedCell,'IsSelected',0);
      delete(selectedRow);

      refresh
   end
end

% end LDeleteRow

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LBringToFront

function LBringToFront(HG,ax)

if ~isempty(HG)
   HGHandles = HG.MyHGHandle;
   if iscell(HGHandles)
      HGHandles = [HGHandles{:}]'
   end
   children = get(ax,'Children');
   children(find(ismember(children, HGHandles))) = [];
   children = [HGHandles; children];
   set(ax,'Children',children);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LAddText


function textA1 = LAddText(selectedCells, value)
pop = {
''
'%<blockdiagram>'
'%<date>'
'%<time>'
'%<page>'
'%<npages>'
'%<system>'
'%<fullsystem>'
'%<filename>'
'%<fullfilename>'
};


if ~isempty(selectedCells)

   selectedCell = selectedCells(1);

   fig = get(selectedCell,'Figure');
   TP = findobj(fig,'Tag','VarTagPopup');
   if isempty(value)
      value = get(TP,'value');
   end

   editStatus = 'off';
   if isa(selectedCell,'framerect')
      contents = selectedCell.Items;
      if ~isempty(contents)
         textA1 = contents(1);
         editStatus = get(textA1,'Editing');
         switch editStatus
         case 'off'
            t = get(textA1,'String');
            set(textA1,'Editing','on');
         case 'on'
            set(textA1,'Editing','off');
            t = get(textA1,'String');
            set(textA1,'Editing','on');
         end
      else
         textA1 = scribehandle(celltext(selectedCell));
         % get the current scale to set the right font size
         set(textA1,'Editing','off');
         xlim = get(get(selectedCell,'Parent'), 'XLim');
         set(textA1,...
                 'Clipping','on',...
                 'Editing','on');
         t = '';
      end
      if ~isempty(value)
         newtext = pop{value};
         if isunix
            % workaround a UNIX focus bug
            set(textA1,'Editing', 'off');
            if value==1
               newtext='text';
            end
         end
         if size(t,1)<=1  % single line text
            set(textA1,'String',[t newtext]);
         else
            t = cellstr(t);
            t{end}= [t{end} newtext];
            set(textA1,'String', t);
         end
      end
   end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LNewCellPatch

function p = LNewCellPatch(varargin)

p = patch(varargin{:},'EraseMode','background');
set(p,'EdgeColor','none');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LResize

function LResize(f,h)

if nargin<2
   h=getappdata(f,'FrameEditHandles');
   %h is a structure containing useful handles
end


figPos=get(h.Figure,'Position');

pad=5;

PushAddExtent=get(h.PushAdd,'Extent');
SplitCellExtent=get(h.SplitCell,'Extent');
DeleteCellExtent=get(h.DeleteCell,'Extent');
AddRowExtent=get(h.AddRow,'Extent');
DeleteRowExtent=get(h.DeleteRow,'Extent');
zoomExtent=get(h.zoom,'Extent');
unzoomExtent=get(h.unzoom,'Extent');
%TextFillExtent=get(h.TextFill,'Extent');
%TextAlignExtent=get(h.TextAlign,'Extent');

mBtnHt=SplitCellExtent(4)*1.25; %most buttons height

%Resize the buttons on the bottom border

reshapeWd=max([SplitCellExtent(3),DeleteCellExtent(3),...
   AddRowExtent(3),DeleteRowExtent(3)])+pad;

borderDim=[h.SplitCell reshapeWd 0
   h.DeleteCell reshapeWd pad
   h.AddRow reshapeWd 3*pad
   h.DeleteRow reshapeWd pad
   h.AlignLeft mBtnHt 3*pad 
   h.AlignCenter mBtnHt 0
   h.AlignRight mBtnHt 0
   h.VarTagPopup 2*reshapeWd 3*pad
   h.PushAdd PushAddExtent(3)+pad 0];

yPos=pad;
xPos=pad;
for i=1:size(borderDim,1)
   xPos=xPos+borderDim(i,3);
   set(borderDim(i,1),'Position',[xPos yPos borderDim(i,2) mBtnHt]);
   xPos=xPos+borderDim(i,2);
end

%Resize the "Window" - i.e. the axis, resize, and zoom controls

zBtnHt=zoomExtent(4); %zoom button height

windowYzero=3*pad+mBtnHt;
windowXzero=pad;
windowHt=max(figPos(4)-pad-windowYzero,4*zBtnHt);
windowWd=max([figPos(3)-2*pad,4*zBtnHt,xPos]);

set([h.Axes h.zoom h.unzoom h.panx h.pany],{'Position'},...
   {[windowXzero windowYzero+zBtnHt  windowWd-zBtnHt windowHt-zBtnHt];...
   [windowXzero windowYzero zBtnHt zBtnHt];...
   [windowXzero+zBtnHt windowYzero zBtnHt zBtnHt];...
   [windowXzero+2*zBtnHt windowYzero windowWd-3*zBtnHt zBtnHt];...
   [windowXzero+windowWd-zBtnHt windowYzero+zBtnHt zBtnHt windowHt-zBtnHt]});

%--------------redraw axis contents ---------------

lineHandle=findall(allchild(h.Axes),...
   'type','line',...
   'tag','PrintFramePaperSettings');
template=get(lineHandle,'UserData');

[xFullPage, yFullPage] = LSetPagePatch(h.Figure,template);
set(h.FullPagePatch,'Xdata',xFullPage,'Ydata',yFullPage);

LSetPaper(f,logical(0));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LSetlim

function LSetLim(uictrl,selectedCells, action)
% setlim
%   scroll and zoom

a = gca;

axObj = getobj(a);


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
case 'unzoom'
   xlim = get(a,'XLim');
   xmid = mean(xlim);
   xrange = xlim(2)-xlim(1);
   ylim = get(a,'YLim');
   ymid = mean(ylim);
   yrange = ylim(2)-ylim(1);
   set(a,'XLim', [xmid-xrange xmid+xrange],...
   'YLim', [ymid-yrange ymid+yrange]);
   zoomScale = get(axObj,'ZoomScale') / 2;
   set(axObj,'ZoomScale', zoomScale);
   tv = findobj(gcbf,'Type','text');
   LScaleFont(tv,zoomScale)

case 'zoom'
   xlim = get(a,'XLim');
   ylim = get(a,'YLim');
   % zoom in by a factor of two, centered on current selection
   if ~isempty(selectedCells)
      selectedCell = selectedCells(1);
      pos = get(selectedCell,'Position');
      xmid = pos(1)+pos(3)/2;
      ymid = pos(2)+pos(4)/2;
   else
      xmid = mean(xlim);
      ymid = mean(ylim);
   end
   xQuarterRange = (xlim(2)-xlim(1))/4;
   yQuarterRange = (ylim(2)-ylim(1))/4;
   set(a,'XLim', [xmid-xQuarterRange xmid+xQuarterRange],...
   'YLim', [ymid-yQuarterRange ymid+yQuarterRange]);
   zoomScale = get(axObj,'ZoomScale') * 2;
   set(axObj,'ZoomScale', zoomScale);
   tv = findobj(gcbf,'Type','text');
   LScaleFont(tv,zoomScale);

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LScaleFont

function LScaleFont(tv, zoomScale)


if ~isempty(tv)
   for aTextHG = tv'
      aTextObj = getobj(aTextHG);
      set(aTextObj,'ZoomScale',zoomScale);
   end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOpen

function LOpen(fig, filename)

pathname = [];

if isempty(filename)
   defaultpath = getappdata(fig,'FrameeditPath');
   [filename, pathname] = uigetfile({'*.fig'},'Open Frame');
end

if filename
   try
      f = hgload([pathname filename]);
      % remember path
      setappdata(fig,'FrameeditPath',pathname);
      LConvertFrom52FrameFiles(f);
   catch
      error('couldn''t open frame file');
      return
   end
else
   return
end


editorFig = fig;
currentAx = findall(editorFig,'Type','axes','Tag','ScribeOverlayAxesActive');
currentuicx = findall(editorFig,'Type','uicontextmenu');
currentPagePatch = findall(currentAx,'Tag','FullPagePatch');
pageColor = get(currentPagePatch,'FaceColor');

for i = LGetSelection(editorFig)
   set(i,'IsSelected',0);
end

ax = findall(f,'Type','axes');
uicx = findall(f,'Type','uicontextmenu');

savedProps = {'Color' 'Units' 'Position' 'Parent'};
savedValues = get(currentAx,savedProps);

set(ax,savedProps,savedValues);
set(uicx,'Parent',editorFig);
newPagePatch = findall(ax,'Tag','FullPagePatch');
set(newPagePatch,'FaceColor',pageColor);

h = getappdata(editorFig,'FrameEditHandles');
h.FullPagePatch = newPagePatch;
h.Axes = ax;
setappdata(editorFig,'FrameEditHandles',h);

paperProperties = {...
        'PaperUnits'...
        'PaperType'...
        'PaperOrientation'...
        'PaperPosition'};
paperValues = get(f,paperProperties);
close(f);

delete(currentAx);
delete(currentuicx);

ah = scribehandle(axisobj(ax));
% this is reset by the call to axisobj
set(editorFig,'ResizeFcn','frameedit gcbf resize');

set(editorFig, paperProperties, paperValues);
LSetPaper(editorFig);
zoomScale = get(ah,'ZoomScale');
tv = findobj(editorFig,'Type','text');
LScaleFont(tv,zoomScale);

set(editorFig,'Name', ['PrintFrame Editor -' filename]);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LInitFig
function f = LInitFig

% only one up at a time:
f = findall(0,...
   'Type','Figure',...
   'Tag','scrFrameEditFigure');

if ishandle(f)
   %raise figure to top of stack
   figure(f)
   return
end

f = figure('Name','PrintFrame Editor',...
   'IntegerHandle','off',...
   'Tag','scrFrameEditFigure',...
   'DoubleBuffer','on',...
   'Units','pixels',...
   'Resize','on',...
   'Color',get(0,'defaultuicontrolbackgroundcolor'),...
   'Visible','off',...
   'NumberTitle','off');

h.Figure=f;


set(f,'PaperOrientation','landscape');

set(f,'MenuBar','none');

LInitMenus(f);

foh = scribehandle(figobj(f));
foh.DragObjects.ResetParent = 0;
foh.ResizeFcn = 'frameedit gcbf resize';

a = axes(...
   'Units', 'pixels',...
   'Parent',f,...
   'Box','on',...
   'Layer','bottom',...
   'Color',[.7 .7 .7],...
   'XTick',[],...
   'YTick',[],...
   'XLimMode','manual',...
   'YLimMode','manual',...
   'ButtonDownFcn','doclick(gcbo)',...
   'Tag','ScribeOverlayAxesActive');  % this needs to change...

h.Axes=a;

ah = scribehandle(axisobj(a));

set(a,...
   'ButtonDownFcn','',...
   'HitTest','off');

% set default margins, then set paperposition accordingly
% default margins:  2 cm on each side.
template.marginUnits = 'inches';
template.margins = [.75 .75 .75 .75];  % L B R T

[xFullPage, yFullPage] = LSetPagePatch(f,template);

% set the axis scaling based on the PaperType, PaperOrientation,
% and PaperPosition (margins)
LSetPaper(f);

% draw the page image
h.FullPagePatch=patch(xFullPage,yFullPage,'w',...
   'Tag','FullPagePatch',...
   'Parent',a);

template.propList = {...
      'PaperType',...
      'PaperOrientation',...
      'PaperUnits',...
      'PaperPosition',...
      'PaperPositionMode'...
   };

template.valueList = get(f,template.propList);

l = line('Parent',a,...
   'Visible','off',...
   'Tag','PrintFramePaperSettings',...
   'UserData',template);

rectbig = scribehandle(framerect(...
   LNewCellPatch([0 0 1 1],[0 1 1 0],'w')));
rectbig.EdgeColor = 'none';

% draw (fixed) margin lines
line([0 0 1 1 0], [0 1 1 0 0],'Color',[0 0 0]);

rect1 = scribehandle(framerect(...
LNewCellPatch([0 0 1 1],[0 .1 .1 0],'w')));
rect1.Visible = 'off';
rect1.ButtonDownFcn = '';
rect1.FaceColor = 'none';
rect1.HitTest = 'off';

rectA1 = scribehandle(framerect(...
LNewCellPatch([0 0 .5 .5],[0 .1 .1 0],'w')));
rectB1 = scribehandle(framerect(...
LNewCellPatch([.5 .5 1 1],[0 .1 .1 0],'w')));

rectA1.IsSelected = 1;
rect2 = scribehandle(framerect(...
LNewCellPatch([0 0 1 1],[.1 1 1 .1],'w')));
rect2.FaceColor = 'none';
rect2.ButtonDownFcn = '';
rect2.Visible = 'off';
rect2.HitTest = 'off';
rectA2 = scribehandle(framerect(...
LNewCellPatch([0 0 1 1],[.1 1 1 .1],'w')));

linev1 = scribehandle(cellline('vertical',rectA1,rectB1));

rect1.NewItem = linev1;
rect1.NewItem = rectA1;
rect1.NewItem = rectB1;

rect2.NewItem = rectA2;

lineh = scribehandle(cellline('horizontal',rect1,rect2));

rectbig.NewItem = lineh;
rectbig.NewItem = rect1;
rectbig.NewItem = rect2;

% fill the big rectangle with %<blockdiagram>
LAddText(rectA2,2);
% system name in the lower left corner
LAddText(rectA1,8);
% page number in the lower right corner
theText = LAddText(rectB1,5);
set(theText,'Editing','off');

%---------------set up pushbuttons-------------------
%column 1=tag and "h" fieldname,
%column 2=string
%column 3=calback
btnProp={'PushAdd','Add','frameedit gcbf addtext',''
   'SplitCell','split cell','frameedit gcbf addcell',''
   'DeleteCell','delete cell','frameedit gcbf deletecell',''
   'AddRow','add row','frameedit gcbf addrow',''
   'DeleteRow','delete row','frameedit gcbf deleterow',''
   'AlignLeft','','frameedit gcbf align left','Align text left'
   'AlignCenter','','frameedit gcbf align center','Align text center'
   'AlignRight','','frameedit gcbf align right','Align text right'
   'zoom','+','frameedit gcbf setlim zoom','Zoom in'
   'unzoom','-','frameedit gcbf setlim unzoom','Zoom out'};

for i=1:size(btnProp,1)
   h=setfield(h,btnProp{i,1},uicontrol('Parent',h.Figure,...
      'Style','pushbutton',...
      'Tag',btnProp{i,1},...
      'String',btnProp{i,2},...
      'Callback',btnProp{i,3},...
      'ToolTipString',btnProp{i,4}));
end

btnCdata=getcdata;

set([h.AlignLeft,h.AlignCenter,h.AlignRight],{'CData'},...
   {btnCdata.alignLeft;...
   btnCdata.alignCenter;...
   btnCdata.alignRight});

%textProp={'TextFill','Fill'
%   'TextAlign','Align'};

%for i=1:size(textProp,1)
%   h=setfield(h,textProp{i,1},uicontrol('Parent',h.Figure,...
%      'Style','text',...
%      'Tag',textProp{i,1},...
%      'String',textProp{i,2},...
%      'BackgroundColor',foh.Color,...
%      'HorizontalAlignment','left'));
%end

popchoices = {'Text'
   'Block Diagram'
   'Date'
   'Time'
   'Page Number'
   'Total Pages'
   'System Name'
   'Full System Name'
   'File Name'
   'Full File Name'};

h.VarTagPopup=uicontrol('Parent',h.Figure,...
   'Style','popupmenu',...
   'String',popchoices,...
   'HorizontalAlignment','left',...
   'Tag','VarTagPopup',...
   'BackgroundColor',[1 1 1]);

% scrolling controls
scrollProp={'panx','frameedit gcbf setlim panx'
   'pany','frameedit gcbf setlim pany'};

for i=1:size(scrollProp,1)
   h=setfield(h,scrollProp{i,1},uicontrol('Parent',h.Figure,...
      'Style','slider',...
      'Tag',scrollProp{i,1},...
      'Callback',scrollProp{i,2},...
      'Value',.5));
end

setappdata(f,'FrameEditHandles',h);

LResize(f,h)

set(f,'HandleVisibility','callback',...
   'ResizeFcn','frameedit gcbf resize',...   
   'Visible','on');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LInitMenus

function LInitMenus(f)

fileMenu = uimenu('Parent',f,...
        'Label','File');
% editMenu = uimenu('Parent',f,...
%        'Label','Edit');
helpMenu = uimenu('Parent',f,...
        'Label','Help');

%u = uimenu('Parent',helpMenu,...
%        'Label','About Print Frames',...
%        'Callback','helpwin frameedit');
     
helpStr = ...
      'helpview([docroot ''/mapfiles/frameedit.map''],''frame_edit'')';
u = uimenu('Parent',helpMenu,...
      'Label','PrintFrame Editor Help',...
      'Callback',helpStr);
     
% u = uimenu('Parent',fileMenu,...
%         'Label','New',...
%         'Tag','NewMenu',...
%         'Callback','frameedit gcbf newframe');
u = uimenu('Parent',fileMenu,...
        'Label','Open...',...
        'Tag','OpenMenu',...
        'Callback','frameedit gcbf openframe');
u = uimenu('Parent',fileMenu,...
        'Label','Close',...
        'Tag','CloseMenu',...
        'Callback','frameedit gcbf close');

% u = uimenu('Parent',fileMenu,...
%         'Separator','on',...
%         'Label','Save',...
%         'Tag','SaveMenu',...
%         'Enable','off',...
%         'Callback','');
u = uimenu('Parent',fileMenu,...
        'Separator','on',...
        'Label','Save As...',...
        'Tag','SaveAsMenu',...
        'Callback','frameedit gcbf save');

u = uimenu('Parent',fileMenu,...
        'Separator','on',...
        'Label','Page Setup...',...
        'Tag','PageSetupMenu',...
        'Callback','frameedit gcbf pagesetupdlg');
% u = uimenu('Parent',fileMenu,...
%         'Label','Print Sample...',...
%         'Tag','PrintSampleMenu',...
%         'Callback','');



function objectVector = LGetSelection(aFig)
objectVector = [];
aFigObjH = getobj(aFig);
if ~isempty(aFigObjH)
   dragBinH = aFigObjH.DragObjects;
   objectVector = dragBinH.Items;
end



function [xFullPage, yFullPage] = LSetPagePatch(f,template);

set(f,'PaperUnits', template.marginUnits);
paperSize = get(f,'PaperSize');
paperPosition = [template.margins(1:2) ...
           paperSize-(template.margins(1:2)+template.margins(3:4))];
set(f,'PaperPosition',paperPosition);

set(f,'PaperUnits','normal');
normPaperPosition = get(f,'PaperPosition');

[pageL, pageB, pageR, pageT] =  LNormPos2XY(normPaperPosition);

xFullPage = [pageL pageL pageR pageR];
yFullPage = [pageB pageT pageT pageB];


function [dL, dB, dR, dT] = LNormPos2XY(pos)
L = pos(1);
W = pos(3);
B = pos(2);
H = pos(4);

dL = 0 - L/W;
dR = 1 + (1-(L+W))/W;

dB = 0 - B/H;
dT = 1 + (1-(B+H))/H;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LSetPaper
%   assumes that the figures paperposition, in normal units,
%   already reflects the correct margin settings.
function LSetPaper(fig,isResetScale)

if nargin<2
   isResetScale=logical(1);
end


ax = findall(fig,'Type','axes');

% get current axis position
[axisW, axisH] = LGetAxisSize(ax);

% find the maximum scale that fits the paper in the visible region
scales = 1./[1 2 4 8 16 32];
paperSize = ones(1,2);
[paperSize(1),paperSize(2)] = LGetScaledPaperSize(1,fig);
nScales = length(scales);
scaledPages = paperSize' * scales;

xFits = scaledPages(1,:) <= axisW * ones(1,nScales);
yFits = scaledPages(2,:) <= axisH * ones(1,nScales);
pageFits = xFits & yFits;

iScale = min(find(pageFits));
if isempty(iScale)  % if it's too big to fit, use the smallest scale
   iScale = nScale;
end
zoomScale = scales(iScale);


axObj = getobj(ax);
if isempty(axObj)
   return
end

if isResetScale
   % set zoom scale
   set(axObj,'ZoomScale',zoomScale);
else
   zoomScale=get(axObj,'ZoomScale');
end

% set axis limits
[scaledPaperW, scaledPaperH] = LGetScaledPaperSize(zoomScale, fig);

normalPrintArea = get(fig,'PaperPosition');
printAreaW = normalPrintArea(3);
printAreaH = normalPrintArea(4);

xLimRange = 1/printAreaW * axisW/scaledPaperW;
yLimRange = 1/printAreaH * axisH/scaledPaperH;

% center on the paper patch
[L B R T] = LNormPos2XY(normalPrintArea);
xMid = mean([L R]);
yMid = mean([B T]);

xlim = [xMid xMid] + [-xLimRange/2  xLimRange/2];
ylim = [yMid yMid] + [-yLimRange/2  yLimRange/2];
set(ax,'XLim',xlim,'YLim',ylim);
tv = findobj(ax,'Type','text');
LScaleFont(tv,zoomScale);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [x,y] = LGetAxisSize(ax)
oldUnits = get(ax,'Units');
set(ax,'Units','points');
pos = get(ax,'Position');
x = pos(3);
y = pos(4);
set(ax,'Units',oldUnits);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [x,y] = LGetScaledPaperSize(zoomScale, fig)

oldUnits = get(fig,'PaperUnits');
set(fig,'PaperUnits','points');
psize = get(fig,'PaperSize');
psize = psize * zoomScale;
x = psize(1);
y = psize(2);
set(fig,'PaperUnits',oldUnits);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% use the dialog paper properties to verify and compute
% new values of the paper properties for the printframe

function err = LDoPageSetupDlg(fig,dlg,action,parameter)

err = 0;

CR = sprintf('\n');

switch action
case 'setmarginunits'

   popup = findobj(dlg,'Tag','MarginUnitsPopup');
   unitTypes = get(popup,'String');
   newUnits = unitTypes{get(popup,'Value')};

   UD = findall(fig,'Tag','PrintFramePaperSettings');
   template = get(UD,'UserData');
   oldUnits = template.marginUnits;

   % assume the paperposition is up to date
   set(dlg, 'PaperUnits', newUnits);
   paperSize = get(dlg,'PaperSize');
   paperPosition = get(dlg,'PaperPosition');

   [L, B, R, T] = LPaperPos2Margins(paperPosition, paperSize);

   try
      % now update margin values
      LEdit = findobj(dlg,'Tag','Left');
      BEdit = findobj(dlg,'Tag','Bottom');
      REdit = findobj(dlg,'Tag','Right');
      TEdit = findobj(dlg,'Tag','Top');

      set(LEdit,'String',num2str(L));
      set(BEdit,'String',num2str(B));
      set(REdit,'String',num2str(R));
      set(TEdit,'String',num2str(T));

      template.margins = [L B R T];
      template.marginUnits = newUnits;
      set(UD,'UserData',template);
   catch
      set(dlg,'PaperUnits',oldUnits);
      oldUnitVal = find(strcmp(oldUnits,unitTypes));
      set(popup,'Value',oldUnitVal);
      return
   end

case 'setmargin'
   UD = findall(fig,'Tag','PrintFramePaperSettings');
   template = get(UD,'UserData');
   if isempty(parameter)  % changing paper type or orientation

      paperSize = get(dlg,'PaperSize');
      newPaperPos = LMargins2PaperPos(template.margins, ...
              paperSize);
      try
         set(dlg,'PaperPosition',newPaperPos);
      catch
         err = 1;
      end

   else % we are setting a value in an edit text field
      oldMargins = template.margins;

      thisEditField = get(gcbo,'Tag');
      marginTags = {'Left' 'Bottom' 'Right' 'Top'};
      whichMargin = find(strcmp(thisEditField,marginTags));

      try
         newValue = str2num(get(gcbo,'String'));
         paperSize = get(dlg,'PaperSize');
         template.margins(whichMargin) = newValue;
         newPaperPos = LMargins2PaperPos(template.margins, ...
                 paperSize);
         set(dlg,'PaperPosition',newPaperPos);

         set(UD,'UserData',template);
      catch
         % restore
         template.margins = oldMargins;
         set(gcbo,'String',num2str(oldMargins(whichMargin)));
         errordlg('This is an invalid margin setting.');
      end
   end

case 'setpapertype'
   paperTypes = get(gcbo,'String');
   oldPaperType = get(dlg,'PaperType');

   newPaperType = paperTypes{get(gcbo,'Value')};
   set(dlg,'PaperType',newPaperType);
   err = LDoPageSetupDlg(fig, dlg,'setmargin',[]);
   if err
      set(dlg,'PaperType',oldPaperType);
      errordlg(['Could not switch the Paper Type' CR...
                 'with the specified margins.']);
   else
      oldValue = find(strcmp(oldPaperType,paperTypes));
      set(gcbo,'Value',oldValue);
   end

case 'setpaperorientation'
   newPaperOrientation = lower(get(gcbo,'String'));
   oldPaperOrientation = get(dlg,'PaperOrientation');
   set(dlg,'PaperOrientation',newPaperOrientation);

   err = LDoPageSetupDlg(fig, dlg,'setmargin',[]);
   if err
      set(dlg,'PaperOrientation',oldPaperOrientation);
      errordlg(['Could not switch the Paper Orientation' CR...
                 'with the specified margins.']);
      switch oldPaperOrientation
      case 'portrait'
         set(findobj(dlg,'String','Landscape'), 'Value', 0);
         set(findobj(dlg,'String','Portrait'), 'Value', 1);
      case 'landscape'
         set(findobj(dlg,'String','Landscape'), 'Value', 1);
         set(findobj(dlg,'String','Portrait'), 'Value', 0);
      end
   else
      switch newPaperOrientation
      case 'portrait'
         set(findobj(dlg,'String','Landscape'), 'Value', 0);
      case 'landscape'
         set(findobj(dlg,'String','Portrait'), 'Value', 0);
      end
   end

case 'cancel'
   close(dlg);

case 'apply'
   % switch back to normal units...
   set(dlg,'PaperUnits','normalized');
   paperProperties = {...
           'PaperUnits'...
           'PaperType'...
           'PaperOrientation'...
           'PaperPosition'};
   paperValues = get(dlg,paperProperties);

   UD = findall(fig,'Tag','PrintFramePaperSettings');
   template = get(UD,'UserData');
   pagePatch = findobj(fig,'Tag','FullPagePatch');
   try
      set(fig,paperProperties,paperValues);
      [X, Y] = LSetPagePatch(fig,template);
      set(pagePatch,'XData',X,'YData',Y);
      LSetPaper(fig);
   catch
      error('didn''t work');
   end
   set(dlg,'PaperUnits',template.marginUnits);
case 'ok'
   err = LDoPageSetupDlg(fig,dlg,'apply',parameter);
   close(dlg);
end


function [L, B, R, T] = LPaperPos2Margins(paperPosition, paperSize);
   L = paperPosition(1);
   B = paperPosition(2);
   R = paperSize(1)-paperPosition(3)-paperPosition(1);
   T = paperSize(2)-paperPosition(4)-paperPosition(2);

function paperPosition = LMargins2PaperPos(margins, paperSize);
   paperPosition(1:2) = margins(1:2);
   paperPosition(3:4) = paperSize - margins(3:4)-margins(1:2);


function LInitPageSetupDlg(fig)

paperProperties = {...
        'PaperUnits'...
        'PaperType'...
        'PaperOrientation'...
        'PaperPosition'};

paperValues = get(fig, paperProperties);

UD = findall(fig,'Tag','PrintFramePaperSettings');
template = get(UD,'UserData');


figW = 350;

nRows = 9;
rowH = 20;
topMargin = 20;
botMargin = 15;
rowPadH = 7;

halfRowH = (rowH+rowPadH)/2;

figH = nRows*rowH + (nRows-1)*rowPadH + topMargin + botMargin;

row = ones(1,nRows)*(figH-topMargin-rowH);
rowOffsets = (0:nRows-1)*(rowH+rowPadH);
row = row - rowOffsets;

dlg = figure(...
        'Name','PrintFrame Page Setup',...
        'Visible','off',...
        'MenuBar','none',...
        'Color',get(0,'DefaultUIcontrolBackgroundColor'),...
        'IntegerHandle','off',...
        'WindowStyle','modal',...
        'HandleVisibility','callback',...
        'NumberTitle','off',...
        'Units','pixels',...
        'UserData',fig);

% set handlevis callback and windowstyle modal

figPos = get(dlg,'Position');
figPos(3:4) = [figW figH];
set(dlg,'Position',figPos);

set(dlg,paperProperties,paperValues);

% work in the marginUnits;
set(dlg,'PaperUnits', template.marginUnits);

leftMargin = 15;
rightMargin = 15;
gutterW = 10;
col3W = (figW - 2*gutterW - leftMargin - rightMargin)/3;

x(1) = leftMargin;
x(2) = x(1) + col3W + gutterW;
x(3) = x(2) + col3W + gutterW;
xmid = figW/2;

uiProps.Parent = dlg;
uiProps.BackgroundColor = get(dlg,'Color');

textProps = uiProps;
textProps.Style = 'text';
textProps.HorizontalAlignment = 'right';

frameProps = uiProps;
frameProps.Style = 'frame';

editProps = uiProps;
editProps.Style = 'edit';
editProps.BackgroundColor = [1 1 1];

popProps = uiProps;
popProps.Style = 'popupmenu';
popProps.BackgroundColor = [1 1 1];

radioProps = uiProps;
radioProps.Style = 'radiobutton';

pushProps = uiProps;
pushProps.Style = 'pushbutton';

% paper type
textProps.String = 'Paper Type:';
textProps.Position = [x(1) row(1) col3W rowH];
u = uicontrol(textProps);

popProps.String = set(dlg,'PaperType');
myPaperType = get(dlg,'PaperType');
popProps.Value = find(strcmp(myPaperType,popProps.String));
popProps.Position = [x(2) row(1) 2*col3W+gutterW rowH];
popProps.Callback = 'frameedit gcbf dopagesetupdlg setpapertype foo';
u = uicontrol(popProps);

% paper orientation
textProps.String = 'Paper Orientation:';
textProps.Position = [x(1) row(2) col3W rowH];
u = uicontrol(textProps);

myPaperOrientation = get(dlg,'PaperOrientation');
radioProps.Position = [x(2) row(2) col3W rowH];
radioProps.String = 'Portrait';
radioProps.Value = strcmp(myPaperOrientation, 'portrait');
radioProps.Callback = ...
        'frameedit gcbf dopagesetupdlg setpaperorientation foo';
u1 = uicontrol(radioProps);

radioProps.Position = [x(3) row(2) col3W rowH];
radioProps.String = 'Landscape';
radioProps.Value = strcmp(myPaperOrientation, 'landscape');
radioProps.Callback = ...
        'frameedit gcbf dopagesetupdlg setpaperorientation foo';
u2 = uicontrol(radioProps);

% margins
frameProps.Position = [x(1) row(7)-halfRowH ...
           figW-leftMargin-rightMargin ...
           row(3)-row(7)+halfRowH];
u = uicontrol(frameProps);

L = template.margins(1);
B = template.margins(2);
R = template.margins(3);
T = template.margins(4);

textProps.String = 'Margins:';
textProps.Position = [x(1) row(3) col3W rowH];
u = uicontrol(textProps);
textSize = get(u,'extent');
textProps.Position(3:4) = textSize(3:4)+[4 0];
textProps.Position(1) = x(1)+col3W-textSize(3);
textProps.Position(2) = row(3)-textSize(4)/2;
textProps.HorizontalAlignment = 'center';
set(u, textProps);

framePad = 20;
xL = x(1)+framePad;
xR = xmid;
mW = (xR-xL-framePad)/2;

yT = row(4)-halfRowH;
yB = row(5)-halfRowH;

textProps.HorizontalAlignment = 'left';
textProps.Position(3:4) = [mW rowH];

editProps.HorizontalAlignment = 'left';
editProps.Position(3:4) = [mW rowH];
editProps.Callback = 'frameedit dlg dopagesetupdlg setmargin foo';

textProps.String = 'Top';
textProps.Position(1:2) = [xL yT];
u = uicontrol(textProps);
editProps.Tag = textProps.String;
editProps.String = num2str(T);
editProps.Position(1:2) = [xL+mW yT];
u = uicontrol(editProps);

textProps.String = 'Bottom';
textProps.Position(1:2) = [xL yB];
u = uicontrol(textProps);
editProps.Tag = textProps.String;
editProps.String = num2str(B);
editProps.Position(1:2) = [xL+mW yB];
u = uicontrol(editProps);

textProps.String = 'Left';
textProps.Position(1:2) = [xR yT];
u = uicontrol(textProps);
editProps.Tag = textProps.String;
editProps.String = num2str(L);
editProps.Position(1:2) = [xR+mW yT];
u = uicontrol(editProps);

textProps.String = 'Right';
textProps.Position(1:2) = [xR yB];
u = uicontrol(textProps);
editProps.Tag = textProps.String;
editProps.String = num2str(R);
editProps.Position(1:2) = [xR+mW yB];
u = uicontrol(editProps);

yU = row(7);
textProps.String = 'Units:';
textProps.HorizontalAlignment = 'right';
textProps.Position = [x(1)+5 yU col3W-5 rowH];
u = uicontrol(textProps);

paperUnitOptions = set(dlg, 'PaperUnits');
popProps.String = paperUnitOptions;
popProps.Value = ...
        find(strcmp(template.marginUnits,popProps.String));
popProps.Position = [x(2) yU col3W rowH];
popProps.Callback = 'frameedit dlg dopagesetupdlg setmarginunits foo';
popProps.Tag = 'MarginUnitsPopup';
u = uicontrol(popProps);



% Cancel
pushProps.String = 'Cancel';
pushProps.Callback = 'frameedit dlg dopagesetupdlg cancel foo';
pushProps.Position = [x(1) row(end) col3W rowH];
u = uicontrol(pushProps);

% Apply
pushProps.String = 'Apply';
pushProps.Callback = 'frameedit dlg dopagesetupdlg apply foo';
pushProps.Position = [x(2) row(end) col3W rowH];
u = uicontrol(pushProps);

% OK
pushProps.String = 'OK';
pushProps.Callback = 'frameedit dlg dopagesetupdlg ok foo';
pushProps.Position = [x(3) row(end) col3W rowH];
u = uicontrol(pushProps);


set(dlg,'Visible','on');

function LConvertFrom52FrameFiles(f)
HGVector = findall(f);
for aHGObj = HGVector'
   ud = get(aHGObj,'UserData');
   if isstruct(ud) & isfield(ud,'ObjectStore') | ...
              isa(ud,'fighandle');
      setscribeobjectdata(aHGObj, ud);
      set(aHGObj,'UserData',[]);
   end
   if strcmp(get(aHGObj,'type'),'text')
     uic = get(aHGObj,'UIContextMenu');
     if ~isempty(uic)
       colorMenu = findall(uic,'Tag','ScribeAxistextObjColorMenu');
       set(colorMenu,...
	   'Callback','domethod(getobj(gco),''editcolor'')');
     end
   end
end
ax = findobj(HGVector,'Tag','ScribeOverlayAxesActive');
set(ax,'ButtonDownFcn','','HitTest','off');

function LConvertTo52FrameFiles(f)
HGVector = findall(f);
for aHGObj = HGVector'
  ud = getscribeobjectdata(aHGObj);
  if ~isempty(ud)
   set(aHGObj,'UserData',ud);
  end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dataRef=getcdata(dataRef,bgc)
%GETCDATA returns background-transparent button CDATA
%   CDATA=GETCDATA(FILENAME,BGC)
%      FILENAME is the full path to a MAT-file containing CDATA images
%         if FILENAME is empty or omitted,
%         use MATLABROOT/toolbox/simulink/simulink/frameedit.mat
%      BGC (optional) - backgroundcolor to use.  Should be a 1x3 colorspec 
%         default is get(0,'defaultuicontrolbackgroundcolor')
%
%   CDATA=GETCDATA(FSTRUCT,BGC)
%      FSTRUCT is a structure containing CDATA

if nargin<2
   bgc=255*get(0,'DefaultUIcontrolBackgroundColor');
   if nargin<1
      dataRef='';
   end
else
   bgc=255*bgc;
end

%The CDATA for the frame editor lives in
%toolbox/simulink/simulink/private/frameedit.mat
if ischar(dataRef)
   if isempty(dataRef)
      %dataRef=[matlabroot filesep 'toolbox' filesep ...
      %      'simulink' filesep 'simulink' filesep ...
      %      'private' filesep 'frameedit.mat'];
      dataRef='frameedit.mat';
   end
   
   try
      dataRef=load(dataRef,'-mat');
   catch
      warning(['CDATA MAT-file ' dataRef ' could not be loaded.']);
      dataRef=[];
   end
end

if isstruct(dataRef)
   dataRef=LocProcessStructure(dataRef,bgc);
else
   dataRef=[];
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function   cdStruct=LocProcessStructure(cdStruct,bgc);

sFieldnames=fieldnames(cdStruct);

for i=1:length(sFieldnames)
   sField=getfield(cdStruct,sFieldnames{i});
   if isstruct(sField)
      sField=LocProcessStructure(sField,bgc);
   elseif isnumeric(sField)
      sField=LocProcessMatrix(sField,bgc);
   end   
   cdStruct=setfield(cdStruct,sFieldnames{i},sField);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cData=LocProcessMatrix(cData,bgc);
%remove NAN's out and replace with BGC

nanIndex=find(isnan(cData(:,:,1)));
if ~isempty(nanIndex)
   for k=1:3
      cLayer=cData(:,:,k);
      cLayer(nanIndex)=ones(1,length(nanIndex))*bgc(k);
      cData(:,:,k)=cLayer;
   end
end

cData=uint8(cData);

