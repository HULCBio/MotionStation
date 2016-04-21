function addXLabel(this)

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2003/12/13 02:49:43 $

prompt = 'Enter the xlabel:';
dlgTitle = 'XLabel';
lineNo = 1;
if isempty(this.XLabel)
  answer=inputdlg(prompt,dlgTitle,lineNo);
  if length(answer) >= 1 && ~isempty(answer{1})
    oldunits = this.Axis.Units;
    this.Axis.Units = 'Points';
    axisPos = this.Axis.Position;
    nLines = size(answer{1},1);
    space = 12 * nLines;
    this.ExtraBottomMargin = space;
    
    % Move the axis up and shrink the axis height
    this.Axis.Position = [axisPos(1) axisPos(2)+space axisPos(3) axisPos(4)-space];
    axisPos = this.Axis.Position;
    this.Axis.Units = oldunits;
    
    % X,Y text position for Units = normalized 
    xpos = 0.5;
    ypos = 0;
    
    h = MapGraphics.Text('Label',...
                         'Parent',double(this.AnnotationAxes),...
                         'String',cellstr(answer),...
                         'Color','black',...
                         'HorizontalAlignment','center',...
                         'VerticalAlignment','top',...
                         'Units','normalized',...
                         'Position',[xpos ypos 0],...
                         'EraseMode','normal',...
                         'DeleteFcn',{@deleteXLabel this nLines});
    this.XLabel = h;
  end
else
  answer=inputdlg(prompt,dlgTitle,lineNo,get(this.XLabel,'String'));
  if  length(answer) >= 1 && ~isempty(answer{1})
    % Use CELLSTR to handle multi-line titles.
    set(this.XLabel,'String',cellstr(answer))
  end
end

function deleteXLabel(hSrc,event,this,nLines)
ax = this.Axis;
oldunits = ax.Units;
ax.Units = 'Points';
axisPos = ax.Position;

space = nLines * 12;

% Move the axis down 12 points and expand the axis height by 12 points
ax.Position = [axisPos(1) axisPos(2)-space axisPos(3) axisPos(4)+space];
axisPos = ax.Position;
ax.Units = oldunits;
this.XLabel = [];

this.ExtraBottomMargin = 0;
