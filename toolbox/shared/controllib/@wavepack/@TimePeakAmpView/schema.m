function schema
%SCHEMA  Defines properties for @TimePeakAmpView class

%   Author(s): John Glass
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:25:34 $

% Register class
superclass = findclass(findpackage('wrfc'), 'PointCharView');
c = schema.class(findpackage('wavepack'), 'TimePeakAmpView', superclass);

% Public attributes
schema.prop(c, 'VLines', 'MATLAB array');    % Handles of vertical lines 
schema.prop(c, 'HLines', 'MATLAB array');    % Handles of horizontal lines 
