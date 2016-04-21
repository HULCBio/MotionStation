function setLegendInfo(this)
%SETLEGENDINFO Set legendinfo 

%   Copyright 1984-2004 The MathWorks, Inc.

cdata = this.CData;
ax = ancestor(this,'axes');
if isequal(size(cdata),[1,3]) 
  % cdata 1x3, all patches same
  mfacecolor = cdata;
  if ischar(this.MarkerFaceColor)
    switch this.MarkerFaceColor
     case 'none'
      mfacecolor = 'none';
     case 'auto';
      mfacecolor = get(ax,'color');
    end
  end
  medgecolor = cdata;
  if ischar(this.MarkerEdgeColor)
    switch this.MarkerEdgeColor
     case 'none'
      medgecolor = 'none';
     case 'auto'
      medgecolor = mfacecolor;
    end
  end  
  cdata = [];
elseif isequal(size(cdata(:)),size(this.XData(:))) 
  % cdata index into colormap
  mfacecolor = 'flat';
  if ischar(this.MarkerFaceColor)
    switch this.MarkerFaceColor
     case 'none'
      mfacecolor = 'none';
     case 'auto';
      mfacecolor = get(ax,'color');
    end
  end
  medgecolor = 'flat';
  if ischar(this.MarkerEdgeColor)
    switch this.MarkerEdgeColor
     case 'none'
      medgecolor = 'none';
     case 'auto'
      medgecolor = mfacecolor;
    end
  end
  if ~isempty(cdata)
    cdata = mean(cdata);
  end
else
  % colorspec per patch/marker
  c = cdata(ceil(size(cdata,1)/2),:);
  mfacecolor = c;
  if ischar(this.MarkerFaceColor)
    switch this.MarkerFaceColor
     case 'none'
      mfacecolor = 'none';
     case 'auto';
      mfacecolor = get(ax,'color');
    end
  end
  medgecolor = c;
  if ischar(this.MarkerEdgeColor)
    switch this.MarkerEdgeColor
     case 'none'
      medgecolor = 'none';
     case 'auto'
      medgecolor = mfacecolor;
    end
  end
  cdata = [];
end
if ~ischar(this.MarkerEdgeColor)
  medgecolor = this.MarkerEdgeColor;
end
if ~ischar(this.MarkerFaceColor)
  mfacecolor = this.MarkerFaceColor;
end
legendinfo(this,'patch',...
    'Marker',this.Marker,...
    'MarkerEdgeColor',medgecolor,...
    'MarkerFaceColor',mfacecolor,...
    'EdgeColor','none',...
    'FaceColor','none',...
    'MarkerSize',6,...
    'XData',.5,...
    'YData',.5,...
    'CData',cdata);
setappdata(double(this),'LegendLegendType','patch');
