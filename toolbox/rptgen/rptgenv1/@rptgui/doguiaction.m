function varargout=doguiaction(g,action,varargin)
%DOGUIACTION - acts as a switchyard for GUI interactions
%   G=DOGUIACTION(G,'Action',input arguments....)
%   G is an RPTGUI object
%

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:16:56 $

g=feval(action,g,varargin{:});

if nargout>0
   varargout{1}=g;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function g=AcDeactivate(g)
%activate/deactivate a component

parentselect=selectroot(g.s.ref.outlineIndex,...
   get(g.h.Main.outline,'Value'));

if ~isoutlineselected(parentselect)
   g=savecursor(g);
   
   toggleactive(parentselect);
   
   indexlist(g.s);
   
   g=LocUpdateSelect(g,parentselect);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function g=AddComponent(g);

%create component to add
currcpos = get(g.h.AddTab.complist,'Value');
compName=g.ref.complist(currcpos).compname;
if ~isnumeric(compName)
   eval(['newcomp=',compName,';'],'newcomp=[];');
else
   newcomp=[];
end

if isa(newcomp,'rptcomponent')
   newcompInfo=getinfo(newcomp);
   statbar(g,newcompInfo.Desc);
   g=savecursor(g);
   
   curropos = get(g.h.Main.outline,'Value');
   curropos = curropos(length(curropos));
   
   added=addcomp(subset(g.s.ref.outlineIndex,curropos),...
      newcomp,logical(0));
   indexlist(g.s);
   
   %make sure that outline string length matches number of components
   %temporary - will be overwritten
   oldString = get(g.h.Main.outline,'String');
   oldString{end+1}='<new component>';
   set(g.h.Main.outline,'String',oldString);
      
   g=LocUpdateSelect(g,added);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function g=ChangeAutoSave(g);
%OBSOLETE - not used now that AutoSaveOnGenerate
%is a COUTLINE-level property

g=savecursor(g);

if strcmp(get(g.h.FileMenu.fAutoSave,'Checked'),'on')
   check='off';
   value=logical(0);
else
   check='on';
   value=logical(1);
end   

set(g.h.FileMenu.fAutoSave,'Checked',check);
g.s.Setfile.AutoSaveOnGenerate=value;

g=updateui(g);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function g=ChangeEchoDetail(g)

rank=get(g.h.GenTab.statuspop,'Value')-1;

if g.s.Setfile.EchoDetail~=rank;
   g=savecursor(g);   
   msg=get(g.h.GenTab.statuslist,'UserData');
   %msg is a structure containing fields "string" and "rank"
   if ~isempty(msg) & rank>0
      found=find([msg.rank]<=rank);
      if isempty(found)
         newstring={};
      else
         newstring={msg(found).string};
      end
   else
      newstring={};
   end
   
   set(g.h.GenTab.statuslist,'String',newstring)
   
   g.s.Setfile.EchoDetail=rank;
   updateui(g);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function g=ChangeSetfile(g,OSindex);
%called from Window menu.... we are changing the
%currently visible setup file

if isNonIntegerHandle(OSindex)
   OSindex=rptsp(OSindex);
elseif ~isa(OSindex,'rptsp')
   %we have been handed an index into the list of OpenSetfiles
   OSindex=rptsp(g.ref.OpenSetfiles(OSindex));
end

if g.s~=OSindex
   g=savecursor(g,logical(0));
   set(g.h.Main.outline,...
      'visible','off',...
      'uicontextmenu',[]);
   g.h.Main.outline=outlinehandle(OSindex,g.hg.all);
   set(g.h.Main.outline,...
      'visible','on',...
      'uicontextmenu',g.h.OutlineContext.Parent);
   
   g.s=OSindex;
   
   %set(g.h.Main.outline,'value',1);
   g.c=rptcp;
   
   g=updateui(g,'NewSetfile');
end

   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function g=ClearStatusList(g);

set(g.h.GenTab.statuslist,...
   'Value',[],...
   'String',{},...
   'ListBoxTop',1,...
   'UserData',[])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function g=CloseSetfile(g,isReplaceIfEmpty)

if nargin<2
   isReplaceIfEmpty=logical(1);
end

g=CheckForChange(g); 
if ~g.ref.continue
   return;
