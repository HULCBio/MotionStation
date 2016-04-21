function table_data = getOutputTableData(this);
%getOutputTableData  Method to get the current Simulink linearization Output 
%                   settings for the Output table in the GUI.

%  Author(s): John Glass
%  Copyright 1986-2003 The MathWorks, Inc.

import java.lang.* java.awt.*;

table_data = javaArray('java.lang.Object',2,1);

outputs = this.OpSpecData.Outputs;

if ~isempty(outputs)
    %% Get all the number of outputs
    all_noutputs = get(outputs,{'PortWidth'});
    total_outputs = sum([all_noutputs{:}]);
    
    %% Create the java object to store the outputs table data
    output_table = javaArray('java.lang.Object',length(outputs)+total_outputs,5);
    %% Create the java object to store the indecies for where each output
    %% begins in the table
    output_ind = javaArray('java.lang.Integer',length(outputs),1);
    
    %% Initialize the counter
    counter = 1;
    
    for ct1 = 1:length(outputs)
        %% Enter the state name
        output_table(counter,1) = String(regexprep(outputs(ct1).Block,'\n',' '));
        %% Enter the index in Java array units
        output_ind(ct1,1) = Integer(counter - 1);
        %% Put in dummy data
        output_table(counter,2) = String('0');
        output_table(counter,3) = java.lang.Boolean(0);
        output_table(counter,4) = String('0');
        output_table(counter,5) = String('0');
        %% Increment the counter
        counter = counter + 1;
        for ct2 = 1:outputs(ct1).PortWidth
            output_table(counter,1) = String(sprintf('Channel - %d',ct2));
            output_table(counter,2) = String(num2str(outputs(ct1).y(ct2)));
            output_table(counter,3) = java.lang.Boolean(outputs(ct1).Known(ct2));
            output_table(counter,4) = String(num2str(outputs(ct1).Min(ct2)));
            output_table(counter,5) = String(num2str(outputs(ct1).Max(ct2)));
            counter = counter + 1;
        end
    end    
else
    %% Return that there are no outputs in the Simulink model
    output_table = javaArray('java.lang.Object',1,5);
    %% Return the index which is zero
    output_ind = javaArray('java.lang.Integer',1,1);
    output_ind(1,1) = Integer(0);
    output_table(1,1) = String(sprintf('The model %s has no outputs',this.Model));
    output_table(1,2) = String('');
    output_table(1,3) = java.lang.Boolean(0);
    output_table(1,4) = String('');
    output_table(1,5) = String('');
end

table_data(1) = output_table;
table_data(2) = output_ind;