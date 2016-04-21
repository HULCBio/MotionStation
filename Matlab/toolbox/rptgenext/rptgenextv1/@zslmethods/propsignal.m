function out=propsignal(z,action,varargin)
%PROPSIGNAL returns properties of signals
%   FLIST  = PROPSIGNAL(ZSLMETHODS,'GetFilterList');
%   PLIST  = PROPSIGNAL(ZSLMETHODS,'GetPropList',FILTERNAME);
%   PVALUE = PROPSIGNAL(ZSLMETHODS,'GetPropValue',PORTHANDLES,PROPNAME);
%

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:22:48 $

switch action
case 'GetFilterList'
   out={
      'main' 'Main Properties'
      'display','Display Properties'
      'other','Other Properties'
  };
  
  v=version;
  if v(1)~='5'
      out(end+1,:)={'object' 'Data Properties'};
  end
  
  out(end+1,:)={'all' 'All Properties'};
  
case 'GetPropList'
   out=LocGetPropList(varargin{1});
case 'GetSignalObjects'
    out=getSignalObjects(varargin{1});
case 'GetPropValue'
   Property=varargin{2};
   Signals=varargin{1};
   
   switch Property
   case {'Name' 'ParentBlock' 'ParentSystem' 'PropagatedSignals',...
               'Depth' 'NameLinked','GraphicalName'}
       out=feval(['Loc' Property],z,Signals);
   case {'Tag','Position','Rotation'}
       out=getparam(z,Signals,Property);
   case {'FontName','FontAngle','FontWeight','FontSize'}
       out=LocLineProperty(z,Signals,Property);
   case {'DocumentLink','RTWStorageClass','RTWStorageTypeQualifier'}
       if length(varargin)>2
           Objects=varargin{3};
       else
           Objects=getSignalObjects(Signals);
       end
       out=feval(['Loc' Property],z,Signals,Objects);
   otherwise
       if length(varargin)>2
           Objects=varargin{3};
       else
           Objects=getSignalObjects(Signals);
       end
       out=getsigparam(z,Signals,Property,Objects);
   end %case Property
end %primary case

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sigObj=getSignalObjects(h)

sigObj=cell(length(h),1);
for i=1:length(h)
    try
        sigObj{i}=slresolveporthandle(h(i));
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function list=LocGetPropList(filter)

switch filter
case 'all'
   [mName,sName,bName,sigHandle]=tempmodel(zslmethods);
   sigProps=fieldnames(get_param(sigHandle,'objectparameters'));
   list=[sigProps;{'ParentBlock';'ParentSystem';'Depth';'GraphicalName'}];
   
  v=version;
  if v(1)~='5'
      list=[list;LocGetPropList('object')];
  end
   
case 'main'
   list={
       'Name'
       'Tag'
       'Description'
       'ParentBlock'
       'ParentSystem'
       'Depth'
       'GraphicalName'
   };
case 'display'
   list={
       'Position'
       'Rotation'
       'FontName'
       'FontSize'
       'FontWeight'
       'FontAngle'
   };
case 'object'
    %is there some way to NOT hardcode this?
    
    list={
        'LongID_ASAP2'
        'PhysicalMin_ASAP2'
        'PhysicalMax_ASAP2'
        'Units_ASAP2'
    };
case 'other'
   list={'DocumentLink'
      'RTWStorageClass'
      'RTWStorageTypeQualifier'};
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=getsigparam(z,Signals,Property,Objects);

[out,badIndices]=getobjparam(Objects,Property);

if ~isempty(badIndices)
    out(badIndices)=getparam(z,Signals(badIndices),Property);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [out,badIndices]=getobjparam(Objects,Property)

out=cell(length(Objects),1);
badIndices=[];
for i=1:length(Objects)
    isBad=1;
    if isa(Objects{i},'Simulink.Signal')
        try
            out{i}=subsref(Objects{i},locMakeSubsref(Property));
            isBad=0;
        end
    end
    if isBad
        badIndices(end+1)=i;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sref=locMakeSubsref(propName)
%this throws an error if propName is not valid

sTerms={};
while ~isempty(propName)
    [sTerms{end+1},propName]=strtok(propName,'.');
end

sref=cell(1,length(sTerms)*2);

[sref{1:2:end-1}]=deal('.');
[sref{2:2:end}]=deal(sTerms{:});

sref=substruct(sref{:});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function linkList=LocDocumentLink(z,obj, Objects)

linkList=getsigparam(z,obj,'DocumentLink',Objects);
notEmptyList=find(~cellfun('isempty',linkList));
if ~isempty(notEmptyList)
   r=rptcomponent;
   linkObj=r.comps.cfrlink;
   linkObj.att.LinkType='Ulink';
   
   for i=1:length(notEmptyList);
      
      linkObj.att.LinkID=linkList{notEmptyList(i)};
      linkObj.att.LinkText=linkList{notEmptyList(i)};
      
      linkList{notEmptyList(i)}=runcomponent(linkObj,0);
      
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=LocRTWStorageClass(z,h,Objects)
%The RTW storage class can come from the object or from get_param.
%If there is a valid data object, use it.  Otherwise, use the
%get_param value.


