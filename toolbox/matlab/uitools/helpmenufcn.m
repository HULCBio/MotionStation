function helpmenufcn(hfig, cmd)
%HELPMENUFCN Implements part of the figure help menu.
%  HELPMENUFCN(H, CMD) invokes help menu command CMD in figure H.
%
%  CMD can be one of the following:
%
%    HelpGraphics
%    HelpPlottingTools
%    HelpAnnotatingGraphs
%    HelpPrintingExport
%    HelpDemos
%    HelpAbout

%  Copyright 1984-2002 The MathWorks, Inc.
%  $Revision: 1.1.6.4 $  $Date: 2004/04/10 23:33:51 $

switch cmd
 case 'HelpmenuPost'
  % FOR INTERNAL USE.
  if isstudent
   if ~isempty(gcbo)
    set(findobj(allchild(gcbo),'tag','figMenuHelpUpdates'), ...
        'visible','off');
   end
  end
 case 'HelpGraphics'
  helpview([docroot '/techdoc/creating_plots/creating_plots.map'],'creating_plots')
 case 'HelpPlottingTools'
  helpview([docroot '/techdoc/creating_plots/creating_plots.map'],'matlab_plotting_tools')
 case 'HelpAnnotatingGraphs'
  helpview([docroot '/techdoc/creating_plots/creating_plots.map'],'annotating_graphs')
 case 'HelpPrintingExport'
  helpview([docroot '/techdoc/creating_plots/creating_plots.map'],'print_collection_intro')
 case 'HelpDemos'
  demo
 case 'HelpAbout'
  uimenufcn(hfig, 'HelpAbout');
end

