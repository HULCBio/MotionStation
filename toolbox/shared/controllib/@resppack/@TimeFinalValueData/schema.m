function schema
%  SCHEMA  Defines properties for @TimeFinalValueData class

%  Author(s): John Glass
%  Revised:
%  Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:20:04 $

% Register class
superclass = findclass(findpackage('wrfc'), 'data');
c = schema.class(findpackage('resppack'), 'TimeFinalValueData', superclass);

% Public attributes
schema.prop(c, 'FinalValue', 'MATLAB array'); % FinalValue
