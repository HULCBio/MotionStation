function out=execute(c)
%EXECUTE generates report contents
%   OUT=EXECUTE(C)

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:19:27 $

currContext=getparentloop(c);

if c.att.isSinglePlot | c.att.isSingleTable
   singleList=searchblocktype(c.zslmethods,...
      {'BlockType','Lookup'},...
      currContext);
   numSingle=length(singleList);
else
   singleList={};
   numSingle=0;
end

if c.att.isDoublePlot | c.att.isDoubleTable
   doubleList=searchblocktype(c.zslmethods,...
       {'BlockType','Lookup2D'},... %{'BlockType','SubSystem','MaskType','Lookup Table (2-D)'},...
      currContext);
   numDouble=length(doubleList);
else
   doubleList={};
   numDouble=0;
end

if c.att.isMultiTable
   multiList=searchblocktype(c.zslmethods,...
      {'BlockType','S-Function','MaskType','LookupNDInterp'},...
      currContext);
   multiPreList=searchblocktype(c.zslmethods,...
      {'BlockType','S-Function','MaskType','LookupNDInterpIdx'},...
      currContext);
   multiDirectList=searchblocktype(c.zslmethods,...
      {'BlockType','S-Function','MaskType','LookupNDDirect'},...
      currContext);
  
  numMulti=length(multiList)+length(multiPreList)+length(multiDirectList);
else
   multiList={};
   multiPreList={};
   numMulti=0;
end


if numSingle+numDouble+numMulti>0
   %if any candidate blocks were found
   
   if (c.att.isSinglePlot & numSingle>0) | ...
         (c.att.isDoublePlot & numDouble>0)
      %if any images will be drawn, initialize the image comp
      drawFig=figure('IntegerHandle','off',...
         'HandleVisibility','on',...
         'InvertHardcopy','off',...
         'MenuBar','none',...
         'Name','Report Generator Lookup Table Plot',...
         'Tag','RPTGEN LOOKUP TABLE FIGURE',...
         'Color',[1 1 1],...
         'Visible','off');
      figSnap=c.rptcomponent.comps.chgfigsnap;
      
      att=figSnap.att;
      att.isCapture=logical(0);
      att.ImageFormat=c.att.ImageFormat;
      att.FigureHandle=drawFig;
      att.PaperOrientation=c.att.PaperOrientation;
      att.isResizeFigure='manual';
      att.PrintSize=c.att.PrintSize;
      att.PrintUnits=c.att.PrintUnits;
      figSnap.att=att;
   else
      figSnap.att.ImageTitle='';
      drawFig=[];
   end 
      
   if (c.att.isSingleTable & numSingle>0) | ...
         (c.att.isDoubleTable & numDouble>0) | ...
          (c.att.isMultiTable & numMulti>0)
      tableComp=c.rptcomponent.comps.cfrcelltable;
      %if any tables will be drawn, initialize the table comp
      tableComp.att.isPgwide=0;
      tableComp.att.numHeaderRows=0;
   else
      tableComp.att.TableTitle='';
   end
   
   %Produce output
   out={};
   for i=1:numSingle
      [xVal,xName]=LocParamValue(singleList{i},'InputValues');
      [yVal,yName]=LocParamValue(singleList{i},'OutputValues');
      
      if ~isempty(xVal) & length(xVal)==length(yVal)
         blkTitle=LocBlockTitle(c,singleList{i});
         if c.att.isSinglePlot
            if LocSinglePlot(singleList{i},drawFig,c.att.SinglePlotType,...
                  xVal,xName,yVal,yName);
               figSnap.att.ImageTitle=blkTitle;
               out{end+1}=runcomponent(figSnap,0);
               blkTitle='';
            end %if plotting
         end
         if c.att.isSingleTable
             out{end+1}=locGenerateTable(tableComp,yVal,blkTitle,0,xVal);
         end %if table
      else
         status(c,LocWarning(singleList{i}),2);
      end %if ok
   end %loop over all singles
   
   for i=1:numDouble
      [xVal,xName]=LocParamValue(doubleList{i},'x');
      [yVal,yName]=LocParamValue(doubleList{i},'y');
      [tVal,tName]=LocParamValue(doubleList{i},'t');
      
      xLength=length(xVal);
      yLength=length(yVal);
      tSize=size(tVal);
      
      if ~isempty(tVal) & xLength*yLength==prod(tSize)
         blkTitle=LocBlockTitle(c,doubleList{i});
         if c.att.isDoublePlot
            if LocDoublePlot(doubleList{i},drawFig,c.att.DoublePlotType,...
                  xVal,xName,yVal,yName,tVal,tName);
               figSnap.att.ImageTitle=blkTitle;
               out{end+1}=runcomponent(figSnap,0);
               blkTitle='';
            end
         end %if creating plots
         if c.att.isDoubleTable
             out{end+1}=locGenerateTable(tableComp,tVal,blkTitle,0,xVal,yVal);
         end %if 
      else
         status(c,LocWarning(singleList{i}),2);
      end
   end
   
   delete(drawFig);
   
   if numMulti>0
       for i=1:length(multiList)
           out=[out,locMultiTable(multiList{i},...
                   tableComp,...
                   LocBlockTitle(c,multiList{i}))];
       end
       for i=1:length(multiPreList)
           out=[out,locMultiPreTable(multiPreList{i},...
                   tableComp,...
                   LocBlockTitle(c,multiPreList{i}))];
       end
       for i=1:length(multiDirectList)
           out=[out,locMultiDirectTable(multiDirectList{i},...
                   tableComp,...
                   LocBlockTitle(c,multiDirectList{i}))];
       end
   end
