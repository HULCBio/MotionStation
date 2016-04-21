function plotfis(fis)
%PLOTFIS Display FIS input-output diagram.
%   PLOTFIS(FISSTRUCT) creates an input-output display of the fuzzy
%   inference system associated with the FIS structure FISSTRUCT. 
%   Inputs and their membership functions appear to the left of 
%   the FIS structural characteristics, while outputs and their 
%   membership functions appear on the right.
%
%   This FIS diagram is similar to the one shown at the top of the 
%   FIS Editor (invoked by the command FUZZY).
%
%   For example:
%
%           a=newfis('tipper');
%           a=addvar(a,'input','service',[0 10]);
%           a=addmf(a,'input',1,'poor','gaussmf',[1.5 0]);
%           a=addmf(a,'input',1,'excellent','gaussmf',[1.5 10]);
%           a=addvar(a,'input','food',[0 10]);
%           a=addmf(a,'input',2,'rancid','trapmf',[-2 0 1 3]);
%           a=addmf(a,'input',2,'delicious','trapmf',[7 9 10 12]);
%           a=addvar(a,'output','tip',[0 30]);
%           a=addmf(a,'output',1,'cheap','trimf',[0 5 10]);
%           a=addmf(a,'output',1,'generous','trimf',[20 25 30]);
%           ruleList=[1 1 1 1 2; 2 2 2 1 2 ];
%           a=addrule(a,ruleList);
%           plotfis(a)
%
%   See also EVALMF, PLOTMF.

%   Ned Gulley, 5-26-94
%   Copyright 1994-2003 The MathWorks, Inc.
%   $Revision: 1.21.2.3 $  $Date: 2004/04/10 23:15:33 $

figNumber=gcf;
if strcmp(get(figNumber,'NextPlot'),'new'),
    figNumber=figure;
else
    delete(findobj(allchild(figNumber),'type','Axes','tag','oneOfPlotFisAxes'));
end

set(figNumber,'NextPlot','replace')

numInputs=length(fis.input);
numOutputs=length(fis.output);


for i=1:length(fis.input)
 numInputMFs(i)=length(fis.input(i).mf);
end

numOutputMFs=[];
for i=1:length(fis.output)
 numOutputMFs(i)=length(fis.output(i).mf);
end

numRules=length(fis.rule);
fisName=fis.name;
fisType=fis.type;
[xi,yi,xo,yo,r]=discfis(fis,181);

% Delete all axes to clean up (but retain location of current axes)
mainAxHndl=gca;
set(mainAxHndl,'Units','pixel')
mainAxPos=get(mainAxHndl,'Position');
axList=findobj(figNumber,'Type','axes');
delete(axList)
mainAxHndl=axes( ...
   'Visible','off', ...
   'Units','pixel', ...
   'HandleVis','on',...
   'Position',mainAxPos,...
   'Xlim',[mainAxPos(1) mainAxPos(1)+mainAxPos(3)],...
   'Ylim',[mainAxPos(2) mainAxPos(2)+mainAxPos(4)],...
   'tag','oneOfPlotFisAxes');
XlabelStr = sprintf('System %s: %d inputs, %d outputs, %d rules',... 
   fisName,numInputs,numOutputs,numRules);
set(get(mainAxHndl,'XLabel'),'String',XlabelStr,'Visible','on','FontSize', 8)

xCenter=mainAxPos(1)+mainAxPos(3)/2;
yCenter=mainAxPos(2)+mainAxPos(4)/2;

% Inputs first
inputColor=[1 1 0.5];
grayColor=[0.7 0.7 0.7];
fontSize=8;
boxWid=(1/3)*mainAxPos(3);
xInset=boxWid/5;
if numInputs>0,
    boxHt=(1/(numInputs))*mainAxPos(4);
    yInset=boxHt*.3;   %   /(numInputs+2);
end

for varIndex=1:numInputs,
    boxLft=mainAxPos(1);
    boxBtm=mainAxPos(2)+mainAxPos(4)-boxHt*varIndex;
    axPos=[boxLft+xInset boxBtm+yInset boxWid-2*xInset max(boxHt/2,boxHt-2*yInset)];
    % Draw the line that connects the input to the main block
    % Make it a dotted line if the variable is not used in the rule base
    if numRules==0,
       lineStyle='--';
    elseif ~any(r(:,varIndex)), 
       lineStyle='--';
    else
       lineStyle='-';
    end
    xInputCenter=axPos(1)+axPos(3);
    yInputCenter=axPos(2)+axPos(4)/2;
    line([xInputCenter xCenter],[yInputCenter yCenter], ...
       'Parent',mainAxHndl,...
       'LineStyle',lineStyle, ...
       'LineWidth',3, ...
       'Color',grayColor);
    
    varName=fis.input(varIndex).name;
    mfIndex=(1:numInputMFs(varIndex))+sum(numInputMFs(1:(varIndex-1)));
    xMin=min(min(xi(:,mfIndex)));
    xMax=max(max(xi(:,mfIndex)));
    xiInset=(xMax-xMin)/10;
    
    axHndl=axes( ...
       'Units','pixel', ...
       'Box','on', ...
       'XTick',[],'YTick',[], ...      
       'YLim',[-0.1 1.1], ...
       'XColor','black','YColor','black', ...
       'Color',inputColor, ...
       'LineWidth',2, ...
       'Position',axPos,...
       'HandleVis','on',...
       'Xlim',[xMin-xiInset xMax+xiInset],...
       'Ylim',[-0.1 1.1],...
       'tag','oneOfPlotFisAxes');
    set(get(axHndl,'xLabel'),...
       'String',sprintf('%s (%d)',varName,numInputMFs(varIndex)),...
       'FontSize',fontSize)
    line(xi(:,mfIndex),yi(:,mfIndex),'Color','black','Parent',axHndl);
