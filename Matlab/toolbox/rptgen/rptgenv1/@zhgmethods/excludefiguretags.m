function badTags=excludefiguretags(z)
%EXCLUDEFIGURETAGS returns tags the report generator should not report on
%   TAGLIST=EXCLUDEFIGURETAGS(ZHGMETHODS) returns a list of
%   figure tags which the Report Generator is "not interested in".
%   These tags are excluded from the figure loop, cleanup, and 
%   other applications.

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:17:39 $

badTags={
   'Setup File Editor' %--------report generator figures
   'rptlistFigure'
   'rptconvert_Figure'
   'rptgen_compwiz_Figure'
   'RPTGEN_SETFILE_FIGURE'
   'RPTGEN_COMPONENT_CLIPBOARD'
   'SFCHART' %-----stateflow figures
   'DEFAULT_SFCHART'
   'SFEXPLR'
   'SF_DEBUGGER'
   'SF_SAFEHOUSE'
   'SF_VIEWER'
   'SF_RG_Viewer'
   'SIMULINK_XYGRAPH_FIGURE' %----simulink figures
   'SIMULINK_SIMSCOPE_FIGURE'
   'SIMULINK_SLCHANGELOG'
};
