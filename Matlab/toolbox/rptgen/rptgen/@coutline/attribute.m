function c=attribute(c,action,varargin)
%ATTRIBUTE launches the setup file editor options page

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:10:20 $

c=feval(action,c,varargin{:});

%--------1---------2---------3---------4---------5---------6---------7---------8
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=start(c)

c.x.cdata=getcdata(c.rptcomponent,...
	fullfile(fileparts(mfilename('fullpath')),'iconcdata.mat'));


nameFrame=controlsframe(c,'Report File Location');
transFrame=controlsframe(c,'Report Format & Stylesheet');
genFrame=controlsframe(c,'Generation Options');

%make all of the other controls
c=controlsmake(c,{'DirectoryType','DirectoryName',...
      'FilenameType','FilenameName','isIncrementFilename',...
      'Format','Stylesheet','Description'});

set([c.x.DirectoryTypeTitle c.x.FilenameTypeTitle ...
      c.x.DescriptionTitle],'HorizontalAlignment','left');
set([c.x.Format c.x.Stylesheet],{'ToolTipString'},...
   {xlate('Format');xlate('Stylesheet')});

c.x.NameFeedback=uicontrol(c.x.all,...
   'FontWeight','bold',...
   'horizontalalignment','left',...
   'Style','text');
c.x.DirectoryBrowse= uicontrol(c.x.all,...
   'FontWeight','bold',...
   'Style','pushbutton',...
   'BackgroundColor',get(0,'defaultuicontrolbackgroundcolor'),...
   'Callback',[c.x.getobj,'''BrowseDirectory'');'],...
   'String','...');

%c.x.StylesheetDescription=uicontrol(c.x.all,...
%   'HorizontalAlignment','left',...
%   'Enable','inactive',...
%   'Style','edit');

c.x.OptionsButton=uicontrol(c.x.all,...
   'Style','pushbutton',...
   'BackgroundColor',get(0,'defaultuicontrolbackgroundcolor'),...
   'String','Edit...',...  %'FontWeight','bold',...
   'Callback',[c.x.getobj,'''GenerationOptions'');']);

controlList={'isView','isRegenerateImages','isAutoSaveOnGenerate'};
for i=1:length(controlList)
   currUserData=getfield(c.x.cdata,controlList{i});
   atx=getattx(c,controlList{i});
   currH=uicontrol(c.x.all,...
      'style','pushbutton',...
      'Callback',[c.x.getobj,'''ToggleOption'',''' controlList{i} ''');'],...
      'ToolTipString',atx.String,...
      'UserData',currUserData);
   c.x=setfield(c.x,[controlList{i} 'Toggle'],currH);   
end

UpdateOptionsView(c);


%--Context strings-------------------

[sPath sName sExt sVer]=fileparts(c.rptcomponent.SetfilePath);
if isempty(sName)
   sName='Unnamed';
end
if isempty(sPath)
   sPath=pwd;
end

contextStrings={sprintf('Same as setup file (%s)', sPath ) 
   sprintf('Same as setup file (%s)', sName )};

set([c.x.DirectoryType(1) c.x.FilenameType(1)],...
   {'string'},contextStrings);

c.x.PresentDirectoryRadiobutton=c.x.DirectoryType(2);
LocPwdString(c);

%--Stylesheet & Format Popups--------
c=InitializePopupMenus(c);

%---Enabling of custom name edits ----------

set([c.x.DirectoryName c.x.DirectoryBrowse],'enable',...
   onoff(strcmp(c.att.DirectoryType,'other')));

set(c.x.FilenameName,'enable',...
   onoff(strcmp(c.att.FilenameType,'other')));

LocUpdateFilename(c)

%------------layout ---------------------

nameFrame.FrameContent={
   [1]
   c.x.NameFeedback
   [1]
   {c.x.DirectoryTypeTitle c.x.DirectoryType(1)
      'indent' c.x.DirectoryType(2)
      'indent' ...
         {c.x.DirectoryType(3) c.x.DirectoryName c.x.DirectoryBrowse}
      [1] [1]
      c.x.FilenameTypeTitle c.x.FilenameType(1)
      'indent' {c.x.FilenameType(2) c.x.FilenameName}
      'indent' c.x.isIncrementFilename}};

%transFrame.FrameContent=   {c.x.FormatTitle c.x.Format [3] [5]
%   c.x.StylesheetTitle c.x.Stylesheet [3] c.x.StylesheetDescription};

transFrame.FrameContent={c.x.Format c.x.Stylesheet};


genFrame.FrameContent={c.x.isAutoSaveOnGenerateToggle [3] ...
      c.x.isViewToggle [3] c.x.isRegenerateImagesToggle [3] c.x.OptionsButton  };

c.x.LayoutManager={nameFrame
   [1]
   transFrame
   [1]
   genFrame};

c=resize(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=refresh(c);
%Update component when switching tabs, moving
%deactivating

LocPwdString(c);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=resize(c)

c=controlsresize(c);

% make sure push button has same height as toggle buttons
togglePos=get(c.x.isViewToggle,'Position');
pushPos=get(c.x.OptionsButton,'Position');
pushPos([2,4])=togglePos([2,4]);
set(c.x.OptionsButton,'Position',pushPos);


%position the "Description" field in the remaining space
yPad=5;
barht=13;
if c.x.lowLimit>c.x.yzero+2*yPad+2*barht
   xStart=c.x.xzero+c.x.pad;
   xWid=c.x.xext-c.x.xzero-2*c.x.pad;
   yTitle=c.x.lowLimit-yPad-barht;
   yEdit=c.x.yzero+yPad;
   
   set([c.x.Description c.x.DescriptionTitle],{'position'},...
      {[xStart,...
            yEdit,...
            xWid,...
            yTitle-yEdit];...
         [xStart,...
            yTitle,...
            xWid,...
            barht]});   
   c.x.InvisibleHandles=[];
else
   c.x.InvisibleHandles=[c.x.Description c.x.DescriptionTitle];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=Update(c,whichControl,varargin);

oldDir=c.att.DirectoryName;

c=controlsupdate(c,whichControl,varargin{:});
switch whichControl
case 'DirectoryType'
   set([c.x.DirectoryName c.x.DirectoryBrowse],'enable',...
      onoff(strcmp(c.att.DirectoryType,'other')));
case 'DirectoryName'
   aPath=c.att.DirectoryName;
   
   if isempty(findstr(aPath,'%<'))
      %Checking to see if a filename was also given
      dotLoc=findstr(aPath,'.');
      
      if isempty(dotLoc)
         aPath=fullfile(aPath,'*.*');
      end
      [aPath aFile aExt aVer]=fileparts(aPath);
	   c.att.DirectoryName=aPath;
	   set(c.x.DirectoryName,'String',aPath);
   end
case 'FilenameName'
   [aPath aFile aExt aVer]=fileparts(...
      c.att.FilenameName);
   
   if isempty(aFile)
      aFile='report';
   end
   
   c.att.FilenameName=aFile;
   set(c.x.FilenameName,'String',aFile);
   
   if ~isempty(aPath)
      if exist(aPath)==7
         c.att.DirectoryName=[aPath filesep];
         set(c.x.DirectoryName,'String',[aPath filesep]);
         
         c.att.DirectoryType='other';
         set(c.x.DirectoryType,'Value',0);
         set(c.x.DirectoryType(3),'Value',1);
         set([c.x.DirectoryName c.x.DirectoryBrowse],'Enable','on')
      end
   end
   
case 'FilenameType'
   set(c.x.FilenameName,'enable',...
      onoff(strcmp(c.att.FilenameType,'other')));
case 'Format'
   c=LocValidateStyleSheet(c);
   c.rptcomponent.Format=c.att.Format;
case 'Stylesheet'
   LocUpdateStylesheetDescription(c);
end   

LocPwdString(c);

LocUpdateFilename(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=BrowseDirectory(c);
%triggered when user selects the "..." button

[rPath,rFile,rExt]=getrptname(c);

rPath = uigetdir(rPath,...
    'Select report directory');

if ~isnumeric(rPath)
   set(c.x.DirectoryName,'String',rPath);
   c.att.DirectoryName=rPath;
   LocUpdateFilename(c);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function strVal=onoff(logVal)

if logVal
   strVal='on';
else
   strVal='off';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=LocValidateStyleSheet(c);

ValidStyleIndex=getfield(c.x.formats,upper(c.att.Format));

styleString={c.x.sheets(ValidStyleIndex).Name};
styleID={c.x.sheets(ValidStyleIndex).ID};

styleIndex=find(strcmp(styleID,c.att.Stylesheet));

styleEnable='on';
if isempty(styleIndex)
   if ~isempty(styleID)
      styleIndex=1;
      c.att.Stylesheet=styleID{styleIndex};
   else
      styleString={' '};
      styleID={''};
      styleindex=1;
      c.att.Stylesheet='';
      styleEnable='off';
   end   
else
   styleIndex=styleIndex(1);
end

set(c.x.Stylesheet,'UserData',styleID,...
   'String',styleString,...
   'Enable',styleEnable,...
   'Value',styleIndex);
LocUpdateStylesheetDescription(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sList=LocMakeStylesheetList(c);

persistent RPTGEN_STYLESHEET_LIST

if isempty(RPTGEN_STYLESHEET_LIST)
   RPTGEN_STYLESHEET_LIST=stylesheets(c);
end

sList=RPTGEN_STYLESHEET_LIST;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fStruct=LocMakeFormatList(sStruct);

allFormats=preferences(rptparent);
allFormats={allFormats.format.Name};
[emptyCells{1:length(allFormats)}]=deal({[]});
allCells=[allFormats;emptyCells];
fStruct=struct(allCells{:});

for i=1:length(sStruct)
   [matchNames,matchIndexA,matchIndexB]=intersect(...
      upper(sStruct(i).Formats),allFormats);
   
   for j=1:length(matchNames)
      currVal=getfield(fStruct,matchNames{j});
      fStruct=setfield(fStruct,matchNames{j},[currVal i]);
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function formatInfo=LocPruneFormats(formatInfo,validFormats)

i=1;
while i<=length(formatInfo)
   if isempty(getfield(validFormats,formatInfo(i).Name))
      %there are no valid stylesheets for this format
      formatInfo=formatInfo([1:i-1,i+1:end]);
   else
      i=i+1;
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocUpdateFilename(c)

[rDir,rFile,rExt]=getrptname(c);
set(c.x.NameFeedback,'String',fullfile(rDir,[rFile '.' rExt]));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocUpdateStylesheetDescription(c)

sheetIndex=find(strcmp({c.x.sheets.ID},c.att.Stylesheet));
if isempty(sheetIndex)
   descText='';
else
   descText=c.x.sheets(sheetIndex(1)).Description;
end

statbar(c,descText);

%set(c.x.StylesheetDescription,'String',descText);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=InitializePopupMenus(c);

c.x.sheets=LocMakeStylesheetList(c);
c.x.formats=LocMakeFormatList(c.x.sheets);

formatInfo=preferences(c);
formatInfo=LocPruneFormats(formatInfo.format,c.x.formats);

formatvalues={formatInfo.Name};
formatstring={formatInfo.Desc};

formatindex=find(strcmpi(formatvalues,c.att.Format));

set(c.x.Format,'UserData',formatvalues,...
   'String',formatstring,...
   'Value',formatindex);

c=LocValidateStyleSheet(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=GenerationOptions(c)
%launch the "options" modal dialog

c=optionsdialog(c,'start');

UpdateOptionsView(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=ToggleOption(c,whichControl)

currVal=~getfield(c.att,whichControl);
c.att=setfield(c.att,whichControl,currVal);
UpdateOptionsView(c,whichControl);


%c=GenerationOptions(c);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function UpdateOptionsView(c,whichControl)

if nargin<2
   whichControl={'isView','isRegenerateImages','isAutoSaveOnGenerate'};
else
   whichControl={whichControl};
end

for i=1:length(whichControl)
   currH=getfield(c.x,[whichControl{i} 'Toggle']);
   currUserData=get(currH,'UserData');
   currVal=getfield(c.att,whichControl{i});
   
   if currVal
      currCdata=currUserData.ok;
   else
      currCdata=currUserData.no;
   end
   
   set(currH,'CData',currCdata);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocPwdString(c)
%sets the Present Working Directory context string

set(c.x.PresentDirectoryRadiobutton,'string',...
   sprintf('Present working directory (%s)',pwd));