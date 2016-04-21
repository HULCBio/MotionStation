function g=updateui(g,varargin)
%UPDATEUI refreshes the setup file editor user interface
%   G=UPDATEUI(G,action1,action2,action3,....)
%   
%   See also BUILDUI, UPDATEUI

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:17:06 $


for i=1:length(varargin)
   g=feval(varargin{i},g);
end

%%%%%%%% always check the "changed" variable %%%%%%%%%%
isDirty=g.s.ref.changed;

figName=get(g.h.fig,'Name');
isStar=strncmp(figName(end),'*',1);

if isDirty
   if ~isStar
      figName=[figName,'*'];
      set(g.h.fig,'Name',figName);
   end
else %if not dirty
   if isStar
      figName=figName(1:end-1);
      set(g.h.fig,'Name',figName);
   end
end

%%%%%%%%%%%% Update the Pointer %%%%%%%%%%%%%%%%%%%%%

if strcmpi(g.ref.Pointer,'watch')
   g.ref.Pointer='arrow';
end

set(g.h.fig,...
   'Visible','on',...
   'Pointer',g.ref.Pointer)
g=MouseMotionFcn(g);
rgstoregui(g);
drawnow


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BEGIN COMPOUND UPDATE FUNCTIONS             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function g=NewSetfile(g);

g=SetfileName(g);
g=UpdateButtons(g);
g=UpdateAttPage(g,logical(1));
g=UpdateGenerationFilter(g);
%g=MouseMotionFcn(g);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function g=UpdateAll(g)
%This is called from rptgui/buildui when
%the setup file editor is being created

g=UpdateOutline(g);
g=SetfileName(g);
g=UpdateButtons(g);
g=Resize(g);
g=NewTab(g);
g=UpdateGenerationFilter(g);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BEGIN SINGLE-FUNCTION UPDATE FUNCTIONS      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function g=MouseMotionFcn(g)

if ~isempty(g.h.Main.outline)
   olH=sprintf('%0.16d',g.h.Main.outline);
else
   olH='[]';
end


barPos=get(g.h.Main.resizeline,'Position');

CR=sprintf('\n'); %carriage return
TB='   '; %tab
hrString=['if ' LocTruthString(barPos) CR ...   
      TB,'set(gcbf,''Pointer'',''left'')' CR ...
      TB,'set(',olH,',''HitTest'',''off'')' CR ...
      'else' CR];

if isempty(g.ref.ComponentPointer)
   hrString=[hrString ...
         TB,'set(gcbf,''Pointer'',''arrow'')',CR,... 
         TB,'set(',olH,',''HitTest'',''on'')',CR,...
         'end'];
