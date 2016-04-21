function out = mathforsoftscope(equation, varargin);
%MATHFORSOFTSCOPE Helper function used by Data Acquisition Toolbox oscilloscope.
%
%   MATHFORSOFTSCOPE helper function used by Data Acquisition Toolbox 
%   oscilloscope. MATHFORSOFTSCOPE is used by the oscilloscope to calculate
%   the Math Channel values.
%  
%   This function should not be called directly by users.
%
%   See also SOFTSCOPE.
%

%   MP 10-03-01
%   Copyright 1998-2003 The MathWorks, Inc. 
%   $Revision: 1.5.2.3 $  $Date: 2003/08/29 04:44:36 $

% Define the variables needed to make the calculation. The variable name
% is the channel name, the variable value is the data for that channel.
for i=1:2:length(varargin)
    eval([varargin{i} ' = varargin{i+1};'])
end

% Evaluate the Math Channel's equation.
out = eval(equation);
