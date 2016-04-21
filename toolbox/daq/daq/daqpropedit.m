function daqpropedit(varargin)
%DAQPROPEDIT Property Editor.
%
%   DAQPROPEDIT allows editing of properties for the currently
%   selected object through the use of a GUI.  
%   DAQPROPEDIT(OBJ) will set the currently selected object to OBJ on the GUI.
%
%   See also PROPINFO, DAQHELP.
  
%   LPD
%   Copyright 1998-2003 The MathWorks, Inc.
%   $Revision: 1.7.2.5 $ $Date: 2003/12/22 00:48:05 $
  
switch nargin,
  %%%%%%%%%%%%%%%%%%
  %%% Initialize %%%
  %%%%%%%%%%%%%%%%%%
  case 0,
    objList=daqfind;
    if ~isempty(objList),
      objList=objList(1);
    else
      objList=[];
    end
    [hFig,data]=LInitFig(objList);
   
  case 1,
    if isa(varargin{1}, 'daqdevice') || isa(varargin{1}, 'daqchild') 
       if ~isvalid(varargin{1}),
          error('daq:daqpropedit:argcheck', 'Input must be a valid data acquisition object.')
       end
    else
       error('daq:daqpropedit:argcheck', 'Input must be a valid data acquisition object.');
    end
    
    if length(varargin{1})>1,
      error('daq:daqpropedit:argcheck', 'Only one object is allowed as a first input argument.')
    end
    [hFig,data]=LInitFig(varargin{1});
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%% Peform an action from the GUI %%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  case 2,
    Action=varargin{1};
    hFig=varargin{2};

    if ~ischar(Action) && ~ishandle(hFig),
      error('daq:daqpropedit:argcheck', 'Too many input arguments to DAQPROPEDIT');
    end
    
    set(hFig,'pointer','watch');
    data=get(hFig,'UserData');
    
    switch Action,
      case 'Close',
       data=LClose(data,hFig);
    
      case 'Delete',
       data=LDelete(data,hFig);
    
      case 'Help',
       LHelp(hFig);
    
      case 'HelpDAQ',
        LHelpDAQ  
    
      case 'ObjectBrowser',
        data=LObjButtonDown(data,hFig);

      case 'PropertyChange',
       data=LPropertyChange(data);
    
      case 'Resize',
        LResize(data,hFig);

      case 'SetProperty',
        data=LSetProperty(data);

      case 'SetValue',
       data=LSetValue(data);
       % Need to first set the listbox string since LSubPropertyChange looks
       % at the string in the listbox if it is one line.
       data=LCreateListboxString(data);
       data=LSubPropertyChange(data);
    
      case 'Update'
        data=LUpdate(data,data.CurrentObj);
	
    end % switch Action

  %%%%%%%%%%%%%
  %%% Error %%%
  %%%%%%%%%%%%%
  otherwise,
      error('daq:daqpropedit:argcheck', 'Too many input arguments to DAQPROPEDIT');

end % switch nargin

if ~isempty(hFig)&&ishandle(hFig),
  set(hFig,'UserData',data,'Pointer','arrow');
end

%%%%%%%%%%%%%%%%%%
%%%%% LClose %%%%%
%%%%%%%%%%%%%%%%%%
function data=LClose(data,hFig)

% Take care of close being called from command line
if isempty(hFig),
  hFig=gcf;
  data=get(hFig,'UserData');
end
set(hFig,'Visible','off');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LCollapseTree %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%
function data=LCollapseTree(data,value)
% Collapse the Tree
data.ExpandAll=logical(0);
set(data.hMenu(6),'Checked','off');

