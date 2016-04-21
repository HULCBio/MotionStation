function schema
% Defines properties for @metadata class

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:29:32 $

% Register class 
c = schema.class(findpackage('hds'),'metadata');

% Public properties
schema.prop(c,'Interpolation','handle');
schema.prop(c,'Units','string'); 

