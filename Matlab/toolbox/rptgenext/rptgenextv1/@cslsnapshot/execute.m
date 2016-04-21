function out=execute(c)
%EXECUTE inserts tags into the source file
%   OUTPUT=EXECUTE(C)
%

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:21:53 $

imgInfo=getimgformat(c,c.att.format);
sysName=c.zslmethods.System;

if isempty(sysName)
   out='';
   status(c,'Warning - could not find System for snapshot.',2);
   return
end

if strcmp(get_param(sysName,'Type'),'block') & ...
         strcmp(get_param(sysName,'MaskType'),'Stateflow')
   out='';
   status(c,'Warning - can not take snapshots of Stateflow systems',2);
   return
end

[warnStr,c]=checkframeformat(c,imgInfo);
if length(warnStr)>0
   status(c,warnStr,2);
end

[imgFileName,isNew]=getimgname(c,imgInfo,'sl',getfullname(sysName));

imSize=[];
paperOrientation=c.att.PaperOrientation;
boundBox=nan;
if isNew
    switch imgInfo.ID
    case {'jpeg90' 'jpeg75' 'jpeg30' 'png'}
        tempImgInfo=getimgformat(c,'bmp16m');
        tempFileName=[tempname '.' tempImgInfo.ext];
        boundBox = LocTakeSnap(c,...
            sysName,...
            tempImgInfo,...
            tempFileName);
        
        switch imgInfo.ID
        case 'png'
            imgOpt={'Description','A Simulink snapshot',...
                    'CreationTime',datestr(date)};
        otherwise
            imgOpt={'Quality',str2double(imgInfo.ID(end-1:end))};
        end   
        
        imSize=LocTransformImage(tempFileName,...
            imgFileName,...
            imgInfo,...
            imgOpt{:});
    case 'png-capture'
        tempImgInfo=getimgformat(c,'bmp-capture');
        tempFileName = [tempname '.' tempImgInfo.ext];
        boundBox = LocTakeSnap(c,...
            sysName,...
            tempImgInfo,...
            tempFileName);
        imSize=LocTransformImage(tempFileName,...
            imgFileName,...
            imgInfo,...
            'CreationTime',datestr(date));
        paperOrientation='portrait';
        sbo = get_param(sysName,'scrollbaroffset');
        zoomFactor = str2double(get_param(sysName,'ZoomFactor'))/100;
        boundBox=[sbo/zoomFactor,(imSize+sbo)/zoomFactor];
        %boundBox=[sbo,(imSize+sbo)];
    otherwise   
        boundBox = LocTakeSnap(c,...
            sysName,...
            imgInfo,...
            imgFileName);
    end
end

if ~isempty(imgFileName)
    imgComponent=c.rptcomponent.comps.cfrimage;
    imgComponent.att.FileName=imgFileName;

    switch c.att.TitleType
    case 'sysname'
        imgComponent.att.isTitle = 'local';
        imgComponent.att.Title = getparam(c,sysName,'Name');
    case 'fullsysname'
        imgComponent.att.isTitle = 'local';
        imgComponent.att.Title = sysName;
    case 'manual'
        imgComponent.att.isTitle = 'local';
        imgComponent.att.Title = parsevartext(c,c.att.TitleString);
    otherwise
        imgComponent.att.isTitle = 'none';
    end
    
    switch c.att.CaptionType
    case '$auto'
        desc=getparam(c,sysName,'Description');
        imgComponent.att.Caption=desc{1};
    case '$manual'
        imgComponent.att.Caption=parsevartext(c,c.att.CaptionString);
    end
    
    if c.att.isPrintFrame
        imSize=[];
    elseif isempty(imSize) & ~any(strcmp({'ps','eps','ill'},imgInfo.ext))
        try
            iInfo=imfinfo(imgFileName);
            imSize=[iInfo.Width,iInfo.Height];
        end
    end
    
    if ~isempty(imSize)
        imgComponent.att.CalloutList=LocImagemap(sysName,[0,0,imSize],paperOrientation,boundBox);
    end
    
    out=runcomponent(imgComponent,0);
else
    out='';
    status(c,'Could not take snapshot of system',2);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocTakeSnap        %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function boundBox = LocTakeSnap(c,systemName,imgInfo,fileName)

boundBox = nan;
if c.att.isPrintFrame
   pfName=c.att.PrintFrameName;
else
   pfName='';
end

oldOrient=get_param(systemName,...
    'PaperOrientation');

if ~isempty(c.att.PaperOrientation)
    pOrient = c.att.PaperOrientation;
else
    pOrient = oldOrient;
end

numOptions=length(imgInfo.options);
if numOptions==0
   oString='';
elseif numOptions==1
   oString=imgInfo.options{1};
   if strmatch('-r',oString)
      oString='';
   end
else
   %Simulink printing does not like having its resolution set
   opt=imgInfo.options;
   rezIndex=strmatch('-r',opt);
   if ~isempty(rezIndex)
      [opt{rezIndex}]=deal('');
   end
   
   oString=singlelinetext(c,opt,' ');
end

if c.rptcomponent.DebugMode
   oString=[oString ' -DEBUG'];
end


PrintInfo=struct('PrintLog','off',...
   'PrintFrame',pfName,...
   'FileName', fileName,...
   'PrintOptions',[imgInfo.driver ' ' oString],...
   'PaperOrientation',pOrient,...
   'PaperType','usletter');

