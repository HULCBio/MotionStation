function schema
% Defines properties for @LinkArray class.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $ $Date: 2004/04/11 00:28:42 $

% Register class 
c = schema.class(findpackage('hds'),'LinkArray');

% Public properties
schema.prop(c,'Alias','handle');         % Associated variable (@variable)
schema.prop(c,'Links','MATLAB array');   % Cell array of data set handles

% All data-holding variables accessible through the link
schema.prop(c,'LinkedVariables','handle vector');   

% Template for building new data set entries in link array
schema.prop(c,'Template','handle');      % data set handle

% When Transparency='on', GETSAMPLE follows links
p = schema.prop(c,'Transparency','on/off');  