else
   closeS=g.s;
end

allSetfiles=g.ref.OpenSetfiles;
closeIndex=find(allSetfiles==closeS.h);
if length(closeIndex)>0
   closeIndex=closeIndex(1);      
   g=savecursor(g,logical(0));
   allSetfiles=[allSetfiles(1:closeIndex-1),...
         allSetfiles(closeIndex+1:end)];
   
   delete(g.h.Main.outline);
   delete(closeS);
   
   if ~isempty(allSetfiles)
      newS=rptsp(allSetfiles(min(closeIndex,length(allSetfiles))));
   elseif isReplaceIfEmpty
      newS=rptsetupfile;
      allSetfiles=newS.h;      
   else
      newS=[];
   end
   g.ref.OpenSetfiles=allSetfiles;
   g.s=newS;
   
   if ~isempty(newS)
      %setting the dirty flag off prevents multiple prompts upon exiting
      %g.s.ref.changed=logical(0);
      g.h.Main.outline=outlinehandle(newS,g.hg.all,g.ref.grud);
      set(g.h.Main.outline,'visible','on');
      g=updateui(g,'NewSetfile','Resize');
   end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function g=Collapse(g)

parentselect=selectroot(g.s.ref.outlineIndex,...
   get(g.h.Main.outline,'Value'));

if ~isoutlineselected(parentselect)
   g=savecursor(g,logical(0));
   
   togglecollapse(parentselect);
   
   indexlist(g.s);
   
   g=LocUpdateSelect(g,parentselect);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CompInfo(g,infostring)

set(g.h.AddTab.compinfo,'String',infostring);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function g=ComponentHelp(g)
%called from "?" button on Add Component tab

currcpos = get(g.h.AddTab.complist,'Value');

if length(currcpos)==1 & ...
      isfield(g.ref,'complist') & ...
      isstruct(g.ref.complist)
   compName=g.ref.complist(currcpos).compname;
   if isnumeric(compName)
      typeID=g.ref.compTypes(compName).Type;
      helpview(g,typeID,'category',g.ref.compTypes,g.ref.allcomps);
   else
      helpview(g,compName,'component');
   end
else
   %statbar(g,'Wait for component list to initialize',logical(1));
end

   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function g=Copy(g)

parentselect=selectroot(g.s.ref.outlineIndex,...
   get(g.h.Main.outline,'Value'));

if ~isoutlineselected(parentselect)   
   cbHandle=copybuffer(g.rptparent);
   delete(allchild(cbHandle));
   newBufferObjects=copyobj(parentselect.h,cbHandle);
   indexlist(g.s);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function g=Cut(g)

%isSpecialEdit=0;
%if isSpecialEdit
g=DeleteComponent(g,logical(1));
%else
%   uimenufcn(g.h.fig,'EditCut');
%end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function   g=DeleteComponent(g,isMoveToBuffer);
%DELETECOMPONENT(g,1) causes the deleted components
%to be moved to the copybuffer.  (Acts as "cut" behavior)

if nargin<2
   isMoveToBuffer=logical(0);
end

selected=get(g.h.Main.outline,'Value');
oldselect=selected(1);
parentselect=selectroot(g.s.ref.outlineIndex,...
   get(g.h.Main.outline,'Value'));

if ~isoutlineselected(parentselect)
   g=savecursor(g);
   
   if ~isMoveToBuffer
      delete(parentselect);   
   else
      cbHandle=copybuffer(g.rptparent);
      delete(allchild(cbHandle));
      set(parentselect.h,'Parent',cbHandle)
   end
   
   indexlist(g.s)
   
   set(g.h.Main.outline,'Value',oldselect);
   g=updateui(g,'UpdateOutline','UpdateButtons','UpdateAttPage');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function g=Exit(g,forceStr)
%called from "Exit" menu item or "X" box on window

if nargin<2
   isForce=logical(0);
else
   isForce=strcmpi(forceStr,'force');
end

g.ref.continue=logical(1);
if ~isForce
   while g.ref.continue & ~isempty(g.ref.OpenSetfiles)
      %calling closesetfile with isReplaceIfEmpty to
      %prevent an infinite loop of closing and creating
      %empty setfiles
      g=CloseSetfile(g,logical(0));
   end
