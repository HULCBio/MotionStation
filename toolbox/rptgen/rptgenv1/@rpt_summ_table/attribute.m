function c=attribute(r,c,action,varargin)
%ATTRIBUTE launches the setup file editor options page
%   C=ATTRIBUTE(RPT_SUMM_TABLE,C,'Action',arg1,arg2,...)

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:16:38 $

c=feval(action,c,r,varargin{:});

%--------1---------2---------3---------4---------5---------6---------7---------8

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=start(c,r)

c=controlsmake(c,{'ObjectType','TitleType','TableTitle'});

x=subsref(c,substruct('.','x'));

objectCData={r.Table.btnImg};
set(x.ObjectType,...
    {'cdata'},objectCData(:));

x.ObjectFrame=controlsframe(c,'Object List');
x.OptionFrame=controlsframe(c,'Table Options');
x.PropsFrame=controlsframe(c,'Object Properties');

%%%%% Create Loop Props Button %%%%%%%%%%%%%
btnBGC=get(0,'DefaultUIcontrolBackgroundColor');

x.LoopButton=uicontrol(x.all,...
    'Style','pushbutton',...
    'BackgroundColor',btnBGC,...
    'String','String set in LocChangeObjectType',...
    'Callback',[x.getobj '''EditLoopComponent'');']);

%%%%% Create navigation buttons %%%%%%%%%%%%
cdata=getcdata(rptcomponent);
buttonNames={'MoveUp'
    'MoveDown'
    'AddProp'
    'DeleteProp'};
btnTTS={'Move property up'
    'Move property down'
    'Add property to list'
    'Delete property from list'};

ud=struct('ok',{cdata.moveup cdata.movedn cdata.addok cdata.remok},...
    'no',{cdata.moveupno cdata.movednno cdata.addno cdata.remno});
clear cdata

for i=1:length(buttonNames)
    x=setfield(x,buttonNames{i},uicontrol(x.all,...
        'Style','pushbutton',...
        'BackgroundColor',btnBGC,...
        'String','',...
        'CData',ud(i).ok,...
        'UserData',ud(i),...
        'ToolTipString',btnTTS{i},...
        'Callback',[x.getobj ...
            '''NavBtn'',''',buttonNames{i},''');']));
end

%%%%% Create Property Lists %%%%%%%%%%%%%%%%%%%%%%

x.ObjectParametersTitle=uicontrol(x.all,...
    'Style','text',...
    'String','This string set in LocChangeObjectType',...
    'HorizontalAlignment','left');

x.ObjectParameters=uicontrol(x.all,...
    'Style','listbox',...
    'BackgroundColor',[1 1 1],...
    'Callback',[x.getobj ...
        '''Update'',''Proplist'');']);

x.PropFilter=uicontrol(x.all,...
    'Style','popupmenu',...
    'String','yo',...
    'BackgroundColor',[1 1 1],...
    'Callback',[x.getobj ...
        '''ChangeFilter'');']);

x.PropList=uicontrol(x.all,...
    'Style','listbox',...
    'BackgroundColor',[1 1 1],...
    'Callback',[x.getobj ...
        '''SelectProplist'');']);

x.isObjectAnchor=uicontrol(x.all,...
    'Style','checkbox',...
    'String','This string set in LocChangeObjectType',...
    'Callback','This callback set in LocChangeObjectType');


%%%%% Set up Layout Manager %%%%%%%%%%%%%%%%%%%%%%%%


%Note: the layout of x.ObjectFrame is determined
%dynamically at resize-time

x.OptionFrame.FrameContent={
    x.isObjectAnchor
    {x.TitleTypeTitle {x.TitleType(1);{x.TitleType(2) x.TableTitle}}}
};


navColumn={x.MoveUp;[3];x.MoveDown;[10];x.DeleteProp};

x.PropsFrame.FrameContent={
   [1]       [1] x.ObjectParametersTitle [1] [1]         [1] x.PropFilter
   navColumn [1] x.ObjectParameters      [1] {x.AddProp} [1] x.PropList
};

% Note: x.LayoutManager is set at resize-time

%%%%% Finish Page Draw %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

c=subsasgn(c,substruct('.','x'),x);

c=LocChangeObjectType(c,r);

c=resize(c,r);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=refresh(c,r)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=resize(c,r)

x=subsref(c,substruct('.','x'));
numObjects = length(x.ObjectType);
numObjectsAdded = 1;

availWidth = x.xlim-x.xzero-20; %30 points for border width

typeColumn = {};
typeRow = {};
widthSoFar = 0;

while numObjectsAdded<=numObjects
    btnSize = get(x.ObjectType(numObjectsAdded),'Extent');
    btnSize = btnSize(3)+10; %10 pts padding
    
    if widthSoFar+btnSize>availWidth
    	%create a new row
        typeRow = typeRow(1:end-1); %remove trailing [-inf,.5]
        typeColumn{end+1,1}=typeRow;
        typeRow = {};
        widthSoFar = 0;
    end
    
    typeRow(1,end+1:end+2)={x.ObjectType(numObjectsAdded),[-inf,.5]};
    widthSoFar = widthSoFar + btnSize;
    numObjectsAdded = numObjectsAdded + 1;
end


if ~isempty(typeRow)
    typeRow = typeRow(1:end-1); %remove trailing [-inf,.5]
    if ~isempty(typeColumn)
        typeColumn{end+1,1}=typeRow;
    else
        typeColumn = typeRow;
    end
end


if ~isempty(typeColumn)
    fc={
        typeColumn
        [3]
        x.LoopButton
    };
else
    fc={x.LoopButton};
    set(x.ObjectType,'Position',[-1000 -1000 5 5]);
end
x.ObjectFrame.FrameContent=fc;

x.LayoutManager={
   x.ObjectFrame
   [1]
   x.OptionFrame
   [1]
   x.PropsFrame
};
c=subsasgn(c,substruct('.','x'),x);

c=controlsresize(c);

x=subsref(c,substruct('.','x'));
%use a slightly less restrictive test to see if the attpage fits
x.allInvisible=(x.lowLimit<x.yzero);
c=subsasgn(c,substruct('.','x'),x);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=Update(c,r,whichControl,varargin);

switch whichControl
case 'Proplist'   
   LocEnableButtons(c,r);
case 'ObjectType'
   c=controlsupdate(c,whichControl,varargin{:});
   c=LocChangeObjectType(c,r);
otherwise
   c=controlsupdate(c,whichControl,varargin{:});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=NavBtn(c,r,whichBtn)

x=subsref(c,substruct('.','x'));

currIndex  = get(x.ObjectParameters, 'Value');
currString = get(x.ObjectParameters, 'String');
if ~iscell(currString)
   currString={currString};
end

switch whichBtn
case 'MoveUp'
   currString={currString{1:currIndex-2} ...
         currString{currIndex} ...
         currString{currIndex-1} ...
         currString{currIndex+1:end}};
   currIndex=currIndex-1;   
case 'MoveDown'
   currString={currString{1:currIndex-1} ...
         currString{currIndex+1} ...
         currString{currIndex} ...
         currString{currIndex+2:end}};
   currIndex=currIndex+1;      
case 'AddProp'
   allProps=get(x.PropList,'String');
   toAddProp=allProps{get(x.PropList,'Value')};
   currString={currString{1:currIndex} toAddProp ...
         currString{currIndex+1:end}};
   currIndex=currIndex+1;
case 'DeleteProp'
   currString={currString{1:currIndex-1} ...
         currString{currIndex+1:end}};
   currIndex=min(currIndex,length(currString));
end

typeInfo=get_table(r,c);
attName=sprintf('%sParameters',typeInfo.id);
c=subsasgn(c,substruct('.','att','.',attName),currString);

set(x.ObjectParameters,...
   'Value',currIndex,...
   'String',currString);

LocSetAutoTitle(x,typeInfo);

LocEnableButtons(c,r);

%--------1---------2---------3---------4---------5---------6---------7---------8
function c=LocChangeObjectType(c,r)

x=subsref(c,substruct('.','x'));
att=subsref(c,substruct('.','att'));

typeInfo=get_table(r,c);

x=setfield(x,sprintf('is%sAnchor',typeInfo.id),x.isObjectAnchor);

set(x.isObjectAnchor,...
   'String',...
   sprintf('Insert linking anchor for all "%s" objects in table',...
   lower(typeInfo.displayName)),...
   'Callback',...
   sprintf('%s''Update'',''is%sAnchor'');',x.getobj,typeInfo.id),...
   'Value',...
   getfield(att,sprintf('is%sAnchor',typeInfo.id)));

set(x.ObjectParametersTitle,'String',...
   sprintf('%s parameters',typeInfo.displayName));

objParam=getfield(att,sprintf('%sParameters',typeInfo.id));
if isempty(objParam)
   objMax=2;
   objVal=[];
else
   objMax=1;
   objVal=1;
end

set(x.ObjectParameters,...
   'String',objParam,...
   'Value',objVal,...
   'Min',0,...
   'Max',objMax);

allFilter=feval(typeInfo.getCmd,c,'GetFilterList');

set(x.PropFilter,...
   'String',allFilter(:,2),...
   'UserData',allFilter(:,1),...
   'Value',1);

LocSetAutoTitle(x,typeInfo);

set(x.LoopButton,'String',...
   sprintf('Edit %ss to be included in table...',...
   lower(typeInfo.displayName)));

c=subsasgn(c,substruct('.','x'),x);

c=ChangeFilter(c,r);

LocEnableButtons(c,r);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocEnableButtons(c,r);

x=subsref(c,substruct('.','x'));

handleList=[x.MoveUp x.MoveDown x.AddProp x.DeleteProp];
okList=[1 1 1 1];

numProps=length(get(x.ObjectParameters,'String'));
currValue=get(x.ObjectParameters,'Value');

if numProps<1
   okList=[0 0 0 0];
else
   okList=[(currValue>1) (currValue<numProps) ...
         logical(1) numProps>1];
end

for i=1:length(okList)
   btnUserData=get(handleList(i),'UserData');
   if okList(i)
      cData=btnUserData.ok;
      eString='on';
   else
      cData=btnUserData.no;
      eString='off';
   end
   set(handleList(i),'CData',cData,'Enable',eString);   
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=ChangeFilter(c,r)

x=subsref(c,substruct('.','x'));
typeInfo=get_table(r,c);

allFilters=get(x.PropFilter,'UserData');
currFilter=allFilters{get(x.PropFilter,'Value')};

allProps=feval(typeInfo.getCmd,...
   c,...
   'GetPropList',currFilter);


if strcmp(typeInfo.id,'Block') & ...
      any(strcmp({'main' 'all'},currFilter))
   allProps{end+1}='%<SplitDialogParameters>';
end

set(x.PropList,...
   'String',allProps,...
   'Value',1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=SelectProplist(c,r)

x=subsref(c,substruct('.','x'));

switch get(LocParentFigure(x.ObjectParameters),'SelectionType')
case 'open'
   c=NavBtn(c,r,'AddProp');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%
function strOnOff=LocOnOff(logOnOff)

if logOnOff
   strOnOff='on';
else
   strOnOff='off';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function hOut=LocParentFigure(hIn)

if strcmp(get(hIn,'type'),'figure')
   hOut=hIn;
else
   hOut=LocParentFigure(get(hIn,'Parent'));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=EditLoopComponent(c,r)

l=make_loop_comp(r,c);

%See if there is a special embedded attribute
%method for use with rpt_summ_table
compClass=subsref(l,substruct('.','comp','.','Class'));
if any(strcmp(methods(compClass),'attribute_summ_table'))
   attMethod='attribute_summ_table';
else
   attMethod='attribute';
end

typeInfo=get_table(r,c);
tString=sprintf('%ss in Table',typeInfo.displayName);

l=embedattribute(l,'start',attMethod,tString);

c=clear_loop_comp(r,c,l);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocSetAutoTitle(x,typeInfo);

if any(strcmp(get(x.ObjectParameters,'String'),...
      '%<SplitDialogParameters>'))
   autoTitle='<BlockType> Block Parameters';
else
   autoTitle=[typeInfo.displayName ' Parameters'];
end

set(x.TitleType(1),'String',...
   sprintf('Automatic (%s)',autoTitle));
