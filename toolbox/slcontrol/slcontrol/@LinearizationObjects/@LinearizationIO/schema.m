function schema
%SCHEMA  Defines properties for @LinearizationIO class

%%  Author(s): John Glass
%%  Revised:
%% Copyright 1986-2003 The MathWorks, Inc.
%% $Revision: 1.1.6.3 $ $Date: 2003/12/04 02:36:28 $

% Register class
pkg = findpackage('LinearizationObjects');
c = schema.class(pkg, 'LinearizationIO');

pkg.JavaPackage  =  'com.mathworks.toolbox.ctrlbs.Linearize';
c.JavaInterfaces = {'com.mathworks.toolbox.ctrlbs.Linearize.LinearizationIO'};

% Public attributes

%%% Property for whether the analysis point is active
p = schema.prop(c, 'Active','on/off');
p.FactoryValue = 'on';

%%% Property for the reference block name
schema.prop(c, 'Block', 'string');                   

%%% Property for the open-loop analysis flag
p = schema.prop(c, 'OpenLoop', 'on/off');             
p.FactoryValue = 'off';

%%% Property for the port number for the analysis point
p = schema.prop(c, 'PortNumber', 'MATLAB array');     
p.FactoryValue = 1;

%%% Property for the analysis point type
p = schema.prop(c, 'Type', 'string');           
p.FactoryValue = 'in';
p.SetFunction = @LocalSetType;

%%% Property for the user description
p = schema.prop(c, 'Description', 'string');           
p.FactoryValue = '';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Function to check for valid input arguements for the analysis point
%% type.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function NewType = LocalSetType(this,NewType);

if ~any(strcmp({'in','out','inout','outin','none'},NewType))
    str = 'Not a valid linear analysis point type.  Valid entries are: \n';
    str = [str,'''in'' - Linearization input perturbation\n'];
    str = [str,'''out'' - Linearization output measurement\n'];
    str = [str,'''inout'' - Linearization input perturbation then output measurement\n'];
    str = [str,'''outin'' - Linearization output measurement then input perturbation\n'];
    str = [str,'''none'' - No linearization input or output\n'];
    error('InvalidLinearizationPointType',sprintf(str))
end