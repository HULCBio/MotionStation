function table_data = getInputTableData(this);
%getInputTableData  Method to get the current Simulink linearization Input 
%                   settings for the Input table in the GUI.

%  Author(s): John Glass
%  Copyright 1986-2003 The MathWorks, Inc.

import java.lang.* java.awt.*;

table_data = javaArray('java.lang.Object',2,1);

inputs = this.OpPoint.Inputs;

if ~isempty(inputs)
    %% Get all the number of inputs
    all_ninputs = get(inputs,{'PortWidth'});
    total_inputs = sum([all_ninputs{:}]);
    
    %% Create the java object to store the inputs table data
    input_table = javaArray('java.lang.Object',length(inputs)+total_inputs,2);
    %% Create the java object to store the indecies for where each input
    %% begins in the table
    input_ind = javaArray('java.lang.Integer',length(inputs),1);
    
    %% Initialize the counter
    counter = 1;
    
    for ct1 = 1:length(inputs)
        %% Enter the state name
        input_table(counter,1) = String(regexprep(inputs(ct1).Block,'\n',' '));
        %% Enter the index in Java array units
        input_ind(ct1,1) = Integer(counter - 1);
        %% Put in dummy data
        input_table(counter,2) = String('0');
        %% Increment the counter
        counter = counter + 1;
        for ct2 = 1:inputs(ct1).PortWidth
            input_table(counter,1) = String(sprintf('Channel - %d',ct2));
            input_table(counter,2) = String(num2str(inputs(ct1).u(ct2)));
            counter = counter + 1;
        end
    end    
else
    %% Return that there are no inputs in the Simulink model
    input_table = javaArray('java.lang.Object',1,2);
    %% Return the index which is zero
    input_ind = javaArray('java.lang.Integer',1,1);
    input_ind(1,1) = Integer(0);
    input_table(1,1) = String(sprintf('The model %s has no inputs',this.Model));
end

table_data(1) = input_table;
table_data(2) = input_ind;