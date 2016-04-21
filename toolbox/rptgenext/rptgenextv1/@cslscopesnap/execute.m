function out=execute(c)
%EXECUTE generates report contents
%   OUT=EXECUTE(C)

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:21:37 $

%Take snapshots of scope blocks

currContext=getparentloop(c);
scopeList=searchblocktype(c.zslmethods,...
   {'BlockType','Scope'},...
   currContext);


[xyFigureList,xyBlockList]=LocXYfigures(c.zslmethods,...
   searchblocktype(c.zslmethods,...
   {'MaskType','XY scope.'},...
   currContext));

numScopes=length(scopeList);
numXYGraphs=length(xyFigureList);

if numScopes>0 | numXYGraphs>0
   snapComp=c.rptcomponent.comps.chgfigsnap;
   
   att=snapComp.att;
   att.isCapture=logical(0);
   att.ImageFormat=c.att.ImageFormat;
   att.PaperOrientation=c.att.PaperOrientation;
   att.isResizeFigure='manual';
   att.PrintSize=c.att.PaperSize;
   att.PrintUnits=c.att.PaperUnits;
   if c.att.isInvertHardcopy
      att.InvertHardcopy='on';
   else
      att.InvertHardcopy='off';
   end
   
   
   snapComp.att=att;
   
   for i=numScopes+numXYGraphs:-1:numXYGraphs+1
      [out{i},errString]=LocTakeSnapshot(scopeList{i-numXYGraphs},...
         snapComp,...
         c.att.isForceOpen,...
         c.att.isInvertHardcopy,...
         c.att.CaptionType,...
         c.att.AutoscaleScope);
      if length(errString)>0
         status(c,errString,1);
      end
   end
   
   if numXYGraphs>0
      snapComp.att.InvertHardcopy='off';
      
      for i=numXYGraphs:-1:1
         figH=xyFigureList(i);
         
         snapComp.att.FigureHandle=figH;
         snapComp.att.ImageTitle=xyBlockList{i};
         snapComp.att.Caption=LocGetCaption(c.att.CaptionType,xyBlockList{i});
         
         if c.att.isInvertHardcopy
            oldLineColors=patternlines(figH);
            oldFigColor=get(figH,'Color');
            set(figH,'color',[ 1 1 1]);
         end
         
         out{i}=runcomponent(snapComp,5);
         
         if c.att.isInvertHardcopy
            set(figH,'color',oldFigColor);
            patternlines(figH,oldLineColors);
         end
      end
   end
else
   %if no scopes were found
   out='';
end

%----------Take XY Graph Snapshots


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [figTag,errString]=LocTakeSnapshot(scopeBlock,...
   snapComp,...
   isForceOpen,...
   isInvert,...
   capType,...
   isAutoscaleScope)  

errString={};

try
   scopeHandle=get_param(scopeBlock,'Figure');
catch
   scopeHandle=-1;
end

if ishandle(scopeHandle)
   isVisible = strcmp(get(scopeHandle,'visible'),'on');
else
   isVisible = -1;
   %-1 indicates that the scope did not exist
end

try
   scopeName=get_param(scopeBlock,'Name');
catch
   scopeName='';
end

openedScope = 0;
if isVisible<1
    if isForceOpen
        try
            set_param(scopeBlock,'Open','on');
            openedScope=1;
        catch
            errString{end+1}=sprintf('Error - could not open scope "%s"', scopeName );
        end
        
        if openedScope
            try
                scopeHandle=get_param(scopeBlock,'Figure');
            catch
                scopeHandle = -1;
            end
        end
    else
        scopeHandle = -1;
    end
end
      
if ishandle(scopeHandle)
        if isAutoscaleScope
            simscope('ScopeBar','ActionIcon','Find',scopeHandle);
        end
   tempHandle=simscope('PrintFigure',scopeHandle);
   

   if isInvert
      patternlines(tempHandle);
   else
      set(tempHandle,'color',[ .5 .5 .5 ]);
      %axText=findall(allchild(tempHandle),...
      %   'type','text');
      %set(axText,'Color',[0 0 0]);
      %allAx=findall(allchild(tempHandle),'flat',...
      %   'type','axes');
      %set(allAx,...
      %   'Xcolor',[0 0 0],...
      %   'Ycolor',[0 0 0],...
      %   'Zcolor',[0 0 0]);
   end
   
   
   snapComp.att.FigureHandle=tempHandle;
   snapComp.att.ImageTitle=scopeName;
   snapComp.att.Caption=LocGetCaption(capType,scopeBlock);
   
   figTag=runcomponent(snapComp,5);      
   
   delete(tempHandle);
else
   figTag='';
end
      
if openedScope==1
   try
       set_param(scopeBlock,'Open','off');         
   catch
       errString{end+1}=sprintf('Error - could not close scope "%s"', scopeName );
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [foundFigs,foundBlocks]=LocXYfigures(z,allBlocks)

foundFigs=[];
foundBlocks={};

if ~isempty(allBlocks)
   allFigs=findall(allchild(0),'flat',...
      'Tag','SIMULINK_XYGRAPH_FIGURE');
   
   allBlockHandles=getparam(z,allBlocks,'handle');
   allBlockHandles=[allBlockHandles{:}];
   
   allBlockNames=getparam(z,allBlocks,'name');
   
   for i=1:length(allFigs)
      ud=get(allFigs(i),'UserData');
      if isstruct(ud) & isfield(ud,'Block')
         blockIndex=find(allBlockHandles==ud.Block);
         
         if ~isempty(blockIndex)
            blockIndex=blockIndex(1);
            
            foundFigs(end+1)=allFigs(i);
            foundBlocks(end+1)=allBlockNames(blockIndex);
         end
      end
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function caption=LocGetCaption(capType,blk);

switch capType
case '$auto'
    desc=getparam(zslmethods,blk,'Description');
    caption=desc{1};
case '$manual'
    caption=parsevartext(c,c.att.CaptionString);
otherwise
    caption='';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function oldVals = patternlines(figHandle,patternVals)
%PATTERNLINES Convert solid lines to patterns
%   OLDVALS = PATTERNLINES(FIGHANDLE) converts a colored 
%             multiline plot to black and white patterns
%   PATTERNLINES(FIGHANDLES,OLDVALS) restores the same
%             plot to its old state.

lineHandles=findall(allchild(figHandle),...
    'type','line');

if nargin>1
    set(lineHandles,patternVals{:});
else
    newColor = [.1 .1 .1];
    nLines = length(lineHandles);
    
    if nLines == 1
        %don't need to change patterns, only color
        oldVals = {'color',get(lineHandles,'color'),...
                'linewidth',get(lineHandles,'linewidth')};
        set(lineHandles,...
            'color',newColor,...
            'linewidth',2);
    else   
        oldVals = {{'color'},get(lineHandles,'color'),...
                {'linestyle'},get(lineHandles,'linestyle'),...
                {'linewidth'},get(lineHandles,'linewidth')};
        
        set(lineHandles,'color',newColor);
        
        set(lineHandles(2:4:end),'linestyle','--');
        set(lineHandles(3:4:end),'linestyle',':');
        set(lineHandles(4:4:end),'linestyle','-.');
        
        lineWidth=1;
        for i=1:4:nLines
            lineWidth=lineWidth+1;
            set(lineHandles(i:min(i+4,nLines)),'linewidth',lineWidth);
        end
    end
end
