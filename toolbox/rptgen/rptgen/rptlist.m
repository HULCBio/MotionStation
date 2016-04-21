function varargout=rptlist(varargin)
%RPTLIST returns a list of all .rpt files on the path
%   LIST=RPTLIST returns a list of all .rpt files on 
%   the MATLAB path.
%
%   RPTLIST by itself opens the Report Generator editor with a
%   list of all available setup files.  These files can be opened,
%   run, or associated with the current Simulink system.
%
%   RPTLIST('system_name') starts the GUI with the Simulink system's 
%   "ReportName" property selected.
%
%   See also: SETEDIT, REPORT, RPTCONVERT, COMPWIZ

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:12:52 $

%-------1--------2--------3--------4--------5--------6--------7--------8

% v1 info.  To get v1 behavior, do "RptgenML.v1mode(true)"
%RPTLIST can be started in the following modes:
%RPTLIST ?Mode 'ModeName' modeOpt1,modeOpt2,....
%
%'cmdline' - starts with an "Edit" and "Report" button
%            opt1 (optional) - report name to start as selected
%            opt2 (optional) = '-generatereport' flag
%            Note: this is how RPTLIST starts if called with no input args
%
%'simulink' - adds a "set" button and enables associating names w/ systems
%            opt1 = system name
%            opt2 (optional) = '-generatereport' flag
%            Note: RPTLIST('system_name') or RPTLIST(system_handle) starts
%               the GUI in this mode.
%
%'report' -  has only the "Report" button.
%            opt1 (optional) - report name to start as selected
%            opt2 (optional) = '-generatereport' flag
%
%'arbitrary' - intended to return only the report name
%            opt1 (optional) - String to display on button.
%                defaults to "OK"
%            opt2 (optional) - ToolTipString for button. 
%                defaults to none
%            opt3 (optional) - other buttons to display.
%                =2 for the "Edit" button
%                =3 for the "Report" button
%                =[2 3] for both
%                =[] for neither (default)
%
%   RPTLIST by itself launches the "Setup File List"
%   GUI, which contains a list of all .rpt files on the
%   MATLAB path.  The "Edit" button opens the selected
%   setup file in the Setup File Editor.  "Report" generates
%   the currently selected setup file.  Additional setup
%   files can be  added to the list by using the edit box
%   or the browse button.
%
%   RPTLIST('system_name') starts the GUI with the
%   Simulink system's ReportName property selected.
%   The GUI has an additional button "Set" which
%   sets the selected setup file as the system's new
%   ReportName property.  Using the "Edit" or "Report"
%   buttons will open the editor or generate a report
%   without setting the ReportName property.

if nargin<1
   if nargout<1
	   if (RptgenML.v1mode)
		   StartGUI('cmdline');
	   else
		   viewChild(RptgenML.Root);
	   end
   else
      varargout{1}=LocGetFileList;
   end
else
   if strncmp(varargin{1},'?Action',7);
      %Perform GUI actions
      listFig=gcbf;
      k=get(listFig,'UserData');
      k=feval(varargin{1}(2:end),k,varargin{2:end});
      if ishandle(listFig)
         set(listFig,'UserData',k);
      end
   elseif strcmp(varargin{1},'?Mode')
      %rptlist ?Mode arbitrary
      %              report
      %              cmdline
      %              simulink
      
      rptName=StartGUI(varargin{2:end});
      
      if nargout>0
         varargout{1}=rptName;
      end
      
   else %nargin is still greater than 0
       try
           find_system(varargin{1},'SearchDepth',0);
           isSystem = logical(1);
       catch
           isSystem = logical(0);
           %note: what if someone passes in a root/system which is unloaded?
           if exist(varargin{1})==4
               try
                   load_system(varargin{1});    
                   isSystem = logical(1);
               end
           end
       end
            
      if nargin>1
         isImmediateGenerate=strcmpi(varargin{2},'-generatereport');
      else
         isImmediateGenerate=logical(0);
      end
      
      if isSystem
         modeFlag='simulink';
      else
         modeFlag='cmdline';
      end
      
	   if (RptgenML.v1mode)
		   rptName=StartGUI(modeFlag,varargin{:});
	   else
		   if isSystem
			   rptName = rptgen.findSlRptName(varargin{1});
			   rptObj = viewChild(RptgenML.Root,rptName);
			   
			   if isImmediateGenerate
				   rptName = cbkReport(RptgenML.Root,rptObj);
			   end
		   else
			   rptName = '';
			   viewChild(RptgenML.Root); 
		   end
	   end
		   
      
      if nargout>0
         varargout{1}=rptName;
      end
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function rptName=StartGUI(runMode,varargin)

