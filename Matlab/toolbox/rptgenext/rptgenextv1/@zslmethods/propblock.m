function out=propblock(z,action,varargin)
%PROPBLOCK gets Simulink block properties

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:22:46 $

switch action
case 'GetFilterList'
   out={'main' 'Main Properties'
      'mask','Mask Properties'
      'fcn','Function Properties'
      'display','Display Properties'
      'all' 'All Properties'
  };   
case 'GetPropList'
   out=LocGetPropList(varargin{1});
case 'GetPropValue'
   Property=varargin{2};
   Objects=varargin{1};
   
   switch Property
   case {'Parent' 'dialogparameters' 'Depth' 'Name' 'NameLinked' 'DefinedInBlk'}
      out=feval(['Loc' Property],z,Objects);
   case 'InputSignalNames' 
      out=SignalName(z,Objects,'Inport');
   case 'OutputSignalNames'
      out=SignalName(z,Objects,'Outport');      
   case 'DefinedInSys'
      out=LocDefinedInBlk(z,Objects,true);
   case 'DefinedIn'
      out=LocDefinedInBlk(z,Objects,true);
   otherwise
      out=getparam(z,Objects,Property);
   end %case Property
end %primary case

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function list=LocGetPropList(filter)

switch filter
case 'all'
   list=LocAllProps;
case 'mask'
   list=LocFilterList(LocAllProps,'Mask');
case 'fcn'
   list=LocFilterList(LocAllProps,'Fcn',logical(1));
case 'display'
   list={'Position'
      'Orientation'
      'ForegroundColor'
      'BackgroundColor'
      'DropShadow'
      'NamePlacement'
      'ShowName'
      'FontName'
      'FontSize'
      'FontWeight'
      'FontAngle'};
case 'main'
    list={
        'Name'
        'BlockType'
        'Tag'
        'Description'
        'Parent'
        'InputSignalNames'
        'OutputSignalNames'
        'dialogparameters'
        'Depth'
        'DefinedInBlk'
        'DefinedInSys'
    };
otherwise
   list={};
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function parentList=LocParent(z,obj)

parentList=getparam(z,obj,'Parent');
isEmpty=cellfun('isempty',parentList);

%----------add linking to parents-----
z=zslmethods;
r=rptcomponent;

parentType=getparam(z,parentList,'type');
isModel=strcmp(parentType,'block_diagram');

linkComp=r.comps.cfrlink;
linkComp.att.LinkType='Link';

for i=length(parentList):-1:1
   if ~isEmpty(i)
      
      linkComp.att.LinkID=linkid(z,parentList{i},'sys');
      linkComp.att.LinkText=strrep(parentList{i},char(10),' ');
      
      parentList{i}=runcomponent(linkComp,0);
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function allList=Locdialogparameters(z,obj)

allList=getparam(z,obj,'dialogparameters');

for i=1:length(allList)
   if isstruct(allList{i})
      allList{i}=fieldnames(allList{i});
   else
      allList{i}='';
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function value=LocDepth(z,obj)

value={};
for i=length(obj):-1:1
   depth=-2;
   parent=obj{i};
   while ~isempty(parent)
      try
         parent=get_param(parent,'Parent');
         depth=depth+1;
      catch
         parent=[];
      end
   end
   value{i,1}=depth;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function value=LocName(z,obj)

value=strrep(getparam(z,obj,'Name'),char(10),' ');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function value=LocNameLinked(z,obj)

objName=getparam(z,obj,'Name');

r=rptcomponent;
linkComp=r.comps.cfrlink;
linkComp.att.LinkType='Link';

numObj=length(obj);
value=cell(numObj,1);
for i=numObj:-1:1
   if ~isempty(objName{i})
      linkComp.att.LinkID=linkid(z,obj{i});
      linkComp.att.LinkText=strrep(objName{i},char(10),' ');
      value{i}=runcomponent(linkComp,0);
   else
      value{i}='&nbsp;';
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  value=SignalName(z,objList,portType);

portStruct=getparam(z,objList,'PortHandles');

r=rptcomponent;

linkComp=r.comps.cfrlink;
slinkComp.att.LinkType='Link';


