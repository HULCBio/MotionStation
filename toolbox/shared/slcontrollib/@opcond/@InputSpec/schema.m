function schema
%SCHEMA  Defines properties for @InputSpec class

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:31:04 $

%% Find the package
pkg = findpackage('opcond');

%% Register class
c = schema.class(pkg, 'InputSpec');

%% Public attributes
schema.prop(c, 'Block', 'string');                   % Simulink block
schema.prop(c, 'PortWidth', 'MATLAB array');         % Port Width
p = schema.prop(c, 'u', 'MATLAB array');             % Value of the input
p.SetFunction = @LocalSetValue;

%% Property for the known flag
schema.prop(c, 'Known', 'MATLAB array');

p = schema.prop(c, 'Min', 'MATLAB array');        % Lower Bound
p.SetFunction = @LocalSetValue;

p = schema.prop(c, 'Max', 'MATLAB array');        % Upper Bound
p.SetFunction = @LocalSetValue;

schema.prop(c, 'Description', 'string');             % User description


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Function to check for valid input arguements for the analysis point
%% type.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function NewValue = LocalSetValue(this,NewValue);

if (~isempty(this.PortWidth)) && ...
        (~(length(NewValue) == this.PortWidth) && ~(length(NewValue) == 0))
    error('Invalid entry. The input port %s has port width of %d',this.Block,this.PortWidth);
end