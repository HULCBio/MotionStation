function schema

% SCHEMA  Defines properties for @LTIsummary class

% Author(s): Larry Ricker
% Revised:
% Copyright 1986-2003 The MathWorks, Inc.

% Register class 
pkg = findpackage('mpcobjects');
c = schema.class(pkg, 'LTIsummary');

pkg.JavaPackage  =  'com.mathworks.toolbox.mpc';
%c.JavaInterfaces = {'com.mathworks.toolbox.mpc.importltiObject'};

% Properties
   
% Pointer to Java JTextArea component
schema.prop(c, 'jText','javax.swing.JLabel');
% Pointer to container (JScrollPane)
schema.prop(c, 'jScroll','javax.swing.JScrollPane');

