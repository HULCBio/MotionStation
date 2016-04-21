function createTitleListener(this) 

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/03/24 21:09:40 $

%% Get the plot configurations
plotconfigs = this.PlotConfigurations(:,2);
ind_config = find(~strcmp(plotconfigs,'None'));

%% Add listener to the AxesGrids of the views.  Do not add if there are no
%% plots visible.
if ~isempty(ind_config)
    AxGrid = get(this.LTIViewer.Views(1:length(ind_config)),{'AxesGrid'});
    this.TitleListener = handle.listener([AxGrid{:}],AxGrid{1}.findprop('Title'),...
        'PropertyPostSet',{@LocalTitleChanged, this});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalTitleChanged
function LocalTitleChanged(es,ed,this);

import java.lang.*;

%% Disable the table data changed callback
DataChangedFcn = get(this.PlotSetupTableModelUDD,'TableChangedCallback');
set(this.PlotSetupTableModelUDD,'TableChangedCallback',[]);

%% Get the indecies of the rows of the table that are active
plotconfigs = this.PlotConfigurations(:,2);
active_ind = find(~strcmp(plotconfigs,'None'));

%% Get the handles to the axesgrids
AxGrid = get(this.ltiviewer.Views(1:length(active_ind)),{'AxesGrid'});
%% Find the index to the axesgrid that has changed
ind = find(ed.AffectedObject==[AxGrid{:}]);
%% Set the plot title
this.PlotSetupTableModelUDD.data(active_ind(ind),3) = String(ed.AffectedObject.Title);
%% Fire the table update event
thr = com.mathworks.toolbox.control.spreadsheet.MLthread(...
            this.PlotSetupTableModelUDD, 'fireTableCellUpdated',...
            {int32(active_ind(ind)-1); int32(2)},'int,int');
javax.swing.SwingUtilities.invokeLater(thr);

%% Renable the table data changed callback
set(this.PlotSetupTableModelUDD,'TableChangedCallback',DataChangedFcn);