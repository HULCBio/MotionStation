function Contents = getViewerContents(sisodb)
%GETVIEWERCONTENTS  Queries current configuration of the SISO Tool LTI Viewer.
%
%   CONTENTS = GETVIEWERCONTENTS(SISODB) reads the current configuration of 
%   the SISO Tool LTI Viewer.  CONTENTS is a struct array with as many entries 
%   as plot, and fields
%     * PlotType:      a string specifying the plot type (alias)
%     * VisibleModels: the list of visible responses (specified as
%                      model aliases such as $T_ry).
%
%   See also SISOTOOL.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2002/05/04 02:11:08 $

ViewerObj = sisodb.AnalysisView;
if isempty(ViewerObj) || ~ishandle(ViewerObj)
   Contents = struct('PlotType',cell(0,1),'VisibleModels',[]);
else
   Contents = getContents(ViewerObj);
end