end

% Now for the outputs
outputColor=[0.5 1 1];
if numOutputs>0,
    boxHt=(1/(numOutputs))*mainAxPos(4);
    yInset=boxHt/(numOutputs+2);
end

for varIndex=1:numOutputs,
   boxLft=mainAxPos(1)+2*boxWid;
   boxBtm=mainAxPos(2)+mainAxPos(4)-boxHt*varIndex;
   axPos=[boxLft+xInset boxBtm+yInset boxWid-2*xInset boxHt-2*yInset];
   
   % Draw the line connect the center block to the output
   % Make it a dotted line if the variable is not used in the rule base
   if ~any(r(:,varIndex+numInputs)), 
      lineStyle='--';
   else
      lineStyle='-';
   end
   line([axPos(1) xCenter],[axPos(2)+axPos(4)/2 yCenter], ...
      'Parent',mainAxHndl,...
      'LineWidth',3, ...
      'LineStyle',lineStyle, ...
      'Color',grayColor);
   
   varName=fis.output(varIndex).name;
   axHndl=axes( ...
      'Units','pixel', ...
      'Box','on', ...
      'Color',outputColor, ...
      'XColor','black','YColor', 'black', ...
      'LineWidth',2, ...
      'XTick',[],'YTick',[], ...      
      'Position',axPos,...
      'HandleVis','on',...
      'tag','oneOfPlotFisAxes');
   mfIndex=(1:numOutputMFs(varIndex))+sum(numOutputMFs(1:(varIndex-1)));
   if ~isempty(yo),
      % Don't try to plot outputs it if it's a Sugeno-style system
      line(xo(:,mfIndex),yo(:,mfIndex),'Color','black','Parent',axHndl);
      xMin=min(min(xo(:,mfIndex)));
      xMax=max(max(xo(:,mfIndex)));
      xoInset=(xMax-xMin)/10;
      set(axHndl,'XLim',[xMin-xoInset xMax+xoInset],'Ylim',[-0.1 1.1])
   else
      set(axHndl,'XLim',[-1 1],'YLim',[-1 1])
      text(0,0,'f(u)', ...
         'Parent',axHndl,...
         'FontSize',fontSize, ...
         'Color','black', ...
         'HorizontalAlignment','center');
   end
   set(get(axHndl,'XLabel'),...
      'String',sprintf('%s (%d)',varName,numOutputMFs(varIndex)), ...
      'FontSize',fontSize)
end

% Now draw the box in the middle
boxLft=mainAxPos(1)+boxWid;
boxBtm=mainAxPos(2);
boxHt=mainAxPos(4);
yInset=boxHt/(max(numInputs,numOutputs)+2);
axPos=[boxLft+xInset boxBtm+yInset boxWid-2*xInset boxHt-2*yInset];
axHndl=axes( ...
   'Units','pixel', ...
   'Box','on', ...
   'XTick',[],'YTick',[], ...  
   'YLim',[-1 1],'XLim',[-1 1], ...
   'LineWidth',2, ...
   'XColor','black','YColor','black', ...
   'Color',[0.95 0.95 0.95], ...
   'Position',axPos,...
   'HandleVis','on',...
   'tag','oneOfPlotFisAxes');
text(0,1/2,fisName, ...
   'Parent',axHndl,...
   'FontSize',fontSize, ...
   'Color','black', ...
   'HorizontalAlignment','center');
text(0,0,['(' fisType ')'], ...
   'Parent',axHndl,...
   'FontSize',fontSize, ...
   'Color','black', ...
   'HorizontalAlignment','center');
text(0,-1/2,[num2str(numRules) ' rules'], ...
   'Parent',axHndl,...
   'FontSize',fontSize, ...
   'Color','black', ...
   'HorizontalAlignment','center');
set(get(axHndl,'Title'),'FontSize',fontSize,'Color','black');
drawnow

hndlList=findobj(figNumber,'Units','pixels');
set(hndlList,'Units','normalized')
