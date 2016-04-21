function tablearray = getResultsTableData(this);
%getResultsTableData  Method to get the current Simulink linearization  
%                     results for the GUI.

%  Author(s): John Glass
%  Copyright 1986-2003 The MathWorks, Inc.

import java.lang.*; 
import java.awt.*;

states = this.TrimCondition(1).States;
inputs = this.TrimCondition(1).Inputs;
outputs = this.TrimCondition(1).Outputs;

tablearray = javaArray('java.lang.Object',3);

if length(states) > 0
    statetable = javaArray('java.lang.Object',length(states),3);
    ind = 1;
    for ct1 = 1:length(states)
        for ct2 = 1:length(states(ct1).Value)
            if ct2 == 1
                statetable(ind,1) = String(states(ct1).Block);
            else 
                statetable(ind,1) = String('');
            end             
            statetable(ind,2) = String(num2str(states(ct1).Value(ct2)));
            statetable(ind,3) = String(num2str(states(ct1).dx(ct2)));
            ind = ind + 1;
        end
    end
end

if length(inputs) > 0
    inputtable = javaArray('java.lang.Object',length(inputs),2);
    ind = 1;
    for ct1 = 1:length(inputs)
        for ct2 = 1:inputs(ct1).PortWidth
            if ct2 == 1
                inputtable(ind,1) = String(inputs(ct1).Block);
            else 
                inputtable(ind,1) = String('');
            end    
            inputtable(ind,2) = String(num2str(inputs(ct1).Value(ct2)));
            ind = ind + 1;    
        end    
    end
end

if length(outputs) > 0
    outputtable = javaArray('java.lang.Object',length(outputs),2);
    ind = 1;
    for ct1 = 1:length(outputs)
        for ct2 = 1:outputs(ct1).PortWidth
            if ct2 == 1
                outputtable(ind,1) = String(outputs(ct1).Block);
            else 
                outputtable(ind,1) = String('');
            end
            outputtable(ind,2) = String(num2str(outputs(ct1).Value(ct2)));
            ind = ind + 1;    
        end
    end
end

tablearray(1,1) = statetable;
tablearray(2,1) = inputtable;
tablearray(3,1) = outputtable;
