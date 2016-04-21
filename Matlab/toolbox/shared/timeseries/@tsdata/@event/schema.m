function schema
%SCHEMA Defines properties for @event class.
%
%   Author(s): James G. Owen
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:33:15 $
 
% Register class 
p = findpackage('tsdata');

% Register class 
c = schema.class(p,'event');

% Public properties
schema.prop(c,'EventData','MATLAB array');
schema.prop(c,'Name','string');
schema.prop(c,'Time','double');
schema.prop(c,'Parent','handle');


