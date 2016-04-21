function setStateTableData(this,row,col);
%% setStateTableData  Method to update the Simulink model with changes to the
%%                   state operating condition properties in the GUI.

%%  Author(s): John Glass
%%  Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $ $Date: 2004/04/11 00:36:40 $

import java.lang.* java.awt.*;

states = this.OpPoint.States;

%% Convert to Matlab data types
mStateIndecies = LocalConvertToMatlabInteger(this.StateIndecies);
%% Find the index corresponding to the state block being used.
diff_indecies = mStateIndecies-row;
diff_ind = find(diff_indecies <= 0);
stateind = diff_ind(end);
ind = row-mStateIndecies(stateind);

%% Check to see if the value is numberic.  Then set the properties. 
switch col
    case 1
        var = str2num(this.StateTableData(row+1,col+1));
        if length(var) == 1
            states(stateind).x(ind) = var;
        end
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
