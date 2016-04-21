function c=attribute(c,action,varargin)
%ATTRIBUTE launches the setup file editor options page

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:19:32 $

c=feval(action,c,varargin{:});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=start(c)

loopFrame=controlsframe(c,'Report On ');
optFrame=controlsframe(c,'Loop Options');

c=controlsmake(c,{
   'LoopType'
   'ObjectList'
   'SortBy'
   'isFilterList'
});

slCD=getslcdata(c);
loopInfo=loopblock(c.zslmethods);

c.x.LoopData=[loopInfo.contextCode,...
      {slCD.SystemLarge;slCD.ModelLarge;...
         slCD.SignalLarge;slCD.BlockLarge;slCD.ModelLarge},...
      loopInfo.contextName];

c.x.LoopImage=uicontrol(c.x.all,...
   'style','togglebutton',...
   'Enable','inactive',...
   'Value',1,...
   'Position',[-100 -100 1 1]);

loopFrame.FrameContent={
   c.x.LoopType(1)
   c.x.LoopType(2)
   {'indent' c.x.ObjectList}
};


c.x.FilterNameTitle=uicontrol(c.x.all,...
   'style','text',...
   'HorizontalAlignment','left',...
   'String','Property name');
c.x.FilterValueTitle=uicontrol(c.x.all,...
   'style','text',...
   'HorizontalAlignment','left',...
   'String','Property value');

%Note: to increase the number of filter terms
%exposed in the GUI, assign "numFilters" to be
%any integer.  Note that for large numbers of
%exposed filters, the GUI may extend beyond
%the available space.
numFilters=1;
for i=numFilters:-1:1
   nameIndex=i*2-1;
   valueIndex=i*2;
   
   if length(c.att.FilterTerms)>=valueIndex
      nameString=c.att.FilterTerms{nameIndex};
      valueString=c.att.FilterTerms{valueIndex};
   else
      nameString='';
      valueString='';
   end
   
   cbString=sprintf('%s''UpdateFilter'',%i);',...
      c.x.getobj,...
      nameIndex);
   c.x.FilterName(i,1)=uicontrol(c.x.all,...
      'style','edit',...
      'HorizontalAlignment','left',...
      'BackgroundColor',[1 1 1],...
      'String',nameString,...
      'Callback',cbString);
   
   c.x.FilterValue(i,1)=uicontrol(c.x.all,...
      'style','edit',...
      'HorizontalAlignment','left',...
      'BackgroundColor',[1 1 1],...
      'String',valueString,...
      'Callback',cbString);
end

optFrame.FrameContent={
   {c.x.SortByTitle c.x.SortBy}
   [5]
   c.x.isFilterList
   {
      'indent' c.x.FilterNameTitle c.x.FilterValueTitle
      [5] num2cell(c.x.FilterName) num2cell(c.x.FilterValue)
   }
   [3]
};

c.x.LayoutManager={loopFrame
   [5]
   optFrame};

UpdateFrame(c);
EnableControls(c);


c=resize(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=refresh(c);
%Update component when switching tabs, moving
%deactivating

UpdateFrame(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=resize(c)

c=controlsresize(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=Update(c,whichControl,varargin)

c=controlsupdate(c,whichControl,varargin{:});
EnableControls(c);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function EnableControls(c);

set([c.x.ObjectList],'enable',...
   onoff(strcmp(c.att.LoopType,'$list')));


set([c.x.FilterNameTitle;c.x.FilterValueTitle;...
      c.x.FilterName;c.x.FilterValue],'enable',...
   onoff(c.att.isFilterList));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function UpdateFrame(c);

lType=getparentloop(c);
ud=c.x.LoopData;

typeIndex=find(strcmp(ud(:,1),lType));
if length(typeIndex)<1
   typeIndex=size(ud,1);
else
   typeIndex=typeIndex(1);
end

set(c.x.LoopImage,'CData',ud{typeIndex,2});
set(c.x.LoopType(1),'String',...
   sprintf('Auto - %s',ud{typeIndex,3}));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function strOnOff=onoff(logOnOff)

if logOnOff
   strOnOff='on';
else
   strOnOff='off';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=UpdateFilter(c,index);
%Index is the "name" position of the P-V pair

nameIndex=index;
valueIndex=index+1;
hIndex=(index+1)/2;

hName=c.x.FilterName(hIndex);
hValue=c.x.FilterValue(hIndex);

nameString=get(hName,'String');
valueString=get(hValue,'String');

if length(c.att.FilterTerms)>=nameIndex
   prevName=c.att.FilterTerms{nameIndex};
   newFilter=logical(0);
else
   prevName='';
   newFilter=logical(1);
end

if ~isempty(nameString)
   [nameString,errorMsg]=rptgenutil('VariableNameCheck',...
      nameString,...
      prevName,...
      logical(0));
   errorMsg=strrep(errorMsg,'variable','property');
   errorMsg=strrep(errorMsg,'Variable','Property');
else
   errorMsg='';
end


statbar(c,errorMsg,1);
set(hName,'String',nameString);

c.att.FilterTerms{nameIndex}=nameString;
c.att.FilterTerms{valueIndex}=valueString;