else
   %we have forced an exit.  Clean up and
   %close open setup files
   delete(g.ref.OpenSetfiles);
end

if g.ref.continue
   %should we clear out rptgui() ?
   
   %update java view
   if ~isempty(g.ref.ObjectBrowserHandle)
      try
	     obh=g.ref.ObjectBrowserHandle;
         obh.finish;
      end
   end
   
   cH=rptsp('clipboard');
   delete(cH.h);
   delete(g.h.fig);
   cleanup(g);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function g=FlipNavDirection(g,btnNumber)

newCode='';
oldCode=get(g.h.Main.movbtn(btnNumber),'Tag');
if ~strcmp(oldCode,'no')
   switch btnNumber
   case 1
      %not doing anything here yet.  allow jumpins?
   case 2
      %not doing anything here yet.  allow jumpins?
   case 3
      if strcmp(oldCode,'ui')
         newCode='di';
      elseif strcmp(oldCode,'di')
         newCode='ui';
      end   
   end
end

if ~isempty(newCode)
   curropos = get(g.h.Main.outline,'Value');
   ok=movecomp(...
      selectroot(g.s.ref.outlineIndex,curropos),...
      't',{newCode});
   if ok
      img=get(g.h.Main.movbtn(btnNumber),'UserData');
      set(g.h.Main.movbtn(btnNumber),...
         'Cdata',getfield(img,newCode),...
         'Tag',newCode);
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function   g=GenerateReport(g);
%Triggered from the "Report" File menu item
%or the "Report" button

g=savecursor(g,logical(0));

g=ClearStatusList(g);

g=dotabselect(g,3);

oldFigProps.Pointer='arrow';
oldFigProps.WindowButtonMotionFcn=...
   get(g.h.fig,'WindowButtonMotionFcn');

set(g.h.fig,'Pointer','watch',...
   'WindowButtonMotionFcn','');

%get current outline position
olpos=get(g.h.Main.outline,'Value');
set(g.h.Main.outline,'Value',1);

oldOutlineTag=get(g.h.Main.outline,'Tag');
currgenoutline(g,g.h.Main.outline);

enablechange=[g.h.Main.outline
   g.h.GenTab.statuspop
   g.h.FileMenu.Parent
   g.h.EditMenu.Parent
   g.h.WindowMenu.Parent
   g.h.HelpMenu.Parent];
set(enablechange,'Enable','off');

tabHandles=[g.h.Main.catab g.h.Main.artab g.h.Main.getab];
tabBDF=get(tabHandles,'ButtonDownFcn');
set(tabHandles,'ButtonDownFcn','','Enable','off');

cDataHandles=[g.h.Main.movbtn(1)
    g.h.Main.movbtn(2)
    g.h.Main.movbtn(3)
    g.h.Main.deacbtn
    g.h.Main.rembtn];

for i=1:length(cDataHandles)
   img=get(cDataHandles(i),'UserData');
   set(cDataHandles(i),...
      'enable','off',...
      'cdata',img.no);
end

oldGenerateBtn.Callback=get(g.h.Main.GenerateBtn,'Callback');
oldGenerateBtn.ToolTipString=get(g.h.Main.GenerateBtn,'ToolTipString');
oldGenerateBtn.String=get(g.h.Main.GenerateBtn,'String');
oldGenerateBtn.Interruptible=get(g.h.Main.GenerateBtn,'Interruptible');


set(g.h.Main.GenerateBtn,...
   'String',xlate('Stop'),...
   'ToolTipString',xlate('Stop report generation'),...
   'Interruptible','on',...
   'Enable','on',...
   'Callback',['doguiaction(',g.ref.grud,',''HaltGenerate'');']);

drawnow

%if auto-save is turned on, save setup file

rptC=children(g.s);
if rptC.att.isAutoSaveOnGenerate
   g=SaveAs(g,logical(0));
end
statbar(g,'Generating report.....');

oldFigProps.Interruptible=get(g.h.fig,'Interruptible');
set(g.h.fig,'Interruptible','on');


drawnow

%generate report
reportname=generatereport(g.s);

set(g.h.fig,oldFigProps);

set(g.h.Main.GenerateBtn,oldGenerateBtn,'Enable','on');

