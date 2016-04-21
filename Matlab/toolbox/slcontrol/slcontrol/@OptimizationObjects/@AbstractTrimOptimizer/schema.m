function schema
%SCHEMA  Defines properties for @TrimOptimizer class

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2004/04/11 00:35:02 $

%% Find the package
pkg = findpackage('OptimizationObjects');

%% Register class
c = schema.class(pkg, 'AbstractTrimOptimizer');

%% Public attributes
schema.prop(c, 'model', 'string');
%% Initial variables and known variables
schema.prop(c, 'x0', 'MATLAB array');     
schema.prop(c, 'u0', 'MATLAB array');
schema.prop(c, 'y0', 'MATLAB array');     
schema.prop(c, 'dx0', 'MATLAB array');
%% Fixed indecies
schema.prop(c, 'ix', 'MATLAB array');     
schema.prop(c, 'iu', 'MATLAB array');
schema.prop(c, 'iy', 'MATLAB array');     
schema.prop(c, 'idx', 'MATLAB array');
%% Free indecies
schema.prop(c, 'indx', 'MATLAB array');     
schema.prop(c, 'indu', 'MATLAB array');
schema.prop(c, 'indy', 'MATLAB array');     
%% Upper and lower bounds
schema.prop(c, 'lbx', 'MATLAB array');     
schema.prop(c, 'ubx', 'MATLAB array');    
schema.prop(c, 'lbu', 'MATLAB array');     
schema.prop(c, 'ubu', 'MATLAB array');
schema.prop(c, 'lby', 'MATLAB array');     
schema.prop(c, 'uby', 'MATLAB array');
%% Unique indecies to the output.  This is for the Jacobian calculation
schema.prop(c, 'iy_unique', 'MATLAB array');     
schema.prop(c, 'BlockHandles', 'MATLAB array');
schema.prop(c, 'PortNumbers', 'MATLAB array');     
schema.prop(c, 'OutportHandles', 'MATLAB array');
schema.prop(c, 'ConstrainedSignals', 'MATLAB array');
%% Time
schema.prop(c, 't', 'MATLAB array');    
%% Operating Conditions Constraint Object
schema.prop(c, 'opcond', 'MATLAB array');
%% LINOPTIONS
schema.prop(c, 'linoptions', 'MATLAB array');
%% Number of states
schema.prop(c, 'ncstates', 'MATLAB array');
%% Error vectors
schema.prop(c, 'F_x', 'MATLAB array');     
schema.prop(c, 'F_u', 'MATLAB array');    
schema.prop(c, 'F_y', 'MATLAB array');     
schema.prop(c, 'F_dx', 'MATLAB array');
%% Optimization Data Storage
schema.prop(c, 'DoneOptimData', 'MATLAB array');     
schema.prop(c, 'IterOptimData', 'MATLAB array');
%% Optimization Display Function 
schema.prop(c, 'dispfcn', 'MATLAB array');
%% Stop Check Function
schema.prop(c, 'stopfcn', 'MATLAB array');
%% Constraint Blocks
schema.prop(c, 'StateConstraintBlocks', 'MATLAB array');
schema.prop(c, 'OutputConstraintBlocks', 'MATLAB array');