else
   out='';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ok=LocSinglePlot(blkName,h,plotType,xVal,xName,yVal,yName);

delete(allchild(h));
axHandle=axes('Parent',h,...
   'HandleVisibility','on',...
   'Box','on',...
   'Color',[1 1 1],...
   'XlimMode','auto',...
   'YlimMode','auto');

ok=logical(0);

switch plotType
case 'lineplot'
   try
      lnHandle=line('Parent',axHandle,...
         'Xdata',xVal,...
         'Ydata',yVal,...
         'Color',[0 0 1],...
         'LineWidth',2,...
         'Marker','.');
      ok=logical(1);
   end
case 'barplot'
   try
      bar(double(xVal),double(yVal));
      ok=logical(1);
   end
end

if ok
   axProp=struct('FontAngle',  get(axHandle, 'FontAngle'), ...
      'FontName',   get(axHandle, 'FontName'), ...
      'FontSize',   get(axHandle, 'FontSize'), ...
      'FontWeight', get(axHandle, 'FontWeight'));
   
   allPorts=get_param(blkName,'PortHandles');
   
   %Attach labels to axes based on signal or variable names
   set(get(axHandle,'xlabel'),axProp,'String',...
      LocAxLabel(xName,allPorts.Inport,'Input Values'));
   set(get(axHandle,'ylabel'),axProp,'String',...
      LocAxLabel(yName,allPorts.Outport,'Output Values'));
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ok=LocDoublePlot(blkName,h,plotType,xVal,xName,yVal,yName,tVal,tName)


%plotType = multilineplot or surfaceplot
delete(allchild(h));
axHandle=axes('Parent',h,...
   'Box','off',...
   'Color',[1 1 1],...
   'Xgrid','on',...
   'Ygrid','on',...
   'Zgrid','on',...
   'ZlimMode','auto',...
   'XlimMode','auto',...
   'YlimMode','auto');

if strcmp(plotType,'surfaceplot')
    try
        set(axHandle,'View',[-37.5,30]);
        
        surfHandle=surface(double(yVal),double(xVal),double(tVal),...
            'FaceColor','interp',...
            'Parent',axHandle);
        ok=logical(1);
    catch
        ok=logical(0);
    end
else
    try
        plotHandles=plot(double(xVal),double(tVal),'parent',axHandle);

        legendLabels=cellstr(num2str(double(yVal(:))));
        
        legend(plotHandles,legendLabels,-1);
        
        ok=logical(1);
    catch
        ok=logical(0);
    end
