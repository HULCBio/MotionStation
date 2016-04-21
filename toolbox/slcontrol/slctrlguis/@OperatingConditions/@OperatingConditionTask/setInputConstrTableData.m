function setInputConstrTableData(this,Data,InputIndecies,row,col);
%% setInputConstrTableData  Method to update the Simulink model with changes to the
%%                   input operating condition properties in the GUI.

%%  Author(s): John Glass
%%  Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $ $Date: 2004/04/11 00:36:59 $

import java.lang.* java.awt.*;

inputs = this.OpSpecData.Inputs;

% Convert to Matlab data types
mInputIndecies = LocalConvertToMatlabInteger(InputIndecies);
% Find the index corresponding to the state block being used.
diff_indecies = mInputIndecies-row;
diff_ind = find(diff_indecies <= 0);
inputind = diff_ind(end);
ind = row-mInputIndecies(inputind);

%% Set the properties
switch col
    case 2
        inputs(inputind).Known(ind) = double(Data(row+1,col+1));
        this.InputSpecTableData(row+1,col+1) = Boolean(Data(row+1,col+1));
    otherwise
        %% Set the data in the task node object
        this.InputSpecTableData(row+1,col+1) = String(Data(row+1,col+1));
end

%% Set the dirty flag
this.setDirty

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Function to convert the java integer array to a Matlab array
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function array = LocalConvertToMatlabInteger(javaarray)

array = zeros(length(javaarray),1);

for ct = 1:length(javaarray)
    array(ct) = intValue(javaarray(ct,1));
end