if strcmp(c.att.PaperExtentMode,'manual')
    boundBox=get_param(systemName,'SystemBounds');
    aspectRatio = (boundBox(4)-boundBox(2))/(boundBox(3)-boundBox(1)); %H/W
    
    if strcmpi(pOrient,'portrait')
        pWid = min(c.att.PaperExtent(1),c.att.PaperExtent(2)/aspectRatio);
    else
        pWid = min(c.att.PaperExtent(1)/aspectRatio,c.att.PaperExtent(2));
    end
    PrintInfo.PaperPosition = [0,0,...
            pWid,...
            pWid*aspectRatio];
    
    PrintInfo.PaperUnits = c.att.PaperUnits;
end


%set_param(systemName,'paperorientation',pOrient)
%open_system(systemName);
%print(['-s' systemName],imgInfo.driver,fileName);


simprintdlg(systemName,...
   'CurrentSystem',...
   logical(1),...
   logical(1),...
   PrintInfo);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [imSize]=LocTransformImage(origFileName,newFileName,imgInfo,varargin)

[x,map]=imread(origFileName,'bmp'); 
      
%crop to image
%BackgroundColor = x(1,1);
%[Row,Col]=find(x~=BackgroundColor);
%if isempty(Row) | isempty(Col)
%   newFileName='';
%else         
%   XIdx=[max(1,min(Row)-10) min(max(Row)+10,size(x,1))];
%   YIdx=[max(1,min(Col)-10) min(max(Col)+10,size(x,2))];
%   x=x(XIdx(1):XIdx(2),YIdx(1):YIdx(2));        

if isempty(map)
   imwrite(x,newFileName,imgInfo.ext,varargin{:});
else
   imwrite(x,map,newFileName,imgInfo.ext,varargin{:});
end

imSize=size(x);
imSize=imSize([2,1]);

try
   delete(origFileName)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function iList=LocImagemap(sysName,imSize,pOrient,boundBox)

blockList=get_param(sysName,'blocks');
lineInfo=get_param(sysName,'lines');

if nargin<4 | isnan(boundBox)
    boundBox=get_param(sysName,'SystemBounds');
end

if isempty(pOrient)
   pOrient=get_param(sysName,...
      'PaperOrientation');
end

iList=cell(length(blockList),3);

z=zslmethods;

for i=1:length(blockList)
    bName=sprintf('%s/%s',sysName,strrep(blockList{i},'/','//'));
    iList{i,1}=locImagemapCoords(get_param(bName,'position'),boundBox,imSize,pOrient);
    
    if strcmp(get_param(bName,'BlockType'),'SubSystem')
        linkType='sys';
    else
        linkType='blk';
    end

    iList{i,3}=linkid(z,bName,linkType);
end

for i=1:length(lineInfo)
    blockH=lineInfo(i).SrcBlock;
    portIdx=str2double(lineInfo(i).SrcPort);
    if ishandle(blockH) & length(portIdx)==1
        portList=get_param(blockH,'PortHandles');
        if length(portList.Outport) >= portIdx
            hSignal=portList.Outport(portIdx);
            
            iList=[iList;LocLineImagemap(lineInfo(i),...
                    linkid(z,hSignal,'sig'),...
                    boundBox,...
                    imSize,...
                    pOrient)];
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pos = locImagemapCoords(pos,boundBox,imSize,pOrient)
%pos = simulink position (must have even number of elements)
%boundBox = bounding box in simulink units [x1,y1,x2,y2]
%simSize =[ 0 0 w h ]

if strncmpi(pOrient,'p',1)
    %portrait
    pos(1:2:end-1)=round((pos(1:2:end-1)-boundBox(1))*...
        (imSize(3)-imSize(1))/(boundBox(3)-boundBox(1)));
    pos(2:2:end)=  round((pos(2:2:end)  -boundBox(2))*...
        (imSize(4)-imSize(2))/(boundBox(4)-boundBox(2)));
else
    %landscape
    origPos=pos;
    pos(1:2:end-1)=round((origPos(2:2:end)-boundBox(1))*...
        (imSize(3)-imSize(1))/(boundBox(4)-boundBox(2)));
    pos(2:2:end)  =round((boundBox(3)-origPos(1:2:end-1))*...
        (imSize(4)-imSize(2))/(boundBox(3)-boundBox(1)));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function lineBox = locBorder(x1,y1,x2,y2,r)
%[x1,y1,x2,y2] position of a line
%r = size of border to surround line
%box = coordinates of box around line

h=y2-y1;
w=x2-x1;
n=r/(sqrt(max(h^2+w^2,1))); %scaling factor

lineBox=[x1-n*w+n*h,y1-n*h-n*w,...
         x2+n*w+n*h,y2+n*h-n*w,...
         x2+n*w-n*h,y2+n*h+n*w,...
         x1-n*w-n*h,y1-n*h+n*w];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function lineList=LocLineImagemap(lineInfo,id,boundBox,imSize,pOrient)

points=lineInfo.Points;
lineList=cell(size(points,1)-1,3);
for i=2:size(points,1)
    x1=points(i-1,1);
    x2=points(i,1);
    y1=points(i-1,2);
    y2=points(i,2);
    
    lineList{i-1,1}=locImagemapCoords(locBorder(x1,y1,x2,y2,2),...
        boundBox,...
        imSize,...
        pOrient);
    lineList{i-1,3}=id;
end

branchLines=lineInfo.Branch;
for i=1:length(branchLines)
    lineList=[lineList;LocLineImagemap(branchLines(i),id,boundBox,imSize,pOrient)];
end