set(tabHandles,{'ButtonDownFcn'},tabBDF,'Enable','inactive');

set(enablechange,'Enable','on')
%set(activechange,'Enable','inactive');

%return outline highlight to previous position
set(g.h.Main.outline,...
   'Value',olpos,...
   'Tag',oldOutlineTag);
statbar(g,'Report generation complete.');

g.c=rptcp; %force an update of the attributes tab
           %next time it is selected
g=updateui(g,'UpdateButtons');

g.s.ref.ContinueGenerate=logical(1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function g=HaltGenerate(g);

set(g.h.Main.GenerateBtn,'enable','off');

subsasgn(rptcomponent,...
   substruct('.','HaltGenerate'),...
   logical(1));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function   g=HorizResize(g,action,varargin);
%changes the relative widths of the outline and the
%tab dialog pages
set(g.h.Main.resizeline,'UserData',logical(1));

outlinePos=get(g.h.Main.outline,'Position');

minX=outlinePos(1)+g.layout.minOutlineWidth;
maxX=g.layout.figWidth-2*g.layout.padding-g.layout.minTabBodyWidth;

if maxX>minX+1 %if the bar can be moved
   oldColor=get(g.h.Main.resizeline,'BackgroundColor');
   set(g.h.Main.resizeline,...
      'Style','pushbutton',...
      'BackgroundColor','black',...
      'ForegroundColor','black');
   
   oldProps=struct('WindowButtonMotionFcn',...
      get(g.h.fig,'WindowbuttonMotionFcn'),...
      'WindowButtonUpFcn',get(g.h.fig,'WindowButtonUpFcn'),...
      'Interruptible',get(g.h.fig,'Interruptible'),...
      'Pointer',get(g.h.fig,'Pointer'));
      
   set(g.h.fig,...
      'Pointer','left',...
      'Interruptible','on',...
      'WindowButtonUpFcn',['set(' num2str(g.h.Main.resizeline,32) ...
         ',''UserData'',logical(0))'],...
      'WindowButtonMotionFcn','pause(0),drawnow');
   
   %resize function makes sure that resizeline is on top
   %of outline and tab
   %uistack(g.h.Main.resizeline,'top')
   linePos=get(g.h.Main.resizeline,'Position');
   while(get(g.h.Main.resizeline,'UserData'))
      currMousePos=get(g.h.fig,'CurrentPoint');      
      linePos(1)=min(maxX,max(minX,currMousePos(1)));      
      set(g.h.Main.resizeline,'Position',linePos);
      pause(0);
   end
   
   currMousePos=get(g.h.fig,'CurrentPoint');
   newX=min(maxX,max(minX,currMousePos(1)));   
   
   oldTotalWidth=g.layout.outlinewidth+g.layout.tabbodywidth;  
   g.layout.outlinewidth=newX-outlinePos(1);
   g.layout.tabbodywidth=oldTotalWidth-g.layout.outlinewidth;
   set(g.h.Main.resizeline,...
      'Style','frame',...
      'BackgroundColor',oldColor,...
      'ForegroundColor',oldColor);

   set(g.h.fig,oldProps)
   g=updateui(g,'Resize');      
end   


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function g=InitializeMenu(g,whichMenu)
%Allows menus to be initialized on the fly


switch whichMenu
case 'FileMenu'
   %isDirty=g.s.ref.changed;
   %[fPath, fName,fExt,fVer]=fileparts(g.s.ref.Path);
   
   %if isDirty | isempty(fName)
   %   fEnable='on';
   %else
   %   fEnable='off';
   %end
   
   
   
   %set(g.h.FileMenu.fSave,'Enable',...
   %   fEnable);
   
case {'EditMenu' 'OutlineContext'}
   mH=getfield(g.h,whichMenu);
   
   curropos = get(g.h.Main.outline,'Value');
   firstComp=subset(g.s.ref.outlineIndex,curropos(1));
   isFirstCompSelected=isoutlineselected(g.s,curropos);
   MultiSelect=(length(curropos)>1);
   
   %Undo
   if isfield(mH,'Undo')
      cbHandle=undobuffer(g.s);
      numSaved=length(get(cbHandle,'children'));
      set(mH.Undo,'Enable',...
         LocOnOff(numSaved>0));
   end
   
   %Paste
   cbHandle=copybuffer(g.rptparent);
   pasteHandles=get(cbHandle,'children');
   set(mH.Paste,'Enable',LocOnOff(length(pasteHandles>0)));
   
   
   %Cut, Copy, Delete, ActivateDeactivate
   set([mH.Cut mH.Copy mH.DeleteComponent mH.ActivateDeactivate],...
      'Enable',LocOnOff(~isFirstCompSelected));
   
   %CollapseExpand
   if isfield(mH,'CollapseExpand')
      firstChildren=get(firstComp.h,'Children');
      set(mH.CollapseExpand,'Enable',...
         LocOnOff(min(~isFirstCompSelected,length(firstChildren)>0)));
   end
   
   %ViewOptionsTab
   if isfield(mH,'ViewOptionsTab')
      set(mH.ViewOptionsTab,'Enable',...
         LocOnOff(getcurrtab(g)~=1));   
   end
   
   if isfield(mH,'ViewReportOptionsTab')
      set(mH.ViewReportOptionsTab,'Enable',...
         LocOnOff((getcurrtab(g)~=1) | ...
         ~any(ismember(get(g.h.Main.outline,'Value'),1))));   
   end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function g=KeyPress(g)

key=get(g.h.fig,'CurrentCharacter');
if ~isempty(key)
   switch abs(key)
   case 116 %'t'
      t=getcurrtab(g);
      if t<3
         t=t+1;
      else
         t=1;
      end
      g=dotabselect(g,t);
   %case 127 %delete key
   %   g=DeleteComponent(g);
   case 27 %escape key
      
   otherwise
      %key
      %num=abs(key)
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function g=MakeLogFile(g,isView)
%MakeLogFile produces a text file with the
%same name as the current setup file with a
%.log extension.  It contains the complete 
%generation status text and a snapshot of
%the outline.

if nargin<2
   isView=logical(0);
end

r=rptcomponent;
setfilePath=r.SetfilePath;
[lPath lFile lExt lVer]=fileparts(setfilePath);
lExt='.log';
if isempty(lFile)
   lFile='Unnamed';
end
if isempty(lPath)
   lPath=pwd;
end

logFileName=fullfile(lPath,[lFile lExt lVer]);
fid=fopen(logFileName,'w');
if fid<0
   logFileName=fullfile(pwd,[lFile lExt lVer]);
   fid=fopen(logFileName,'w');
end

if fid>0
   statbar(g,sprintf('Creating log file %s ...', logFileName ));
   drawnow;
   
   CR=sprintf('\n');
   HR=[CR '========================================================' CR CR];
   headerText=[sprintf('Report Generator Log File\n\n') ...
         sprintf('          Created: %s\n', date ) ...
         sprintf('       Setup File: %s\n', setfilePath) ...
         HR];
         
   fprintf(fid,strrep(strrep(headerText,'\','\\'),'%','%%'));
   
   
   %outline string section
   logText=get(g.h.Main.outline,'String');
   logText=strvcat(sprintf('Outline Treeview: \n'), logText{:});
   logText=[logText CR*ones(size(logText,1),1)]';
   logText=strrep(strrep(logText(:)','\','\\'),'%','%%');
   
   fprintf(fid,logText);      
   fprintf(fid,HR);
   
   %Generation status section
   logText=get(g.h.GenTab.statuslist,'UserData');
   if isstruct(logText)
      logText=strvcat(sprintf('Generation Status Messages: \n'),...
         logText.string);
      logText=[logText CR*ones(size(logText,1),1)]';
      logText=strrep(strrep(logText(:)','\','\\'),'%','%%');
   else
      logText='Generation Status Messages: none';
   end
   
   fprintf(fid,logText);   
   fprintf(fid,[HR CR]);   
   
   %component attributes section
   allComps=g.s.ref.outlineIndex;
   for i=1:length(allComps)
      logText=strrep([evalc('allComps(i).att'), CR],...
         'ans =',...
         ['(' num2str(i) ')' allComps(i).comp.Class]);
      
      logText=strrep(strrep(logText,'\','\\'),'%','%%');
      fprintf(fid,logText);      
   end
   
   fprintf(fid,[HR CR]);   
   
   %version info section
   verText=evalc('ver');
   fprintf(fid,strrep(strrep(verText,'\','\\'),'%','%%'));
   
   fclose(fid);
   statbar(g,sprintf('Log file written to %s', ...
         logFileName));
   if isView
      edit(logFileName);
   end
else %if fopen did not execute properly
   statbar(g,sprintf('Error - could not write log file to %s', ...
         logFileName),1);   
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function g=MoveComponent(g,buttonnumber);

direction=get(g.h.Main.movbtn(buttonnumber),'Tag');
curropos=get(g.h.Main.outline,'Value');

g=savecursor(g);

try
   [movedComponents]=movecomp(...
      selectroot(g.s.ref.outlineIndex,curropos),...
      'm',direction);
   ok=1;
catch
   ok=0;
end

if ok
   indexlist(g.s);
   g=LocUpdateSelect(g,movedComponents);
else
   g=updateui(g);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function g=OpenFile(g,FileName)

if strcmp(FileName,'NEW')
    newS=rptsetupfile;
    currentS=[];
else
    if isempty(FileName)
        [uiFile,uiPath] = uigetfile(...
            {'*.rpt','Report Generator Setup Files (*.rpt)';'*.*','All files (*.*)'},...
            'Open Setup File');
        
        if ischar(uiFile) %user selected a file
            FileName=fullfile(uiPath,uiFile);
            %Create a list of already open setup files.  If this
            %filename is on that list, just bring that file to the
            %front.  Otherwise, open it.
        else
            return
        end
    else
        [path name ext ver]=fileparts(FileName);
        if isempty(ext)
            ext='.rpt';
        end
        
        if isempty(path)
            FileName=which([name ext]);
            if isempty(FileName)
                FileName=fullfile(pwd,[name ext]);
            end
        else   
            FileName=fullfile(path,[name ext ver]);
        end
    end
    
    openFileNames={};
    for i=length(g.ref.OpenSetfiles):-1:1
        openFileNames{i}=subsref(rptsp(g.ref.OpenSetfiles(i)),...
            substruct('.','ref','.','Path'));
    end
    
    currentIndex=find(strcmpi(openFileNames,FileName));
    if length(currentIndex)>0
        newS=[];
        currentS=g.ref.OpenSetfiles(currentIndex(1));
    else
        newS=loadsetfile(g.rptparent,FileName);
        currentS=[];
    end
end

if isa(newS,'rptsp')
   g=savecursor(g,logical(0));
   %g=rptgui(newS);
   %the syntax g(s) updates g.s, g.ref.OpenSetfiles,
   %g.c, and g.h.Main.outline
   g.s=newS;
   g.s.ref.changed=logical(0);
   g.ref.OpenSetfiles(end+1)=newS.h;
   g.c=rptcp;
   oldPos=get(g.h.Main.outline,'Position');
   set(g.h.Main.outline,'Visible','off');
   g.h.Main.outline=outlinehandle(newS,g.hg.all);
   set(g.h.Main.outline,...
      'Visible','on',...
      'Position',oldPos,...
      'uicontextmenu',g.h.OutlineContext.Parent);
      
   g=updateui(g,'UpdateOutline','NewSetfile');   
elseif ~isempty(currentS)
   %we have been handed an index into an already open
   %setup file
   g=ChangeSetfile(g,currentS);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function g=Paste(g)

cbHandle=copybuffer(g.rptparent);
pasteHandles=get(cbHandle,'children');

if ~isempty(pasteHandles)
   g=savecursor(g);
   curropos = get(g.h.Main.outline,'Value');
   curropos = curropos(length(curropos));
   
   added=addcomp(subset(g.s.ref.outlineIndex,curropos),...
      pasteHandles,logical(1));
   indexlist(g.s);
   
   g=updateui(g,'UpdateOutline');
   g=LocUpdateSelect(g,added);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function   g=SaveAll(g)

prevcheck=1;
for i=1:length(g.ref.OpenSetfiles)
   toSave=rptsp(g.ref.OpenSetfiles(i));
   g=SaveAs(g,logical(0),toSave);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function g=SaveAs(g,isSaveAs,toSave)

if nargin<3
   toSave=g.s;
   if nargin<2
      isSaveAs=logical(0);
   end
end

currname=toSave.ref.Path;
[cpath cfile cext cver]=fileparts(currname);
if isempty(cpath)
   cpath=pwd;
end
currname=fullfile(cpath,[cfile '.rpt' cver]);

if isempty(cfile)
   myFileName='Unnamed';
   emptyFileName=logical(1);
else
   myFileName=cfile;
   emptyFileName=logical(0);
end

statbar(g,sprintf('Saving setup file %s%s...',myFileName, cext));

if isSaveAs | emptyFileName
    
    [fullfilename, pathname]= uiputfile(currname,...
        'Save Setup File As');
    
    
    if ischar(fullfilename)
      %if user selected a valid filename
      [fPath fFile fExt fVer]=fileparts(fullfilename);
      fExt='.rpt';
      if isempty(fFile)
         fFile='Unnamed';
      end
      if isempty(pathname)
         pathname=pwd;
      end
      
      fName=fullfile(pathname,[fFile fExt fVer]);
      isOK=savesetfile(toSave,fName);
      namechange=logical(1);
   else
      %User cancelled out of saveas dialog
      return
   end
else %if just being called as a standard save
   namechange=logical(0);
   isOK=savesetfile(toSave);
end

g=savecursor(g,logical(0));

if ~isOK %if the setfile was not successfully saved
   statbar(g,xlate('Failed to save setup file.'),1); 
else
   statbar(g,xlate('Setup file successfully saved'));
   %tell the GUI that no changes have been made since the last time
   %the setup file was saved
   toSave.ref.changed=logical(0);
end


if namechange & toSave==g.s
   g=updateui(g,'SetfileName');
   %if outline is selected, force an update
   olPos=get(g.h.Main.outline,'position');
   if getcurrtab(g)==1 & olPos(1)==1
      g=updateui(g,'UpdateAttPageForce');
   end
else
   g=updateui(g);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function   g=SelectComplist(g,SelectionType,CompListValue);
%triggered when the component list on the add/remove
%tab is clicked

if ~isfield(g.ref,'complist') | isempty(g.ref.complist)
   return;
end

if nargin<3
   CompListValue=get(g.h.AddTab.complist,'Value');
   if nargin<2
      SelectionType=get(g.h.fig,'SelectionType');
   end
end

compname=g.ref.complist(CompListValue).compname;

numtabs=3;
if isnumeric(compname) %if the selected item is a group header
   if strcmp(SelectionType,'open')
      g.ref.compTypes(compname).Expand=...
         ~g.ref.compTypes(compname).Expand;
      updateType='UpdateComplist';
   else
      updateType='UpdateAddButton';
   end
   
   if g.ref.compTypes(compname).Expand
      action='collapse';
   else
      action='expand';
   end
   statbar(g,sprintf('Double click to %s this category',action));
   CompInfo(g,'');
   g=updateui(g,updateType);
else %if the user has selected a component
   switch SelectionType
   case 'open'  %add the currently selected component
         g=AddComponent(g);
         CompInfo(g,'Component added');
   case 'alternate'   %do nothing for now
   case 'extend'     %do nothing for now
   otherwise   %update the status bar
      eval(['myc=',g.ref.complist(CompListValue).compname,';'],...
         'myc=[]');
      if isa(myc,'rptcomponent')
         mycInfo=getinfo(myc);
         CompInfo(g,[mycInfo.Name,': ',mycInfo.Desc]);
      else
         CompInfo(g,'');
      end
      delete(myc)
      statbar(g,...
         'Double-click or push the "add" button to insert this component in the outline.');
      g=updateui(g,'UpdateAddButton');
   end   
end %if isnumeric(compname)
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function g=SelectOutline(g,SelectionType,OutlineValue);
%Triggered on mouse-up in the report outline.


currentOutline=gcbo;
if length(currentOutline)==1 & ...
      currentOutline~=g.h.Main.outline & ...
      strcmp(get(currentOutline,'type'),'uicontrol') & ...
      strcmp(get(currentOutline,'style'),'listbox')
   %this means that the selected outline does not reflect
   %the current setup file in g.s
   g=ChangeSetfile(g,get(currentOutline,'UserData'));
   %the setup file to which this outline applies is 
   %stored in the object's user data.   
end

if nargin<3
   OutlineValue=get(g.h.Main.outline,'Value');
   valChanged=logical(0);
   if nargin<2
      SelectionType=get(g.h.fig,'SelectionType');
   end
   
else
   set(g.h.Main.outline,'Value',OutlineValue);
   valChanged=logical(1);
end


switch SelectionType
case 'open'
   %double-clicks are captured as a single, then a double
   %we can therefore assume that the proper page has already
   %been created and that the outline is current
   if getcurrtab(g)~=1 | valChanged
      g=savecursor(g,logical(0));
      g=dotabselect(g,1,logical(1));
   end
case 'normal'
   %Selecting the outline does not update the Undo
   %information - it just sets the cursor to an
   %hourglass
   g=savecursor(g,logical(0));
   
   selected=multipleselect(g.s.ref.outlineIndex,OutlineValue);
   set(g.h.Main.outline,'Value',selected);
   
   %if ~isempty(g.c) & subset(g.s.ref.outlineIndex,selected(1))~=g.c{1}
      cinfo=getinfo(g.s.ref.outlineIndex(selected(1)));
      statbar(g,cinfo.Desc);      
   %end
   
   g=updateui(g,'UpdateAttPage','UpdateButtons');
case 'alt'
   %can't capture this yet - would like to launch the contextmenu
case 'extend'
   %can't capture this yet - would like to collapse
   %g=docollapse(g);
   %g=updateui(g,'UpdateAttPage','UpdateOutline','UpdateButtons');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function g=Undo(g)

undoHandle=get(undobuffer(g.s),'children');
undoSize=length(undoHandle);
if undoSize>0
   undoHandle=undoHandle(1);
   
   %note that we don't save undo information here.  makes sense.
   g=savecursor(g,logical(0));
   
   delete(children(g.s));
   uS=get(undoHandle,'UserData');
   uS.ref.ID=g.s;
   set(g.s,'UserData',uS);
   
   mainChild=get(undoHandle,'children');
   set(mainChild,'Parent',g.s.h);
   validate(children(g.s));
   indexlist(g.s);
      
   g.c=rptcp;
   
   g=updateui(g,'UpdateOutline',...
      'UpdateComplist','SetfileName',...
      'UpdateAttPageForce','NewTab','UpdateButtons');
   delete(undoHandle);
else
   statbar(g,'Can''t undo - no remaining undo actions saved',1); 
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% General utility functions used by other      %%
%% functions in this file.  Not intended to     %%
%% be called externally                         %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function StringOnOff=LocOnOff(LogicalOnOff)

if LogicalOnOff
   StringOnOff='on';
else
   StringOnOff='off';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%
function g=CheckForChange(g)

continueCheck=logical(1);
if g.s.ref.changed
   %if changes are not saved
   questtext={'Yes'
      'No'
      'Cancel'};
   [sPath sFile sExt sVer]=fileparts(g.s.ref.Path);
   if isempty(sFile)
      sFile='Unnamed';
   end
   
   whichbtn=questdlg(sprintf('Save Changes to "%s"?',sFile),...
      sprintf('Setup File Changed'),...
      questtext{1},questtext{2},questtext{3},questtext{3});
   
   switch whichbtn
   case 'Yes' %questtext{1}
      g=SaveAs(g,logical(1));
   case 'No' %questtext{2}
      g.s.ref.changed=logical(0);
      g=updateui(g);
   otherwise
      continueCheck=logical(0);
   end
end
g.ref.continue=continueCheck;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function   g=LocUpdateSelect(g,whichComponents)
%whichComponents is a list of component pointers
%These components should be selected in the outline list

toSelect=multipleselect(g.s.ref.outlineIndex,whichComponents);
set(g.h.Main.outline,'Value',toSelect);
g=updateui(g,'UpdateOutline',...
   'UpdateAttPage',... %update attpage handles outlinecurrent
   'UpdateButtons');

%g=SelectOutline(g,logical(0),'normal');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tf=isNonIntegerHandle(h)

%isHand=ishandle(h);
%isNonInteger=(mod(h,1)~=0);
%tf=isHand.*isNonInteger;

tf=ishandle(h) .* (mod(h,1)~=0);

