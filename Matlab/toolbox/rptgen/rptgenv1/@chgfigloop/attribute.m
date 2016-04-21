function c=attribute(c,action,varargin)
%ATTRIBUTE launches the setup file editor options page

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:14:01 $

c=feval(action,c,varargin{:});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=start(c)

%controlsmake creates the UICONTROLS.
%they are passed back in c.x with fieldnames
%mirroring the attribute name.  For example,
%c.att.Foo creates a uicontrol with handle
%c.x.Foo.  If the control creates a text field
%(for example a compound text/edit) the text
%field's handle is c.x.FooTitle

%controlsmake uses getinfo(c) to obtain the information
%it needs to automatically create uicontrols.  
%Information is stored in c.attx.Foo

%loopFrame=controlsframe(c,'Figures to Include in Report');
previewFrame=controlsframe(c,'Loop Figure List');

c=controlsmake(c);

set(c.x.TagList,...
   'String',c.att.TagList,...
   'Max',2,'Min',0,'value',[]);

c.x.previewList=uicontrol(c.x.all,...
   'style','listbox',... %'BackgroundColor',[1 1 1],...
   'Max',2,'Min',0,'Value',[],...
   'Callback',[c.x.getobj,'''SelectPreviewList'');']);

%previewDesc=uicontrol(c.x.all,...
%   'style','text',...
%   'horizontalalignment','left',...
%   'String','Current figures to be included in the report');

figCData=getcdata(c.rptcomponent);

c.x.addButton=uicontrol(c.x.all,...
   'Callback',[c.x.getobj, '''Update'',''AddButton'');'],...
   'style','pushbutton',...
   'UserData',struct('ok',figCData.addok,'no',figCData.addno));

c.x.delButton=uicontrol(c.x.all,...
   'Callback',[c.x.getobj, '''Update'',''DeleteButton'');'],...
   'ToolTipString','Delete selected tags from list',...
   'style','pushbutton',...
   'UserData',struct('ok',figCData.remok,'no',figCData.remno));

c.x.existingTagList=uicontrol(c.x.all,...
   'HorizontalAlignment','left',...
   'BackgroundColor',[1 1 1],...
   'style','popupmenu',...
   'Callback',[c.x.getobj, '''Update'',''ExistingListSelect'');'],...
   'String',LocMakeTagListString(c));

