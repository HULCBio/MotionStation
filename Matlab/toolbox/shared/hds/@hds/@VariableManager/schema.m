function schema
% Defines properties for @VariableManager class.
%
%   Singleton class that maintains the variable pool and 
%   assigns a unique handle to each variable name.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:29:10 $

% Register class 
c = schema.class(findpackage('hds'),'VariableManager');

% Private properties
p = schema.prop(c,'VarTable','MATLAB array');   
p.FactoryValue = struct;
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';
