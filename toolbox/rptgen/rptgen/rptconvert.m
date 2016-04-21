function varargout=rptconvert(varargin)
%RPTCONVERT  Transform Report Generator source to desired output format
%   RPTCONVERT will transform a DocBook source file of the
%   type created by the Report Generator to a formatted document.
%
%   RPTCONVERT called with no input arguments will launch the 
%   conversion GUI.
%
%   RPTNAME=RPTCONVERT(SOURCE)
%   RPTNAME=RPTCONVERT(SOURCE,FORMAT)
%   RPTNAME=RPTCONVERT(SOURCE,FORMAT,STYLESHEET)
%
%   SOURCE is the name of the DocBook file (with or without the
%      file extension)
%   FORMAT is a unique identifier code for each output format type.
%      Omitting FORMAT will result in a transform to HTML.
%   STYLESHEET is a unique identifier to a stylesheet.
%      Omitting STYLESHEET will use the default stylesheet for
%      the selected FORMAT.
%
%   See also SETEDIT, REPORT, RPTLIST, COMPWIZ

% To get v1.x capability, type "RptgenML.v1mode(true)"
% V1 only:
%      A list of 
%      stylesheet ID's is returned by typing RPTCONVERT #STYLESHEETLIST
%      ID's are in the first column, a description is in the second.
%
%   [RPTNAME,STATMSG]=RPTCONVERT(SOURCE,....)
%   When called with two output arguments, status messages from the 
%   conversion engine are returned in the second output.


%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/26 23:54:31 $

if nargin==0
	if (RptgenML.v1mode)
		ActionStartGUI;
	else
		r = RptgenML.Root;
		r.getEditor;
		RptgenML.FileConverter(RptgenML.Root);
	end
else
   if strncmp(varargin{1},'?',1)
      rptconvertFigure=gcbf;
      c=get(rptconvertFigure,'UserData');
      c=feval(varargin{1}(2:end),c,varargin{2:end});
      if ishandle(rptconvertFigure)
         set(rptconvertFigure,'UserData',c);
      end
   elseif strcmpi(varargin{1},'#STYLESHEETLIST')
	   if (RptgenML.v1mode)
		   sList=stylesheets(rptparent);
		   varargout{1}=[{sList(:).ID}' {sList(:).Name}'];
	   else
		   varargout=cell(0,2);
		   warning('This option not supported');
		   %@TODO: bring this back for V2
	   end
   elseif (RptgenML.v1mode)
      [rptName,errMsg]=ConvertFromCmdLine(varargin{:});
      if any(strcmpi(varargin,'-view')) & ...
            ~isempty(rptName)
         rptviewfile(rptName);
      end
      
      if any(strcmpi(varargin,'-messages')) & ~isempty(errMsg)
         disp(singlelinetext(rptparent,errMsg,sprintf('\n')));
      end
      
      if nargout>0
         varargout{1}=rptName;
         if nargout>1
            varargout{2}=errMsg;
         end
      end
   else
	   %v2 mode
	   fc = RptgenML.FileConverter;
	   if nargin>0 && ~isequal(varargin{1},'-')
		   %@TODO: get DocBook source extension from prefs
		   fc.SrcFileName = rptgen.findFile(varargin{1},true,'xml','db','sgml');
		   if nargin>1 && ~isequal(varargin{2},'-')
			   fc.Format = varargin{2};
			   if nargin>2 && ~isequal(varargin{3},'-')
				   fc.setStylesheet(varargin{3})
			   end
		   end
	   end
	   if any(strcmp(varargin,'-view'))
		   fc.View = true;
	   elseif any(strcmp(varargin,'-noview'))
		   fc.View = false;
	   end
	   
	   varargin{1} = fc.cbkConvert;
	   if nargout>1
		   varargout{2}={''};
	   end
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ActionStartGUI

figTag='rptconvert_Figure';

allFigs=allchild(0);
allTags=get(allFigs,'tag');
if ~isempty(allTags)
   matchIndex=find(strcmp(allTags,figTag));
   if ~isempty(matchIndex)
      figure(allFigs(matchIndex(1)));
      return;
   end
end

c=LocMakeCoutline;

figPos=[ 0 0 c.x.xlim c.x.ylim];
c.x.all.Parent = figure('DoubleBuffer','on',...
   'Units',c.x.all.Units,...
   'HandleVisibility',c.x.all.HandleVisibility,...
   'IntegerHandle','off',...
   'MenuBar','none', ...
   'Color',c.x.all.BackgroundColor,...
   'Name','Convert an SGML File', ...
   'Visible','off',...
   'Position',figPos,...
   'NumberTitle','off', ... %'WindowStyle','modal',...
   'resize','off',...
   'closerequestfcn','rptconvert ?ActionCancelButton',...
   'Tag',figTag);

sourceFrame=controlsframe(c,'SGML Source File');
transformFrame=controlsframe(c,'Conversion Options');

c=controlsmake(c,{'Format' 'Stylesheet' 'isView'});

