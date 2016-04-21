function schema
%SCHEMA  Defines properties for @timeview class

%  Author(s): Bora Eryilmaz
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:25:58 $

% Register class
superclass = findclass(findpackage('wrfc'), 'view');
c = schema.class(findpackage('wavepack'), 'timeview', superclass);

% Class attributes
schema.prop(c, 'Curves', 'MATLAB array');  % Handles of HG lines (matrix)
p = schema.prop(c, 'Style', 'string');     % Curve style [{line}|stairs|stem]
p.FactoryValue = 'line';