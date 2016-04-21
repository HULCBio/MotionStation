function schema
%SCHEMA  Defines properties for @linoptions class

%%  Author(s): John Glass
%%  Revised:
%% Copyright 1986-2004 The MathWorks, Inc.
%% $Revision: 1.1.6.5 $ $Date: 2004/04/11 00:34:59 $

%% Find the package
pkg = findpackage('LinearizationObjects');

%% Register class
c = schema.class(pkg, 'linoptions');

%% Public attributes
p = schema.prop(c, 'LinearizationAlgorithm', 'string');
p.FactoryValue = 'blockbyblock';
p.SetFunction = @LocalSetValue;
p = schema.prop(c, 'SampleTime', 'MATLAB array');     
p.FactoryValue = -1;

%% blockbyblock
p = schema.prop(c, 'BlockReduction', 'on/off');       
p.FactoryValue = 'on';
p = schema.prop(c, 'IgnoreDiscreteStates', 'on/off'); 
p.FactoryValue = 'off';

%% numericalpert
p = schema.prop(c, 'NumericalPertRel', 'MATLAB array');     
p.FactoryValue = 1e-5;
p = schema.prop(c, 'NumericalXPert', 'MATLAB array');     
p.FactoryValue = [];
p = schema.prop(c, 'NumericalUPert', 'MATLAB array');     
p.FactoryValue = [];

p = schema.prop(c, 'OptimizationOptions', 'MATLAB array');       
p.FactoryValue = optimset('Jacobian','off','Display','off',...
                            'DiffMinChange', 1e-8, 'DiffMaxChange', 0.1,...
                            'MaxIter', 400, 'MaxFunEvals', 600,...
                            'TolFun', 1e-6, 'TolX', 1e-6,...  
                            'LargeScale','off');
                        
p = schema.prop(c, 'OptimizerType', 'MATLAB array');
%% Set the default optimizer. 
p.FactoryValue = 'graddescent_elim';
p.SetFunction = @LocalOptimSet;

p = schema.prop(c, 'DisplayReport', 'string');
p.FactoryValue = 'on';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Function to check for valid optimization schemes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function NewValue = LocalOptimSet(this,NewValue);

switch NewValue
    case {'graddescent_elim','graddescent','simplex'}
        %% No error
    case {'lsqnonlin','fminunc'}
        if ~license('test','Optimization_Toolbox')
            error('slcontrol:linoptions:InvalidOptimizationRoutine',...
                ['The use of the optimization routine lsqnonlin requires ',...
                 'The Optimization Toolbox']) 
        end
    otherwise
        if license('test','Optimization_Toolbox')
            types = 'graddescent_elim, graddescent, simplex, or lsqnonlin';
        else
            types = 'graddescent_elim, graddescent, or simplex';
        end
        error('slcontrol:linoptions:InvalidOptimizationRoutine',...
                sprintf(['Invalid optimization type %s.  Please select either\n',...
                         '%s.'],NewValue,types));
            
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Function to check for valid input arguements 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function NewValue = LocalSetValue(this,NewValue);

if (~strcmp(NewValue,'blockbyblock') && ...
            ~strcmp(NewValue,'numericalpert'))
    error(sprintf(['Invalid entry for the property LinearizationAlgorithm.',...
                'Entry must either \n ''blockbyblock'' of ''numericalpert''']));
end
