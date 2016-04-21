function out=execute(c)
%EXECUTE generate report output
%   OUTPUT=EXECUTE(C)

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:14:19 $

%assume CurrFig is passed in as a single figure handle

if isempty(c.att.FigureHandle)
   CurrFig=c.zhgmethods.Figure;
else
   CurrFig=c.att.FigureHandle;
end

noFigFlag=(isempty(CurrFig) | ~ishandle(CurrFig));

%hvOffFlag=~strcmp(get(CurrFig,'HandleVisibility'),'on');
%if hvOffFlag
%   slScopeFlag=(strcmp(get(CurrFig,'ResizeFcn'),'simscope Resize') & ...
%      strcmp(get(CurrFig,'DeleteFcn'),'simscope DeleteFcn'));
%else
%   slScopeFlag=logical(0);
%end

if ~noFigFlag
   [figPropNames,figPropValues]=LocPaperProperties(c.att,CurrFig);
   oldPropValues=LocFigGet(CurrFig,figPropNames);
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %disp('Property Names to Change')
   %disp(figPropNames)
   %disp('Old Property Values')
   %disp(oldPropValues')
   %disp('New Property Values')
   %disp(figPropValues)
   %disp('-------------------------------')
   
   LocFigSet(CurrFig,figPropNames,figPropValues);
   
   filename=LocTakeSnapshot(c,CurrFig);
   
   LocFigSet(CurrFig,figPropNames,oldPropValues);
   
   if isempty(filename)
	   out='';
   else
	   imgC=c.rptcomponent.comps.cfrimage;
	   imgC.att.FileName=filename;
	   imgC.att.Caption=c.att.Caption;

	   if ~isempty(c.att.ImageTitle)
		   imgC.att.isTitle='local';
		   imgC.att.Title=c.att.ImageTitle;
	   end

	   out=runcomponent(imgC,0);
   end

else
   status(c,'Warning - figure not found',2);
   out='';
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function propValues=LocFigGet(h,propNames)

propValues={};
for i=length(propNames):-1:1
   propValues{i}=get(h,propNames{i});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocFigSet(h,propNames,propValues)

numProps=length(propNames);
if numProps>0
   [propPairs{1:2:2*numProps-1}]=deal(propNames{:});
   [propPairs{2:2:2*numProps}]=deal(propValues{:});
   set(h,propPairs{:});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [pNames,pValues]=LocPaperProperties(att,figHandle);

pNames={};
pValues={};

if ~att.isCapture
   switch att.isResizeFigure
   case 'auto'
      pNames={'PaperPosition' 'PaperPositionMode'};
      pValues={[0 0 4 3] 'auto'};
      
      %We are setting PaperPosition here because 
      %setting PaperPositionMode to Auto changes
      %PaperPosition and we want to make sure that
      %PaperPosition is on the list of properties
      %we save for later restoration.  PaperPosition
      %must be before PaperPositionMode on the list
      %or else we'll just end up setting the Mode to 
      %'manual'
      
      
   case 'manual'
      
      pNames={'PaperPositionMode' 'PaperUnits' 'PaperPosition'};
      pValues={'manual' att.PrintUnits [0 0 att.PrintSize]};
   end
   
   if ~isempty(att.PaperOrientation)
      pNames{end+1}='PaperOrientation';
      pValues{end+1}=att.PaperOrientation;      
   end
   
   switch att.InvertHardcopy
   case 'auto'
      pNames{end+1}='InvertHardcopy';
      pValues{end+1}=LocAutoInvertHardcopy(figHandle);                  
   case {'on' 'off'}
      pNames{end+1}='InvertHardcopy';
      pValues{end+1}=att.InvertHardcopy;            
   end  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result=LocAutoInvertHardcopy(figHandle);

axHandles=findall(allchild(figHandle),'Type','axes');
figColor=get(figHandle,'Color');
if ~isnumeric(figColor)
    %If the figure color is 'none', call it white
    figColor=[1 1 1];
end
axColor=get(axHandles,'Color');

if ~isempty(axColor)
   if iscell(axColor)
      stringIdx = find(cellfun('isclass',axColor,'char'));
      if ~isempty(stringIdx)
          [axColor{stringIdx}]=deal(figColor);
      end
      colorMatrix=cat(1,axColor{:});
   else
      if ~isnumeric(axColor)
          %if color is 'none'
          colorMatrix=figColor;
      else
          colorMatrix=axColor;
      end
   end   
   colorMatrix=rgb2hsv(colorMatrix);
   colorMatrix=mean(colorMatrix(:,3));
   
   if colorMatrix<.5
      result='on';
   else
      result='off';
   end
else
   result='off';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function filename = LocTakeSnapshot(c,CurrFig)
%CurrFig is a handle

imgInfo=getimgformat(c,c.att.ImageFormat);

oldVis=get(CurrFig,'Visible');

if c.att.isCapture
   captureImageExt={'tif'
      'tiff'
      'jpg'
      'jpeg'
      'bmp'
      'png'
      'hdf'
      'pcx'
      'xwd'};
   
   if ~any(strcmpi(captureImageExt,imgInfo.ext))
      status(c,{sprintf('Warning - image format type "%s" can not be used with "capture".',...
	        imgInfo.ext);...
            sprintf('Using format "png" instead')},2);
      imgInfo=getimgformat(c,'png');
   end
   
   filename=getimgname(c,imgInfo,'hg');
   
   try
	   [x, map] = frame2im(getframe(CurrFig));
	   if ~isempty(map)
		   x = ind2rgb(x,map);
	   end
	   imwrite(x,filename,imgInfo.ext);
   catch
	   status(c,lasterr,2);
	   filename='';
   end
else
   filename=getimgname(c,imgInfo,'hg');
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %disp(['Generating Image  - ' get(CurrFig,'Name')])
   %disp(['PaperPositionMode - ' get(CurrFig,'PaperPositionMode')])
   %disp(['PaperPosition     - ' num2str(get(CurrFig,'PaperPosition'))])
   %disp(['PaperUnits        - ' get(CurrFig,'PaperUnits')])
   %disp(['PaperSize         - ' num2str(get(CurrFig,'PaperSize'))])
   %disp('*************************************************')
   
   if c.rptcomponent.DebugMode
      imgInfo.options{end+1}='-DEBUG';
   end
   
   drawnow;
   try
	   print(CurrFig,imgInfo.driver,imgInfo.options{:},filename);
   catch
       status(c,lasterr,2);
	   filename='';
   end
   
end

set(CurrFig,'Visible',oldVis);
