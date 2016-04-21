function c=attribute(c,action,varargin)
%ATTRIBUTE launches the setup file editor options page

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:21:28 $

c=feval(action,c,varargin{:});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=start(c)

c.x.ObjectFrame=controlsframe(c,'Object Type');
c.x.PropFrame=controlsframe(c,'Object Property  ');
c.x.RenderFrame=controlsframe(c,'Render As');

c=controlsmake(c,{'ObjectType' 'Render'});

c.x.PropFilter=uicontrol(c.x.all,...
   'Style','popupmenu',...
   'String','yo',...
   'BackgroundColor',[1 1 1],...
   'Callback',[c.x.getobj,'''ChangeFilter'');']);

c.x.PropList=uicontrol(c.x.all,...
   'Style','listbox',...
   'BackgroundColor',[1 1 1],...
   'Callback',[c.x.getobj,'''SelectProplist'');']);

cdata=getslcdata(c);

set(c.x.ObjectType,{'cdata'},{cdata.ModelLarge;...
      cdata.SystemLarge;...
      cdata.BlockLarge;...
      cdata.SignalLarge});

smallSpacer=[-inf 5];
c.x.ObjectFrame.FrameContent={c.x.ObjectType(1)  smallSpacer,...
      c.x.ObjectType(2) smallSpacer c.x.ObjectType(3) ...
      smallSpacer  c.x.ObjectType(4) };
   
c.x.RenderFrame.FrameContent={c.x.Render(1)
   c.x.Render(2)
   c.x.Render(3)};

c.x.PropFrame.FrameContent={c.x.PropFilter;c.x.PropList};

c.x.LayoutManager={c.x.ObjectFrame;c.x.PropFrame;c.x.RenderFrame};

c.x.CurrFilter=struct('Model','','System','','Signal','','Block','');

c=ChangeObject(c);   

c=resize(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=refresh(c);
%Update component when switching tabs, moving
%deactivating

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=resize(c)

c=controlsresize(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=Update(c,whichControl,varargin);

c=controlsupdate(c,whichControl,varargin{:});
if strcmp(whichControl,'ObjectType');
   c=ChangeObject(c);
else
   c=UpdatePreview(c);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=ChangeObject(c)

objType=c.att.ObjectType;

set(c.x.PropFrame.FrameName,'String',...
   [objType ' Property']);

objProp=getfield(c.att,[objType 'Property']);


allFilters=feval(['prop' lower(objType)],c,'GetFilterList');
filterString=allFilters(:,2);
filterID=allFilters(:,1);

objFilter=getfield(c.x.CurrFilter,objType);
if isempty(objFilter)
   %we need to find an object filter that works
   %for the current object
   filterIndex=[];
   i=1;
   while isempty(filterIndex) & i<=length(filterID)
      filterProps=feval(['prop' lower(objType)],...
         c,'GetPropList',filterID{i});
      if any(strcmp(filterProps,objProp))
         filterIndex=i;
      else
         i=i+1;
      end      
   end
   if isempty(filterIndex)
      filterIndex=1;
      filterProps=feval(['prop' lower(objType)],...
         c,'GetPropList',objFilter); 
   end
   objFilter=filterID{1};

   
   c.x.CurrFilter=setfield(c.x.CurrFilter,objType,objFilter);
else
   filterProps=feval(['prop' lower(objType)],...
      c,'GetPropList',objFilter);
   filterIndex=find(strcmp(filterID,objFilter));
end


propIndex=find(strcmp(filterProps,objProp));
if isempty(propIndex)
   propIndex=1;
   c.att=setfield(c.att,[objType 'Property'],filterProps{propIndex});   
else
   propIndex=propIndex(1);
end

set(c.x.PropFilter,'String',filterString,...
   'UserData',filterID,...
   'Value',filterIndex);

set(c.x.PropList,'String',filterProps,...
   'Value',propIndex);

c=UpdatePreview(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=ChangeFilter(c);

objType=c.att.ObjectType;

allFilters=get(c.x.PropFilter,'UserData');
filterIndex=get(c.x.PropFilter,'Value');
objFilter=allFilters{filterIndex};

c.x.CurrFilter=setfield(c.x.CurrFilter,objType,objFilter);

filterProps=feval(['prop' lower(objType)],...
   c,'GetPropList',objFilter);

objProp=getfield(c.att,[objType 'Property']);
propIndex=find(strcmp(filterProps,objProp));
if isempty(propIndex)
   propIndex=1;
   c.att=setfield(c.att,[objType 'Property'],filterProps{propIndex});
end

set(c.x.PropList,'String',filterProps,...
   'Value',propIndex);

c=UpdatePreview(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=SelectProplist(c)

allProps=get(c.x.PropList,'String');
propIndex=get(c.x.PropList,'Value');

c.att=setfield(c.att,[c.att.ObjectType 'Property'],allProps{propIndex});

c=UpdatePreview(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=UpdatePreview(c)

