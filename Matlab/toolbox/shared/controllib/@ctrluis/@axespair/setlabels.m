function setlabels(this,varargin)
%SETLABELS  Updates visibility, style, and contents of HG labels.

%   Author: P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:17:36 $

vis = strcmp(this.Visible,'on') & strcmp(this.RowVisible,'on');
visax = this.Axes2d(vis);

% Conditional label visibility
if ~isempty(visax)
   % Get labels
   LabelMap = feval(this.LabelFcn{:});
   % Left labels
   set(visax,'YtickLabelMode','auto')
   ylab = hglabel(this,'YLabel');
   if ischar(LabelMap.YLabel)
      set(ylab(vis),'String',LabelMap.YLabel,struct(LabelMap.YLabelStyle))
   else
      set(ylab(vis),{'String'},LabelMap.YLabel(vis),struct(LabelMap.YLabelStyle))
   end
   % Top labels
   set(get(visax(1),'Title'),'String',this.Title,struct(this.TitleStyle))
   % Bottom labels
   visax(end).XtickLabelMode = 'auto';
   set(get(visax(end),'XLabel'),'String',LabelMap.XLabel,struct(LabelMap.XLabelStyle))
   % Between axes
   if length(visax)==2
      % No x and tick labels on upper axes
      visax(1).XtickLabel = [];
      set(visax(1).XLabel,'String','');
      set(visax(2).Title,'String','');
   end
end