c.x.customEdit=uicontrol(c.x.all,...
   'Callback',[c.x.getobj, '''Update'',''CustomEdit'');'],...
   'HorizontalAlignment','left',...
   'BackgroundColor',[1 1 1],...
   'style','edit');

smallSpacer=2;

myBtn={c.x.addButton {[smallSpacer] c.x.existingTagList
      [smallSpacer] c.x.customEdit}
   [5] [inf 1]
   c.x.delButton []};

previewFrame.FrameContent={c.x.previewList};

c.x.LayoutManager={c.x.LoopType(1)
   c.x.LoopType(2)
   {'indent' c.x.isDataFigureOnly}
   c.x.LoopType(3)
   {[1] [inf 1] [1] [1] [1] [inf 1];
      'indent' c.x.TagList [smallSpacer] ...
         {c.x.addButton;[10];c.x.delButton} [smallSpacer]...
         {c.x.existingTagList;c.x.customEdit}} 
   [5]
   previewFrame};


%ExistingListSelect runs SetEnable
c=Update(c,'ExistingListSelect',logical(0));

UpdatePreviewList(c);

c=resize(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=refresh(c);
%Update component when switching tabs, moving
%deactivating


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=resize(c)

%controlsresize returns the lowest Y position
%reached by any uicontrols in c.x.lowLimit

c=controlsresize(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=Update(c,whichControl,varargin);

isEnableWarnings=logical(0);
switch whichControl
case {'LoopType' 'isDataFigureOnly'}
   c=controlsupdate(c,whichControl,varargin{:});
case 'AddButton'
   elString=get(c.x.existingTagList,'String');
   elValue=get(c.x.existingTagList,'Value');
   if elValue==length(elString)
      addTag=get(c.x.customEdit,'String');
   else
      addTag=elString{elValue};
   end
   
   oldList=get(c.x.TagList,'String');
   oldList{end+1}=addTag;
   
   newList=unique(oldList);
   
   c.att.TagList=newList;
   set(c.x.TagList,'String',newList,'Value',[]);
   
   set(c.x.customEdit,'String','');
   
case 'DeleteButton'
   selectedTags=get(c.x.TagList,'Value');
   allTags=get(c.x.TagList,'String');
   okTags=setdiff([1:length(allTags)],selectedTags);
   newTags=allTags(okTags);
   
   
   set(c.x.TagList,'String',newTags,'Value',[]);
   c.att.TagList=newTags;
   
case 'ExistingListSelect'
   elString=get(c.x.existingTagList,'String');
   elValue=get(c.x.existingTagList,'Value');
   if elValue==length(elString)
      customString='';
   else
      customString=elString{elValue};
   end
   set(c.x.customEdit,'String',customString);
   if length(varargin)>0
      isEnableWarnings=varargin{1};
   else
      isEnableWarnings=logical(1);
   end
   
case 'CustomEdit'
   isEnableWarnings=logical(1);
case 'TagList'
   %do nothing
end


SetEnable(c,isEnableWarnings);

UpdatePreviewList(c);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SetEnable(c,isWarning);

onEnable=[];
offEnable=[];

statusMessage='';
statusError=logical(0);

switch c.att.LoopType
case 'CURRENT'
   offEnable=[c.x.isDataFigureOnly,...
         c.x.TagList,...
         c.x.addButton,...
         c.x.delButton,...
         c.x.existingTagList,...
         c.x.customEdit];
case 'ALL'
   onEnable=c.x.isDataFigureOnly;
   offEnable=[c.x.TagList,...
         c.x.addButton,...
         c.x.delButton,...
         c.x.existingTagList,...
         c.x.customEdit];
case 'TAG'
   offEnable=c.x.isDataFigureOnly;
   onEnable=[c.x.TagList,...
         c.x.existingTagList];
   
   if length(c.att.TagList)>0 & length(get(c.x.TagList,'Value'))>0
      onEnable=[onEnable c.x.delButton];
   else
      offEnable=[offEnable c.x.delButton];
   end
   
   tlValue=get(c.x.existingTagList,'Value');
   tlString=get(c.x.existingTagList,'String');
   
   statusMessage='';
   if tlValue==length(tlString)
      onEnable=[onEnable c.x.customEdit];
      toAddString=get(c.x.customEdit,'String');
      if isempty(toAddString)
         statusMessage='Enter a tag name in the edit box';
      end
   else
      offEnable=[offEnable c.x.customEdit];
      toAddString=tlString{tlValue};
   end
   
   set(c.x.addButton,'ToolTipString',...
      sprintf('Add tag "%s" to list', toAddString));
   
   if any(strcmp(c.att.TagList,toAddString))
      offEnable=[offEnable c.x.addButton];
      statusMessage=sprintf('"%s" is already in the tag list',toAddString);
      statusError=logical(1);
   else
      onEnable=[onEnable c.x.addButton];
   end
   if isempty(statusMessage)
      statusMessage=sprintf('Use the Add button to insert "%s" into the tag list',...
	                        toAddString);
   end
   
end

if isWarning
   statbar(c,statusMessage,statusError);
end


set(onEnable,'Enable','on');
set(offEnable,'Enable','off');


iconButtons=[c.x.addButton c.x.delButton];
for i=1:length(iconButtons)
   ud=get(iconButtons(i),'UserData');
   enable=get(iconButtons(i),'Enable');
   if strcmp(enable,'on')
      btnCdata=ud.ok;
   else
      btnCdata=ud.no;
   end
   set(iconButtons(i),'CData',btnCdata);
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function UpdatePreviewList(c);

foundFigures=getfigs(c);

figNames={};
for i=length(foundFigures):-1:1
   figNames{i}=objname(c.zhgmethods,foundFigures(i),-1);
end

set(c.x.previewList,'String',figNames,'UserData',foundFigures);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=SelectPreviewList(c);

foundFigures=get(c.x.previewList,'UserData');
listIndex=get(c.x.previewList,'Value');

if length(listIndex)>0 & listIndex(1)<=length(foundFigures)
   currFig=foundFigures(listIndex(1));
   
   if ishandle(currFig)
      if strcmp(get(currFig,'Visible'),'on')
         figure(currFig);
      else
         oldViz=get(currFig,'Visible');
         set(currFig,'Visible','on');
         figure(currFig);
         drawnow
         pause(.7);
         if ishandle(currFig)
            set(currFig,'Visible',oldViz);
         end
      end
   else
      UpdatePreviewList(c);
   end
end

set(c.x.previewList,'Value',[]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function strOnOff=LocOnOff(logOnOff)

if logOnOff
   strOnOff='on';
else
   strOnOff='off';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tagList=LocMakeTagListString(c);

allFigs=allchild(0);

tagList=get(allFigs,'Tag');

if isempty(tagList)
   tagList={};
elseif ~iscell(tagList)
   tagList={tagList};
else
   tagList=unique(tagList);
end


if isfield(c.ref,'RptgenTagList')
   badTags=c.ref.RptgenTagList;
else
   i=getinfo(c);
   badTags=i.ref.RptgenTagList;
end
badTags{end+1}='';

tagList=setdiff(tagList,badTags);

tagList{end+1}='(Enter tag in edit field)';


