function SavedData = save(sisodb)
%SAVE   Creates SISO Tool backup for Save Session.
%
%   See also SISOTOOL.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.13 $  $Date: 2002/04/10 05:00:04 $

% Version history
% 1.0 -> R12.1
% 2.0 -> R13

% Save Viewer state
ViewerContents = getViewerContents(sisodb);
if ~isempty(ViewerContents)
   % Save menu states
   Menus = handle(sisodb.HG.Menus.Analysis.PlotSelection);
   Viewer = sisodb.AnalysisView;
   ViewerContents(1).SelectedMenu = [];  % Add field to keep track of selected menus
   for ct=1:length(Menus)
      if strcmp(Menus(ct).Checked,'on')
         ViewerContents(Menus(ct).UserData.View==Viewer.Views).SelectedMenu = ct;
      end
   end
end


SavedData = struct(...
    'History',{sisodb.EventManager.gethistory},...
    'Preferences',sisodb.Preferences.save,...
    'LoopData',save(sisodb.LoopData),...
    'RootLocusEditor',sisodb.PlotEditors(1).save,...
    'OpenLoopBodeEditor',sisodb.PlotEditors(2).save,...
    'NicholsEditor',sisodb.PlotEditors(3).save,...
    'PrefilterBodeEditor',sisodb.PlotEditors(4).save,...
    'ViewerContent',ViewerContents,...
    'Version',2.0);