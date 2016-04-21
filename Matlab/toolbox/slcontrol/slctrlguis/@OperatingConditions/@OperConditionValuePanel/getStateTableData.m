function table_data = getStateTableData(this);
%getStateTableData  Method to get the current Simulink linearization State 
%                settings for the State table in the GUI.

%  Author(s): John Glass
%  Copyright 1986-2003 The MathWorks, Inc.

import java.lang.*; 
import java.awt.*;

table_data = javaArray('java.lang.Object',2,1);

states = this.OpPoint.States;

if ~isempty(states)
    %% Get all the number of states
    all_nstates = get(states,{'Nx'});
    total_states = sum([all_nstates{:}]);
    
    %% Create the java object to store the state table data
    state_table = javaArray('java.lang.Object',length(states)+total_states,2);
    %% Create the java object to store the indecies for where each state
    %% begins in the table
    state_ind = javaArray('java.lang.Integer',length(states),1);
    
    %% Initialize the counter
    counter = 1;
    
    for ct1 = 1:length(states)
        %% Enter the state name
        if isa(states(ct1),'opcond.StatePoint')
            state_table(counter,1) = String(regexprep(states(ct1).Block,'\n',' '));
        else
            state_table(counter,1) = String(regexprep(states(ct1).SimMechBlock,'\n',' '));
        end
        %% Enter the index in Java array units
        state_ind(ct1,1) = Integer(counter - 1);
        %% Put in dummy data
        state_table(counter,2) = String('0');
        %% Increment the counter
        counter = counter + 1;
        for ct2 = 1:states(ct1).Nx
            state_table(counter,1) = String(sprintf('State - %d',ct2));
            state_table(counter,2) = String(num2str(states(ct1).x(ct2)));
            counter = counter + 1;
        end
    end    
else
    %% Return that there are no states in the Simulink model
    state_table = javaArray('java.lang.Object',1,2);
    %% Return the index which is zero
    state_ind = javaArray('java.lang.Integer',1,1);
    state_ind(1,1) = Integer(0);
    state_table(1,1) = String('The model has no states');
end

table_data(1) = state_table;
table_data(2) = state_ind;