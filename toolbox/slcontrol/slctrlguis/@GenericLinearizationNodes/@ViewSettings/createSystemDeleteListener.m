function createSystemDeleteListener(this)

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2004/03/10 21:51:41 $

%% Create the delete listener
this.DeleteViewListeners = handle.listener(this.LTIViewer,...
                                this.LTIViewer.findprop('Systems'),...
                                'PropertyPostSet',{@LocalSystemDeleted, this});
                                
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalSystemDeleted - Determine if a system has been deleted by a user 
%%                      in the LTIViewer
function LocalSystemDeleted(es,ed,this)

NUMBER_OF_PLOTS = 6;

%% Disable the table data changed callback
DataChangedFcn = get(this.VisibleResultTableModelUDD,'TableChangedCallback');
set(this.VisibleResultTableModelUDD,'TableChangedCallback',[]);

%% Loop over all the analysis results to see what systems have been deleted
for ct = 1:size(this.AnalysisResultPointers,1)
    if ~isempty(this.AnalysisResultPointers{ct,2})
        ind = find(this.AnalysisResultPointers{ct,2} == this.LTIViewer.Systems);
        if isempty(ind)
            this.AnalysisResultPointers{ct,2} = handle(0);
            for ct2 = 2:NUMBER_OF_PLOTS+1
                %% Update the table data
                this.VisibleResultTableModelUDD.data(ct,ct2) = java.lang.Boolean(false);
            end
        end
    end
end

%% Fire the table update event
evt = javax.swing.event.TableModelEvent(this.VisibleResultTableModelUDD);
awtinvoke(this.VisibleResultTableModelUDD, 'fireTableChanged',evt);

%% Disable the table data changed callback
set(this.VisibleResultTableModelUDD,'TableChangedCallback',DataChangedFcn);