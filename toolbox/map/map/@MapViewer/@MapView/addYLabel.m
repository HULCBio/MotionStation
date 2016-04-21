function addYLabel(this)

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2003/12/13 02:49:44 $

if isempty(this.YLabel)
  answer=inputdlg('Enter the ylabel:','YLabel',1);
  if  length(answer) >= 1 && ~isempty(answer{1})
    oldunits = this.Axis.Units;
    this.Axis.Units = 'Points';
    axisPos = this.Axis.Position;
    nLines = size(answer{1},1);
    space = 12 * nLines;
    this.ExtraLeftMargin = space;
    
    % Move the axis right and shrink the axis width
    this.Axis.Position = [axisPos(1)+space axisPos(2) axisPos(3)-space axisPos(4)];
    axisPos = this.Axis.Position;
    this.Axis.Units = oldunits;
    
    % X,Y text position for Units = normalized 
    xpos = 0;
    ypos = 0.5;
    
    h = MapGraphics.Text('Label',...
                         'Parent',double(this.AnnotationAxes),...
                         'String',cellstr(answer),...
                         'Color','black',...
                         'HorizontalAlignment','center',...
                         'VerticalAlignment','bottom',...
                         'Units','normalized',...
                         'Position',[xpos ypos 0],...
                         'Rotation',90,...
                         'EraseMode','normal',...
                         'DeleteFcn',{@deleteYLabel this nLines});
    this.YLabel = h;
  end
else
  answer=inputdlg('Enter the YLabel:','YLabel',2,get(this.YLabel,'String'));
  if  length(answer) >= 1 && ~isempty(answer{1})
    % Use CELLSTR to handle multi-line titles.
    set(this.YLabel,'String',cellstr(answer))
  end
end

function deleteYLabel(hSrc,event,this,nLines)
ax = this.Axis;
oldunits = ax.Units;
ax.Units = 'Points';
axisPos = ax.Position;

space = nLines * 12;

% Move the axis down 12 points and expand the axis height by 12 points
ax.Position = [axisPos(1)-space axisPos(2) axisPos(3)+space axisPos(4)];
axisPos = ax.Position;
ax.Units = oldunits;
this.YLabel = [];

this.ExtraLeftMargin = 0;