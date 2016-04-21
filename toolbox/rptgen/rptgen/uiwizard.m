function uiwizard(varargin)
%UIWIZARD launches a wizard
%   UIWIZARD <mfile> launches a wizard based upon the m-file

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:12:55 $

if nargin<1
   %no argin - launch the wizard creation wizard
   uiwizard mywiz;
else   
   eType=exist(varargin{1});
   if eType==2 | eType==6;
      %we were given the name of an m-file or p-file
      w=LocStartWizard(varargin{:});
   else
      w=get(gcbf,'UserData');
      w=feval(['Loc',varargin{1}],w,varargin{2:length(varargin)});      
   end
   if w.ref.Quit > 0 
      LocQuit(w);
   else
      set(w.h.figure,'UserData',w);
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function w=LocCancelButton(w)

w.ref.Quit=1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function w=LocPreviousButton(w);

w=LocRunPageExit(w,'Prev');

lpp=length(w.ref.PrevPages);
prevPage=w.ref.PrevPages{lpp};
w.ref.PrevPages={w.ref.PrevPages{1:lpp-1}};

w=LocMakePage(w,prevPage);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function w=LocNextButton(w);

info=LocGetPageInfo(w);
if info.Pathlist{info.Whichpath,1}<0
   %we are exiting
   w=LocRunPageExit(w,'Next');

   %w=feval(w.ref.MainPage,[w.ref.CurrPage,'Exit'],w,'Next');   
   w.ref.Quit=2;
elseif info.Pathlist{info.Whichpath,1}>0
   w=LocRunPageExit(w,'Next');
   nextPage=info.Pathlist{info.Whichpath,2};
   w.ref.PrevPages={w.ref.PrevPages{:},w.ref.CurrPage};   
   w=LocMakePage(w,nextPage);
else
   %do nothing
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function w=LocSkipButton(w);

skipPage=feval(w.ref.MainPage,'MainSkipTo',w);
if ~isempty(skipPage)
   w=LocRunPageExit(w,'Skip');
   w.ref.PrevPages={w.ref.PrevPages{:},w.ref.CurrPage};
   w=LocMakePage(w,skipPage);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function w=LocRoadmapSelect(w,index);

if strcmp(get(w.h.figure,'SelectionType'),'normal')
   if nargin<2
      index=get(w.h.Roadmap,'Value');
   end
   w=LocRunPageExit(w,'Rmap');
   
   pagelist=get(w.h.Roadmap,'UserData');
   w.ref.PrevPages={pagelist{1:index-1}};
   w=LocMakePage(w,pagelist{index});
end

   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function w=LocStartWizard(MainPageName,varargin)

w=LocInitData(MainPageName,varargin{:});

%eventually, tag should come from w
allFigs=allchild(0);
allTags=get(allFigs,'tag');
if ~isempty(allTags)
   matchIndex=find(strcmp(allTags,w.options.FigureTag));
   if ~isempty(matchIndex)
      figNumber=allFigs(matchIndex(1));
      figure(figNumber);
      w=get(figNumber,'UserData');
      return;
   end
end

w=LocInitFig(w);
w=LocMakePage(w,w.options.FirstPage);

