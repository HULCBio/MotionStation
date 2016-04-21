function schema
%SCHEMA  Defines properties for @OutputReport class

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:31:23 $

%% Find the package
pkg = findpackage('opcond');

%% Register class
c = schema.class(pkg, 'OutputReport');

%% Public attributes
schema.prop(c, 'Block', 'string');                   % Simulink block
schema.prop(c, 'PortWidth', 'MATLAB array');         % Port Width
schema.prop(c, 'PortNumber', 'MATLAB array');         % Port Width
p = schema.prop(c, 'y', 'MATLAB array');             % Value of the input
p.SetFunction = @LocalSetValue;

p = schema.prop(c, 'yspec', 'MATLAB array');             % Value of the input
p.SetFunction = @LocalSetValue;

%% Property for the known input flag
schema.prop(c, 'Known', 'MATLAB array');

%% Property to store the lower bound of the constraint
p = schema.prop(c, 'Min', 'MATLAB array');       
p.SetFunction = @LocalSetValue;

%% Property to store the upper bound of the constraint
p = schema.prop(c, 'Max', 'MATLAB array');     
p.SetFunction = @LocalSetValue;

schema.prop(c, 'Description', 'string');             % User description

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Function to check for valid input arguements for the port width.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function NewValue = LocalSetValue(this,NewValue);

if (~isempty(this.PortWidth)) && ...
        (~(length(NewValue) == this.PortWidth) && ~(length(NewValue) == 0))
    if isnan(this.PortNumber)
        error('Invalid entry. The output port %s, has port width of %d',...
            this.Block,this.PortWidth);        
    else
        error('Invalid entry. The signal %s, port %s, has port width of %d',...
            this.Block,this.PortNumber,this.PortWidth);
    end    
end