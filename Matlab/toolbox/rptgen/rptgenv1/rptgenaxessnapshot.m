function axFig=rptgenaxessnapshot(fHandle)
%RPTGENAXESSNAPSHOT assists in taking a snapshot of axes contents
%   AXFIG=RPTGENAXESSNAPSHOT(H) accepts a handle to a figure
%   and creates another figure with handle AXFIG.  The new
%   figure contains only the axes in the original figure.
%   This new figure is invisible

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:17:54 $


if nargin<1
   fHandle=gcf;
elseif ~ishandle(fHandle)
   error('Input figure does not exist');
end

%copy axes to new figure
allAx=findall(allchild(fHandle),'flat','type','axes');
if ~isempty(allAx)
   axFig=LocAxesFigure(fHandle);
   LocCopyAxes(axFig,allAx);
end

set(0,'CurrentFigure',axFig);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function axFig=LocAxesFigure(sHandle)

figTag='rptgen-AxesFigure';

axFig=findall(allchild(0),'flat',...
   'tag',figTag);
if isempty(axFig)
   axFig=figure('Visible','on',...
      'tag',figTag,...
      'IntegerHandle','off',...
      'HandleVisibility','on',...
      'CloseRequestFcn','set(gcbf,''Visible'',''off'')',...
      'NumberTitle','off',...
      'Name','Report Generator Axes Figure');
else
   axFig=axFig(1);
   %clear the figure
   delete(allchild(axFig));
end

%match figure sizes (necessary if axes have units='normalized')
orig.Units=get(sHandle,'Units');
orig.Position=get(sHandle,'position');
orig.Color=get(sHandle,'color');
orig.ColorMap=get(sHandle,'colormap');
orig.InvertHardcopy=get(sHandle,'InvertHardcopy');
orig.Renderer=get(sHandle,'Renderer');
orig.ShareColors=get(sHandle,'ShareColors');

set(axFig,orig);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocCopyAxes(axFig,allAx)

allAx=copyobj(allAx,axFig);

set([allAx;axFig],'units','pixels');

numAx=length(allAx);

extentMatrix=ones(numAx,4);
for i=1:numAx
   extentMatrix(i,1:4)=LocAxesExtent(allAx(i));
end

minExtent=min(extentMatrix,[],1);

border=10;


axPos=get(allAx,'Position');
if numAx>1
   axPos=cat(1,axPos{:});
   axPos(:,1)=axPos(:,1)-minExtent(1)+border;
   axPos(:,2)=axPos(:,2)-minExtent(2)+border;
   axPos=num2cell(axPos,2);
   posID={'Position'};
else
   posID='Position';
   axPos(:,1)=axPos(:,1)-minExtent(1)+border;
   axPos(:,2)=axPos(:,2)-minExtent(2)+border;
   posID='Position';
end

set(allAx,posID,axPos);

maxExtent=max(extentMatrix,[],1);

figSize=maxExtent(3:4)-minExtent(1:2)+2*border;
%-figSize-30
set(axFig,'Position',[20 20 figSize]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function axExtent=LocAxesExtent(axH)

axPos=get(axH,'Position');

txH=findall(allchild(axH),'type','text');
axView=get(axH,'view');
if axView(2)==90
   txH=setdiff(txH,get(axH,'zlabel'));
end

set(txH,'units','pixels')
txExtent=get(txH,'extent');

txExtent=cat(1,txExtent{:});
txExtent(:,1)=txExtent(:,1)+axPos(1);
txExtent(:,2)=txExtent(:,2)+axPos(2);
txExtent(:,3:4)=txExtent(:,3:4)+txExtent(:,1:2);

allExtent=[[axPos(1:2),axPos(1:2)+axPos(3:4)];txExtent];

axMin=min(allExtent,[],1);
axMax=max(allExtent,[],1);

axExtent=[axMin(1:2) axMax(3:4)];