figureTitle='Setup File List'; 
rptlistTag='rptlistFigure';
startReport='';
whichBtn=[2 3 4];
okBtnName='OK';
okBtnTTS='';
sysHandle=[];
windowStyle='normal';

runAction='';

existingFigureHandles=findall(allchild(0),...
   'flat',...
   'type','figure',...
   'tag',rptlistTag);
sameModeHandles=[];
for i=1:length(existingFigureHandles)
   figData=get(existingFigureHandles(i),'UserData');
   if isstruct(figData) & ...
         isfield(figData,'runMode') & ...
         strcmp(getfield(figData,'runMode'),runMode)
      sameModeHandles(end+1)=existingFigureHandles(i);
   end
end

switch runMode
case 'cmdline'
   %varargin{1} (optional) - the name of the report to be highlighted
   %varargin{2} (optional) - whether to immediately generate the report
   if isempty(sameModeHandles)
      existingFig=[];
   else
      existingFig=sameModeHandles(1);
   end
   
   if length(varargin)>0
      startReport=varargin{1};
      if length(varargin)>1 & strcmpi(varargin{2},'-generatereport');
         runAction='Report';
         figureTitle=[figureTitle ' - generating report ' startReport];
      end
   end
case 'simulink'
   %varargin{1} (optional) - the name of the system 
   %varargin{2} (optional) - whether to immediately generate the report
   
   if length(varargin)>0
      sysHandle=varargin{1};
      if length(varargin)>1 & strcmpi(varargin{2},'-generatereport');
         runAction='Report';
      end
   else
      sysHandle=gcs;
   end
   
   startReport=rptgenutil('SimulinkSystemReportName',sysHandle);

   
   if isempty(sameModeHandles)
      existingFig=[];
   else
      existingFig=[];
      i=1;
      numSLhandles=length(sameModeHandles);
      try
         targetHandle=get_param(sysHandle,'handle');
      catch
         targetHandle=-1;
      end
      
      while isempty(existingFig) & i<=numSLhandles
         ud=get(sameModeHandles(i),'UserData');
         try
            foundHandle=get_param(ud.sysHandle,'handle');
         catch
            foundHandle=-2;
         end
         
         if length(foundHandle) == length(targetHandle) & ...
               foundHandle == targetHandle
            existingFig=sameModeHandles(i);
         end
         i=i+1;
      end
   end
      
   try
      sysName=strrep(singlelinetext(...
         rptparent,get_param(sysHandle,'Name'),' '),...
         sprintf('\n'),' ');
      
   catch
      sysName='current Simulink system';
   end
   
   
   if strcmp(runAction,'Report')
      actionString='generate report';
   else
      actionString='select a setup file';
   end
   
   figureTitle=[figureTitle ' - ' actionString ' for ' sysName];
   
   whichBtn=[1 2 3 4];
   
   okBtnName='Set';
   okBtnTTS=sprintf('Set file as %s ReportName',sysName );
   
case 'report'
   
   if isempty(sameModeHandles)
      existingFig=[];
   else
      existingFig=sameModeHandles(1);
   end

   %varargin{1} (optional) - the name of the report to be highlighted
   %varargin{2} (optional) - whether to immediately generate the report

   if length(varargin)>0
      startReport=varargin{1};
      if length(varargin)>1 & strcmpi(varargin{2},'-generatereport');
         runAction='Report';
         figureTitle=[figureTitle ' - generating report ' startReport];
      end
   end
   
   figureTitle='Generate a Report';
   
   whichBtn=[3 4];
   
