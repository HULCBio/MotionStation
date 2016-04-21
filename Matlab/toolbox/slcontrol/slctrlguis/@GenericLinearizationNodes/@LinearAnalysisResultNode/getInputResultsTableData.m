function table_data = getInputResultsTableData(this,Index);
%getinputTableData  Method to get the current Simulink linearization input 
%                settings for the input table in the GUI.

%  Author(s): John Glass
%  Copyright 1986-2003 The MathWorks, Inc.

import java.lang.*; 
import java.awt.*;

table_data = javaArray('java.lang.Object',2,1);

%% Get the index of the selected model
inputs = this.OpCondData(Index).inputs;

%% Get the desired operating condition information
opdata = this.OpConstrData;
%% Get the state information
if ~isempty(opdata)
    inputsdes = opdata.inputs;
else
    inputsdes = [];
end
    
if ~isempty(inputs)
    %% Get all the number of inputs
    all_ninputs = get(inputs,{'PortWidth'});
    total_inputs = sum([all_ninputs{:}]);
    
    %% Create the java object to store the input table data
    input_table = javaArray('java.lang.Object',length(inputs)+total_inputs,3);
    %% Create the java object to store the indecies for where each input
    %% begins in the table
    input_ind = javaArray('java.lang.Integer',length(inputs),1);
    
    %% Initialize the counter
    counter = 1;
    
    for ct1 = 1:length(inputs)
        %% Enter the input name
        input_table(counter,1) = String(regexprep(inputs(ct1).Block,'\n',' '));
        %% Enter the index in Java array units
        input_ind(ct1,1) = Integer(counter - 1);
        %% Put in dummy data
        input_table(counter,2) = String('0');
        input_table(counter,3) = String('0');
        %% Increment the counter
        counter = counter + 1;
        for ct2 = 1:inputs(ct1).PortWidth
            input_table(counter,1) = String(sprintf('input - %d',ct2));
            if (isempty(inputsdes))
                input_table(counter,2) = String('N/A');
            elseif (inputsdes(ct1).Known(ct2))
                input_table(counter,2) = String(num2str(inputsdes(ct1).Value(ct2)));
            else
                input_table(counter,2) = String(['[ ',...
                        num2str(inputsdes(ct1).LowerBound(ct2)),...
                        ' , ',...
                        num2str(inputsdes(ct1).UpperBound(ct2)),...
                        ' ]']);
            end
            input_table(counter,3) = String(num2str(inputs(ct1).Value(ct2)));
            counter = counter + 1;
        end
    end    
else
    %% Return that there are no inputs in the Simulink model
    input_table = javaArray('java.lang.Object',1,3);
    %% Return the index which is zero
    input_ind = javaArray('java.lang.Integer',1,1);
    input_ind(1,1) = Integer(0);
    input_table(1,1) = String(sprintf('The model % has no inputs',this.Model));
    input_table(1,2) = String('');
    input_table(1,3) = String('');
end

table_data(1) = input_table;
table_data(2) = input_ind;