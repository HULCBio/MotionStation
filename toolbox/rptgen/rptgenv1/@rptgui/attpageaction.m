function g=attpageaction(g,action,varargin)
%ATTPAGEACTION controls the attribute page
%   G=ATTPAGEACTION(G,'action',argin1,argin2,argin3...)

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:16:51 $

currSelected=subset(g.s.ref.outlineIndex,get(g.h.Main.outline,'Value'));
c=subset(currSelected,1);

%currSelected=g.s.ref.outlineIndex(get(g.h.Main.outline,'Value'));
%c=currSelected{1};

%--------set up information flags ------------
multiflag=(length(currSelected)>1);
newflag=~(currSelected==g.c);
startflag=(strcmpi(action,'start') | ...
   strcmpi(action,'startforce'));
resizeflag=strcmpi(action,'resize');
updateActions={};

%---------RUN THE "ATTRIBUTE" PAGE--------------

if startflag & newflag | strcmpi(action,'startforce')      
   c=LocInitComponent(c,g,logical(1));
   g.h.catab.title=c.x.title;
   g.h.catab.ComponentHelpButton=c.x.ComponentHelpButton;
   
   LocTopbarPosition(c);
   
   try
      attribute(c,'start',varargin{:});
      updateActions{end+1}='UpdateOutlineCurrent';
      g.c=currSelected;
   catch
      statbar(g,'Warning - error while drawing options page',1);
      c.x.allInvisible=logical(1);
   end
elseif ~startflag & ~newflag
   c=LocInitComponent(c,g,logical(0));

   if ~resizeflag
      g=savecursor(g,logical(1));
      attribute(c,action,varargin{:});
      updateActions{end+1}='UpdateOutlineCurrent';
   else
      %if we are resizing....
      LocTopbarPosition(c);
      try
         attribute(c,'resize',varargin{:});
      catch
         c.x.allInvisible=logical(1);
      end
   end %if ~resizeflag  
elseif startflag & ~newflag
   %We were given a start command but already
   %exist:  refresh the attpage
   oldWarn=nenw(g);
   try
      attribute(c,'refresh');
   end
   updateActions{end+1}='UpdateOutlineCurrent';
   nenw(g,oldWarn);
else
   %Not start command but new (probably a resize)
   if ~isfield(c.x,'allInvisible');
      c.x.allInvisible=logical(0);
   end
   if ~isfield(c.x,'InvisibleHandles')
      c.x.InvisibleHandles=[];
   end
   if ~isfield(c.x,'ComponentPointer')
      c.x.ComponentPointer=[];
   end
end

apo=findall(allchild(g.h.fig),...
   'Tag','ComponentAttributesPageObject');

if multiflag %if multiple selected, disable all uicontrols
   allcontrols=findall(apo,'Type','uicontrol');
   set(allcontrols,'enable','off')
   titleFunction='';
else
   titleFunction='';
   %This causes clicking on the title to toggle
   %the Activate/Deactivate state
   %titleFunction=['doguiaction(',g.ref.grud,',''AcDeactivate'');'];
end

if c.comp.Active
   titleEnable='inactive';
else
   titleEnable='off';
end

try
   set(g.h.catab.title,...
      'ButtonDownFcn',titleFunction,...
      'Enable',titleEnable);
end

if getcurrtab(g)==1
   if ~c.x.allInvisible
      set(apo,'Visible','on');
      set(g.h.AttTab.ErrorMessage,'Visible','off');
      %disp('Setting invisibles')
      try
         set(c.x.InvisibleHandles,'Visible','off');
      end
      
   else
      set(apo,'Visible','off');
      set(g.h.AttTab.ErrorMessage,'Visible','on');
   end
else
   set(apo,'Visible','off');
end

g.ref.ComponentPointer=c.x.ComponentPointer;
if ~resizeflag
   updateui(g,updateActions{:});
end


%%%%%%%%%%%%%% Set Layout "c.x" values %%%%%%%%%%%%%%
function c=LocInitComponent(c,g,isFirst);

if isFirst
   all=g.hg.all;
   all.Tag='ComponentAttributesPageObject';
   all.Visible='off';
   
   x=struct('InvisibleHandles',[],...
      'ComponentPointer',struct('Area',{},'Pointer',{}),...
      'all',all,...   
      'getobj',['attpageaction(' g.ref.grud ','],...
      'title',[],...
      'ComponentHelpButton',[],...
      'statusbar',g.h.Main.statusbar);
   
   apo=findall(allchild(x.all.Parent),'flat',...
      'Tag',x.all.Tag);
   delete(apo);   
   
   info=getinfo(c);
   
   x.title=uicontrol(x.all,...
      'style','text',...
      'FontSize',get(0,'defaultuicontrolfontsize')*2-1,...
      'HorizontalAlignment','left',... 
      'String',info.Name);
   
   x.ComponentHelpButton=uicontrol(x.all,...
      'Style','pushbutton',...
      'ToolTipString','Component help',...
      'BackgroundColor',get(0,'DefaultUIcontrolBackgroundColor'),...
      'Cdata',g.ref.CData.questionsmall,...
      'Callback',['helpview(rptparent,''' c.comp.Class ''',''component'');']);
else
   x=c.x;
end

%these are updated every time
tabpos=get(g.h.Main.tabedge,'Position');
tp1=tabpos{1};
tp2=tabpos{2};
tp3=tabpos{3};
tp4=tabpos{4};

x.xzero= tp4(1)+tp4(3);
x.xext= tp2(1);
x.xlim= x.xext;

try
   titleExtent=get(x.title,'extent');
   x.titleheight=titleExtent(4);
catch
   x.titleheight=20;
end

x.ylim = tp1(2)-x.titleheight-5;
x.yorig=tp3(2)+tp3(4);
x.yzero=x.yorig;

x.allInvisible=logical(0);


c.x=x;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tbPos=LocTopbarPosition(c)
%a 2x1 array with the appropriate positions
%for the {1,1} title and {2,1} help button

x=c.x;

pad=10;
btnSide=20;

%position help button right
titlePos=[x.xzero+pad
   x.ylim
   (x.xext-2.5*pad-x.xzero-btnSide)
   x.titleheight];
helpPos=[x.xext-pad-btnSide
   x.ylim+x.titleheight-btnSide
   btnSide
   btnSide];

   
tbPos={titlePos;helpPos};

set([x.title x.ComponentHelpButton],...
   {'Position'},tbPos);
