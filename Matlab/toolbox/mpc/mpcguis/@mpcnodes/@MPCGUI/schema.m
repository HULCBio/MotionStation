function schema
%  SCHEMA  Defines properties for MPCGUI class

%  Author:  Larry Ricker
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.6 $ $Date: 2004/04/10 23:36:25 $

% Find parent package
pkg = findpackage('mpcnodes');

% Find parent classes

supclass = findclass(findpackage('explorer'), 'projectnode');

% Register subclass in package
c = schema.class(pkg, 'MPCGUI', supclass);
pkg.JavaPackage  =  'com.mathworks.toolbox.mpc';

% Properties
schema.prop(c,'MPCObject','MATLAB array');  % MPC Object
p = schema.prop(c,'Linearization','handle');  % Linearization dialog udd handle
p.AccessFlags.Serialize = 'off';
schema.prop(c,'Block','string'); % MPC Simulink block name (if needed)
schema.prop(c, 'Sizes', 'MATLAB array');
% Sizes mapping (vector of integers):
% 1 NumMV
% 2 NumMD
% 3 NumUD
% 4 NumMO
% 5 NumUO
% 6 NumIn = NumMV + NumMD + NumUD
% 7 NumOut = NumMO + NumUO
schema.prop(c,'iMV','MATLAB array');
schema.prop(c,'iMD','MATLAB array');
schema.prop(c,'iUD','MATLAB array');
schema.prop(c,'iMO','MATLAB array');
schema.prop(c,'iUO','MATLAB array');
p = schema.prop(c,'InUDD','handle');
p.AccessFlags.Serialize = 'off';
p = schema.prop(c,'OutUDD','handle');
p.AccessFlags.Serialize = 'off';
schema.prop(c,'InData', 'MATLAB array');
schema.prop(c,'OutData','MATLAB array');
schema.prop(c,'ModelImported','int32');
p = schema.prop(c,'Frame','MATLAB array');
p.AccessFlags.Serialize = 'off';
p = schema.prop(c,'TreeManager','MATLAB array');
p.AccessFlags.Serialize = 'off';
schema.prop(c,'Reset','MATLAB array');
schema.prop(c,'SpecsChanged','MATLAB array');
schema.prop(c,'SimulinkProject', 'int32');
% Hin and Hout will be handles to the graphical display windows for this
% project.
p = schema.prop(c,'Hin','MATLAB array');  % Don't save these figure handles!
p.AccessFlags.Serialize = 'off';
p = schema.prop(c,'Hout','MATLAB array');
p.AccessFlags.Serialize = 'off';
schema.prop(c,'Created','MATLAB array');
schema.prop(c,'Version','MATLAB array');
schema.prop(c,'Updated','MATLAB array');
schema.prop(c, 'SaveFields', 'MATLAB array');
schema.prop(c, 'SaveData', 'MATLAB array');
schema.event(c,'ControllerListUpdated');
