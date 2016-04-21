function c=attribute(c,action,varargin)
%ATTRIBUTE launches the setup file editor options page
%   C=attribute(C,ACTION,OPTIONS....)

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:13:19 $

c=feval(action,c,varargin{:});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=start(c)

fileFrame=controlsframe(c,'Image Filename');
optFrame=controlsframe(c,'Image Title');
preFrame=controlsframe(c,'Image Preview');

c=controlsmake(c,{'isTitle' 'Title' 'FileName' 'isInline'...
      'isCopyFile'});

c.x.previewAxes=axes('Parent',c.x.all.Parent,...
   'Tag',c.x.all.Tag,...
   'HandleVisibility',c.x.all.HandleVisibility,...
   'Units',c.x.all.Units,...
   'Color',[.7 .7 .7],... %note this is the same color as proptable axes
   'Box','on',...
   'Xtick',[],...
   'Ytick',[],...
   'XTickLabelMode','manual',...
   'YTickLabelMode','manual',...
   'XTickLabel',[],...
   'YTickLabel',[]);

c.x.errorMessage=text('Parent',c.x.previewAxes,...
   'Tag',c.x.all.Tag,...
   'HandleVisibility',c.x.all.HandleVisibility,...
   'String','',...
   'Units','normalized',...
   'Position',[40 -40],...
   'HorizontalAlignment','center',...
   'Clipping','on'); %,...
%   'FontSize',18);

c.x.previewImage=image('Parent',c.x.previewAxes,...
   'Tag',c.x.all.Tag,...
   'ButtonDownFcn',[c.x.getobj,'''ExpandPreview'');'],...
   'Clipping','on',...
   'HandleVisibility',c.x.all.HandleVisibility);


fileFrame.FrameContent={num2cell(c.x.FileName)
   c.x.isCopyFile};
      
preFrame.FrameContent={c.x.previewAxes};

optFrame.FrameContent={
   {c.x.isTitle(1) c.x.isInline
      c.x.isTitle(2) c.x.Title}
   c.x.isTitle(3)
};

c.x.LayoutManager={
   fileFrame
   [5]
   optFrame
   [5]
   preFrame};

c=resize(c);
LocUpdateEnable(c);
LocUpdatePreview(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=refresh(c);
%Update component when switching tabs, moving
%deactivating


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=resize(c)

c=controlsresize(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=Update(c,whichControl,varargin);

c=controlsupdate(c,whichControl,varargin{:});

switch whichControl
case 'FileName'
   LocUpdatePreview(c);
case 'isTitle'
   LocUpdateEnable(c);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocUpdateEnable(c);

set(c.x.Title,'Enable',...
   onoff(strcmp(c.att.isTitle,'local')));
set(c.x.isInline,'Enable',...
   onoff(strcmp(c.att.isTitle,'none')));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocUpdatePreview(c);

fileName = parsevartext(c,c.att.FileName);
try
   oldWarn=nenw(c);
   [img,map]=imread(fileName);
   nenw(c,oldWarn);
   warnStr='';
catch
   img=[];
   map=[];
   fileExist=exist(fileName);
   if ~isempty(fileExist) & fileExist==2
      dotIndex=findstr(fileName,'.');
      if ~isempty(dotIndex)
         ext=c.att.FileName(dotIndex(end)+1:end);
      else
         ext='';
      end
      if any(strcmpi({'jpeg','jpg','gif','eps','ps','bmp',...
               'tiff','ill','png','emf'},ext))
         warnStr=xlate('Can not preview image file');
      else
         warnStr=xlate('Warning - can not preview file');
      end
   else
      warnStr=xlate('Error - file not found');
   end
end

imgSize=size(img);
if imgSize(1)>0
   if ~isempty(map)
      img=ind2rgb(img,map);
   end
   
   img=flipdim(img,1);
   set(c.x.previewImage,'CData',img);
   set(c.x.previewAxes,...
      'PlotBoxAspectRatioMode','manual',...
      'PlotBoxAspectRatio',[imgSize(2) imgSize(1) 1],...
      'Xlim',[1 imgSize(2)],...
      'Ylim',[1 imgSize(1)]);
   set(c.x.errorMessage,'Position',[40 -40],'String',warnStr);
else
   set(c.x.errorMessage,'Position',[.5 .5],'String',warnStr);
   set(c.x.previewImage,'CData',[]);
   set(c.x.previewAxes,...
      'PlotBoxAspectRatioMode','auto');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=ExpandPreview(c)

img=get(c.x.previewImage,'cdata');

imgSize=size(img);
if imgSize(1)>0
   
   oldUnits=get(0,'Units');
   set(0,'Units','pixels');
   screenSize=get(0,'ScreenSize');
   set(0,'Units',oldUnits);
   
   figOffset=50;
   figPos=[figOffset,...
         screenSize(4)-figOffset-imgSize(1),...
         imgSize(2),...
         imgSize(1)];
   
   viewFig=figure('MenuBar','none',...
      'Units','Pixels',...
      'Color',c.x.all.BackgroundColor,...
      'DoubleBuffer','on',...
      'NumberTitle','off',...
      'Visible','off',...
      'Position',figPos,...
      'Name',sprintf('Image - %s', c.att.FileName),...
      'Tag','RPTGEN_IMAGE_VIEWER');
   
   
   newAx=copyobj(c.x.previewAxes,viewFig);
   set(newAx,'Units','normalized','position',[0 0 1 1]);
   
   newImg=findall(newAx,'type','image');
   set(newImg,'ButtonDownFcn','');
   
   set(viewFig,...
      'Visible','on');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function strOnOff=onoff(logOnOff)

if logOnOff
   strOnOff='on';
else
   strOnOff='off';
end

