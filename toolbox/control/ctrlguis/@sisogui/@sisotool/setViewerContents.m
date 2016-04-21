function setViewerContents(sisodb,Contents)
%SETVIEWERCONTENTS  Configures the SISO Tool LTI Viewer.
%
%   SETVIEWERCONTENTS(SISODB,CONTENTS) opens and configures the LTI Viewer to 
%   show the responses specified in CONTENTS.  CONTENTS is a struct 
%   array with as many entries as plot, and fields
%     * PlotType:      a string specifying the plot type (alias)
%     * VisibleModels: the list of visible responses (specified as
%                      model aliases such as $T_ry).
%
%   See also SISOTOOL.

%   Author(s): K. Gondoly and P. Gahinet
%   Revised  : Kamesh Subbarao
%   Copyright 1986-2002 The MathWorks, Inc.
%   $Revision: 1.27 $  $Date: 2002/04/04 15:19:56 $

% If no Viewer is opened yet, open one
ViewerObj = sisodb.AnalysisView;
if isempty(ViewerObj) | ~ishandle(ViewerObj)
   ViewerObj = viewgui.SisoToolViewer(sisodb);
   sisodb.AnalysisView = ViewerObj;
end
   
% Set contents
ViewerObj.setContents(Contents);

% Make it visible
% RE: Beware that listener to figure visibility always gets fired
if strcmp(get(ViewerObj.Figure,'Visible'),'off')
   set(ViewerObj.Figure,'Visible','on')
end