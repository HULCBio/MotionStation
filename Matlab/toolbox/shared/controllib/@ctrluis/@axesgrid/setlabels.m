function setlabels(this,varargin)
%SETLABELS  Updates visibility, style, and contents of HG labels.

%   Author: P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:16:54 $

% Outer label visibility
backax = this.BackgroundAxes;
set([backax.Title;backax.XLabel;backax.YLabel],'Visible',this.Visible);

% Inner labels
if strcmp(this.Visible,'on')
   % Get map from @axesgrid properties to HG labels
   LabelMap = feval(this.LabelFcn{:});
   
   % Title, xlabel, ylabel contents and style
   set(backax.Title,'String',this.Title,struct(this.TitleStyle))
   set(backax.XLabel,'String',LabelMap.XLabel,struct(LabelMap.XLabelStyle))
   set(backax.YLabel,'String',LabelMap.YLabel,struct(LabelMap.YLabelStyle))
   
   % Row and column visibility
   [VisAxes,indrow,indcol] = findvisible(this);
   [nr,nc] = size(VisAxes);
   if nr==0 | nc==0
      return
   end
   
   % Global reset
   set(VisAxes,'XTickLabel',[],'YTickLabel',[])
   for ct=1:nr*nc
      set([VisAxes(ct).Title,VisAxes(ct).XLabel,VisAxes(ct).YLabel],'String','','HitTest','off')
   end
   
   % Tick labels on borders
   if strcmp(this.YNormalization,'off')
      set(VisAxes(:,1),'YTickLabelMode','auto')
   end
   set(VisAxes(nr,:),'XTickLabelMode','auto')
   
   % Row labels
   if any(strcmp(this.AxesGrouping,{'none','column'}))
      RowLabelStyle = struct(LabelMap.RowLabelStyle);
      if strcmpi(LabelMap.RowLabelStyle.Location,'left')
         for ct=1:nr,
            set(VisAxes(ct,1).YLabel,'String',LabelMap.RowLabel{indrow(ct)},RowLabelStyle)
         end
      end
   end
   
   % Column labels
   if any(strcmp(this.AxesGrouping,{'none','row'}))
      ColumnLabelStyle = struct(LabelMap.ColumnLabelStyle);
      if strcmpi(LabelMap.ColumnLabelStyle.Location,'top')
         for ct=1:nc,
            set(VisAxes(1,ct).Title,'String',LabelMap.ColumnLabel{indcol(ct)},ColumnLabelStyle)
         end
      else
         for ct=1:nc,
            set(VisAxes(nr,ct).XLabel,'String',LabelMap.ColumnLabel{indcol(ct)},ColumnLabelStyle)
         end
      end
   end
   
   % Adjust position of background axes labels
   % RE: Still needed for empty axis (no data -> no LimitChanged event)
   labelpos(this)
end
