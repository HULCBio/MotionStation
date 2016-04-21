function load(sisodb,SavedData)
%LOAD   Reloads SISO Tool session.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.17.4.1 $  $Date: 2002/09/01 23:06:55 $

% Hide editors (prevents updating until all settings are restored)
set(sisodb.PlotEditors,'Visible','off')
% Temporary fix to work around uitool segv at this time g142004
drawnow;

% Restore session preferences
sisodb.Preferences.load(SavedData.Preferences);

% REVISIT: replace this by a try/catch with transaction rollback
if ~isfield(SavedData.LoopData,'Compensator')
   % Invalid second argument
   error('Invalid session data.')
else
   % Upgrade saved data from previous versions
   SavedData = LocalUpgrade(SavedData);
end

% Record data load
LoopData = sisodb.LoopData;
T = ctrluis.transaction(LoopData,'Name','Load Session',...
    'OperationStore','on','InverseOperationStore','on');

% Load loop data and notify peers (e.g., Current Compensator frame)
LoopData.load(SavedData.LoopData);
LoopData.dataevent('all');

% Commit transaction
sisodb.EventManager.record(T);

% Restore Editor settings and update plots
Ver = SavedData.Version;
sisodb.PlotEditors(1).load(SavedData.RootLocusEditor,Ver);
sisodb.PlotEditors(2).load(SavedData.OpenLoopBodeEditor,Ver);
sisodb.PlotEditors(3).load(SavedData.NicholsEditor,Ver);
sisodb.PlotEditors(4).load(SavedData.PrefilterBodeEditor,Ver);

% Restore LTI Viewer settings
if ~isempty(SavedData.ViewerContent)
   vc = SavedData.ViewerContent;
   setViewerContents(sisodb,vc);
   % Restore analysis menus state (check mark) 
   Viewer = sisodb.AnalysisView;
   Menus = sisodb.HG.Menus.Analysis.PlotSelection;
   for ct=1:length(vc)
      if ~isempty(vc(ct).SelectedMenu)
         set(Menus(vc(ct).SelectedMenu),'Checked','on')
         Viewer.linkMenu(vc(ct).SelectedMenu,Viewer.Views(ct));
      end
   end
end

% Restore history 
sisodb.EventManager.sethistory(SavedData.History);


%--------------------------- Local Functions ----------------------

function SavedData = LocalUpgrade(SavedData)
% Upgrade from previous versions
if SavedData.Version<=1
   % Added Input Disturbance and Output Disturbance entries to Analysis menu
   SavedData.ResponseMenuState = ...
      [SavedData.ResponseMenuState(1);{'off'};SavedData.ResponseMenuState(3:5)];
   % New ViewerContent format
   nviews = length(SavedData.ViewerContent);
   if nviews>0
      vismod = cell(nviews,1);
      for ct=1:nviews
         vismod{ct} = [SavedData.ViewerContent(ct).OpenLoop ; SavedData.ViewerContent(ct).ClosedLoop];
      end
      SavedData.ViewerContent = struct('PlotType',{SavedData.ViewerContent.PlotType}',...
         'VisibleModels',vismod,'SelectedMenu',[]);
   end
end