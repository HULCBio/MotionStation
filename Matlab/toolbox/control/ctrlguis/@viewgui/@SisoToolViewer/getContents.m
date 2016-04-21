function Contents = getContents(this)
%GETCONTENTS  Queries current configuration of the SISO Tool LTI Viewer.
%
%   CONTENTS = GETCONTENTS(THIS) reads the current configuration of the 
%   SISO Tool LTI Viewer.  CONTENTS is a struct array with as many entries 
%   as plot, and fields
%     * PlotType:      a string specifying the plot type (alias)
%     * VisibleModels: the list of visible responses (specified as
%                      model aliases such as $T_ry).
%
%   See also SISOTOOL.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2002/05/04 02:10:05 $

RespList = resplist(this.Parent);
ActiveViews = getCurrentViews(this);
ActiveViewTypes = get(ActiveViews,{'Tag'});
Contents = struct('PlotType',ActiveViewTypes(:),'VisibleModels',[]);
for ct=1:length(ActiveViews)
   RespVis = get(ActiveViews(ct).Responses,'Visible');
   Contents(ct).VisibleModels = RespList(strcmp(RespVis,'on'),1);
end
