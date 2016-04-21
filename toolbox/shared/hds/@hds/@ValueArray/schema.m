function schema
% Defines properties for @ValueArray base class.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $ $Date: 2004/04/11 00:29:03 $

% Register class 
c = schema.class(findpackage('hds'),'ValueArray');

% Public properties
p = schema.prop(c,'GridFirst','bool');      % Controls if grid dimensions appear first or last
p.FactoryValue = true;
schema.prop(c,'SampleSize','MATLAB array'); % Size of individual data point
p = schema.prop(c,'Metadata','handle');         % @metadata object
p.SetFunction = @privateSetMetaData;
schema.prop(c,'Variable','handle');         % @variable description
