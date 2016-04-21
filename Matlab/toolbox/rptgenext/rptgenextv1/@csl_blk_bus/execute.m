function out=execute(c)
%EXECUTE generates report contents
%   OUTPUT=EXECUTE(C)

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:19:13 $

%out.att.BusLinkType='none';
%out.att.SignalLinkType='link';

currContext=getparentloop(c);
busList=searchblocktype(c.zslmethods,...
   {'BlockType','BusSelector'},...
   currContext);

if c.att.isHierarchy & length(busList)>1
	busList=LocFindRootBusses(busList);   
end

out={};

listComp=c.rptcomponent.comps.cfrlist;
linkComp=c.rptcomponent.comps.cfrlink;

for i=length(busList):-1:1
   listCells=LocMakeList(busList(i),...
      c.att.isHierarchy,...
      c.att.BusAnchor,...
      c.att.SignalAnchor,...
      linkComp);

  listComp.att.ListTitle=c.att.ListTitle;
  listComp.att.isSourceFromWorkspace=0;
  listComp.att.SourceCell=listCells;
  listComp.att.Spacing='Compact';
  out{i}=runcomponent(listComp,0);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=LocMakeList(busBlocks,...
      isHierarchy,...
      BusAnchor,...
      SignalAnchor,...
      linkComp);

out={};
for i=1:length(busBlocks)
    if iscell(busBlocks)
        currObj=busBlocks{i};
    else
        currObj=busBlocks(i);
    end
    
    bName=get_param(currObj,'Name');
    if BusAnchor
        linkComp.att.LinkType='Anchor';
    else
        linkComp.att.LinkType='Link';
    end
    linkComp.att.LinkID=linkid(zslmethods,currObj);
    linkComp.att.LinkText=bName;
    linkComp.att.isEmphasizeText=logical(1);
    
    out{end+1}=runcomponent(linkComp,0);
    
    kids={};
    allPorts=get_param(currObj,'PortHandles');
    sigList=allPorts.Outport(:);
    for i=1:length(sigList)
        sName=get_param(sigList(i),'Name');
        if isempty(sName)
            sName=num2str(sigList(i));
        end
        
        if SignalAnchor
            linkComp.att.LinkType='Anchor';
        else
            linkComp.att.LinkType='Link';
        end
        
        linkComp.att.LinkID=linkid(zslmethods,sigList(i));
        linkComp.att.LinkText=sName;     
        linkComp.att.isEmphasizeText=logical(0);
        
        kids{end+1}=runcomponent(linkComp,0);
    
        if isHierarchy
            childBusses=LocChildBusses(sigList(i));
            kids{end+1}=LocMakeList(childBusses,...
                isHierarchy,...
                BusAnchor,...
                SignalAnchor,...
                linkComp);
        end
    end
    if ~isempty(kids)
        out{end+1}=kids;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function rootList=LocFindRootBusses(busList)

rootList={};

for i=1:length(busList)
    try
        allPorts=get_param(busList{i},'PortHandles');
        inPort=allPorts.Inport(:);
    catch
        inPort=[];
    end
    
    isRoot=1;
    if length(inPort)==1 & ishandle(inPort)
        try
            lineHandle=get_param(inPort,'Line');
        catch
            lineHandle=-1;
        end
        
        srcBlock=[];
        if ishandle(lineHandle)
            srcBlock=get_param(lineHandle,'SrcBlockHandle');
        end
        
        if length(srcBlock)==1 & ishandle(srcBlock)
            isRoot=~strcmp(get_param(srcBlock,'BlockType'),'BusSelector');
        end
    end
    
    if isRoot
        rootList{end+1}=busList{i};
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function bList=LocChildBusses(currSig)

bHandles=[];
if ~isempty(currSig)
   try
      lineHandle=get_param(currSig,'Line');
   catch
      lineHandle=-1;
   end
   
   if ishandle(lineHandle)
      try
         bHandles=get_param(lineHandle,'DstBlockHandle');
         bHandles=bHandles(ishandle(bHandles));
      end
  end
end

bList=find_system(bHandles,...
    'SearchDepth',0,...
    'BlockType','BusSelector');
