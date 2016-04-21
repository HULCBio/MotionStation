function out=propsystem(z,action,varargin)
%PROPSYSTEM gets Simulink system properties

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:22:49 $

switch action
case 'GetFilterList'
   out={
      'main' 'Main Properties'
      'mask','Mask Properties'
      'paper','Print Properties'
      'fcn','Function Properties'
      'all' 'All Properties'
   };
   
case 'GetPropList'
   out=LocGetPropList(varargin{1});
case 'GetPropValue'
   Property=varargin{2};
   Systems=varargin{1};
   
   switch Property
   case {'Blocks' 'Lines' 'Signals' ...
            'Parent' 'Depth' 'NameLinked' ...
            'Name' 'PaperSize' 'PaperPosition'}
      %Special-case properties
      out=feval(['Loc' Property],z,Systems);
      
      %note that calling with the lower case
      %(i.e. 'blocks') will cause the usual
      %getparam to be called and will not
      %use the special case functions.
      
   otherwise
      out=getparam(z,Systems,Property);
   end %case Property
end %primary case

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function list=LocGetPropList(filter)

switch filter
case 'all'
   list=LocAllProps;
   %rtwList=LocGetPropList('rtwsummary');
   %list=[list rtwList];
case 'paper'
   list=LocFilterList(LocAllProps,'Paper');
case 'fcn'
   list=LocFilterList(LocAllProps,'Fcn',logical(1));
case 'mask'
   list=LocFilterList(LocAllProps,'Mask');
case 'main'
   list={'Name'
      'Tag'
      'Type'
      'Parent'
      'Handle'
      'Blocks'
      'Signals'
      'Depth'};
%case 'rtwsummary'
otherwise
   list={};
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function parentList=LocParent(z,obj)

parentList=getparam(z,obj,'Parent');

%----------add linking to parents-----
z=zslmethods;
r=rptcomponent;

objType=getparam(z,obj,'type');
isModel=strcmp(objType,'block_diagram');
isEmpty=cellfun('isempty',objType);

linkComp=r.comps.cfrlink;
linkComp.att.LinkType='Link';

for i=1:length(obj)
   if isModel(i)
      parentList{i}='<root>';
   elseif isEmpty(i)
      parentList{i}='';
   else
      linkComp.att.LinkID=linkid(z,parentList{i},'sys');
      linkComp.att.LinkText=strrep(parentList{i},char(10),' ');
      parentList{i}=runcomponent(linkComp,0);
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function value=LocDepth(z,obj)

value={};
for i=length(obj):-1:1
   depth=-1;
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
function value=LocBlocks(z,obj)

value=getparam(z,obj,'Blocks');

%insert links
z=zslmethods;
r=rptcomponent;
linkComp=r.comps.cfrlink;
linkComp.att.LinkType='Link';

for i=1:length(value)
   valueCell=value{i};
   %we apply linking to all cells
   
   for j=length(valueCell):-1:1
      fullName=[obj{i} '/' strrep(valueCell{j},'/','//')];
      
      if strcmp(get_param(fullName,'blocktype'),'SubSystem')
         linkType='sys';
      else
         linkType='blk';
      end
      
      linkComp.att.LinkID=linkid(z,fullName,linkType);
      linkComp.att.LinkText=strrep(valueCell{j},char(10),' ');
      
      valueCell{j}=set(runcomponent(linkComp,0),'indent',logical(0));
   end %for each entry in valueCell
   value{i}=valueCell;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function value=LocLines(z,obj)

value=getparam(z,obj,'Lines');
for i=1:length(value)
    if ~isstruct(value{i})
        value{i}='N/A';
    else
        value{i}=sprintf('%i lines',locLineCount(value{i},0));
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function numLines=locLineCount(lineStruct,numLines)


for i=1:length(lineStruct)
    numLines=locLineCount(lineStruct(i).Branch,numLines+1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function value=LocName(z,obj)

value=strrep(getparam(z,obj,'Name'),char(10),' ');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function value=LocSignals(z,obj)

z=zslmethods;
r=rptcomponent;
linkComp=r.comps.cfrlink;
linkComp.att.LinkType='Link';

value={};
for i=length(obj):-1:1
   if iscell(obj)
      currSys=obj{i};
   else %handle
      currSys=obj(i);
   end
   
   sigList=find_system(currSys,...
      'findall','on',...
      'SearchDepth',1,...
      'type','port',...
      'porttype','outport');
      
   numSignals=length(sigList);
   valueCell={};
   for j=numSignals:-1:1
      sigName=strrep(get_param(sigList(j),'Name'),char(10),' ');
      if length(sigName)<1
         sigName=sprintf('<%0.5f>',sigList(j));
      end
            
      
      linkComp.att.LinkID=linkid(z,sigList(j),'sig');
      linkComp.att.LinkText=sigName;
      
      valueCell{j}=set(runcomponent(linkComp,0),'indent',logical(0));
   end %for each entry in valueCell
   value{i,1}=valueCell;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function value=LocNameLinked(z,obj)

objName=strrep(getparam(z,obj,'Name'),char(10),' ');

r=rptcomponent;
linkComp=r.comps.cfrlink;
linkComp.att.LinkType='Link';

numObj=length(obj);
value=cell(numObj,1);
for i=numObj:-1:1
   if ~isempty(objName{i})
      linkComp.att.LinkID=linkid(z,obj{i},'sys');
      linkComp.att.LinkText=objName{i};
      value{i}=runcomponent(linkComp,0);
   else
      value{i}='&nbsp;';
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function valCells=LocPaperPosition(z,objHandles)

valCells=getparam(z,objHandles,'PaperPosition');

for i=1:length(valCells)
   currCell=valCells{i};
   valCells{i}=sprintf('(%0.2f, %0.2f) %0.2f x %0.2f',...
      currCell(1),currCell(2),currCell(3),currCell(4));
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function valCells=LocPaperSize(z,objHandles)

valCells=getparam(z,objHandles,'PaperSize');

for i=1:length(valCells)
   currCell=valCells{i};
   valCells{i}=sprintf('%0.2f x %0.2f',currCell(1),currCell(2));
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

%Note: SubSystem blocks do not currently have
%any write-only properties.  If any do appear,
%this function will have to work like the one 
%in zslmethods/propmodel

persistent ZSLMETHODS_ALL_MODEL_PROPERTIES

if isempty(ZSLMETHODS_ALL_MODEL_PROPERTIES)
   [modname,sysname]=tempmodel(zslmethods);
   
   ZSLMETHODS_ALL_MODEL_PROPERTIES=...
      [fieldnames(get_param(sysname,'objectparameters'));...
         {'Depth';'Signals'}];
end

allProps=ZSLMETHODS_ALL_MODEL_PROPERTIES;