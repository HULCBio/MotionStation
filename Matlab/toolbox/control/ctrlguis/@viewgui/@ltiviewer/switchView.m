function NewView = switchView(this,ViewLocator,NewType)
%SWITCHVIEW  Switches plot type in given plot area
%
%   NewView = this.switchView(OldView,NewType)
%   NewView = this.switchView(OldViewIndex,NewType)
%
%   Note that the new view has Visible=off to allow for additional
%   initializations before drawing.

%   Author(s): Kamesh Subbarao, P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.11 $  $Date: 2002/05/04 02:09:20 $

if isnumeric(ViewLocator)
   idxView = ViewLocator;
   OldView = this.Views(idxView);
else
   OldView = ViewLocator;
   idxView = find(this.Views==OldView);
end
   
if strcmp(NewType,'none')
   NewView = handle(NaN);
else
   % Check if any view in stack has requested view type
   idx = find(strcmp(NewType,get(this.PlotCells{idxView},'Tag')));
   if isempty(idx)
      % Create new view (Visible='off' initially)
      NewView = this.addview(NewType);
      % Add new view to corresponding view stack
      % REVISIT: simplify 3->1
      PlotCells = this.PlotCells;
      PlotCells{idxView} = [PlotCells{idxView} ; NewView];
      this.PlotCells = PlotCells;
   else
      NewView = this.PlotCells{idxView}(idx);
   end
   
   % Make response visibility of new view conform to old view (only for 
   % responses associated with systems)
   % Find responses previously hidden
   Visible = cell(size(NewView.Responses));
   Visible(:) = {'on'};
   if ishandle(OldView) && ~isempty(OldView.Responses)
      r = find(OldView.Responses,'Visible','off','-not','DataSrc',[]);
      src = get(r,{'DataSrc'});
      [junk,i_off,ib] = intersect(this.Systems,cat(1,src{:}));
      Visible(i_off) = {'off'};
   end
   
   % Make all systems visible except those hidden in previous plot
   % RE: Do not first make all responses visible (will cause redraw 
   %     of all responses)
   set(NewView.Responses,{'Visible'},Visible)
end