end

if ok
   axProp=struct('FontAngle',  get(axHandle, 'FontAngle'), ...
      'FontName',   get(axHandle, 'FontName'), ...
      'FontSize',   get(axHandle, 'FontSize'), ...
      'FontWeight', get(axHandle, 'FontWeight'));
   
   allPorts=get_param(blkName,'PortHandles');
   
   
   set(get(axHandle,'xlabel'),axProp,'String',...
      LocAxLabel(yName,allPorts.Inport(2),'Column'));

  if strcmp(plotType,'surfaceplot')
      set(get(axHandle,'zlabel'),axProp,'String',...
          LocAxLabel(tName,allPorts.Outport,'Table'));
      set(get(axHandle,'ylabel'),axProp,'String',...
          LocAxLabel(xName,allPorts.Inport(1),'Row'));
  else
      set(get(axHandle,'ylabel'),axProp,'String',...
          LocAxLabel(tName,allPorts.Outport,'Table'));
      
  end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  tCells=LocSingleTable(xVal,yVal);

tCells=[{'Input Value','Output Value'};...
      num2cell([xVal(:),yVal(:)])];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  tCells=LocDoubleTable(xVal,yVal,tVal);

tCells=[{''},num2cell(yVal(:)');...
      num2cell([xVal(:),tVal])]';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function warnStr=LocWarning(blkName);

warnStr=sprintf('Warning - could not draw %s lookup table',...
      strrep(blkName,sprintf('\n'),' '));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [pVal,pString]=LocParamValue(blkName,pName)

try
   pString=get_param(blkName,pName);
   pVal=evalin('base',pString);
catch
   pString=[];
   pVal=[];
end
if isa(pVal,'Simulink.Data')
   pVal=pVal.Value;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function labelString=LocAxLabel(varName,portH,labelName)

labelString='';

avN=abs(varName);
if any(find((avN>='a' & avN<='z') | ...
      (avN>='A' & avN<='Z')))
   %we'll assume that the property string is actually
   %the proper axes label
   labelString=varName;
else
   try
      portType=get_param(portH,'porttype');
   catch
      portType='not found';
   end
   
   switch portType
   case 'outport'
      try
         labelString=get_param(portH,'Name');
      end
   case 'inport'
      try
         lineH=get_param(portH,'Line');
         srcH=get_param(lineH,'SrcPortHandle');
         labelString=get_param(srcH,'Name');
      end
   end
end

if isempty(labelString)
   labelString=labelName;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function imTitle=LocBlockTitle(c,blkName);

switch c.att.TitleType
case 'none'
   imTitle='';
case 'auto'
   try
      imTitle=get_param(blkName,'Name');
   catch
      imTitle=blkName;
   end
otherwise
   imTitle=c.att.TitleString;   
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=locMultiTable(tBlock,tableComp,tableTitle)

try
    eNumDims = get_param(tBlock,'numDimsPopupSelect');
    if strncmp(eNumDims,'More',4)
        eNumDims =LocParamValue(tBlock,'explicitNumDims');
    else
        eNumDims = str2double(eNumDims);
    end
catch
    out={};
    return;
end

for i=min(4,eNumDims):-1:1
    try
        inVals{i} = LocParamValue(tBlock,sprintf('bp%i',i));
    catch
        inVals{i}=[];
    end
end
if eNumDims>4
    try
        bpCell = LocParamValue(tBlock,'bpcell');
        for i=eNumDims:-1:5
            inVals{i}=bpCell{i-4};
        end
    catch
        inVals{eNumDims}=[];
    end
end

tableData = LocParamValue(tBlock,'tableData');

out=locMakeMultiTable(tableData,inVals,tableComp,tableTitle,[],0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=locMultiPreTable(tBlock,tableComp,tableTitle)

try
    eNumDims = get_param(tBlock,'numDimsPopupSelect');
    if strncmp(eNumDims,'More',4)
        eNumDims = LocParamValue(tBlock,'explicitNumDims');
    else
        eNumDims = str2double(eNumDims);
    end
catch
    out={};
    return;
end

inVals = cell(eNumDims,1);
for i=1:eNumDims
    %sltblpresrc is a function which returns the pre lookup input block
    try
        inputBlock = sl('tblpresrc',tBlock,i);
        inVals{i}=LocParamValue(inputBlock,'bpData');
    catch
        %throw a warning!
    end
end

tableData = LocParamValue(tBlock,'table');


out=locMakeMultiTable(tableData,inVals,tableComp,tableTitle,[],0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=locMultiDirectTable(tBlock,tableComp,tableTitle)

try
    eNumDims = get_param(tBlock,'maskTabDims');
    if strncmp(eNumDims,'More',4)
        eNumDims = LocParamValue(tBlock,'explicitNumDims');
    else
        eNumDims = str2double(eNumDims);
    end
catch
    out={};
    return;
end

inVals = cell(eNumDims,1);

tableData = LocParamValue(tBlock,'mxTable');

tableTitle = sprintf('%s (%s output)',...
    tableTitle,...
    get_param(tBlock,'outDims'));

out=locMakeMultiTable(tableData,inVals,tableComp,tableTitle,[],1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=locMakeMultiTable(tableData,inVals,tableComp,tableTitle, history,zeroBasedIndices)
%tableData is an N-D array
%inVals is a cell array of double vectors representing the breakpoint data
%tableComp is a cfrcelltable component
%tableTitle is the title of the table
%history is a numeric vector telling us what dimensions we are reporting on

sz = size(tableData);
nDims = length(sz);
thisDim = nDims-length(history);

if thisDim<=2
    tableTitle=[tableTitle,' ',locTitleSuffix(history,inVals,nDims,zeroBasedIndices)];
    history=num2cell(history);
    dataSlice=tableData(:,:,history{:});
    
    %if this is really a 1-d table, make sure it is vertical
    if nDims==2 & min(sz)==1
        numLabels=1;
    else
        numLabels=2;
    end
    out=locGenerateTable(tableComp,dataSlice,tableTitle,zeroBasedIndices,inVals{1:numLabels});
else
    out={};
    for i=1:sz(thisDim)
        out=[out,locMakeMultiTable(tableData,inVals,tableComp,tableTitle,[i,history],zeroBasedIndices)];
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ts=locTitleSuffix(history,inVals,nDims,zeroBasedIndices)

if nargin<4
    zeroBasedIndices=0;
end

ts='(:,:';
for i=3:nDims
    thisIdx = history(i-2);
    try
        ts=sprintf('%s,%f',ts,inVals{i}(thisIdx));
    catch
        ts=sprintf('%s,[%i]',ts,thisIdx-zeroBasedIndices);
    end
end
ts=[ts,')'];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=locGenerateTable(tableComp,tableData,tableTitle,zeroBasedIndices,yData,xData)

sz=size(tableData);
yDim=sz(1);
xDim=sz(2);
if nargin<6
    %This is a 1-D table.  There is no X data.
    %force the table to be a column
    tableData=tableData(:);
    xLabels=cell(0,2);
    yDim=max(sz);
else
    xLabels = processBreakpoints(xData,xDim,zeroBasedIndices);
    xLabels = [{''},xLabels(:)'];
end

yLabels=processBreakpoints(yData,yDim,zeroBasedIndices);
tableData=[xLabels;[yLabels(:),num2cell(tableData)]];


tableComp.att.TableCells=tableData;
tableComp.att.TableTitle=tableTitle;

out=runcomponent(tableComp);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function bpLabel=processBreakpoints(bpData,maxDim,zeroBasedIndices)

if nargin<3
    zeroBasedIndices=0;
end

bpLabel = num2cell(bpData);
if length(bpLabel)<maxDim
    for i=maxDim:-1:length(bpLabel)+1
        bpLabel{i}=sprintf('[%i]',i-zeroBasedIndices);
    end
elseif length(bpData)>maxDim
    bpLabel=bpLabel(1:maxDim);
end

for i=1:length(bpLabel)
    bpLabel{i}=set(sgmltag,...
        'tag','emphasis',...
        'data',bpLabel{i});
end
