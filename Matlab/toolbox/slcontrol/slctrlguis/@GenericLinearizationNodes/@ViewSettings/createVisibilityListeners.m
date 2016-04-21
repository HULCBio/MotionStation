function createVisibilityListeners(this)

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/03/24 21:09:41 $

%% Get the plot configurations
plotconfigs = this.PlotConfigurations(:,2);
ind_config = find(~strcmp(plotconfigs,'None'));
    
for ct = 1:length(ind_config)
    if ~isempty(this.LTIViewer.Views(ct).Responses)
        this.PlotVisbilityListeners(ind_config(ct)) = handle.listener(...
            this.LTIViewer.Views(ct).Responses,...
            this.LTIViewer.Views(ct).Responses(1).findprop('Visible'),...
            'PropertyPostSet',{@LocalResponseVisabilityChanged, this,...
            this.LTIViewer.Views(ct).Responses,ind_config(ct)});
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalResponseVisabilityChanged
function LocalResponseVisabilityChanged(es,ed,this,responses,table_ind);

import java.lang.*;

%% Disable the table data changed callback
DataChangedFcn = get(this.VisibleResultTableModelUDD,'TableChangedCallback');
set(this.VisibleResultTableModelUDD,'TableChangedCallback',[]);

%% Find the response index
resp_ind = find(ed.AffectedObject==responses);
%% Get the ltisource that matches the index
source = this.LTIViewer.Systems(resp_ind);
%% Get the corresponding pointers in the table
result_pointers = [this.AnalysisResultPointers{:,2}];
%% Get the matching index to the table
resp_ind = find(source == result_pointers);

%% Update the table data
this.VisibleResultTableModelUDD.data(resp_ind,table_ind+1) = Boolean(onoff2bool(ed.NewValue));
%% Fire the table update event
thr = com.mathworks.toolbox.control.spreadsheet.MLthread(...
            this.VisibleResultTableModelUDD, 'fireTableCellUpdated',...
            {int32(resp_ind-1); int32(table_ind)},'int,int');
javax.swing.SwingUtilities.invokeLater(thr);

%% Renable the table data changed callback
set(this.VisibleResultTableModelUDD,'TableChangedCallback',DataChangedFcn);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Local Functions
function boolval = onoff2bool(onoffval)
if strcmp(onoffval,'on');
    boolval = true;
else
    boolval = false;
end
    
function onoffval = bool2onoff(boolval)
if boolval;
    onoffval = 'on';
else
    onoffval = 'off';
end