set(w.h.figure,'closerequestfcn',['uiwizard CancelButton']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocQuit(w)

if w.ref.Quit==1 & w.options.WarnOnCancel
   questtext={'Exit'
      'Return'};
   whichbtn=questdlg('Exit wizard?','?',...
      questtext{1},questtext{2},questtext{2});
else
   whichbtn='Exit';
end

if strcmp(whichbtn,'Exit')
   delete(w.h.figure);
end


   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  The section from this point below represents helper %
%  functions called by the functions above this point. %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function w=LocInitData(MainPageName,varargin);

w=feval(MainPageName,'MainInitialize',LocPrototypeStruct,varargin{:});
w.ref.MainPage=MainPageName;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function w=LocPrototypeStruct;

data=[];

hg.all.Units='Points';
hg.all.BackgroundColor=get(0,'defaultuicontrolbackgroundcolor');
hg.all.HandleVisibility='off';
hg.pad=5;
hg.barht=get(0,'defaultuicontrolfontsize')+8;
hg.btnwidth=50;
hg.btnheight=hg.barht;
hg.roadmapwidth=100;
hg.titleheight=hg.barht;
hg.statbarheight=hg.barht;

ref.PrevPages={};
ref.CurrPage='';
ref.MainPage='';
ref.Quit=0;

h.figure=[];

options.FirstPage='';
options.Name='Wizard';
options.isSkipTo=logical(0);
options.SkipString='Skip to End >>';
options.isStatusBar=logical(0);
options.isCancel=logical(1);
options.WarnOnCancel=logical(1);
options.NavButtonAlign='FIT'; %'LEFT' %'RIGHT' %'CENTER'
options.isRoadmap=logical(0);
options.isTitle=logical(0);
options.PageSize=[300 200];
options.FigureTag='Uiwizard_Figure';

w.options=options;
w.ref=ref;
w.hg=hg;
w.h=h;
w.data=data;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function w=LocInitFig(w);

w.h.figure=figure('Color',w.hg.all.BackgroundColor,...
   'Units',w.hg.all.Units,...
   'HandleVisibility',w.hg.all.HandleVisibility,...
   'IntegerHandle','off',...
   'MenuBar','none', ...
   'Name',w.options.Name, ...
   'NumberTitle','off', ...
   'Resize','off',...
   'Visible','off',...
   'Tag',w.options.FigureTag);

w.hg.all.Parent=w.h.figure;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function w=LocMakePage(w,PageName);

f=w.h.figure;
delete(allchild(f));

w.h=[];
w.h.figure=f;

w.ref.CurrPage=PageName;
w=feval(w.ref.MainPage,[w.ref.CurrPage,'PreDraw'],w);
info=LocGetPageInfo(w);

%------------set up the figure -------------------
if w.options.isRoadmap
   w.hg.Xzero=w.hg.roadmapwidth+2*w.hg.pad;
else
   w.hg.Xzero=w.hg.pad;
end
w.hg.Xlim=w.options.PageSize(1)+w.hg.Xzero-2*w.hg.pad;
w.hg.width=w.hg.Xlim+w.hg.pad;

w.hg.Yzero=w.hg.btnheight+2*w.hg.pad;
if w.options.isStatusBar
   w.hg.Yzero=w.hg.Yzero+w.hg.statbarheight+w.hg.pad;
end
w.hg.Ylim=w.hg.Yzero+w.options.PageSize(2)-w.hg.pad;

if w.options.isTitle
   w.hg.height=w.hg.Ylim+w.hg.titleheight+w.hg.pad;
else
   w.hg.height=w.hg.Ylim+w.hg.pad;
end

pos=get(w.h.figure,'Position');
pos(3)=w.hg.width;
pos(4)=w.hg.height;
set(w.h.figure,'Position',pos,...
   'visible','on');

%--------- Create roadmap view -------------------

if w.options.isRoadmap
   if w.options.isRoadmap==2 %can select and jump
      roadmapEnable='on';
   else %can not select
      roadmapEnable='inactive';
   end
   
   [rmUserData,rmString]=LocMakeRoadmap(w,PageName);
   index=length(w.ref.PrevPages)+1;
   
   pos=[w.hg.pad w.hg.pad w.hg.roadmapwidth...
         w.hg.height-2*w.hg.pad];
   w.h.Roadmap=uicontrol(w.hg.all,...
      'Enable',roadmapEnable,...
      'UserData',rmUserData,...
      'String',rmString,...
      'Value',index,...
      'ListBoxTop',index,...
      'Style','listbox',...
      'BackgroundColor',[1 1 1],...
      'Callback','uiwizard(''RoadmapSelect'')',...
      'Position',pos);
else
   w.h.Roadmap=[];
end

%----------create navigation buttons -------------

numbtn=2;
if w.options.isCancel
   numbtn=numbtn+1;
end

if w.options.isSkipTo
   numbtn=numbtn+1;
end

btnwidth=(w.hg.Xlim-w.hg.Xzero-...
   (numbtn-1)*w.hg.pad)/numbtn;

if ~strcmp(w.options.NavButtonAlign,'FIT')
   btnwidth=min(w.hg.btnwidth,btnwidth);
end
allbtnwidth=btnwidth*numbtn+(numbtn-1)*w.hg.pad;

switch w.options.NavButtonAlign
case 'FIT'
   Xinit=w.hg.Xzero;
case 'LEFT'
   Xinit=w.hg.Xzero;   
case 'RIGHT'
   Xinit=w.hg.Xlim-allbtnwidth;   
case 'CENTER'
   Xinit=(w.hg.Xlim+w.hg.Xzero-allbtnwidth)/2;
end

pos=[Xinit w.hg.pad btnwidth w.hg.btnheight];
if w.options.isCancel
   w.h.Cancel=uicontrol(w.hg.all,...
      'Style','Pushbutton',...
      'String','Cancel',...
      'Callback',['uiwizard CancelButton'],...
      'Position', pos);
   pos(1)=pos(1)+pos(3)+w.hg.pad;
else
   w.h.Cancel=[];
end

if isempty(w.ref.PrevPages)
   pvEnable='off';
else
   pvEnable='on';
end

w.h.Previous=uicontrol(w.hg.all,...
   'Style','Pushbutton',...
   'Enable',pvEnable,...
   'String','<- Previous',...
   'Callback','uiwizard(''PreviousButton'')',...
   'Position', pos);


if info.Pathlist{info.Whichpath,1}<0
   nxEnable='on';
   nxString='Done';   
elseif info.Pathlist{info.Whichpath,1}>0
   nxEnable='on';
   nxString='Next ->';   
else
   nxEnable='off';
   nxString='Next ->';
end

pos(1)=pos(1)+pos(3)+w.hg.pad;
w.h.Next=uicontrol(w.hg.all,...
   'Style','Pushbutton',...
   'String',nxString,...
   'Enable',nxEnable,...
   'Callback','uiwizard(''NextButton'')',...
   'Position', pos);
pos(1)=pos(1)+pos(3)+w.hg.pad;

if w.options.isSkipTo
   skipTo=feval(w.ref.MainPage,'MainSkipTo',w);
   if isempty(skipTo) | strcmp(skipTo,w.ref.CurrPage)
      skEnable='off';
   else
      skEnable='on';
   end
   
   w.h.Skip=uicontrol(w.hg.all,...
      'Style','Pushbutton',...
      'Enable',skEnable,...
      'String',w.options.SkipString,...
      'Callback','uiwizard(''SkipButton'')',...
      'Position', pos);
else
   w.h.Skip=[];
end

%------------create status bar -------------------
if w.options.isStatusBar
   pos=[w.hg.Xzero w.hg.btnheight+2*w.hg.pad...
         w.hg.Xlim-w.hg.Xzero w.hg.statbarheight];
   w.h.StatusBar=uicontrol(w.hg.all,...
      'HorizontalAlignment','left',...
      'Style','edit',...
      'enable','inactive',...
      'Position',pos);
else
   w.h.StatusBar=[];
end

%------------create title -------------------------
if w.options.isTitle
   pos=[w.hg.Xzero w.hg.Ylim...
         w.hg.Xlim-w.hg.Xzero w.hg.titleheight];
   w.h.StatusBar=uicontrol(w.hg.all,...
      'HorizontalAlignment','left',...
      'Style','text',...
      'FontWeight','bold',...
      'String',info.Title,...
      'Position',pos);   
   set(w.h.figure,'Name',w.options.Name);
elseif w.options.isRoadmap
   set(w.h.figure,'Name',w.options.Name);   
else
   set(w.h.figure,'Name',info.Title);
end

%------------populate the rest of the page ---------

controlHandles=[w.h.Skip w.h.Previous w.h.Next w.h.Cancel ...
      w.h.Roadmap];
prevEnable=get(controlHandles,'Enable');
newEnable=strrep(prevEnable,'on','inactive');
set(controlHandles,{'Enable'},newEnable);
set(w.h.figure,'Pointer','watch');

w=feval(w.ref.MainPage,[w.ref.CurrPage,'Draw'],w);

set(w.h.figure,'Pointer','arrow');
set(controlHandles,{'Enable'},prevEnable);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [rmUserData,rmString]=LocMakeRoadmap(w,PageName);

rmUserData={w.ref.PrevPages{:},PageName};
for i=1:length(rmUserData)
   info=LocGetPageInfo(w,rmUserData{i});
   rmString{i}=info.Title;
end

fwdLoop=find([info.Pathlist{:,1}]==2);
fwdNext=find([info.Pathlist{:,1}]==1);
while ~isempty(fwdNext)
   i=i+1;
   nextName=info.Pathlist{fwdNext(1),2};
   rmUserData{i}=nextName;
   info=LocGetPageInfo(w,nextName);
   fwdLoop=find([info.Pathlist{:,1}]==2);
   fwdNext=find([info.Pathlist{:,1}]==1);
   if isempty(fwdLoop)
      loopString='';
   else
      loopString=' (loop)';
   end
   
   rmString{i}=[info.Title loopString];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function info=LocGetPageInfo(w,PageName);

if nargin<2
   PageName=w.ref.CurrPage;
end

info=feval(w.ref.MainPage,[PageName,'Information'],w);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function w=LocRunPageExit(w,caller)

PageName=w.ref.CurrPage;

w=feval(w.ref.MainPage,[PageName,'Exit'],w,caller);