out  =getobjparam(Objects,'RTWInfo.StorageClass');
outNotOkIndex=find(cellfun('isempty',out));

if ~isempty(outNotOkIndex)
    hVal =getparam(z,h(outNotOkIndex),'RTWStorageClass');
    
    testPointIndex=find(strcmp(getparam(z,h(outNotOkIndex),'TestPoint'),'on'));
    if ~isempty(testPointIndex)
        [hVal{testPointIndex}]=deal('SimulinkGlobal');    
    end
    
    out(outNotOkIndex)=hVal;
end

%This is left over from an age in which the decision of which
%value to use was more complicated.  I'm leaving it around in case
%it changes back.
%hValNotAutoIndex = find(~strcmp(hVal,'Auto'));
%resolveToEmptyIndex=find(cellfun('isempty',strrep(getparam(z,h,'ResolveTo'),'N/A','')));
%hValIndex=union(outNotOkIndex,...
%    intersect(resolveToEmptyIndex,hValNotAutoIndex));
%out(hValIndex)=hVal(hValIndex);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=LocRTWStorageTypeQualifier(z,h,Objects)

[out,badIndices]=getobjparam(Objects,'RTWInfo.TypeQualifier');

if ~isempty(badIndices)
    out(badIndices)=getparam(z,h(badIndices),...
        'RTWStorageTypeQualifier');
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function nameList=LocName(z,obj)

nameList=getparam(z,obj,'Name');
emptyList=find(cellfun('isempty',nameList));
for i=1:length(emptyList)
   nameList{emptyList(i)}=...
      ['<' num2str(obj(emptyList(i))) '>'];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function nameList = LocGraphicalName(z,obj)

nameList=getparam(z,obj,'Name');
psIdx   = find(strcmp(getparam(z,obj,'ShowPropagatedSignals'),'on'));
if ~isempty(psIdx)
    obj = obj(psIdx);
    psNames = getparam(z,obj,'PropagatedSignals');
    nameList(psIdx)=strcat(nameList(psIdx),' <',psNames,'>');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = LocPropagatedSignals(z,obj)

result = strrep(getparam(z,obj,'PropagatedSignals'),', ',char(10));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function value=LocNameLinked(z,obj)

objName=strrep(getparam(z,obj,'Name'),char(10),' ');
emptyNameList=cellfun('isempty',objName);

objHandle=getparam(z,obj,'Handle');
emptyHandleList=cellfun('isempty',objHandle);

r=rptcomponent;
linkComp=r.comps.cfrlink;
linkComp.att.LinkType='Link';

numObj=length(obj);
value=cell(numObj,1);
for i=numObj:-1:1
   if ~emptyHandleList(i)
      if emptyNameList(i)
         thisName=['<' num2str(objHandle{i}) '>'];
      else
         thisName=objName{i};
      end
      
      linkComp.att.LinkID=linkid(z,obj(i),'sig');
      linkComp.att.LinkText=thisName;
      value{i}=runcomponent(linkComp,0);
   else
      value{i}='&nbsp';
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function parentList=LocParentBlock(z,obj)

parentList=getparam(z,obj,'Parent');
isEmpty=cellfun('isempty',parentList);

r=rptcomponent;
linkC=r.comps.cfrlink;
linkC.att.LinkType='Link';

for i=1:length(parentList)
   if isEmpty(i)
      parentList{i}='';
   else
      linkC.att.LinkID=linkid(z,parentList{i},'blk');
      linkC.att.LinkText=strrep(parentList{i},char(10),' ');
      
      parentList{i}=runcomponent(linkC,0);
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function parentList=LocParentSystem(z,obj)

parentList=getparam(z,getparam(z,obj,'Parent'),'Parent');

r=rptcomponent;
linkC=r.comps.cfrlink;
linkC.att.LinkType='Link';

[uniqParents,uniqI,uniqJ]=unique(parentList);
isEmpty=cellfun('isempty',uniqParents);

for i=1:length(uniqParents)
   if isEmpty(i)
      uniqValue='&nbsp;';
   else      
      linkC.att.LinkID=linkid(z,uniqParents{i},'sys');
      linkC.att.LinkText=strrep(uniqParents{i},char(10),' ');
      
      uniqValue=runcomponent(linkC,0);      
   end
   [parentList{find(uniqJ==i)}]=deal(uniqValue);   
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function value=LocDepth(z,obj)

parentBlocks=getparam(z,obj,'Parent');
value=propblock(z,...
   'GetPropValue',parentBlocks,'Depth');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=LocLineProperty(z,Signals,Property);

lineH = getparam(z,Signals,'Line');
out={};
for i=length(lineH):-1:1
    if ishandle(lineH{i})
        try
            out{i,1}=get_param(lineH{i},Property);
        catch
            out{i,1}='N/A';
        end
    else
        out{i,1}='N/A';
    end
end
