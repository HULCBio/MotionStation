function schema
%SCHEMA  Defines properties for @TimeFinalValueView class

%   Author(s): John Glass
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:20:11 $

% Register class
superclass = findclass(findpackage('wrfc'), 'view');
c = schema.class(findpackage('resppack'), 'TimeFinalValueView', superclass);

% Public attributes
schema.prop(c, 'HLines', 'MATLAB array');    % Handles of horizontal lines 