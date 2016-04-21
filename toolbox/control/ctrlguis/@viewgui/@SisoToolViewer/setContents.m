function setContents(this,Contents)
%SETCONTENTS  Configures the SISO Tool LTI Viewer.
%
%   SETCONTENTS(THIS,CONTENTS) configures the LTI Viewer to show the
%   responses specified in CONTENTS.  CONTENTS is a struct array
%   with as many entries as plot, and fields
%     * PlotType:      a string specifying the plot type (alias)
%     * VisibleModels: the list of visible responses (specified as
%                      model aliases such as $T_ry).
%
%   See also SISOTOOL.

%   Author(s): K. Gondoly and P. Gahinet
%   Revised  : Kamesh Subbarao
%   Copyright 1986-2002 The MathWorks, Inc.
%   $Revision: 1.27 $  $Date: 2002/05/04 02:10:00 $

% Configures the LTI Viewer
nplots = length(Contents);
RespList = resplist(this.Parent);

% Update Views list (no event sent and no drawing of new plots)
this.setCurrentViews({Contents.PlotType},'silent')

% Set response visibility for each visible plot
NewVis = cell(length(this.Systems),1);
for ct=1:nplots
   % Compute current and new visibility state for each resp.
   v = this.Views(ct);
   OldVis = get(v.Responses,{'Visible'});
   NewVis(:) = {'off'};
   [junk,ia,ib] = intersect(Contents(ct).VisibleModels,RespList(:,1));
   NewVis(ib) = {'on'};
   idxMisMatch = find(~strcmp(OldVis,NewVis));
   % Update visibility where mismatch
   if length(idxMisMatch)
      % Optimized for performance
      v.AxesGrid.LimitManager = 'off';
      set(v.Responses(idxMisMatch),{'Visible'},NewVis(idxMisMatch))
      % Update limits
      v.AxesGrid.LimitManager = 'on';
      v.AxesGrid.send('ViewChanged')
   end
end

% Make new plots visible and update layout
set(this.Views(1:nplots),'Visible','on')
this.send('ConfigurationChanged')