else
   hrString=[hrString,TB,'if getcurrtab(rgstoregui)==1' CR];
   for i=1:length(g.ref.ComponentPointer)
      if i==1
         word='if ';
      else
         word='elseif ';
      end      
      hrString=[hrString,TB,TB,word, ...
            LocTruthString(g.ref.ComponentPointer(i).Area),CR,...
            TB,TB,TB,'set(gcbf,''Pointer'',''' g.ref.ComponentPointer(i).Pointer ''')',CR,...
            TB,TB,TB,'set(',olH,',''HitTest'',''on'')' CR ...
         ];
   end
        
   hrString=[hrString,TB,TB 'else' CR ...
         TB,TB,TB,'set(gcbf,''Pointer'',''arrow'')' CR ...
         TB,'set(',olH,',''HitTest'',''on'')', CR,...
         TB,TB,'end',CR ...
         TB, 'else' CR ...
         TB,TB,'set(gcbf,''Pointer'',''arrow'')' CR ...      
         TB,TB,'set(',olH,',''HitTest'',''on'')', CR,...
         TB, 'end' CR ...
         'end'];  
end

   
set(g.h.fig,'WindowButtonMotionFcn',hrString);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function g=Resize(g)
%resizes all figure children

g.layout=LocUpdateLayout(g.layout,g.h.fig);
l=g.layout;

allOutlines=findobj(allchild(g.h.fig),'flat',...
   'tag','OutlineListbox');

resizeHandles=[g.h.Main.statusbar;...
      g.h.Main.movbtn';... %3 objects!
      g.h.Main.deacbtn;...
      g.h.Main.rembtn;...      
      g.h.Main.GenerateBtn;...
      g.h.Main.resizeline;...   
      g.h.Main.tabedge';... %6 objects!
      g.h.Main.catab;...
      g.h.Main.artab;...
      g.h.Main.getab;...      
      g.h.AttTab.ErrorMessage(1);...
      g.h.AddTab.addbtn;...
      g.h.AddTab.helpbtn; ...
      g.h.AddTab.complist;... 
      g.h.AddTab.compinfo;...
      g.h.GenTab.statustext;...
      g.h.GenTab.statuspop;...
      g.h.GenTab.statuslist;...
      allOutlines];

barht=layoutbarht(g);
allBtnHt=6*l.btnside+5*l.padding;
outlineHt=l.tabbodyht+l.tabht;
outlineXzero=2*l.padding+l.btnside;


lowerBorder=2*l.padding+barht;

tabXzero=3*l.padding+l.btnside+l.outlinewidth;
tabYzero=lowerBorder;
tabThick=l.pixel;

barThick=3;
barStart=outlineXzero+l.outlinewidth+l.padding/2-barThick/2-1;
%barStart=tabXzero-barThick;


numtabs=3;
tabSpace=3; %space between tabs
tabwidth=l.tabbodywidth/numtabs-tabSpace;
tabOffset=1; %button overlap with tabedge(1)

compInfoHt=2*15;

genBtnWidth=min(100,l.outlinewidth);
genBtnHeight=l.statbarht;

statusTextSize=get(g.h.GenTab.statustext,'Extent');
statusTextWid=min((statusTextSize(3)+l.padding/2),...
   ((l.tabbodywidth-2*l.padding)*.6));

[outlinePosition{1:length(allOutlines),1}]=deal([outlineXzero lowerBorder+genBtnHeight+l.padding ...
      l.outlinewidth outlineHt-genBtnHeight-l.padding]);

resizePosition=[{[l.padding l.padding l.figWidth-2*l.padding l.statbarht] %statusbar
      [l.padding lowerBorder+(outlineHt-allBtnHt)/2+5*(l.btnside+l.padding),...
            l.btnside l.btnside] %movbtn(1)
      [l.padding lowerBorder+(outlineHt-allBtnHt)/2+4*(l.btnside+l.padding),...
            l.btnside l.btnside] %movbtn(2)
      [l.padding lowerBorder+(outlineHt-allBtnHt)/2+3*(l.btnside+l.padding),...
            l.btnside l.btnside] %movbtn(3)
      [l.padding lowerBorder+(outlineHt-allBtnHt)/2+1*(l.btnside+l.padding),...
            l.btnside l.btnside] %deacbtn
      [l.padding lowerBorder+(outlineHt-allBtnHt)/2+0*(l.btnside+l.padding),...
            l.btnside l.btnside] %rembtn
      [outlineXzero+l.outlinewidth-genBtnWidth lowerBorder,...
            genBtnWidth,genBtnHeight] %GenerateBtn
      [barStart lowerBorder barThick outlineHt] %resizeline
      [tabXzero tabYzero+l.tabbodyht-tabThick ...
            l.tabbodywidth-tabThick tabThick*2] %tabedge(1) white
      [tabXzero+l.tabbodywidth-tabThick tabYzero ...
            tabThick,l.tabbodyht] %tabedge(2) black
      [tabXzero tabYzero l.tabbodywidth tabThick] %tabedge(3) black
      [tabXzero tabYzero tabThick*2 l.tabbodyht] %tabedge(4) white
      [tabXzero+l.tabbodywidth-1.5*tabThick tabYzero+tabThick ...
            tabThick,l.tabbodyht-tabThick] %tabedge(5) grey
      [tabXzero+tabThick tabYzero+tabThick ...
            l.tabbodywidth-2*tabThick tabThick] %tabedge(6) grey
      [tabXzero+tabSpace/2 ...
            tabYzero+l.tabbodyht-tabOffset tabwidth l.tabht+tabOffset] %catab
      [tabXzero+tabSpace/2+1*(tabwidth+tabSpace) ...
            tabYzero+l.tabbodyht-tabOffset tabwidth l.tabht+tabOffset] %artab
      [tabXzero+tabSpace/2+2*(tabwidth+tabSpace) ...
            tabYzero+l.tabbodyht-tabOffset tabwidth l.tabht+tabOffset] %getab
      [tabXzero+10 tabYzero+10 l.tabbodywidth-20 l.tabbodyht-20] %ErrorMessage
      [tabXzero+l.padding,...
            tabYzero+l.tabbodyht-4*l.btnside,...
            l.btnside,...
            l.btnside] %addbtn
      [tabXzero+l.padding,...
            tabYzero+l.tabbodyht-5*l.btnside-l.padding,...
            l.btnside,...
            l.btnside] %helpbtn
      [tabXzero+2*l.padding+l.btnside,...
            tabYzero+l.padding+compInfoHt,...
            l.tabbodywidth-2*l.padding-l.btnside-l.padding,...
            l.tabbodyht-2*l.padding-compInfoHt] %complist
      [tabXzero+2*l.padding+l.btnside,...
            tabYzero+l.padding,...
            l.tabbodywidth-2*l.padding-l.btnside-l.padding,...
            compInfoHt] %compinfo
      [tabXzero+l.padding,...
            tabYzero+l.tabbodyht-l.padding-barht,...
            statusTextWid,...
            barht] %statustext
      [tabXzero+l.padding+statusTextWid,...
            tabYzero+l.tabbodyht-l.padding-barht,...
            l.tabbodywidth-2*l.padding-statusTextWid,...
            barht] %statuspop
      [tabXzero+l.padding,...
            tabYzero+l.padding,...
            l.tabbodywidth-2*l.padding,...
            l.tabbodyht-2*l.padding-barht]} %statuslist
   outlinePosition]; 


set(resizeHandles,{'Position'},resizePosition);

%-----perform actual resizing------------------

g=PlacePatch(g);

g=attpageaction(g,'resize');

%g=MouseMotionFcn(g);


%We are forcing the resizeline to the top so
%that it will be recognized when the user clicks in the area 
%between the tab and the outline

%Unfortunately, changing the stacking order of the
%objects screws with uimenus, so we won't do this for now.

%LocForceToTop(g.h.fig,g.h.Main.resizeline,...
%      g.h.Main.outline,g.h.Main.tabedge(4))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  g=SetfileName(g)

rptPath=g.s.ref.Path;

r=rptcomponent;
r.SetfilePath=rptPath;

[sPath, sName, sExt, sVer]=fileparts(rptPath);
if isempty(sName)
   sName='Unnamed';
end
if isempty(sExt)
   sExt='.rpt';
end
if g.s.ref.changed
   endAsterisk='*';
else
   endAsterisk='';
end


%set(g.h.Main.setname,'String',[sName sExt]);
set(g.h.fig,'Name',sprintf('Setup File Editor - %s%s',...
      fullfile(sPath,[sName sExt]), endAsterisk));


UpdateOutlineCurrent(g,1);

%Update "Window" menu item

if ~isfield(g.h.WindowMenu,'rptlist') | ...
        isempty(g.h.WindowMenu.rptlist) | ... 
        ~ishandle(g.h.WindowMenu.rptlist)
    g.h.WindowMenu.rptlist=uimenu(...
        'Parent',g.h.WindowMenu.Parent,...
        'HandleVisibility',g.hg.all.HandleVisibility,...
        'Label','Setup File &List...',...
        'Callback',...
        'statbar(rgstoregui,xlate(''Launching "Setup File List" GUI''));rptlist'); 
end

if ~isfield(g.h.WindowMenu,'rptconvert') | ...
        isempty(g.h.WindowMenu.rptconvert) | ...
        ~ishandle(g.h.WindowMenu.rptconvert)
    g.h.WindowMenu.rptconvert=uimenu(...
        'Parent',g.h.WindowMenu.Parent,...
        'HandleVisibility',g.hg.all.HandleVisibility,...
        'Label','&Convert SGML File...',...
        'Callback',...
        'statbar(rgstoregui,xlate(''Launching "Convert SGML File" GUI''));rptconvert'); 
end

if isfield(g.h.WindowMenu,'OpenFiles')
    delete(g.h.WindowMenu.OpenFiles);
end

g.h.WindowMenu.OpenFiles=[];

allFiles=cell(1,length(g.ref.OpenSetfiles));
for i=1:length(g.ref.OpenSetfiles)   
   if g.ref.OpenSetfiles(i)==g.s.h
      menuName=sName;
      menuCheck='on';
   else
      windowS=get(g.ref.OpenSetfiles(i),'UserData');
      [path,menuName,ext,ver]=fileparts(...
         windowS.ref.Path);
      if isempty(menuName)
         menuName='Unnamed';
      end
      menuCheck='off';
   end
   g.h.WindowMenu.OpenFiles(i)=uimenu(...
      'Parent',g.h.WindowMenu.Parent,...
      'HandleVisibility',g.hg.all.HandleVisibility,...
      'Label',['&' num2str(i) ' ' menuName],...
      'Checked',menuCheck,...
      'UserData',rptsp(g.ref.OpenSetfiles(i)),...
      'Separator',LocOnOff(i==1),...
      'Callback',['doguiaction(',g.ref.grud,...
         ',''ChangeSetfile'',',num2str(i),');']); 
   allFiles{i}=menuName;
end

%disp(allFiles)
%update java view
if ~isempty(g.ref.ObjectBrowserHandle)
   try
       obh=g.ref.ObjectBrowserHandle;
       obh.refresh(allFiles);
   catch
       %disp(lasterr)
   end
else
    %disp('ObjectBrowserHandle is empty - not updating');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  g=UpdateAddButton(g);


currcpos=get(g.h.AddTab.complist,'Value');

if isnumeric(g.ref.complist(currcpos).compname)
   addEnable='off';
   img=getfield(get(g.h.AddTab.addbtn,'UserData'),'no');   
   tts='Select a component to add';
else
   addEnable='on';
   img=getfield(get(g.h.AddTab.addbtn,'UserData'),'ok');   
   tts=sprintf('Add "%s" component',g.ref.complist(currcpos).Name);
end

set(g.h.AddTab.addbtn,...
   'Enable',addEnable,...
   'CData',img,...
   'TooltipString',tts)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function g=UpdateButtons(g)

curropos = get(g.h.Main.outline,'Value');

firstComp = subset(g.s.ref.outlineIndex,curropos(1));
firstInfo=getinfo(firstComp);
OutlineSelect=isoutlineselected(g.s,curropos);
MultiSelect=(length(curropos)>1);

if MultiSelect
   NameString=' selected components ';
else
   NameString=sprintf(' "%s" component ',firstInfo.Name);
end

%-----------logic for navigation buttons -----------

teststr={'us' 'ds' 'uo' 'do' 'ui' 'di'};
ok=movecomp(...
   selectroot(g.s.ref.outlineIndex,curropos),...
   't',teststr);
teststr{7}='no';
ok(7)=logical(1);

tts={sprintf('Move%sup',NameString);
   sprintf('Move%sdown',NameString);
   sprintf('Jump%sup out of loop',NameString);
   sprintf('Jump%sdown out of loop',NameString);
   sprintf('Jump%sinto previous loop',NameString);
   sprintf('Jump%sinto next loop',NameString);
   sprintf('%scan not be moved',NameString)};
   
navPrefs=[1 3 7;  %Straight up, promote up
   2 4 7 %straight down, promote down     %OLD:   4 3 7 %down&out, up&out
   5 6 7]; %up&in, down&in


for i=size(navPrefs,1):-1:1
   index=find(ok(navPrefs(i,:)));
   index=navPrefs(i,index(1));
   code=teststr{index};
   if index==7
      navEnable='off';
   else
      navEnable='on';
   end
         
   %Images are stored in the UserData of the button
   img=getfield(get(g.h.Main.movbtn(i),'UserData'),code);
   
   arrayCdata{i}=img;
   arrayTag{i}=code;
   arrayTip{i}=tts{index};
   arrayEnable{i}=navEnable;
end

set(g.h.Main.movbtn(1:3),...
   {'cdata'},arrayCdata',...
   {'Tag'},arrayTag',...
   {'ToolTipString'},arrayTip',...
   {'Enable'},arrayEnable');

%-------------logic for "deactivate" switches-------------
isActive=firstComp.comp.Active;
if OutlineSelect
   activeEnable='off';
   acdeacVal=logical(0);
   img=getfield(get(g.h.Main.deacbtn,'UserData'),'no');
else
   if isActive
      img=getfield(get(g.h.Main.deacbtn,'UserData'),'ac');
      acdeacVal=logical(0);
   else
      acdeacVal=logical(1);
      img=getfield(get(g.h.Main.deacbtn,'UserData'),'in');
   end
   activeEnable='on';
end

set(g.h.Main.deacbtn,...
   'Enable',activeEnable,...
   'cdata',img,...
   'Value',acdeacVal)

if MultiSelect | ~isActive
   activeCheck='off';
else
   activeCheck='inactive';
end

%Set the title on the component attributes page to Enable="Off"
try
   set(g.h.catab.title,'Enable',activeCheck)
end

%--------------logic for "remove" button-----------------
if OutlineSelect
   enableRemove='off';
   tts=sprintf('Can not remove%s.',NameString);
   img=getfield(get(g.h.Main.rembtn,'UserData'),'no');
else
   enableRemove='on';   
   tts=sprintf('Delete%s',NameString);
   if isparent(firstComp) | MultiSelect
      tts=sprintf('%sand all subcomponents',tts);
   end
   img=getfield(get(g.h.Main.rembtn,'UserData'),'ok');
end

set(g.h.Main.rembtn,...
   'Enable',enableRemove,...
   'CData',img,...
   'ToolTipString',tts);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function g=UpdateComplist(g,isForce)

if nargin<2
   isForce=logical(0);
end

currVal=get(g.h.AddTab.complist,'Value');
g=buildcomplist(g,isForce);
set(g.h.AddTab.complist,...
   'FontAngle','normal',...
   'Enable','on',...
   'Max',1,'Min',0,...
   'Value',(max(1,min(currVal,length(g.ref.complist)))),...
   'string',{g.ref.complist.LBstring});
set(g.h.AddTab.helpbtn,'Enable','on');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function g=UpdateGenerationFilter(g);

set(g.h.GenTab.statuspop,...
   'Value',g.s.Setfile.EchoDetail+1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function g=UpdateOutline(g)

olstr=outlinestring(g.s.ref.outlineIndex);
%protect against going out-of-bounds on listbox

set(g.h.Main.outline,...
   'String',olstr,...
   'Value',...
   min(get(g.h.Main.outline,'Value'),length(olstr)),...
   'ListBoxTop',...
   min(get(g.h.Main.outline,'ListBoxTop'),length(olstr)))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function g=UpdateOutlineCurrent(g,olIndex)
%updates only the current entry in the outline

if nargin<2
   olIndex=get(g.h.Main.outline,'Value');
end

olstring=get(g.h.Main.outline,'String');
oldListBoxTop = get(g.h.Main.outline,'ListboxTop');

olstring(olIndex)=outlinestring(...
    subset(g.s.ref.outlineIndex,olIndex),...
    logical(1));

set(g.h.Main.outline,...
    'String',olstring,...
    'ListboxTop',oldListBoxTop);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function g=NewTab(g);
%TABHACK
g=PlacePatch(g);
   
currtab=getcurrtab(g);
switch currtab
case 1
   SetViz(g.h.AddTab,'off')
   SetViz(g.h.GenTab,'off')
   %drawnow
   g=attpageaction(g,'start');
case 2
   SetViz(g.h.GenTab,'off')
   ClearAtt(g)
   SetViz(g.h.AddTab,'on')
      
   if get(g.h.AddTab.complist,'UserData')
      drawnow
      %if the add Tab has never been clicked before
      set(g.h.AddTab.complist,'UserData',logical(0));
      g=UpdateComplist(g,logical(1));
      g=UpdateAddButton(g);
   end
case 3
   ClearAtt(g)
   SetViz(g.h.AddTab,'off')
   SetViz(g.h.GenTab,'on')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function g=PlacePatch(g)

currtab=getcurrtab(g);
switch currtab
case 1
   copypos=get(g.h.Main.catab,'Position');
case 2
   copypos=get(g.h.Main.artab,'Position');
case 3
   copypos=get(g.h.Main.getab,'Position');
end

pos=[copypos(1)+1 copypos(2) copypos(3)-3 3];
set(g.h.Main.tabpatch,'Position',pos);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function   SetViz(struct,onoff)

fields=fieldnames(struct);
for i=1:length(fields)
   set(getfield(struct,fields{i}),'Visible',onoff)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ClearAtt(g)
%find all children of the current figure and
%delete those which are not listed in the "g.h" struct

apo=findall(allchild(g.h.fig),...
   'Tag','ComponentAttributesPageObject');
set(apo,'Visible','off');

set(g.h.AttTab.ErrorMessage,'Visible','off');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function g=UpdateAttPageForce(g);

g=UpdateAttPage(g,logical(1));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function g=UpdateAttPage(g,forceupdate);

if nargin<2 | ~forceupdate
   forceupdate=logical(0);
end


if getcurrtab(g)==1
   
   if forceupdate
      action='startforce';
   else
      action='start';
   end
   
   g=attpageaction(g,action);
else
   g=UpdateOutlineCurrent(g);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function true=IsInList(parents,thisparent)
%parents is a cell array of vectors
%thisparent is a vector

true=logical(0);
index=1;

while ~true & index<=length(parents)
   if length(thisparent)==length(parents{index})
      true=logical(max(thisparent==parents{index}))
   end
   index=index+1;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function StringOnOff=LocOnOff(LogicalOnOff)

if LogicalOnOff
   StringOnOff='on';
else
   StringOnOff='off';
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function L=LocUpdateLayout(L,figHandle)

mainfig = get(figHandle,'Position');
L.figWidth=mainfig(3);
L.figHeight=mainfig(4);
set(figHandle,'units','pixels');
pixPos=get(figHandle,'Position');
set(figHandle,'units','points');
L.pixel=L.figWidth/pixPos(3);

yleftover=1.5*L.padding*2+L.statbarht+L.tabht;
L.tabbodyht = L.figHeight-yleftover;

if L.tabbodyht<L.minTabBodyHt
   L.tabbodyht=L.minTabBodyHt;
   L.figHeight = L.tabbodyht+yleftover;
end

xleftover=L.padding*4+L.btnside;

partswidth=L.tabbodywidth+L.outlinewidth+xleftover;

L.outlinewidth=L.outlinewidth/partswidth*L.figWidth;
L.tabbodywidth=L.figWidth-L.outlinewidth-xleftover;

if L.tabbodywidth<L.minTabBodyWidth
   L.tabbodywidth=L.minTabBodyWidth;
   L.outlinewidth=L.figWidth-L.tabbodywidth-xleftover;
end

if L.outlinewidth<L.minOutlineWidth
   L.outlinewidth=L.minOutlineWidth;
   L.tabbodywidth=L.figWidth-L.outlinewidth-xleftover;
end

minwidth=L.minOutlineWidth+L.minTabBodyWidth+xleftover;

if L.figWidth<minwidth
   L.tabbodywidth=L.minTabBodyWidth;
   L.outlinewidth=L.minOutlineWidth;
   L.figWidth=minwidth;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tS=LocTruthString(pos)

tS=['all(get(gcbf,''CurrentPoint'')>[' ...
      num2str(pos(1)) ' '  num2str(pos(2)) ...
      ']) & all(get(gcbf,''CurrentPoint'')<[' ...
      num2str(pos(1)+pos(3)) ' '  num2str(pos(2)+pos(4)) '])'];


