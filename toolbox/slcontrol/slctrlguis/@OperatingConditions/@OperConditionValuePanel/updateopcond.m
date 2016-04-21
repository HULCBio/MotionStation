function updateopcond(this)
%  Author(s): John Glass
%  Revised:
% Copyright 1986-2003 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2003/12/04 02:37:40 $

%% STATES
%% Get the states
states = this.OpPoint.States;

%% Convert to Matlab data types
mStateIndecies = LocalConvertToMatlabInteger(this.StateIndecies);

%% Get the tabledata
Data = this.StateCondTableModelUDD.data;

%% Set the state values
for ct1 = 1:length(states)
    for ct2 = 1:states(ct1).Nx
        try
            data = evalin('base', Data(mStateIndecies(ct1)+ct2,2));
            if length(data) == 1
                states(ct1).x(ct2) = data;
            else
                error('Invalid length')
            end
        catch
            str = sprintf('Invalid workspace variable - %s', Data(mStateIndecies(ct1)+ct2,2));
            error(str);
        end
    end
end

%% INPUTS
%% Get the inputs
inputs = this.OpPoint.Inputs;

%% Convert to Matlab data types
mInputIndecies = LocalConvertToMatlabInteger(this.InputIndecies);

%% Get the tabledata
Data = this.InputCondTableModelUDD.data;

%% Set the input values
for ct1 = 1:length(inputs)
    for ct2 = 1:inputs(ct1).PortWidth
        try
            data = evalin('base', Data(mInputIndecies(ct1)+ct2,2));
            if length(data) == 1
                inputs(ct1).u(ct2) = data;
            else
                error('Invalid length')
            end
        catch
            str = sprintf('Invalid workspace variable - %s', Data(mInputIndecies(ct1)+ct2,2));
            error(str);
        end
    end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Function to convert the java integer array to a Matlab array
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function array = LocalConvertToMatlabInteger(javaarray)

array = zeros(length(javaarray),1);

for ct = 1:length(javaarray)
    array(ct) = intValue(javaarray(ct,1)) + 1;
end