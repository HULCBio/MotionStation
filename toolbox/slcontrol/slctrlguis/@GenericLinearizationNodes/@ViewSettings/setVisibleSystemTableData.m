function setVisibleSystemTableData(this, row, col);
%setVisibleSystemTableData  Method to update the visible systems in a view table

%  Author(s): John Glass
%  Copyright 1986-2004 The MathWorks, Inc.

import java.lang.* java.awt.*;

NUMBER_OF_PLOTS = 6;

%% Make the column and rows to be in MATLAB units instead of Java
col = col+1;
row = row+1;

%% Do not update the viewer if the first column is updated since this is
%% the label column
if col > 1
    %% Get the LTIViewer
    ltiviewer = this.LTIViewer;
    
    %% Get the new data 
    newdata = this.VisibleResultTableModelUDD.data(row,col);
    %% Store the new data to be saved
    this.VisibleResultTableData = this.VisibleResultTableModelUDD.data;
    
    if isa(ltiviewer,'viewgui.ltiviewer')
        AnalysisResultPointers = this.AnalysisResultPointers;
        %% Find the index into the ltisource for the system to set the
        %% visibility.  If one does not exist create one.
        if isa(AnalysisResultPointers{row,2},'resppack.ltisource')
            ind = find(AnalysisResultPointers{row,2} == ltiviewer.Systems);
            %% Compute the plot cell index
            cellind = sum([this.VisibleTableColumns{1:col-1,2}]);
            PlotCells = ltiviewer.PlotCells{cellind};
            for ct = 1:length(PlotCells)
                PlotCells(ct).Responses(ind).Visible = bool2onoff(newdata);
            end
        else
            Result = AnalysisResultPointers{row,1};
            ltiviewer.importsys(sprintf('%s',Result.Label),Result.LinearizedModel);            
            this.AnalysisResultPointers{row,2} = ltiviewer.Systems(end);
            
            %% Turn on the visility for all plots for this result
            this.ViewListener.Enabled = 'off';
            
            %% Disable the table data changed callback
            DataChangedFcn = get(this.VisibleResultTableModelUDD,'TableChangedCallback');
            set(this.VisibleResultTableModelUDD,'TableChangedCallback',[]);

            %% Update the table data
            for ct = 2:NUMBER_OF_PLOTS+1
                this.VisibleResultTableModelUDD.data(row,ct) = java.lang.Boolean(true);
            end
            
            %% Fire the table update event
            evt = javax.swing.event.TableModelEvent(this.VisibleResultTableModelUDD);
            awtinvoke(this.VisibleResultTableModelUDD, 'fireTableChanged',evt);
            
            %% Update the listeners for the visible systems
            createVisibilityListeners(this)
            %% Re-Enable the visible result table callback 
            set(this.VisibleResultTableModelUDD,'TableChangedCallback',DataChangedFcn);
        end
    end
end

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
    
        
