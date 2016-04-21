function setNominal(h,opreport)

% Copyright 2003-2004 The MathWorks, Inc.

% Sets nominal data in MPC GUI node to values defined in the specfied
% operating condition report object. Note that this method will always be
% called after adding a model to the MPC project so it is assumed the the
% MPC i/i table is syncronized with the linearization i/o.

% Extract MV inputs and MO outputs from operating condition report object
% Other operating point constraints may or may nor correspond to MD
% linearization inputs. Since there is no way to know, no attempt is made
% to modify the nominal MD or UMD values in the table

%% Get the table data and io data
outtabledata = h.outUDD.CellData;
intabledata = h.inUDD.CellData;
Itablemv = find(strcmp('Manipulated',intabledata(:,2)));

%% If necessary stop the simulation
if ~strcmp(get_param(gcs, 'SimulationStatus'),'stopped')
       feval(opreport.Model,[],[],[],'term')
end
    
%% Loop through each constraint in order and represent the constraint in
%% the input or output table
for k=1:length(opreport.outputs)
    %I = find(opreport.outputs(k).Known);
    
    data = opreport.outputs(k).y;
    I = 1:length(data);
    if ~isempty(I)
        % Is this constraint an MV?
        if strcmp(opreport.outputs(k).Block,h.Block)
            for j=1:length(Itablemv)
                intabledata{Itablemv(j),end} = sprintf('%0.4g',data(I(j)));             
            end
        % Is this constraint an MO? Note that for a linearized Simulink
        % model all output table entries must correspond to Measured
        % outputs
        else
            for j=1:size(outtabledata,1)
                outtabledata{j,end} = sprintf('%0.4g',data(I(j)));
            end
        end
    end
end

%% Write data back to tables
h.InUDD.setCellData(intabledata);
h.OutUDD.setCellData(outtabledata);


