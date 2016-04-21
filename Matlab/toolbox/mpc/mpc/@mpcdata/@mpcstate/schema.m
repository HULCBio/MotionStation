function schema
% Defines properties for @mpcstate class

% Copyright 2004 The MathWorks, Inc.


c = schema.class(findpackage('mpcdata'),'mpcstate');

% Public properties
schema.prop(c,'Plant','MATLAB array'); 
schema.prop(c,'Disturbance','MATLAB array'); 
schema.prop(c,'Noise','MATLAB array'); 
schema.prop(c,'LastMove','MATLAB array'); 

