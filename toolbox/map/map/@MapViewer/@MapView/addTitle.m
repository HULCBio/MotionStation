function addTitle(this)

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/02/01 21:56:52 $

prompt = 'Enter the title:';
dlgTitle = 'Title';
lineNo = 1;
if isempty(this.Title)
  answer=inputdlg(prompt,dlgTitle,lineNo);
  if length(answer) >= 1 && ~isempty(answer{1})
    oldunits = this.Axis.Units;
    this.Axis.Units = 'Points';
    axisPos = this.Axis.Position;
    nLines = size(answer{1},1);
    space = 12 * nLines;
    this.ExtraTopMargin = space;
    
    % Move the axis up and shrink the axis height
    this.Axis.Position = [axisPos(1) axisPos(2) axisPos(3) axisPos(4)-space];
    axisPos = this.Axis.Position;
    this.Axis.Units = oldunits;
    
    % X,Y text position for Units = normalized 
    xpos = 0.5;
    ypos = 1.0;
    
    h = MapGraphics.Text('Label',...
                         'Parent',double(this.AnnotationAxes),...
                         'String',cellstr(answer),...
                         'Color','black',...
                         'HorizontalAlignment','center',...
                         'VerticalAlignment','bottom',...
                         'Units','normalized',...
                         'Position',[xpos ypos 0],...
                         'EraseMode','normal',...
                         'DeleteFcn',{@deleteTitle this nLines});
    this.Title = h;
  end
else
  answer=inputdlg(prompt,dlgTitle,lineNo,get(this.Title,'String'));
  if  length(answer) >= 1 && ~isempty(answer{1})
    % Use CELLSTR to handle multi-line titles.
    set(this.Title,'String',cellstr(answer))
  end
end

function deleteTitle(hSrc,event,this,nLines)
ax = this.Axis;
oldunits = ax.Units;
ax.Units = 'Points';
axisPos = ax.Position;

space = nLines * 12;

% Move the axis down 12 points and expand the axis height by 12 points
ax.Position = [axisPos(1) axisPos(2) axisPos(3) axisPos(4)+space];
axisPos = ax.Position;
ax.Units = oldunits;
this.Title = [];
this.ExtraTopMargin = 0;
