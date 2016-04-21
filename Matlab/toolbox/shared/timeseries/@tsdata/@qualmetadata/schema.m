function schema
% Defines properties for @qualmetadata class.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $ $Date: 2004/04/11 00:33:32 $

% This calls implements the translation table for quality values.
% It is defined as an object rather than a structure so that the
% getData and setData methods can be sued to chceck that quality
% variables are valid

% Register class 
c = schema.class(findpackage('tsdata'),'qualmetadata');

% Public properties
schema.prop(c,'Code','MATLAB array'); 
schema.prop(c,'Description','MATLAB array');
p = schema.prop(c,'GridFirst','bool');
p.FactoryValue = true;



