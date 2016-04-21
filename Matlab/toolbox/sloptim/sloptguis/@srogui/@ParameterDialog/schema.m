function schema
% Singleton class for parameter dialog.

%   Author(s): Pascal Gahinet
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:44:08 $
%   Copyright 1986-2003 The MathWorks, Inc.

% Register class 
c = schema.class(findpackage('srogui'),'ParameterDialog');

% Edited project
schema.prop(c,'Project','handle');

% Edited parameter specs (local copy)
schema.prop(c,'ParamSpecs','handle vector');

% Parameter selection dialog
schema.prop(c,'SelectDialog','handle');

% Java objects and listeners
schema.prop(c,'Figure','MATLAB array');  
schema.prop(c,'Listeners','handle vector');   