value={};
for i=length(portStruct):-1:1
   sigList=getfield(portStruct{i},portType);
   allNames={'&nbsp;'};
   comma='';
   for j=length(sigList):-1:1
      if strcmp(portType,'Inport')
         thisSignal=LocTraceSignalSource(sigList(j));
      else
         thisSignal=sigList(j);
      end
      
      if ~isempty(thisSignal)
         sigName=strrep(get_param(thisSignal,'Name'),char(10),' ');
         if length(sigName)<1
            sigName=sprintf('<%0.5f>',thisSignal);
         end
         
         linkComp.att.LinkID=linkid(z,thisSignal,'sig');
         linkComp.att.LinkText=[sigName comma];
         
         allNames{j}=runcomponent(linkComp,0);
      else
         allNames{j}=[xlate('<Not Connected>') comma];
      end
      comma=', ';
   end
   value{i,1}=allNames;
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Utility functions used by other functions

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function filtered=LocFilterList(unfiltered,spec,compareEnd)
%LocFilterList searches "unfiltered" for the string "spec"
%if compareEnd is false (the default), it searches for spec
%in the prefix.  If true, it looks in the suffix.  

listBlock=strvcat(unfiltered{:});
if nargin>2 & compareEnd
   listBlock=strjust(listBlock(:,end:-1:1),'left');
   spec=spec(:,end:-1:1);
end

okIndices=strmatch(spec,listBlock);
filtered=unfiltered(okIndices);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function allProps=LocAllProps
%LocAllProps returns all properties for a system

persistent ZSLMETHODS_ALL_BLOCK_PROPERTIES

if isempty(ZSLMETHODS_ALL_BLOCK_PROPERTIES)
   
   [mdlName,sysName,blkName,sigName]=tempmodel(zslmethods);
   
   blockProps=fieldnames(get_param(blkName,'objectparameters'));
   
   lastIndex=find(strcmp(blockProps,'Selected'));
   firstIndex=find(strcmp(blockProps,'MaskType'));
   
   ZSLMETHODS_ALL_BLOCK_PROPERTIES=...
      [blockProps([1:lastIndex,firstIndex:end]);...
         {'dialogparameters';'Depth';'DefinedInBlk';'DefinedInSys'}];   
end

allProps=ZSLMETHODS_ALL_BLOCK_PROPERTIES;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function outSig=LocTraceSignalSource(inSig);
%From an inport, trace the outport that it is connected to

lineHandle=get_param(inSig,'Line');
if (~isempty(lineHandle) & ishandle(lineHandle))
   outSig=get_param(lineHandle,'srcporthandle');
   if ~ishandle(outSig)
      outSig=[];
   end
else
   outSig=[];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=LocDefinedInBlk(z,blkList,isSystem)

if nargin<3
    isSystem = false;
end

r=rptcomponent;
linkComp=r.comps.cfrlink;
linkComp.att.LinkType='Link';

for i=length(blkList):-1:1
    try
        thisTrace  = rptgen_sl.traceBlock('src',blkList{i});
    catch
        thisTrace = {{'N/A'}};
    end
    %outputs a cell array, one element per in/outport.  Each element 
    %can potentially be a cell array if there are multiple src/dst per port
    
    listRoot = sgmltag;
    if length(thisTrace)>1
        useNumbers = true;
        %listRoot = set(listRoot,...
        %    'tag','LiteralLayout',...
        %    'indent',false);
    else
        useNumbers = false;
    end
    
    traceFlat = {};
    nPort = length(thisTrace);
    for portIdx = 1:nPort
        if useNumbers
            listRoot.data{end+1}=sprintf('%i. ',portIdx);
        end
        nTrace = length(thisTrace{portIdx});
        for traceIdx = 1:nTrace
            thisObj = thisTrace{portIdx}{traceIdx};
            
            %handle linking here                    
            if isempty(thisObj)
                parentModel = bdroot(blkList{i});
                linkComp.att.LinkID=linkid(z,parentModel,'mdl');
                linkComp.att.LinkText=[parentModel,' (model)'];
                listRoot.data{end+1}=set(runcomponent(linkComp,0),'indent',false);
            elseif strcmp(thisObj,xlate('N/A')) | strcmp(thisObj,xlate('Unconnected'))
                listRoot.data{end+1} = thisObj;
            elseif isSystem
                %show the parent system of the source block
                thisObj=get_param(thisObj,'Parent');
                linkComp.att.LinkID=linkid(z,thisObj,'sys');
                thisObj = get_param(thisObj,'Name');
                linkComp.att.LinkText=strrep(thisObj,char(10),' ');
                listRoot.data{end+1}=set(runcomponent(linkComp,0),'indent',false);
            else
                linkComp.att.LinkID=linkid(z,thisObj); %don't pass 'blk' in case thisObj is a SubSystem block
                thisObj = get_param(thisObj,'Name');
                linkComp.att.LinkText=strrep(thisObj,char(10),' ');
                listRoot.data{end+1}=set(runcomponent(linkComp,0),'indent',false);
            end
            
            if traceIdx<nTrace
                listRoot.data{end+1}=', ';
            elseif portIdx<nPort
                listRoot.data{end+1}=char(10);
            end
        end %traceIdx
    end %portIdx
    out{i,1} = listRoot;
end

