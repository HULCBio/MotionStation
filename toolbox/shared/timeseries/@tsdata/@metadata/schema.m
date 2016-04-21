function schema
%SCHEMA Defines properties for METADATA class

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $ $Date: 2004/04/11 00:33:26 $

% Register class 
c = schema.class(findpackage('tsdata'),'metadata');

% Public properties
schema.prop(c,'Units','string'); 
schema.prop(c,'Scale','MATLAB array');  
schema.prop(c,'Interpolation','handle');
schema.prop(c,'Offset','double'); 
schema.prop(c,'Name','string'); 
p = schema.prop(c,'GridFirst','bool');
p.FactoryValue = true;
 


