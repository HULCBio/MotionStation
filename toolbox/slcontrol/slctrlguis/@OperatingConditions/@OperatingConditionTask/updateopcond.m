function newopcond = updateopcond(this)
% UPDATEOPCOND - Create a new operating condition specification object
% given the table data.

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2003 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2003/12/04 02:38:03 $

%% Create a copy of the operating spec object
newopcond = copy(this.OpSpecData);

%% STATES
%% Get the states
states = newopcond.States;

%% Convert to Matlab data types
mStateIndecies = LocalConvertToMatlabInteger(this.StateIndecies);

%% Get the tabledata
Data = this.StateConstrTableModelUDD.data;

%% Set the state values
for ct1 = 1:length(states)
    for ct2 = 1:states(ct1).Nx
        %% Value Column
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
        %% Lower Bound Column
        try
            data = evalin('base', Data(mStateIndecies(ct1)+ct2,5));
            if length(data) == 1
                states(ct1).Min(ct2) = data;
            else
                error('Invalid length')
            end
        catch
            str = sprintf('Invalid workspace variable - %s', Data(mStateIndecies(ct1)+ct2,5));
            error(str);
        end        
        %% Upper Bound Column
        try
            data = evalin('base', Data(mStateIndecies(ct1)+ct2,6));
            if length(data) == 1
                states(ct1).Max(ct2) = data;
            else
                error('Invalid length')
            end
        catch
            str = sprintf('Invalid workspace variable - %s', Data(mStateIndecies(ct1)+ct2,6));
            error(str);
        end          
    end
end

%% INPUTS
%% Get the inputs
inputs = newopcond.Inputs;

%% Convert to Matlab data types
mInputIndecies = LocalConvertToMatlabInteger(this.InputIndecies);

%% Get the tabledata
Data = this.InputConstrTableModelUDD.data;

%% Set the input values
for ct1 = 1:length(inputs)
    for ct2 = 1:inputs(ct1).PortWidth
        %% Value Column
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
        %% Minimum Value Column
        try
            data = evalin('base', Data(mInputIndecies(ct1)+ct2,4));
            if length(data) == 1
                inputs(ct1).Min(ct2) = data;
            else
                error('Invalid length')
            end
        catch
            str = sprintf('Invalid workspace variable - %s', Data(mInputIndecies(ct1)+ct2,4));
            error(str);
        end        
        %% Maximum Value Column
        try
            data = evalin('base', Data(mInputIndecies(ct1)+ct2,5));
            if length(data) == 1
                inputs(ct1).Max(ct2) = data;
            else
                error('Invalid length')
            end
        catch
            str = sprintf('Invalid workspace variable - %s', Data(mInputIndecies(ct1)+ct2,5));
            error(str);
        end          
    end
end

%% OUTPUTS
%% Get the outputs
outputs = newopcond.Outputs;

%% Convert to Matlab data types
mOutputIndecies = LocalConvertToMatlabInteger(this.OutputIndecies);

%% Get the tabledata
Data = this.OutputConstrTableModelUDD.data;

%% Set the input values
for ct1 = 1:length(outputs)
    for ct2 = 1:outputs(ct1).PortWidth
        %% Value Column
        try
            data = evalin('base', Data(mOutputIndecies(ct1)+ct2,2));
            if length(data) == 1
                outputs(ct1).y(ct2) = data;
            else
                error('Invalid length')
            end
        catch
            str = sprintf('Invalid workspace variable - %s', Data(mOutputIndecies(ct1)+ct2,2));
            error(str);
        end
        %% Minimum Value Column
        try
            data = evalin('base', Data(mOutputIndecies(ct1)+ct2,4));
            if length(data) == 1
                outputs(ct1).Min(ct2) = data;
            else
                error('Invalid length')
            end
        catch
            str = sprintf('Invalid workspace variable - %s', Data(mOutputIndecies(ct1)+ct2,4));
            error(str);
        end        
        %% Maximum Value Column
        try
            data = evalin('base', Data(mOutputIndecies(ct1)+ct2,5));
            if length(data) == 1
                outputs(ct1).Max(ct2) = data;
            else
                error('Invalid length')
            end
        catch
            str = sprintf('Invalid workspace variable - %s', Data(mOutputIndecies(ct1)+ct2,5));
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