%set(c.x.FilenameNameTitle,'String','SGML source file ');

%%%%%%%%%%%%%%%% Need to change callbacks on controls
set(c.x.Format,...
   'Callback','rptconvert ?ActionUpdate Format');
set(c.x.Stylesheet,...
   'Callback','rptconvert ?ActionUpdate Stylesheet');
set(c.x.isView,...
   'Callback','rptconvert ?ActionUpdate isView',...
   'String','View report after converting');

%%%%%%%%%%%%%%%%%%% Create dummy handles
c.x.PresentDirectoryRadiobutton=[];

%%%%%%%%%%%%%%%%%%% Create new UIcontrols

pwdSgmlFiles=dir('*.sgml');
if length(pwdSgmlFiles)==0
   currFile='';
   enableConvert='off';
else
	for i=length(pwdSgmlFiles):-1:1
		fileDate = datenum(pwdSgmlFiles(i).date);
	end
    [lastDate,dateIndex]=max(fileDate);
    currFile=fullfile(pwd,pwdSgmlFiles(dateIndex).name);
    enableConvert='on';
end

c.x.isEchoJadeErrors=uicontrol(c.x.all,...
   'Style','checkbox',...
   'String','Display conversion status messages in command window',...
   'Max',logical(1),'Min',logical(0),'Value',logical(0),...
   'HorizontalAlignment','right');

c.x.FormatTitle=uicontrol(c.x.all,...
   'Style','text',...
   'String','Format  ',...
   'HorizontalAlignment','right');

c.x.StylesheetTitle=uicontrol(c.x.all,...
   'Style','text',...
   'String','Stylesheet  ',...
   'HorizontalAlignment','right');

c.x.SourceName=uicontrol(c.x.all,...
   'Style','edit',...
   'String',currFile,...
   'BackgroundColor','white',...
   'Callback','rptconvert ?ActionChangeSource',...
   'HorizontalAlignment','left');

%c.x.SourceNameTitle=uicontrol(c.x.all,...
%   'Style','text',...
%   'horizontalAlignment','right',...
%   'String','SGML source file ');

c.x.SourcefileBrowse= uicontrol(c.x.all,...
   'FontWeight','bold',...
   'Style','pushbutton',...
   'Callback','rptconvert ?ActionBrowseSource',...
   'String','...');

%c.x.StylesheetDescription=uicontrol(c.x.all,...
%   'HorizontalAlignment','left',...
%   'ToolTipString','Stylesheet description',...
%   'Enable','inactive',...
%   'Style','edit');

%NameFeedback is expected by coutline/attribute
%we're not interested in it here, so just let it be invisible
c.x.NameFeedback=uicontrol(c.x.all,...
   'style','text',...
   'string','',...
   'Visible','off');

c.x.ConvertButton=uicontrol(c.x.all,...
   'Style','pushbutton',...
   'String','Convert',...
   'Enable',enableConvert,...
   'Callback','rptconvert ?ActionConvertButton');

c.x.CancelButton=uicontrol(c.x.all,...
   'Style','pushbutton',...
   'String',' Cancel ',...
   'Callback','rptconvert ?ActionCancelButton');

c.x.HelpButton=uicontrol(c.x.all,...
   'Style','pushbutton',...
   'String','  Help  ',...
   'Callback', 'helpview(rptparent,''rptconvert'',''product'');');

c.x.statusbar=uicontrol(c.x.all,...
   'Enable','inactive',...
   'Style','edit',...
   'String','',...
   'HorizontalAlignment','left');

c=attribute(c,'InitializePopupMenus');

%styleText=get(c.x.StylesheetDescription,'String');
%set(c.x.StylesheetDescription,'String',['stylesheet - ' styleText]);

sourceFrame.FrameContent={[5]
   {c.x.SourceName c.x.SourcefileBrowse}
   [5]};
transformFrame.FrameContent={{[5] [5]
      c.x.FormatTitle c.x.Format
      [2] [inf 2]
      c.x.StylesheetTitle c.x.Stylesheet
      [5] [inf 5]}
   c.x.isView
   c.x.isEchoJadeErrors
   [3]};

c.x.LayoutManager={[5]
   sourceFrame
   [5]
   transformFrame
   [5]
   c.x.statusbar
   [3]
   {c.x.HelpButton [inf 5] c.x.ConvertButton [5] c.x.CancelButton}};

c=controlsresize(c);

yTrans=c.x.lowLimit-5;

%translate everything down
figChildren=allchild(c.x.all.Parent);
objPos=get(figChildren,'Position');
objPos=cat(1,objPos{:});
objPos(:,2)=objPos(:,2)-yTrans;
objPos=num2cell(objPos,2);
set(figChildren,{'Position'},objPos);

set(c.x.statusbar,'String','');
set(c.x.all.Parent,...
   'UserData',c,...
   'Visible','on',...
   'Position',LocFigPos(figPos(3),figPos(4)-yTrans));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=ActionUpdate(c,whichControl);

