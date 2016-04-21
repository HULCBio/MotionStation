function c=attribute(c,action,varargin)
%ATTRIBUTE launches the setup file editor options page

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:17:59 $

c=feval(action,c,varargin{:});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=start(c)

loopFrame=controlsframe(c,'Report On ');
optFrame=controlsframe(c,'Loop Options');

c=controlsmake(c,{
   'LoopType'
   'ObjectList'
   'isSortList'
   'SortBy'
   'isSFFilterList'
   'isSLFilterList'
});

loopFrame.FrameContent={
   c.x.LoopType(1)
   c.x.LoopType(2)
   {'indent' c.x.ObjectList
      [1] c.x.isSortList}
};

c.x.FilterNameTitle=uicontrol(c.x.all,...
   'style','text',...
   'HorizontalAlignment','left',...
   'String','Property name');
c.x.FilterValueTitle=uicontrol(c.x.all,...
   'style','text',...
   'HorizontalAlignment','left',...
   'String','Property value');

[c.x.FilterName{1} c.x.FilterValue{1}] = create_filter_fields( c, c.att.FilterTerms{1}, 1 );
[c.x.FilterName{2} c.x.FilterValue{2}] = create_filter_fields( c, c.att.FilterTerms{2}, 2 );

   
optFrame.FrameContent={
   {c.x.SortByTitle c.x.SortBy}
   [5]
    {  'indent' c.x.FilterNameTitle c.x.FilterValueTitle
      c.x.isSFFilterList c.x.FilterName{1} c.x.FilterValue{1}
      c.x.isSLFilterList c.x.FilterName{2} c.x.FilterValue{2}
    }  
      [3]
};

c.x.LayoutManager={loopFrame
   [5]
   optFrame};

refresh(c);
EnableControls(c);


c=resize(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=resize(c)

c=controlsresize(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=Update(c,whichControl,varargin)

c=controlsupdate(c,whichControl,varargin{:});
EnableControls(c);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function EnableControls(c);

set([c.x.ObjectList,c.x.isSortList],'enable',...
   onoff(strcmp(c.att.LoopType,'$list')));

set(c.x.SortBy,'enable',...
   onoff(strcmp(c.att.LoopType,'$auto') | c.att.isSortList));

set([c.x.FilterName{2};c.x.FilterValue{2}],'enable',...
   onoff(c.att.isSLFilterList));
set([c.x.FilterName{1};c.x.FilterValue{1}],'enable',...
   onoff(c.att.isSFFilterList));
set([c.x.FilterNameTitle;c.x.FilterValueTitle],'enable',...
   onoff(c.att.isSFFilterList|c.att.isSLFilterList));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=refresh(c)
%Update component when switching tabs, moving
%deactivating

[validity, errMsg] = rgsf( 'is_parent_valid', c );
titleString = 'Chart Loop'; 
if ~validity
   titleString='Chart Loop: (invalid parent)';
   errString=sprintf('Error: this component %s', xlate(errMsg));
   errType=1;
else
   errString='';
   errType=0;
end

statbar(c,errString,errType);
set(c.x.title,'String',titleString);
% set the string for the radio btn:
loopInfo=searchblocktype(c.zslmethods,sprintf('Stateflow chart'));
typeIndex=find(strcmp(loopInfo.contextCode,getparentloop(c)));
if ~isempty(typeIndex)
   typeIndex=typeIndex(1);
else
   typeIndex=length(loopInfo.contextCode);
end
outline = loopInfo.contextName{typeIndex};
set( c.x.LoopType(1), 'String', sprintf('Auto - %s', outline) );


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function strOnOff=onoff(logOnOff)

if logOnOff
   strOnOff='on';
else
   strOnOff='off';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=UpdateFilter(c,nameIndex, index);
%Index is 1 for SF, 2 for SL propery pair

nameIndex = 1;
valueIndex = nameIndex+1;

hName=c.x.FilterName{index};
hValue=c.x.FilterValue{index};

nameString=get(hName,'String');
valueString=get(hValue,'String');

prevName=c.att.FilterTerms{index}{nameIndex};
newFilter=logical(0);

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

c.att.FilterTerms{index}{nameIndex}=nameString;
c.att.FilterTerms{index}{valueIndex}=valueString;



function [filterName, filterValue] = create_filter_fields( c, filterTerms, qualifier )
   nameIndex=1;
   valueIndex=2;
   
   if length(filterTerms)>=valueIndex
      nameString=filterTerms{nameIndex};
      valueString=filterTerms{valueIndex};
   else
      nameString='';
      valueString='';
   end
   
   cbString=sprintf('%s''UpdateFilter'',%i, %i);',...
      c.x.getobj,...
      nameIndex, ...
   	qualifier);
   filterName = uicontrol(c.x.all,...
      'style','edit',...
      'HorizontalAlignment','left',...
      'BackgroundColor',[1 1 1],...
      'String',nameString,...
      'Callback',cbString);
   
   filterValue = uicontrol(c.x.all,...
      'style','edit',...
      'HorizontalAlignment','left',...
      'BackgroundColor',[1 1 1],...
      'String',valueString,...
      'Callback',cbString);

