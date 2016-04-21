function setInputTableData(this,row,col);
%setInputTableData  Method to update the Simulink model with changes to the
%                   input operating condition properties in the GUI.

%  Author(s): John Glass
%  Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $ $Date: 2004/04/11 00:36:39 $

import java.lang.* java.awt.*;

inputs = this.OpPoint.Inputs;

% Convert to Matlab data types
mInputIndecies = LocalConvertToMatlabInteger(this.InputIndecies);
% Find the index corresponding to the state block being used.
diff_indecies = mInputIndecies-row;
diff_ind = find(diff_indecies <= 0);
inputind = diff_ind(end);
ind = row-mInputIndecies(inputind);

%% Set the properties 
switch col
    case 1
        var = str2num(this.InputTableData(row+1,col+1));
        if length(var) == 1
            inputs(inputind).u(ind) = var;
        end
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
