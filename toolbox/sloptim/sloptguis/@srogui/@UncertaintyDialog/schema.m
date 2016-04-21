function schema
% Class for SRO uncertainty dialog.

%   Author(s): Pascal Gahinet
%   $Revision $ $Date: 2004/01/03 12:28:03 $
%   Copyright 1986-2004 The MathWorks, Inc. 

% Register class 
c = schema.class(findpackage('srogui'),'UncertaintyDialog');

% Targeted project
schema.prop(c,'Project','handle');

% Targeted test
schema.prop(c,'Test','handle');

% Uncertain parameter spec
schema.prop(c,'Uncertainty','MATLAB array');

% Which spec is active (index)
p = schema.prop(c,'ActiveSpec','double');
p.FactoryValue = 1;

% Parameter selection dialog
schema.prop(c,'SelectDialog','handle');

% Java objects and listeners
schema.prop(c,'Figure','MATLAB array');  
schema.prop(c,'Listeners','handle vector');   



