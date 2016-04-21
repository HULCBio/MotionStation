function c=attribute(c,action,varargin)
%ATTRIBUTE launches the setup file editor options page

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:18:07 $

c=feval(action,c,varargin{:});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=start(c)

loopFrame=controlsframe(c,'Include Stateflow charts ');

slCD=getslcdata(c);

loopInfo=searchblocktype(c.zslmethods,sprintf('Stateflow chart'));
liUD=[loopInfo.contextCode,...
      {slCD.SystemLarge;slCD.ModelLarge;...
         slCD.SignalLarge;slCD.BlockLarge;slCD.ModelLarge},...
      loopInfo.contextName];

c.x.LoopImage=uicontrol(c.x.all,...
   'style','togglebutton',...
   'Enable','inactive',...
   'Value',1,...
   'UserData',liUD);

c.x.LoopEcho=uicontrol(c.x.all,...
   'Style','text',...
   'HorizontalAlignment','left');

loopFrame.FrameContent={c.x.LoopImage [3] {c.x.LoopEcho;[inf 1]}};

c=controlsmake(c);

c.x.ObjectsReportedText=uicontrol(c.x.all,...
	'style','text',...
	'horizontalalignment','left',...
	'String','Report on Stateflow object types:');

c.x.ObjectsReportedList=uicontrol(c.x.all,...
	'style','listbox',...
	'horizontalalignment','left',...
	'Min',0,'Max',2,'Value',[],...
	'Enable','inactive');


% uncomment to put a string below the listbox
% c.x.ObjectsReportedDesc=uicontrol(c.x.all,...
%	'style','text',...
%	'horizontalalignment','left',...
%	'String','To change which objects are reported....');


c.x.LayoutManager={[5]
   loopFrame
   [5]
	{c.x.legibleFontSizeTitle c.x.legibleFontSize}
	[10]
	c.x.ObjectsReportedText
	{[1 90] c.x.ObjectsReportedList}
	...c.x.ObjectsReportedDesc % uncomment to put a string below the listbox
	};

UpdateFrame(c);

UpdateList(c);
c=resize(c);
refresh(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=resize(c)

c=controlsresize(c);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=Update(c,whichControl,varargin);

c=controlsupdate(c,whichControl,varargin{:});
refresh(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function UpdateList(c);


myHandle=c.ref.ID;
if isa(myHandle,'rptcp')
	objReportList=findall(myHandle.h,...
		'type','uimenu',...
		'tag','csf_obj_report');

	objectList=get(objReportList,'Label');
else
   objectList={};
end

if isempty(objectList)
   objectList={
      'Warning - will not report on any Stateflow objects'
      ''
      '  Add "Stateflow Object Report" components as children of this'
      '  Stateflow Loop to report on Stateflow.'
   };
end


set(c.x.ObjectsReportedList,'String',objectList);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=refresh(c)
%Update component when switching tabs, moving
%deactivating

[validity, errMsg] = rgsf( 'is_parent_valid', c );
titleString = 'Stateflow Loop'; 
if ~validity
   titleString='Stateflow Loop: (invalid parent)';
   errString=sprintf('Error: this component %s', xlate(errMsg));
   errType=1;
else
   errString='';
   errType=0;
end

statbar(c,errString,errType);
set(c.x.title,'String',titleString);

UpdateFrame(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function UpdateFrame(c);
slsfParent = rgsf('get_slsf_parent', c);
if ~isempty( slsfParent) & strcmp( slsfParent.comp.Class, 'csf_chart_loop' )
   descString = 'Charts defined in Chart Loop';
   loopImg = [];
else
   lType=getparentloop(c);
   ud=get(c.x.LoopImage,'UserData');
   
   typeIndex=find(strcmp(ud(:,1),lType));
   if length(typeIndex)<1
      typeIndex=1;
   else
      typeIndex=typeIndex(1);
   end
   loopImg = ud{typeIndex,2};
   descString=ud{typeIndex,3};
end
set(c.x.LoopImage,'CData',loopImg);
set(c.x.LoopEcho,'String',descString);

