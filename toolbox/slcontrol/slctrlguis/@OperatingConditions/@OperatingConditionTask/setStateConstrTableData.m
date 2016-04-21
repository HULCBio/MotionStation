function setStateConstrTableData(this,Data,StateIndecies,row,col);
%% setStateTableData  Method to update the Simulink model with changes to the
%%                   state operating condition properties in the GUI.

%%  Author(s): John Glass
%%  Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $ $Date: 2004/04/11 00:37:03 $

import java.lang.* java.awt.*;

states = this.OpSpecData.States;

%% Convert to Matlab data types
mStateIndecies = LocalConvertToMatlabInteger(StateIndecies);
%% Find the index corresponding to the state block being used.
diff_indecies = mStateIndecies-row;
diff_ind = find(diff_indecies <= 0);
stateind = diff_ind(end);
ind = row-mStateIndecies(stateind);

%% Check to see if the value is numberic.  Then set the properties. 
switch col
    case 2
        states(stateind).Known(ind) = double(Data(row+1,col+1));
        %% Set the data in the task node object
        this.StateSpecTableData(row+1,col+1) = Boolean(Data(row+1,col+1));
    case 3
        states(stateind).SteadyState(ind) = double(Data(row+1,col+1));
        %% Set the data in the task node object
        this.StateSpecTableData(row+1,col+1) = Boolean(Data(row+1,col+1));
    otherwise
        %% Set the data in the task node object
        this.StateSpecTableData(row+1,col+1) = String(Data(row+1,col+1));
end

%% Set the dirty flag
this.setDirty
    
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Function to convert the java integer array to a Matlab array
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function array = LocalConvertToMatlabInteger(javaarray)

array = zeros(length(javaarray),1);

for ct = 1:length(javaarray)
    array(ct) = intValue(javaarray(ct,1));
end