data.IsExpanded(value)=logical(0);
data=LGetMapping(data);
data=LCreateObjectString(data);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LConvertEvalCString %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str=LConvertEvalCString(origStr)
% This function wraps a string returned from evalc so
% that the string may be placed in a listbox
origStr=strrep(origStr,'''','''''');
lastLoc=max(find(origStr~=abs(sprintf('\n'))));
origStr=[ ...
      'char(''' ...
      strrep(origStr(1:lastLoc),sprintf('\n'),''',''') ...
      ''')' 
];
origStr=eval(origStr);
str=fliplr(deblank(fliplr(deblank(origStr))));



%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LConvertToString %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str=LConvertToString(val)

switch class(val),
  case 'char',
    str=val;
    
  case 'double',
    if numel(val)==1,
      str=num2str(val);
    else
      str=mat2str(val);
    end
    
  otherwise,
    str=class(val);
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LCreateInfo %%%%%
%%%%%%%%%%%%%%%%%%%%%%%
function data=LCreateInfo(data)

% This function:
% 1) Determine new object info.
% 2) Get Indices old objects
% 3) Remove stale info
% 4) Insert new info
% 5) Restore expand setting


hObj=daqfind;

numObj=length(hObj);
level=ones(numObj,1);
isExpanded=zeros(numObj,1);


if numObj==0,
  oldData.ObjectList={};
  oldData.IsExpanded=[];
else
  oldData.ObjectList=data.ObjectList;
  oldData.IsExpanded=data.IsExpanded;
end

data.ObjectList={};
data.Level=[];
data.HasChildren=[];
data.IsExpanded=[];
data.NameString={};

ct=1;
for lp=1:length(hObj),
  
  if strncmp(get(hObj(lp),'Type'),'A',1),
    children=hObj(lp).Channel;
  else
    children=hObj(lp).Line;
  end
  numChildren=length(children);

  data.ObjectList{ct,1}=hObj(lp);
  data.Level(ct,1)=1;
  data.IsExpanded(ct,1)=logical(0);
  data.HasChildren(ct,1)=numChildren>0;
  data.NameString(ct,1)=LGetNameString(hObj(lp));  
  
  if ~isempty(children),
    data.ObjectList(ct+1:ct+numChildren,1)=num2cell(children);
    data.Level(ct+1:ct+numChildren,1)=2;
    data.IsExpanded(ct+1:ct+numChildren,1)=logical(1);
    data.HasChildren(ct+1:ct+numChildren,1)=logical(0);
    data.NameString(ct+1:ct+numChildren,1)=LGetNameString(children);
  end
  
  ct=ct+numChildren+1;
end


expLoc=[];
if ~isempty(oldData.IsExpanded),  
  expLoc=find(oldData.IsExpanded==logical(1));
  expObj=oldData.ObjectList(expLoc);
  badLoc=[];
  for lp=1:length(expObj),
    if ( isempty(expObj{lp}) | ~isvalid(expObj{lp}) )
      badLoc=[badLoc;lp];
    end
  end
  if ~isempty(badLoc),
    expObj(badLoc)=[];
  end
  
  if ~isempty(data.Level),
    mainObjLoc=find(data.Level==1);
    mainObj=data.ObjectList(mainObjLoc);
  end
  
  if ~isempty(mainObj),
    for lp=1:length(expObj),
      for inlp=1:length(mainObj),
  if isequal(mainObj{inlp},expObj{lp}),
    data.IsExpanded(mainObjLoc(inlp))=logical(1);
    break
  end
      end
    end
    
  end
end

data=LGetMapping(data);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LCreateListboxString %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data=LCreateListboxString(data)
%Create the property value listbox string
if ~isempty(data.CurrentObj),
  dispStruct=get(data.CurrentObj);
  listString=LConvertEvalCString(evalc('disp(dispStruct)'));
  colonLoc=findstr(listString(1,:),':');
  padding=max(0,28-colonLoc(1));
  listString=char(strcat({blanks(padding)},listString));
  data.PropList=fieldnames(dispStruct);
  val=find(strcmp(data.PropList,data.CurrentProp));
else
  listString=' ';
  val=1;
  data.PropList={''};
end

topDispValue=get(data.hUI(1),'ListboxTop');
if topDispValue>val,
  topDispValue=1;
end


set(data.hUI(1), ...
   'String'    ,listString  , ...
   'Value'     ,val      , ...
   'ListboxTop',topDispValue  ...
   );
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LCreateObjectString %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data=LCreateObjectString(data)
% Create the ObjectString
if ~isempty(data.ObjectList),
  fontAngle='normal';
  levelInfo=data.Level(data.Mapping)-1;
  numVal=length(levelInfo);

  space=' ';
  %%% Create the String %%%
  childFlag=data.HasChildren(data.Mapping,1);

  % Does it have children and is it expanded or collapsed
  %43='+',45='-'
  expandCollapse=char(32+childFlag.* ...
      (((data.ExpandAll|data.IsExpanded(data.Mapping))*2)+11));
  expandCollapse=num2cell(expandCollapse,2);
  listString=data.NameString(data.Mapping);
  
  for lpL =1:numVal,
    listString{lpL,1}=[
    space(ones(1,levelInfo(lpL)*2)) ...
    expandCollapse{lpL,1}           ...
    space                           ...
    listString{lpL,1}
];
  end % for lpL
  
else
  fontAngle='italic';
  listString='No Data Acquisition Objects';
  data.Mapping=[];
end % if ~isempty

% List was changed
topDispValue=get(data.hList,{'Value','ListboxTop'});
handleLoc=[];
for lp=1:length(data.ObjectList(data.Mapping)),
  if isequal(data.ObjectList{data.Mapping(lp)},data.CurrentObj),
    handleLoc=lp;
    break
  end
end
if isempty(handleLoc),
  topDispValue={1 1};
else
  topDispValue{1}=handleLoc;
  topDispValue{2}=min(topDispValue{2},handleLoc);
end

set(data.hList, ...
   'FontAngle'           ,fontAngle          , ...
   'String'              ,cellstr(listString), ...
   {'Value','ListboxTop'},topDispValue         ...
   );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%
%%%%% LDelete %%%%%
%%%%%%%%%%%%%%%%%%%
function data=LDelete(data,hFig)
% Take care of delete being called from command line
if isempty(hFig),
  hFig=gcf;
  data=get(hFig,'UserData');
end
delete(hFig)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%
%%%%% LDeQuotify %%%%%
%%%%%%%%%%%%%%%%%%%%%%
function Value=LDeQuotify(Value)
% Everything coming into here is a string array of 1 row
if ~isempty(Value),
  if Value(1)=='''',Value(1)=[];end
end
if ~isempty(Value),
  if Value(end)=='''',Value(end)=[];end
end
 
Value=LQuotingNoOverlap(Value,'''''','''');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%
%%%%% LExpandAll %%%%%
%%%%%%%%%%%%%%%%%%%%%%
function data=LExpandAll(data)
hMenu=data.hMenu(6);
if strcmp(get(hMenu,'Checked'),'on'),
  set(hMenu,'Checked','off');
  data.ExpandAll=logical(0);
else
  set(hMenu,'Checked','on');
  data.ExpandAll=logical(1);
end
data=LGetMapping(data);
data=LCreateObjectString(data);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LExpandTree %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%
function data=LExpandTree(data,value)
% Expand the Tree

data.IsExpanded(value)=1;
data=LGetMapping(data);
data=LCreateObjectString(data);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LGetCurrentProp %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data=LGetCurrentProp(data)
if ~isempty(data.CurrentObj),
  data.PropList=fieldnames(get(data.CurrentObj));
  val=find(strcmp(data.PropList,data.CurrentProp));
  if isempty(val),
    data.CurrentProp=data.PropList{1};
  end
  set(data.hUI(2),'Enable','on');
  
else
  data.CurrentProp='';
  set(data.hUI(2),'Enable','off');
  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%
%%%%% LGetFigPos %%%%%
%%%%%%%%%%%%%%%%%%%%%%
function [horiz,vert]=LGetFigPos(height,width)
% Get Initial Figure Position
temp=get(0,'Units');
set(0,'Units','pixels');
screenSize=get(0,'ScreenSize');
set(0,'Units',temp);

horiz=(screenSize(3)-width)/2;
vert=screenSize(4)/2-height-45;

if horiz < 0,
  horiz=10;
end

if vert<0,
  vert=screenSize(4)-height-30;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LGetMapping %%%%%
%%%%%%%%%%%%%%%%%%%%%%%
function data=LGetMapping(data)

%%% Set up The String data %%%
numObj=length(data.ObjectList);
data.Mapping=(1:numObj)';

% Now to set up the hierarchy
loc=1;
val=[];
while loc<=numObj,
  val=[val;loc];
  if data.ExpandAll | data.IsExpanded(data.Mapping(loc)),
    loc=loc+1;
  else
    valLevel=data.Level(data.Mapping(loc));
    findLevel=find(data.Level(data.Mapping((loc+1):end))<=valLevel);
    if ~isempty(findLevel),
      loc=loc+findLevel(1);
    else
      loc=numObj+1;
    end % if ~isempty
  end % if ~
end % while
data.Mapping=data.Mapping(val);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function nameString=LGetNameString(objList)
%LGETNAMESTRING Return valid name for DAQ object
% NAMESTRING=LGETNAMESTRING(OBJLIST) returns a cell array of 
% valid name strings for the given object list.  
% The assumptions are as follows:
%   OBJLIST contains only channels/lines or devices. 
%   Channels/Lines and Devices are never mixed
%   If it's a device, objList is only 1 element long
%   If it's a set of channels/lines there can be between 0 and n objects

% It's a device
if ~all(ischannel(objList)|isdioline(objList)),
  name=get(objList,'Name');
  tag=get(objList,'Tag');
  nameString={[name '  (' tag ')']};
  
else
  numObj=length(objList);
  if ischannel(objList(1)),
    name=get(objList,{'ChannelName'});
    typeStr='Channel ';
  else
    name=get(objList,{'LineName'});
    typeStr='Line ';
  end
  nameString=strcat({'Channel '}, int2str((1:numObj)') , ...
      {': '},name);
end % if
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LGetValueString %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [valString,typeFlag]=LGetValueString(data,val)
% Called by LSubPropertyChange.  For all values other than enums
% this returns a 1 line string representation.  typeFlag says
% whether the value for the string could be contained on 1 line
% or not.
listStr=get(data.hUI(1),'String');
loc=get(data.hUI(1),'Value');
str=listStr(loc,:);
valString=fliplr(deblank(fliplr(deblank(str))));
valString(1:length(data.CurrentProp)+2)='';

typeFlag=1;

switch class(val),
  case 'double',  
    if isempty(val),
      valString=['[ ]'];
      typeFlag=0;
    else     
      if length(size(val))<=2 && size(val,1)==1,
        valString=mat2str(val);
        typeFlag=0;
      end
    end % if isempty      

  case 'char',
   if (length(size(val))<=2 && size(val,1)==1) || isempty(val),
     valString=valString;
     typeFlag=0;
   end

  % It's a weird value so disable it for now
  otherwise,
     
end % switch
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LGetWorkspaceVariableName %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data=LGetWorkspaceVariableName(data)
      
vars=evalin('base','whos');
vars={vars.name}';

goodFlag=0;
ct=1;
while ~goodFlag,
    pStr=['InWorkspace' int2str(ct)];
    if ~any(strcmp(vars,pStr)),
        goodFlag=1;
    end
    ct=ct+1;
end	
data.WorkspaceVariableName=pStr;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%
%%%%% LHelp %%%%%
%%%%%%%%%%%%%%%%%
function LHelp(hFig)
set(hFig,'Pointer','watch');

HelpCell={ ...
  'The Property Editor is used to Edit and View properties of '
  'data acquisition objects that are currently instantiated. '
  'This editor displays the currently selected object(s) in the'
  'upper listbox.  Underneath this is the property field'
  'and the value field.  Beneath these fields is the property'
  'list with all of the associated values.'
  };
helpwin(HelpCell,'DAQPROPEDIT Help');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%
%%%%% LHelpDAQ %%%%%
%%%%%%%%%%%%%%%%%%%%
function LHelpDAQ
  doc('daq')
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LObjButtonDown %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%
function data=LObjButtonDown(data,hFig)
%Return back and do nothing if there are no objects
if isempty(data.Mapping),
  data=LUpdate(data,[],1);
  if isempty(data.Mapping),
    return
  end
end
 
listString=get(data.hList,'String');
value=data.Mapping(get(data.hList,'Value'));
newObj=data.ObjectList{value};

switch get(hFig,'SelectionType'),
  case 'open',
    if data.IsExpanded(value), % it's expanded or childless
      %it's got children,collapse it
      if data.HasChildren(value),
        data=LCollapseTree(data,value);
      end
    else % it's collapsed and has children
      data=LExpandTree(data,value);

    end % if

  otherwise, % Normal Selection
      data=LUpdate(data,newObj);

end % switch

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LPropertyChange %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data=LPropertyChange(data,callingFromUpdate)
% Called from property selection change in listbox
% Set the property edit field
% Set the value field
  
% This function is also called by LUpdate which assumes that the value has
% already been set correctly.  If the value were to be set here then things
% get out of sync
if nargin==1,
  data=LSetValue(data);
end
data.ValidProp=1;
set(data.hUI(2),'ForegroundColor',[0 0 0])
data=LSubPropertyChange(data);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%
%%%%% LQuotify %%%%%
%%%%%%%%%%%%%%%%%%%%
function Value=LQuotify(MatValue)
% Everything coming in here is a string array of 1 row

if ~isempty(MatValue),
  len=numel(MatValue);
  MatValue=MatValue([sort([1:len find(MatValue=='''')])]);
  MatValue=num2cell(MatValue,2);
  Quotes(1:size(MatValue,1),1)={''''};  
  Value=strcat(Quotes,MatValue,Quotes);  
else
  Value={''''''};    
end  
Value=char(Value);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% LQuotingNoOverlap %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function t = LQuotingNoOverlap(s,q,s3)
% This function does a strrep that checks for overlapping strings
% i.e. aaaaaa with normal strrep('aaaaaa','aa','b') returns 'bbbbb'
% This function returns 'bbb'

k = findstr(s,q);
dk = diff(k);
while any(dk<length(q));
  p = min(find(dk<length(q)));
  k(p+1) = [];
  dk = diff(k);
end

s2len = length(q);

s2pos = k-1;
s1 = s;
% Build resulting string
s=[];
s1pos=1;
for i=1:length(s2pos),
  s=[s,s1(s1pos:s2pos(i)),s3];
  s1pos=s2pos(i)+s2len+1;
end;
t=[s,s1(s1pos:length(s1))];

if isempty(t),t='';end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%
%%%%% LResize %%%%%
%%%%%%%%%%%%%%%%%%%
function LResize(data,hFig)

Data=get(hFig,'UserData');
allHandles=[hFig ; data.hFrame ; data.hUI; data.hInfo];
set(allHandles,'Units','characters');

hOffset=1;
vOffset=.5;
btnWidth=12;
btnHeight=1.5;
txtMove=.5;

posFig=get(hFig,'Position');
if posFig(4)<8,
  posFig(4)=8;
end

hgtObj=2*(btnHeight+vOffset);

posFrame(1,:)=[0 0 posFig(3:4)];

%  'InfoHelp'
%  'InfoDeviceSpecific' ; 'InfoDeviceSpecificVal'
%  'InfoReadOnlyRunning'; 'InfoReadOnlyRunningVal'
%  'InfoReadOnly'       ; 'InfoReadOnlyVal'
%  'InfoConstraintValue'; 'InfoConstraintValueVal'
%  'InfoConstraint'     ; 'InfoConstraintVal'
%  'InfoDefaultValue'   ; 'InfoDefaultValueVal'
%  'InfoType'           ; 'InfoTypeVal'
posInfo(1,:)=[posFrame(1,1)+hOffset posFrame(1,2)+vOffset ...
              posFrame(1,3)-2*hOffset 6*btnHeight];
posInfo(2,:)=[posInfo(1,1) sum(posInfo(1,[2 4]))+vOffset ...
              posInfo(1,3)/4 btnHeight];
posInfo(3,:)=posInfo(2,:);
posInfo(3,1)=sum(posInfo(2,[1 3]));
posInfo(4:5,:)=posInfo(2:3,:);
posInfo(4,1)=posInfo(1,1)+posInfo(1,3)/2;

posInfo(4:5,2)=sum(posInfo(4,[2 4]));
posInfo(5,1)=sum(posInfo(4,[1 3]));

for lp=6:length(data.hInfo),
  posInfo(lp,:)=posInfo(lp-4,:);
  posInfo(lp,2)=sum(posInfo(lp,[2 4]));
end
posInfo(2:end,3)=.9*posInfo(2:end,3);

posInfo(4,2)=posInfo(3,2);
posInfo(4,4)=posInfo(8,2)-posInfo(4,2);

posFrame(1,4)=sum(posInfo(end,[2 4]))+vOffset-posFrame(1,2);

remainingRoom=posFig(4)-sum(posFrame(1,[2 4]));
if remainingRoom<6,remainingRoom=6;end

btmHeight=(remainingRoom-hgtObj)/2;
topHeight=remainingRoom-btmHeight;
posFrame(3,:)=[0 posFig(4)-topHeight posFrame(1,3) topHeight];
posFrame(2,:)=[0 sum(posFrame(1,[2 4])) posFrame(1,3) btmHeight];

% PropertyList
posUI(1,:)=[posFrame(2,1)+hOffset   posFrame(2,2)+vOffset ...
            posFrame(2,3)-2*hOffset posFrame(2,4)-2*vOffset];
% Property
posUI(2,:)=[posUI(1,1)   posFrame(3,2)+vOffset ...
           (diff(posFrame(3,[1 3]))-3*hOffset)/2 btnHeight];
% Value
posUI(3,:)=posUI(2,:);
posUI(3,1)=sum(posUI(2,[1 3]))+hOffset;
posUI(4,:)=posUI(3,:);
posUI(5,:)=posUI(3,:);
% Object List
posUI(6,:)=[posUI(2,1) sum(posUI(3,[2 4])) posUI(1,3) 0];
posUI(6,4)=sum(posFrame(3,[2 4]))-posUI(6,2)-vOffset;

posUI=num2cell(posUI,2);
posFrame=num2cell(posFrame,2);
posInfo=num2cell(posInfo,2);

set(data.hFrame,{'Position'},posFrame);
set(data.hUI,{'Position'},posUI);
set(data.hInfo,{'Position'},posInfo);
set(allHandles,'Units','normalized');

%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LSetProperty %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%
function data=LSetProperty(data)
% The user has typed in a new property name or part of one.
% First set the value for the previous property.  Then determine
% the new property name, set it in the field and then set the
% value field and the selection in the listbox string.

data=LSetValue(data);

oldProp=get(data.hUI(2),'String');
if ~isempty(oldProp),
  [r,c]=find(oldProp~=' ' & oldProp~=0);      
  oldProp=oldProp(:,min(c):max(c));
  % High Speed Property Editing      
  if ~isempty(oldProp),
    [r,c]=find(oldProp==' ');      
    if ~isempty(c),      
      oldProp=oldProp(:,1:max(c)-1);
    end      
  end      
  
else
  oldProp=data.PropList{1};      
end   

property=lower(oldProp);
propList = lower(data.PropList);

value=strmatch(property,propList);
color=[0 0 0];

switch length(value),
  case 0,    
    color=[1 0 0];
    value=[];      
    data.ValidProp=0;        
    
  case 1,
    property=data.PropList{value};      
    data.ValidProp=1;        
    
  otherwise,
    newValue=strmatch(property,propList(value),'exact');
    if ~isempty(newValue), % The typed property is an exact match
      value=value(newValue);
      property=data.PropList{value};      
      data.ValidProp=1;
    else
      color=[1 0 0];
      data.ValidProp=0;             
      subPropList=char(data.PropList(value));
      matchPoint=sum(subPropList,1)==length(value)*subPropList(1,:);
      noMatchLoc=find(~matchPoint);
      if isempty(noMatchLoc),
    property='';
      else           
    matchLen=min(noMatchLoc)-1;          
    property=subPropList(1,1:matchLen);            
      end            
      
    end % if ~isempty
end % switch        

if data.ValidProp,
  data.CurrentProp=property;
end

if isempty(value),
  value=1;
end % if

set(data.hUI(1),'Value',value);
set(data.hUI(2),'ForegroundColor',color,'String',property);

data=LSubPropertyChange(data);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%
%%%%% LSetValue %%%%%
%%%%%%%%%%%%%%%%%%%%%
function data=LSetValue(data)
% Set the Value
data.ValidValue=logical(1);

if ~isempty(data.CurrentObj) && ~isempty(data.CurrentProp),
  curPropInfo=propinfo(data.CurrentObj,data.CurrentProp);
  if ~curPropInfo.ReadOnly,
    % Check to see if the popupmenu is visible
    if strcmp(get(data.hUI(4),'Visible'),'on'),
      valStr=get(data.hUI(4),{'String','Value'});
      val=valStr{1}{valStr{2}};
      
      % It's not read-only and it's not enumerated
    else
      if data.ToWorkspace,
	% Check to see if the same string is still typed in
	% If it isn't then take the string as a literal
	% and move on to the next section by setting data.ToWorkspace 
	% back to 0
	baseVars=evalin('base','whos');
	baseVars={baseVars.name};
	if any(strcmp(baseVars,data.WorkspaceVariableName)),
	  try
	    val=evalin('base',data.WorkspaceVariableName);
	  catch
	    val=get(data.CurrentObj,data.CurrentProp);
	  end
	else
	  data.ToWorkspace=logical(0);
	end
	evalin('base',['clear ' data.WorkspaceVariableName ],'');
      end
      
      
      if ~data.ToWorkspace,
	str=get(data.hUI(3),'String');
	switch curPropInfo.Type,
	 case {'string','callback function'},
	  val=LDeQuotify(str);
	 otherwise,
	  try
	    if ~isempty(str),
	      val=eval(str);
	    else
	      val=[];
	    end
	  catch
	    % do nothing for now it will be caught below
	    val=[];
	  end
	end
	
      end % if ~data.ToWorkspace
    end % if strcmp popup vis on
    
    % Set the value
    try
      % Take care of setting the channel property to an empty value
      if ~(isequal(data.CurrentProp,'Channel') && isempty(val)),
        set(data.CurrentObj,data.CurrentProp,val)
      end
    catch
      data.ValidValue=logical(0);
    end
    
    if ~data.ValidValue,
        set(data.hUI(3:5),'ForegroundColor',[1 0 0]);
    else
        set(data.hUI(3:5),'ForegroundColor',[0 0 0]);
    end
  end %if ~curPropInfo.ReadOnly
end % if ~isempty

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LSubPropertyChange %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data=LSubPropertyChange(data)
% Called from property selection change in listbox and 
% from LSetProperty
% Also called during initialization of the figure

pText='off';
pPopup='off';
pEdit='off';
pStr='';
data.ToWorkspace=logical(0);
data.WorkspaceVariableName='';
pVal=1;
value=get(data.hUI(1),'Value');

% Must have a valid object and a single valid property selected
if ~isempty(data.CurrentObj) && data.ValidProp && length(value)==1,
  data.CurrentProp=data.PropList{value};
  set(data.hUI(2),'String',data.CurrentProp)
  
  curPropInfo=propinfo(data.CurrentObj,data.CurrentProp);
  if strcmp(curPropInfo.Constraint,'Enum'),
    pPopup='on';
    pStr=curPropInfo.ConstraintValue;
    pVal=find(strcmp(pStr,get(data.CurrentObj,data.CurrentProp)));

  else
    if curPropInfo.ReadOnly,    
      pText='on';
    else
      pEdit='on';
    end
    
    
    val=get(data.CurrentObj,data.CurrentProp);
    [pStr,noneditFlag]=LGetValueString(data,val);
    
    if noneditFlag,
      %it's going to the workspace
      data.ToWorkspace=logical(1);
      data=LGetWorkspaceVariableName(data);
      pStr=data.WorkspaceVariableName;
      assignin('base',pStr,get(data.CurrentObj,data.CurrentProp));
    end
    
  end  
  
  if curPropInfo.ReadOnly,    
    pEnable='off';
  else
    pEnable='on';
  end
  
  if ischannel(data.CurrentObj) || isdioline(data.CurrentObj),
    tempObj=get(data.CurrentObj,'Parent');
  else
    tempObj=data.CurrentObj;
  end
  if strcmp(tempObj.Running,'On'),
    if curPropInfo.ReadOnlyRunning,
      pEnable='off';
    end
  end
  
else
  pText='on';
  pStr='';
  pEnable='on';
end

if strcmp(pEnable,'off')
  if strcmp(pText,'on'),
    pEnable='on';
  elseif strcmp(pEdit,'on'),
    pEnable='on';
    pText='on';
    pEdit='off';
  end
end
  

set(data.hValText, ...
    'ForegroundColor',[0 0 0], ...
    'Visible'        ,pText  , ...
    'String'         ,pStr   , ...
    'Enable'         ,pEnable  ...
    );
set(data.hValPopup  , ...
    'ForegroundColor',[0 0 0], ...
    'Visible'        ,pPopup , ...
    'String'         ,pStr   , ...
    'Value'          ,pVal   , ...
    'Enable'         ,pEnable  ...
   );
set(data.hValEdit, ...
    'ForegroundColor',[0 0 0], ...
    'Visible'        ,pEdit  , ...
    'String'         ,pStr   , ...
    'Enable'         ,pEnable  ...
   );

data=LCreateListboxString(data);

% Set the property info for the current property
helpStr=' ';
typeStr='';
defValStr='';
constraintStr='';
constraintValStr='';
readOnlyStr='';
devSpecificStr='';
roRunningStr='';

if ~isempty(data.CurrentObj),
  info=propinfo(data.CurrentObj,data.CurrentProp);
  helpStr=evalc('daqhelp(data.CurrentObj,data.CurrentProp)');
  helpStr=LConvertEvalCString(helpStr);
  % Rip off the leading carriage return
  helpStr(1,:)='';
  typeStr=LConvertToString(info.Type);
  defValStr=LConvertToString(info.DefaultValue);
  constraintStr=LConvertToString(info.Constraint);
  constraintValStr=LConvertToString(info.ConstraintValue);
  readOnlyStr=LTrueFalse(info.ReadOnly);  
  devSpecificStr=LTrueFalse(info.DeviceSpecific);
  roRunningStr=LTrueFalse(info.ReadOnlyRunning);
end

% Set the property help for the current property
set(data.hInfo(1),'String',helpStr,'Value',[]);
set(data.hInfo(15),'String',typeStr);
set(data.hInfo(13),'String',defValStr);
set(data.hInfo(11),'String',constraintStr);
set(data.hInfo(9),'String',constraintValStr);
set(data.hInfo(7),'String',readOnlyStr);
set(data.hInfo(5),'String',roRunningStr);
set(data.hInfo(3),'String',devSpecificStr);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%
%%%%% LTrueFalse %%%%%
%%%%%%%%%%%%%%%%%%%%%%
function str=LTrueFalse(val)
if val,
  str='1 (True)';
else
  str='0 (False)';
end
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%
%%%%% LUpdate %%%%%
%%%%%%%%%%%%%%%%%%%
function data=LUpdate(data,newObj,firstTime)
% Set the value with the old handle
% Insert the new handle and update the selection
if nargin<=2,
  try
    data=LSetValue(data);
  catch
    % Do nothing
  end
  data.CurrentObj=newObj;
end

data=LCreateInfo(data);
data=LCreateObjectString(data);

%A new object is now selected and the listbox needs to be updated as
%well as the property and value fields.
data=LGetCurrentProp(data);

% Update the list
data=LCreateListboxString(data);
data=LPropertyChange(data,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%
%%%%% LInitFig %%%%%
%%%%%%%%%%%%%%%%%%%%
function [hFig,data]=LInitFig(obj)

hFig=findobj(allchild(0),'flat','Name','Data Acquisition Property Editor');
if ~isempty(hFig),
  % This will make it visible and bring it to the front.
  figure(hFig)
  data=get(hFig,'UserData');  
  data=LUpdate(data,obj);
  return
end

figWidth=420;  figHeight=480;
[figHoriz,figVert]=LGetFigPos(figHeight,figWidth);
figPos=[figHoriz figVert-30 figWidth figHeight]; % -30 for menu

%%% Other Info

btnColor=get(0,'DefaultUIControlBackgroundColor');

genInfo.Units='pixels';
genInfo.HandleVisibility='off';
genInfo.Interruptible='off';
genInfo.BusyAction='queue';

uiInfo=genInfo;
uiInfo.BackgroundColor=btnColor;
uiInfo.ForeGroundColor=[0 0 0];
uiInfo.Max=1;
uiInfo.Value=1;
uiInfo.HorizontalAlignment='left';

uiTags={
  'PropertyList'
  'Property'
  'ValueEdit';'ValuePopup';'ValueText'
  'Object'
  };
uiCalls={
  'daqpropedit(''PropertyChange'',gcbf)'
  'daqpropedit(''SetProperty'',gcbf);'
  'daqpropedit(''SetValue'',gcbf);'
  'daqpropedit(''SetValue'',gcbf);'
  ''
  'daqpropedit(''ObjectBrowser'',gcbf);'
  };
uiStyle={
  'listbox'
  'edit'
  'edit';'popupmenu';'text'
  'listbox'
  };

uiBgColor={
  'white'
  'white'
  'white';'white';btnColor
  'white'
  };

infoInfo=genInfo;
infoInfo.BackgroundColor=btnColor;
infoInfo.Enable='inactive';

infoStyle={
  'listbox'
  'text';'edit'
  'text';'edit'
  'text';'edit'
  'text';'edit'
  'text';'edit'
  'text';'edit'
  'text';'edit'
  };

infoHoriz={
  'left' ;
  'right'; 'left'
  'right'; 'left'
  'right'; 'left'
  'right'; 'left'
  'right'; 'left'
  'right'; 'left'
  'right'; 'left'
 }; 
infoTags={
  'InfoHelp'
  'InfoDeviceSpecific' ; 'InfoDeviceSpecificVal'
  'InfoReadOnlyRunning'; 'InfoReadOnlyRunningVal'
  'InfoReadOnly'       ; 'InfoReadOnlyVal'
  'InfoConstraintValue'; 'InfoConstraintValueVal'
  'InfoConstraint'     ; 'InfoConstraintVal'
  'InfoDefaultValue'   ; 'InfoDefaultValueVal'
  'InfoType'           ; 'InfoTypeVal'
  };

infoStrings={
  ' '
  'Device Specific:'        ;''
  'Read Only when Running:' ;''
  'Read Only:'              ;''
  'Constraint Value:'       ;''
  'Constraint:'             ;''
  'Default Value:'          ;''
  'Type:'                   ;''
  };



if ~isunix,
  uiBgColor{1}='white';
else
  uiBgColor{1}=btnColor;
end

%%% Create uimenus
menuLabels={
  '&File'
    '>&Close'
  '&Options'
    '>Up&date^d'
  '&Help'
    '>&Property Editor'
    '>&Data Acquisition'
    };
menuCalls={
  ''
    'daqpropedit(''Close'',gcbf)'
  ''
    'daqpropedit(''Update'',gcbf)'
  ''
    'daqpropedit(''Help'',gcbf)'
    'daqpropedit(''HelpDAQ'',gcbf)'
          };
menuTags={
  'MenuFile'
    'MenuFileCloseEditor'
  'MenuOptions'
    'MenuOptionsUpdate'
  'MenuHelp'
    'MenuHelpPropertyEditor'
    'MenuHelpDataAcquisition'
         };

menuLabels = str2mat(menuLabels{:});
menuCalls =str2mat(menuCalls{:});
menuTags=str2mat(menuTags{:});

% set up tool
hFig=figure(                     ...
              'Color'              ,btnColor                      , ...
              'IntegerHandle'      ,'off'                         , ...
              'CloseRequestFcn'    ,'daqpropedit(''Close'',gcbf)' , ...
              'DeleteFcn'          ,'daqpropedit(''Delete'',gcbf)', ...
              'HandleVisibility'   ,'off'                         , ...
              'MenuBar'            ,'none'                        , ...
              'Name'               ,'Data Acquisition Property Editor', ...
              'Tag'                ,'Data Acquisition Property Editor', ...
              'NumberTitle'        ,'off'                         , ...
              'Units'              ,'pixels'                      , ...
              'Position'           ,figPos                        , ...
              'Resize'             ,'on'                          , ...
              'UserData'           ,[]                            , ...
              'Colormap'           ,[]                            , ...
              'Pointer'            ,'arrow'                       , ...
              'Visible'            ,'off'                           ...
              );

hMenu=makemenu(hFig,menuLabels,menuCalls,menuTags);
set(hMenu,'HandleVisibility','off');

for lpF=1:3,
  hFrame(lpF,1)=uicontrol(uiInfo   , ...
                             'Parent'      ,hFig          , ...
                             'Style'       ,'frame'               , ...
                             'Tag'         ,['Frame' num2str(lpF)]  ...
                             );
end

for lpL=1:length(uiTags),
  hUI(lpL,1)=uicontrol(uiInfo          , ...
            'Parent'         ,hFig          , ...
            'Tag'            ,uiTags{lpL}   , ...
            'Callback'       ,uiCalls{lpL}  , ...
            'BackgroundColor',uiBgColor{lpL}, ...
            'Style'          ,uiStyle{lpL}  , ...
            'String'         ,{''}            ...
            );
end % lpL


set(hUI([1 6]),'FontName','FixedWidth','String',' ','Value',1);
set(hUI(1),'Max',2)

for lpI=1:length(infoTags),
  hInfo(lpI,1)=uicontrol(infoInfo        , ...
	    'Parent'             ,hFig            , ...
            'Tag'                ,infoTags{lpI}   , ...
            'Style'              ,infoStyle{lpI}  , ...
            'HorizontalAlignment',infoHoriz{lpI}  , ...
            'String'             ,infoStrings{lpI}  ...
            );
end % lpI
set(hInfo(1), ...
    'BackgroundColor','white'     , ...
    'Max'            ,2           , ...
    'FontName'       ,'FixedWidth', ...
    'Value'          ,[]            ...
    );

data.hInfo=hInfo;
data.hMenu=hMenu;
data.hUI=hUI;
data.hList=data.hUI(6);
data.hValEdit=data.hUI(3);
data.hValPopup=data.hUI(4);
data.hValText=data.hUI(5);
data.hFrame=hFrame;
data.CurrentObj=obj;
data.PropList={''};
data.CurrentProp='';
data.ValidProp=0;
data.WorkspaceVariableName='towork';
data.ToWorkspace=logical(0);
data.ValidValue=logical(1);


data.ObjectList=[];
data.ExpandAll=logical(0);
data.Level=[];
data.IsExpanded=[];
data.HasChildren=[];
data.NameString={};

% Need to get the child order right for tabbing purposes
children=allchild(hFig);
children(16:21)=children([16 21 17 18 19 20]);

set(hFig,'Children',children)

LResize(data,hFig);

data=LCreateInfo(data);
if ~isempty(data.IsExpanded),
  data.IsExpanded(1)=1;
end

data=LGetMapping(data);
data=LCreateObjectString(data);

if ~isempty(data.ObjectList),
  objLoc=[];
  for lp=1:length(data.ObjectList),
    if isequal(data.ObjectList{lp},obj),
      objLoc=lp;
      break;
    end
  end
    
  if isempty(objLoc),
    loc=1;
  else
    loc=find(data.Mapping==objLoc);
    if isempty(loc),
      loc=1;
    end
  end
  set(data.hList,'Value',loc);
  
end
data=LUpdate(data,data.CurrentObj,1);
% This second set is done to clear out the bad set previously done since
% there was nothing seeding the value field.  This will insure that the value
% field is colored black instead of red.
data=LSetValue(data);


set(hFig, ...
    'Visible'  ,'on'                          , ...
    'UserData' ,data                          , ...
    'ResizeFcn','daqpropedit(''Resize'',gcbf)'  ...
    );

data=get(hFig,'UserData');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