case 'arbitrary'
   
   if length(varargin)>0
      okBtnName=varargin{1};
      if length(varargin)>1
         okBtnTTS=varargin{2};
         if length(varargin)>2
            otherButtons=varargin{3};
         else
            otherButtons=[];
         end
      end      
   end
   whichBtn=[1 otherButtons 4];
   
   existingFig=[];
   
otherwise
   warning('Bad runMode value');
   existingFig=[];
end

if isempty(existingFig)
   
   allProps.BackgroundColor=get(0,'defaultuicontrolbackgroundcolor');
   allProps.Units='points';
   allProps.HandleVisibility='off';
   
   h=struct('Figure',[],...
      'ReturnNameButton',[],...
      'EditButton',[],...
      'ReportButton',[],...
      'CancelButton',[],...
      'ResumeAction','',...
      'SelectedReport','',...
      'runMode',runMode,...
      'sysHandle',sysHandle);
   
   h.Figure = figure('DoubleBuffer','on',...
      'Units',allProps.Units,...
      'HandleVisibility',allProps.HandleVisibility,...
      'Color',allProps.BackgroundColor,...
      'IntegerHandle','off',...
      'MenuBar','none', ...
      'Name',figureTitle,...
      'Visible','off',...
      'Position',LocInitFigPos,...
      'NumberTitle','off', ...
      'WindowStyle',windowStyle,...
      'resize','off',...
      'closerequestfcn','rptlist ?ActionCancel',...
      'Tag',rptlistTag);
   
   allProps.Parent=h.Figure;
   
   btnName={okBtnName
      'Edit'
      'Report'
      'Close'};
   btnCbk={'ReturnName'
      'Edit'
      'Report'
      'Cancel'};
   btnTTS={okBtnTTS
      'View selected file in the Setup File Editor'
      'Generate report from selected file'
      ''};
   
   h.lowerBtn=[];
   for i=1:length(whichBtn)
      cHandle=uicontrol(allProps,...
         'String',btnName{whichBtn(i)},...
         'Enable','off',...
         'ToolTipString',btnTTS{whichBtn(i)},...
         'Callback',['rptlist ?Action' btnCbk{whichBtn(i)}]);
      h.lowerBtn=[h.lowerBtn cHandle];
      h=setfield(h,[btnCbk{whichBtn(i)} 'Button'],cHandle);
   end
   if length(whichBtn)>0
       set(h.lowerBtn(1),'fontweight','bold');
   end
   
   h.HelpButton=uicontrol(allProps,...
      'String',   'Help',...
      'Enable',   'off',...
      'Callback', 'helpview(rptparent,''rptlist'',''product'');');

   
   h.DoubleClickCallback=...
      ['rptlist(''?ActionListboxSelect'',''Action' btnCbk{whichBtn(1)} ''');'];
   
   
   h.FileEdit=uicontrol(allProps,...
      'Style','edit',...
      'Enable','off',...
      'HorizontalAlignment','left',...
      'Callback','rptlist ?ActionFileEdit',...
      'BackgroundColor',[1 1 1]);
   
   h.FileBrowse=uicontrol(allProps,...
      'Style','pushbutton',...
      'Enable','off',...
      'String','...',...
      'FontWeight','bold',...
      'Callback','rptlist ?ActionFileBrowse');
   
   lbString={'Searching path for .rpt files...'
      'Click in this box to stop search.'
      '';'';'';'';'';'';'';'';'';'';'';'';'';'';'';'';'';''
      '';'';'';'';'';'';'';'';'';'';'';'';'';'';'';'';'';''
      '';'';'';'';'';'';'';'';'';'';'';'';'';'';'';'';'';''};
   
   h.CancelSearchCallback='rptlist(''?ActionSearchCancel'');';
   
   
   uicFontSize=get(0,'defaultuicontrolFontSize');
   h.FileListbox=uicontrol(allProps,...
      'String',lbString,...
      'Style','ListBox',...
      'Enable','on',...
      'Min',0,'Max',2,'Value',[],...
      'FontSize',uicFontSize*1.5,...
      'ListBoxTop',1,...
      'UserData',{},...
      'Interruptible','off',...
      'Tag','rptlistFileList',...
      'Callback',h.CancelSearchCallback,...
      'BackgroundColor',[1 1 1]);
   
   h.DescriptionText=uicontrol(allProps,...
      'String','',...
      'HorizontalAlignment','left',...
      'Style','listbox',...
      'Max',2,'Min',0,'Value',[],...
      'Tag','rptlistDescriptionText',...
      'Enable','inactive');
   
   LocPosition(h,'select');
   
   h.variableControls=[h.FileListbox h.ReturnNameButton h.EditButton h.ReportButton];
   h.constantControls=[h.FileEdit h.FileBrowse h.CancelButton h.HelpButton];
   
   if ~strcmp(runAction,'Report');
      h=LocPopulateFileList(h,startReport);
   else
      h.SelectedReport=startReport;
      set(h.FileEdit,'String',startReport);
      set(h.variableControls,'Enable','on')
   end
   set(h.FileListbox,...
      'FontSize',uicFontSize);
   
   set(h.constantControls,'Enable','on');
else
   %we have an existing figure and are using it
   h=get(existingFig,'UserData');
   set(h.ReturnNameButton,'String',okBtnName,...
      'ToolTipString',okBtnTTS);

   
   set(h.Figure,'Name',figureTitle);
   h.sysHandle=sysHandle;
   
   if ~isempty(startReport)
      [foundFile,fIndex]=LocFileIndex(...
         get(h.FileListbox,'String'),startReport);
      
      if foundFile
         set(h.FileListbox,'Value',fIndex);
         h=ActionListboxSelect(h,'none');
      else
         runAction='';
         set(h.DescriptionText,'String',...
            sprintf('Error - could not find file "%s"',startReport));
      end
   end
   
   
   figure(h.Figure);
end

   
set(h.Figure,...
   'UserData',h,...
   'Visible','on');

if strcmp(runAction,'Report')
   h=ActionReport(h);
   rptName=startReport;
elseif strcmpi(windowStyle,'modal')
   uiwait(h.Figure);
   if ishandle(h.Figure);
      h=get(h.Figure,'UserData');
      rptName=h.SelectedReport;
      delete(h.Figure);
   else
      rptName='';
   end
else
   rptName='';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  rptFileList=LocGetFileList
%construct the list of .rpt files

StopSearchValue(logical(0));

pSep=pathsep;

if isempty(findstr(lower(pwd),lower(path)));
   pathString=[pSep pwd pSep path pSep];
else
   pathString=[pSep path pSep];
end

breakIndex=findstr(pathString,pSep);

rptFileList={};
initLength=0;
lastIndex=length(breakIndex)-1;
i=1;
while i<=lastIndex & ~StopSearchValue
   myDir=pathString(breakIndex(i)+1:breakIndex(i+1)-1);
   fileList=dir([myDir filesep '*.rpt']);
   if ~isempty(fileList)
      allFiles={fileList.name};
      rptFileList=[rptFileList;...
            strcat([myDir filesep],allFiles(:))];
   end
   i=i+1;
end

%include custom file names
rptFileList=[rptFileList
   StoreCustomNames];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h=ActionSearchCancel(h)

set(h.DescriptionText,'String',...
   'Path search cancelled!');

StopSearchValue(logical(1));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h=ActionReturnName(h)

rptName=h.SelectedReport;

warnStr={};
if ~isempty(rptName) & ~isempty(h.sysHandle)
   try
       sysName = strrep(getfullname(h.sysHandle),sprintf('\n'),' ');
   catch
       sysName = num2str(h.sysHandle);
   end
    
   try
      set_param(0,'CurrentSystem',h.sysHandle);
   catch
       warnStr{end+1}=sprintf('Error - Can not set "%s" as current system',sysName);
   end
   
   try
      set_param(h.sysHandle,'ReportName',rptName);
      warnStr{end+1}=sprintf('Setting "%s"',rptName);
      warnStr{end+1}=sprintf('as default report for "%s"',sysName);
   catch
      warnStr{end+1}=sprintf('Error - Can not set "%s" as current report.', rptName);
   end
else
    warnStr='No report or system selected';
end

set(h.DescriptionText,'String',warnStr);

%h=ActionCancel(h);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h=ActionEdit(h)

oldPointer=get(h.Figure,'Pointer');
set(h.Figure,'Pointer','watch');

prevEnable=get([h.variableControls h.constantControls],'Enable');
set([h.variableControls h.constantControls],'Enable','off');

set(h.DescriptionText,'String','Launching the Setup File Editor');

drawnow
setedit(h.SelectedReport);   

set([h.variableControls h.constantControls],{'Enable'},prevEnable);
set(h.DescriptionText,'String','Setup File Editor launched');
set(h.Figure,'Pointer',oldPointer);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h=ActionReport(h)

rptName=h.SelectedReport;

oldFigure=LocPreserveProperties(h.Figure,...
   {'Pointer'});
set(h.Figure,'Pointer','watch');

[s,ok]=loadsetfile(rptparent,rptName);
if ok
   LocPosition(h,'report');
   
   set([h.variableControls h.constantControls],'Enable','off');
   
   
   oldFileListbox=LocPreserveProperties(h.FileListbox,...
      {'String','UserData','Tag','ListBoxTop','Value'});
   
   currgenoutline(rptparent,h.FileListbox);
   
   subsasgn(rptcomponent,substruct('.','SetfilePath'),rptName);
   oStr=outlinestring(s.ref.outlineIndex);
   
   set(h.FileListbox,...
      'String',oStr,...
      'UserData','',...
      'ListBoxTop',1,...
      'Value',1);
   
   %-----------Report Button -----------------
   oldReportButton=LocPreserveProperties(h.ReportButton,...
      {'String','ToolTipString','Callback'});
   
   set(h.ReportButton,'String','Stop',...
      'ToolTipString','Stop generating current report',...
      'Callback','rptlist ?ActionHaltGenerate',...
      'Enable','on');
   
   %----------Description Text ---------------
   oldDescriptionText=LocPreserveProperties(h.DescriptionText,...
      {'Tag'});
   
   dString='Generating report from RPTLIST window';
   set(h.DescriptionText,...
      'String',{dString},...
      'UserData',struct('string',dString,'rank',1),...
      'Tag','StatusReport');
   
   drawnow
   reportName=generatereport(s);
   
   set([h.variableControls h.constantControls],'Enable','on');
   set(h.ReportButton,oldReportButton,'Enable','on');
   set(h.DescriptionText,oldDescriptionText);
   set(h.FileListbox,oldFileListbox);
   ok=1;
else
   set(h.DescriptionText,'String',...
      sprintf('Error - can not load setup file "%s"', rptName )); 
   ok=0;
end
delete(s);
set(h.Figure,oldFigure);

if strcmp(get(h.FileListbox,'Callback'),h.CancelSearchCallback)
   generationMessages=get(h.DescriptionText,'String');
   h=LocPopulateFileList(h,rptName);
   set(h.DescriptionText,'String',generationMessages);
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h=ActionCancel(h)

h.SelectedReport='';

if strcmpi(get(h.Figure,'WindowStyle'),'modal')
   uiresume(h.Figure);
else
   delete(h.Figure);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h=ActionListboxSelect(h,action)

if ~strcmp(action,'none') & ...
      strcmp(get(gcbf,'SelectionType'),'open')
   h=feval(action,h);
else   
   allFiles=get(h.FileListbox,'String');
   fileIndex=get(h.FileListbox,'Value');
     
   rptDescriptions=get(h.FileListbox,'UserData');
   
   if ~isempty(fileIndex)
      rptName=allFiles{fileIndex(1)};
   else
      rptName='?error-no-file';
   end
   
   if length(rptDescriptions)<fileIndex | ...
         isempty(rptDescriptions{fileIndex})
      
      fDesc=LocGetFileDesc(rptName);
      rptDescriptions{fileIndex}=fDesc;
      set(h.FileListbox,'UserData',rptDescriptions);
   else
      fDesc=rptDescriptions{fileIndex};
   end
   
   h.SelectedReport=rptName;
   set(h.FileEdit,'String',rptName);
   set(h.DescriptionText,'String',fDesc);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h=ActionFileEdit(h)
%Triggered from edit box.  Adds a setup file to the custom
%list.

oldName=h.SelectedReport;
newName=get(h.FileEdit,'String');

[fDesc,isError]=LocGetFileDesc(newName);

if ~isError
   StoreCustomNames(newName);
   fileList=get(h.FileListbox,'String');
   
   if strcmp(fileList{1},h.FileListErrorMessage)
      %The file list was previously empty - we are adding
      %the first real file
      fileList={};
      fileDescriptions={};
      set(h.variableControls,'Enable','on');
   else
      fileDescriptions=get(h.FileListbox,'UserData');   
   end
    
   fileList{end+1,1}=newName;
   listLength=length(fileList);
   fileDescriptions{listLength}=fDesc;
   set(h.FileListbox,...
      'String',fileList,...
      'UserData',fileDescriptions,...
      'Value',listLength);   
   h=ActionListboxSelect(h,'none');
else
   set(h.FileEdit,'String',oldName);
   set(h.DescriptionText,'String',...
      sprintf('Error - file %s is not a valid setup file.',newName));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h=ActionFileBrowse(h)
%Triggered from '...' button.

startFile=h.SelectedReport;
[fPath fFile fVer fExt]=fileparts(startFile); 
if isempty(fPath) 
    fPath=pwd; 
end 
startFile=fullfile(fPath,'*.rpt'); 

%filterSpec={'*.rpt', 'Report Generator Setup Files (*.rpt)'
%            '*.*'  , 'All files (*.*)'},...
  
[fileName,pathName] = uigetfile(...
    startFile,...
    'Add Setup File to List');

if ~isnumeric(fileName)
   fileName=fullfile(pathName,fileName);
   set(h.FileEdit,'String',fileName);
   h=ActionFileEdit(h);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h=ActionHaltGenerate(h);

set(h.ReportButton,'enable','off');

r=rptcomponent;
r.HaltGenerate=logical(1);
drawnow


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  [fDesc,isError]=LocGetFileDesc(rptName);

r=rptparent;
results=nenw(r);
try
   rptHandle=hgload(rptName);
catch
   rptHandle=[];
end
nenw(r,results);

isError=logical(1);
fDesc='Error: Could not load setup file';
if ishandle(rptHandle)
   olHandle=findall(allchild(rptHandle),'flat',...
      'type','uimenu');
   if ~isempty(olHandle)
      olUD=get(olHandle,'UserData');
      if isstruct(olUD) & isfield(olUD,'att')
         if isstruct(olUD.att) & isfield(olUD.att,'Description')
            fDesc=getfield(olUD.att,'Description');
            isError=logical(0);
         end
      end
   end
   delete(rptHandle);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocPosition(h,mode);
%mode is a string, either 'select' or 'report'



figPos=get(h.Figure,'Position');

figWd=figPos(3);
figHt=figPos(4);

editHt=layoutbarht(rptparent); %the height of the edit bar and browse button
btnWd=50; %width of set/edit/report/cancel/help buttons
btnHt=editHt*5/3; %height of those buttons
pad=editHt/3; %border around objects

switch mode
case 'select'
   descHt=50; %height of the description listbox
case 'report'
   descHt=150;
otherwise
   descHt=100;
end

browseExt=get(h.FileBrowse,'Extent');
browseWd=browseExt(3)+2*pad; %width of the browse button

listHt=figHt-4*pad-btnHt-editHt-descHt; %height of the select listbox

allWd=figWd-2*pad;

btnYzero=pad;
descYzero=2*pad+btnHt;
editYzero=descYzero+descHt+pad;
listYzero=editYzero+editHt;


hList=[h.HelpButton,...
      h.lowerBtn,...
      h.DescriptionText,...
      h.FileEdit h.FileBrowse,...
      h.FileListbox];

hPos={};
numBtn=length(h.lowerBtn);
for i=1:numBtn
   hPos{end+1,1}=[figWd-(pad+btnWd)*(numBtn-i+1) btnYzero btnWd btnHt];
end

hPos=[{[pad btnYzero btnWd btnHt]}
   hPos
   {[pad descYzero allWd descHt]  
   [pad editYzero allWd-browseWd editHt]
   [figWd-pad-browseWd editYzero browseWd editHt]
   [pad listYzero allWd listHt]}];

set(hList,{'Position'},hPos);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout=StoreCustomNames(varargin)
%customList=StoreCustomNames
%     returns the list of stored custom names
%StoreCustomNames(rpt1,rpt2,....)
%     adds input setup file names to the list
%     of stored custom names


persistent RPTGEN_RPTLIST_CUSTOM_SETUP_FILES

if ~iscell(RPTGEN_RPTLIST_CUSTOM_SETUP_FILES)
   RPTGEN_RPTLIST_CUSTOM_SETUP_FILES={};
end

if nargin>0
   RPTGEN_RPTLIST_CUSTOM_SETUP_FILES=...
      [RPTGEN_RPTLIST_CUSTOM_SETUP_FILES
      varargin'];
end

if nargout>0
   varargout{1}=RPTGEN_RPTLIST_CUSTOM_SETUP_FILES;
end

%%%%%%%%%%%%%%%%%%%%%%%%
function stopVal=StopSearchValue(stopVal)

persistent RPTGEN_STOP_RPTLIST_SEARCH

if nargin>0
   RPTGEN_STOP_RPTLIST_SEARCH=stopVal;
end

stopVal=RPTGEN_STOP_RPTLIST_SEARCH;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fPos=LocInitFigPos

figHt=281;
figWd=300;


oldUnits=get(0,'Units');
set(0,'Units','Points');
screen=get(0,'ScreenSize');
set(0,'Units',oldUnits);

hoffset=60;
voffset=60;

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
   
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
function isSame=LocSameFile(listFull,startFile,startPath)

[listPath listFile listExt listVer]=fileparts(listFull);

isSame=strcmp(listFile,startFile);

if isSame & ~isempty(startPath)
   isSame=strcmpi(listPath,startPath);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h=LocPopulateFileList(h,startReport);

set(h.Figure,...
   'Visible','on',...
   'UserData',h);
drawnow

fList=LocGetFileList;
h.FileListErrorMessage=...
   '---No setup files (*.rpt) found on MATLAB path---';

if isempty(fList)
   fList={h.FileListErrorMessage};
   
   fEnable='off';
   fIndex=[];
   fTop=1;
   fMax=2;
   fCallback='';
   foundFile=logical(0);
   emptyMsg='Use the "browse" button to add a setup file to the list';
else
   if isempty(startReport)
      fIndex=1;
      fTop=1;
      foundFile=logical(0);
   else
      [foundFile,fIndex]=LocFileIndex(fList,startReport);
   end
   fEnable='on';
   fMax=1;
   fTop=fIndex;
   fCallback=h.DoubleClickCallback;
   emptyMsg='';
end

%Calling all these sets at once was causing an HG assertion  g94232
set(h.FileListbox,'FontSize',get(0,'defaultuicontrolfontsize'));
set(h.FileListbox,'String',fList);
set(h.FileListbox,'Value',fIndex,'Min',0,'Max',fMax);
set(h.FileListbox,'Callback',fCallback);
set(h.FileListbox,'ListboxTop',fTop);

if ~isempty(startReport) & ~foundFile
   errMsg={sprintf('Warning - could not find setup file "%s".', ...
         startReport);emptyMsg};
else
   errMsg=emptyMsg;
end

if ~isempty(errMsg)
   set(h.DescriptionText,'String',errMsg);
end

if fEnable
   h=ActionListboxSelect(h,'none');
end

set(h.variableControls,'Enable',fEnable)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [foundFile,fIndex]=LocFileIndex(fList,startReport)

fIndex=[];
i=1;

[startPath startFile startExt startVer]=fileparts(startReport);

lengthList=length(fList);
while isempty(fIndex) & i<=lengthList
   if LocSameFile(fList{i},startFile,startPath)
      fIndex=i;
   else
      i=i+1;
   end
end

if isempty(fIndex)
   fIndex=1;
   foundFile=logical(0);
else
   foundFile=logical(1);
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pStruct=LocPreserveProperties(h,props);
%h is the handle to an object whose properties we wish to preserve
%props is a cell array of properties to preserve
%pStruct is a structure with fieldnames of props

pStruct=struct(props{1},{get(h,props{1})});

for i=2:length(props)
   pStruct=setfield(pStruct,props{i},...
      get(h,props{i}));
end
