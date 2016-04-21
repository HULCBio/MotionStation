function DisplayView(this);
%DisplayView  Method to display the current view if it has been deleted 
%             of if it is at the bottom of the stack of windows.

%  Author(s): John Glass
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.7 $ $Date: 2004/04/11 00:35:59 $

if isa(this.LTIViewer,'viewgui.ltiviewer')
    figure(double(this.LTIViewer.Figure));
else
    %% Get the plot configurations
    plotconfigs = this.PlotConfigurations(:,2);
    ind_config = find(~strcmp(plotconfigs,'None'));
    plottype = plotconfigs(ind_config);
    
    %% Check to see that a plot is being created
    if isempty(plottype)
        errordlg('Please select a plot type.','Simulink Control Design');
        return
    end
    
    %% Create the ltiviewer
    [Viewer,ltiviewer] = ltiview(plottype);
    this.LTIViewer = ltiviewer;
    
    %% Store the current set of viewers
    this.ViewHandles = ltiviewer.Views;
    
    %% Add the view listener
    this.ViewListener = handle.listener(ltiviewer,ltiviewer.findprop('Views'),...
                        'PropertyPostSet',{@LocalViewsChanged, this});
                       
    %% Get the visible results table data
    vis_td = this.VisibleResultTableModelUDD.data;
    
    %% Get the Linearization Results Nodes
    ResultsNodes = LocalFindAnalysisResultsChildren(this.up.up.getChildren);
    
    %% Add the analysis results to the view    
    %% ct corresponsed to the current index into the analysis result vector
    for ct = 1:size(vis_td,1)
        %% Compute the sum of the row of plot visibility checkboxes
        cellrow = cell(vis_td(ct,2:7));
        if (sum([cellrow{:}]) > 0)
            sys = ResultsNodes(ct).LinearizedModel;
            ltiviewer.importsys(sprintf('%s',ResultsNodes(ct).Label),sys);
            %% Store a pointer to the ltisource for tracking later
            this.AnalysisResultPointers{ct,2} = this.LTIViewer.Systems(end);
            %% Turn off the invisible systems plots
            PlotCells = ltiviewer.PlotCells;            
            for ct1 = 1:length(PlotCells)                
                if ~vis_td(ct,ct1+1)
                    Cell = PlotCells{ct1};
                    for ct2 = 1:length(Cell)
                        Cell(ct2).Responses(ct).Visible = 'off';
                    end
                end
            end
        end
    end    
    
    %% Update the titles
    for ct = 1:length(plottype)
        table_row = ind_config(ct);
        ltiviewer.Views(ct).AxesGrid.Title = this.PlotConfigurations{table_row,3};
    end
    
    %% Create the plot visibility listeners.  Create a listener upon need
    this.PlotVisbilityListeners = handle(zeros(6,1));
    createVisibilityListeners(this)
    
    %% Create the system delete listener
    createSystemDeleteListener(this)
    
    %% Add listener to the AxesGrids of the views for title changes                 
    createTitleListener(this) 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalViewsChanged
function LocalViewsChanged(es,ed,this);

import java.lang.*;

%% Get the current view configurations in the ltiviewer
ViewConfigs = ed.NewValue;
%% Get the previous configurations in the ltiviewer
OldViewConfigs = this.ViewHandles;

%% Get the indecies of the rows of the table that are active
plotconfigs = this.PlotConfigurations(:,2);
active_ind = find(~strcmp(plotconfigs,'None'));
    
%% Disable the listeners
this.ViewListener.Enabled = 'off';
this.TitleListener.Enabled = 'off';

%% Disable the table data changed callback
DataChangedFcn = get(this.PlotSetupTableModelUDD,'TableChangedCallback');
set(this.PlotSetupTableModelUDD,'TableChangedCallback',[]);

%% Loop over them and set their new values
for ct = 1:length(ViewConfigs)
    table_ind = ct;
    if ~strcmp(class(ViewConfigs(ct)),'handle')
        switch ViewConfigs(ct).tag
            case 'step'
                this.PlotConfigurations{table_ind,2}  = 'step';
                this.PlotSetupTableModelUDD.data(table_ind,2) = String('Step Response Plot');
            case 'bode'
                this.PlotConfigurations{table_ind,2}  = 'bode';
                this.PlotSetupTableModelUDD.data(table_ind,2) = String('Bode Response Plot');
            case 'nichols'
                this.PlotConfigurations{table_ind,2}  = 'nichols';
                this.PlotSetupTableModelUDD.data(table_ind,2) = String('Nichols Plot');
            case 'nyquist'
                this.PlotConfigurations{table_ind,2}  = 'nyquist';
                this.PlotSetupTableModelUDD.data(table_ind,2) = String('Nyquist Plot');
            case 'pzmap'
                this.PlotConfigurations{table_ind,2}  = 'pzmap';
                this.PlotSetupTableModelUDD.data(table_ind,2) = String('Pole Zero Map');
            case 'iopzmap'
                this.PlotConfigurations{table_ind,2}  = 'iopzmap';
                this.PlotSetupTableModelUDD.data(table_ind,2) = String('IO Pole Zero Map');
            case 'impulse'
                this.PlotConfigurations{table_ind,2}  = 'impulse';
                this.PlotSetupTableModelUDD.data(table_ind,2) = String('Impulse Response');
            case 'bodemag'
                this.PlotConfigurations{table_ind,2}  = 'bodemag';
                this.PlotSetupTableModelUDD.data(table_ind,2) = String('Bode Magnitude Plot');
            case 'sigma'
                this.PlotConfigurations{table_ind,2}  = 'sigma';
                this.PlotSetupTableModelUDD.data(table_ind,2) = String('Singular Value Plot');
        end
        %% Set the plot title
        this.PlotSetupTableModelUDD.data(table_ind,3) = String(ViewConfigs(ct).AxesGrid.Title);
    else
        %% Turn off configurations that may have been turned off by the
        %% Plot Configurations Dialog.
        this.PlotConfigurations{table_ind,2} = 'None';
        this.PlotSetupTableModelUDD.data(table_ind,2) = String('None');
        %% Set the plot title to be empty
        this.PlotSetupTableModelUDD.data(table_ind,3) = String('');
    end
end

%% Update the visibility columns
updateVisibleSystemsColumns(this,1:length(ViewConfigs))

%% Fire the table update event
evt = javax.swing.event.TableModelEvent(this.PlotSetupTableModelUDD);
awtinvoke(this.PlotSetupTableModelUDD, 'fireTableChanged',evt);

%% Renable the listener
this.ViewListener.Enabled = 'on';
this.TitleListener.Enabled = 'on';

%% Add listener to the AxesGrids of the views for title changes
createTitleListener(this)
%% Update the listeners for the visible systems
createVisibilityListeners(this)

%% Renable the table data changed callback
set(this.PlotSetupTableModelUDD,'TableChangedCallback',DataChangedFcn);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalFindAnalysisResultsChildren
function Children = LocalFindAnalysisResultsChildren(Children);

%% Loop over all the elements to remove the not of the class
%% GenericLinearizationNodes.LinearAnalysisResultNode
for ct = length(Children):-1:1
    if ~isa(Children(ct),'GenericLinearizationNodes.LinearAnalysisResultNode')
        Children(ct) = [];    
    end
end