c=attribute(c,'Update',whichControl);
%switch whichControl
%case {'Format' 'Stylesheet'}
%   styleText=get(c.x.StylesheetDescription,'String');
%   set(c.x.StylesheetDescription,'String',['stylesheet - ' styleText]);
%end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=ActionChangeSource(c)

fileStr=get(c.x.SourceName,'String');
if isempty(fileStr)
   convertEnable='off';
else
   convertEnable='on';
end

set(c.x.ConvertButton,'Enable',convertEnable);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=ActionConvertButton(c);

sgmlSource=get(c.x.SourceName,'String');

set(c.x.statusbar,...
   'String',sprintf('Converting %s', sgmlSource ));

allControls=findall(allchild(c.x.all.Parent),'flat',...
   'type','uicontrol');
textControls=findall(allControls,'flat','style','text');
allControls=setdiff(allControls,textControls);

prevEnable=get(allControls,'Enable');
set(allControls,'Enable','off');
set(c.x.statusbar,'Enable','on');
set(c.x.all.Parent,'Pointer','watch');
drawnow

[reportName,errMsg]=ConvertSgmlFile(c,sgmlSource);

if get(c.x.isEchoJadeErrors,'Value') & ~isempty(errMsg)
   disp(singlelinetext(rptparent,errMsg,sprintf('\n')));
end

set(c.x.all.Parent,'Pointer','arrow');
set(allControls,{'Enable'},prevEnable);
drawnow

if ~isempty(reportName)
   statString=sprintf('Conversion complete - %s', reportName );
else
   statString='Conversion failed.';
end
set(c.x.statusbar,'String',statString);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=ActionCancelButton(c);

delete(gcbf);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=ActionBrowseSource(c)
%triggered when Browse button is selected

startFile=get(c.x.SourceName,'String');
[fPath fFile fExt]=fileparts(startFile);
if isempty(fPath)
   fPath=pwd;
end
if isempty(fFile)
    fFile='*';
end
fExt='.sgml';

%filterSpec={'*.sgml','SGML source files (*.sgml)'
%   '*.*','All files (*.*)'},...

[fileName,pathName] = uigetfile(fullfile(fPath,[fFile,fExt]),...
   'Select File to Convert');

if ~isnumeric(fileName)
   fileName=fullfile(pathName,fileName);
   set(c.x.SourceName,'String',fileName);
   c=ActionChangeSource(c);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [reportName,errMsg]=ConvertFromCmdLine(varargin)

c=LocMakeCoutline;

if nargin<3 | LocIsFlag(varargin{3})
   dslScript='';
else
   dslScript=varargin{3};
end

if nargin<2 | LocIsFlag(varargin{2})
   OutputFormat='HTML';
elseif strcmpi(varargin{2},'RTF')
   OutputFormat='RTF95';
else
   OutputFormat=varargin{2};
end

if nargin<1 | LocIsFlag(varargin{1})
   pwdSgmlFiles=dir('*.sgml');
   if length(pwdSgmlFiles)==0
      sgmlSource='Unnamed.sgml';
   else
      sgmlSource=fullfile(pwd,pwdSgmlFiles(1).name);
   end
else
   sgmlSource=varargin{1};
end

         
c.att.Format=OutputFormat;
c.att.Stylesheet=dslScript;

if any(strcmpi(varargin,'-debug'))
   c.att.isDebug=logical(1);
end

[reportName,errMsg]=ConvertSgmlFile(c,sgmlSource);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tf=LocIsFlag(argString)

tf=any(strcmpi({'-view','-messages','-debug'},argString));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [reportName,errMsg]=ConvertSgmlFile(c,sourceName);

[rDir,rName,rExt,c]=getrptname(c,sourceName);
[reportName,errMsg]=convertoutputfile(c);
errMsg=errMsg(:);
if c.att.isView & ~isempty(reportName)
   rptviewfile(reportName);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=LocMakeCoutline;

p=coutline('DirectoryType','setfile',...
   'FilenameType','setfile',...
   'isView',logical(0));
c=unpoint(p);

x.all=struct('Units','Points',...
   'Tag','RptconvertUicontrol',...
   'Visible','on',...
   'HandleVisibility','off',...
   'BackgroundColor',get(0,'defaultuicontrolbackgroundcolor'));

Xlim=300;
Ylim=500;

x.getobj= '';
x.xzero = 0;
x.xext  = Xlim;
x.xlim  = Xlim;
x.ylim  = Ylim;
x.yorig = 0;
x.yzero = 0;

c.x=x;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fPos=LocFigPos(figWd, figHt);


oldUnits=get(0,'Units');
set(0,'Units','Points');
screen=get(0,'ScreenSize');
set(0,'Units',oldUnits);

hoffset=90;
voffset=90;

screenWd=screen(3);
screenHt=screen(4);

if screenWd<figWd+hoffset;
   hoffset=0;
end

if screenHt<figHt+voffset;
   voffset=0;
end

fPos=[hoffset, screen(4)-voffset-figHt, ...
      figWd figHt];
   
   
