function op = operspec(model);
%OPERSPEC Create operating point specifications for Simulink model.
%
%   OP = OPERSPEC('sys') returns an operating point specification object, 
%   OP, for a Simulink model, 'sys'. Edit the default operating point 
%   specifications directly or use get and set. Use the operating point 
%   specifications object with the function FINDOP to find operating points 
%   based on the specifications. Use these operating points with the 
%   function LINEARIZE to create linearized models. 
%
%   To get and then view a formatted display of the operating specification 
%   for a Simulink model run the commands:
%
%   >> op = operspec('f14');
%   >> op 
%
%   The operating point object properties are:
%    MODEL - Model is the name of the Simulink model that this operating 
%            point specification object is associated with. 
%
%    STATES - States describes the operating point specifications for 
%             states in the Simulink model. The States property is a vector 
%             of state objects that each contain specifications for 
%             particular states. There is one state specification object 
%             per block that has a state in the model. The States object 
%             has the following properties: 
%
%       Block - Block that the states are associated with.
%       x     - Vector containing values of states in the block. Set the 
%               corresponding value of Known to 1 when these values are 
%               known operating point values. Set the corresponding values 
%               of Known to 0 when these values are initial guesses for the 
%               operating point values. The default value of x is the 
%               initial condition value for the state.
%       Nx    - Number of states in the block. This property is read-only.
%       Known - Vector of values set to 1 for states whose operating points 
%               are known exactly and set to 0 for states whose operating 
%               points are not known exactly. Set the operating point values 
%               themselves in the x property.
%       SteadyState - Vector of values set to 1 for states whose operating 
%                     points should be at equilibrium and set to 0 for 
%                     states whose operating points are not at equilibrium. 
%                     The default value of SteadyState is 1.
%       Min    - Vector containing the minimum values of the corresponding 
%                state's operating pointMaxVector containing the maximum 
%                values of the corresponding state's operating point
%       Description - String describing the blockInputs
%
%    INPUTS - Inputs is a vector of input specification objects that contains 
%             specifications for the input levels at the operating point. 
%             There is one input specification object per root level inport 
%             block in the Simulink model. The Inputs object has the 
%             following properties: 
%
%       Block - The inport block that the input vector is associated with.
%       PortWidth - Width of the corresponding inport
%       u     - Vector containing values of inputs. Set the corresponding 
%               value of Known to 1 when these values are known operating 
%               point values. Set the corresponding values of Known to 0 
%               when these values are initial guesses for the operating 
%               point values. 
%       Known - Vector of values set to 1 for inputs whose operating points 
%               are known exactly and set to 0 for inputs whose operating 
%               points are not known exactly. Set the operating point values 
%               themselves in the u property.
%       Min   - Vector containing the minimum values of the corresponding 
%               input's operating point.
%       Max   - Vector containing the maximum values of the corresponding 
%               input's operating point.
%       Description - String describing the inputTimeTime specifies the time 
%                     at which any time-varying functions in the model are 
%                     evaluated. 
%
%    OUTPUTS - Outputs is a vector of output specification objects that contains 
%              the specifications for the output levels at the operating point. 
%              There is one output specification object per root level outport 
%              block in the Simulink model. To constrain additional outputs, 
%              use the ADDOUTPUTSPEC function to add an another output 
%              specification to the operating point specification object. 
%              The Outputs object has the following properties: 
%
%       Block - Outport block that the output vector is associated with.
%       PortWidth - Width of the corresponding outport.
%       PortNumber - Port number that the output is associated with.
%       y     - Vector containing values of outputs. Set the corresponding 
%               value of Known to 1 when these values are known operating 
%               point values. Set the corresponding values of Known to 0 
%               when these values are initial guesses for the operating 
%               point values.
%       Known - Vector of values set to 1 for outputs whose operating points 
%               are known exactly and set to 0 for outputs whose operating 
%               points are not known exactly. Set the operating point values 
%               themselves in the y property.
%       Min   - Vector containing the minimum values of the corresponding 
%               output's operating point
%       Max   - Vector containing the maximum values of the corresponding 
%               output's operating point.
%       Description - String describing the output.
%
%   See also FINDOP.

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:32:23 $

%% Create operating conditions object
op = opcond.OperatingSpec;

%% Store the model name
op.Model = model;

%% Update the operating condition specification object
op = op.update;
