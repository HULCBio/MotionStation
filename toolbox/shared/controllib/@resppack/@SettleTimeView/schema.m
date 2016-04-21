function schema
%SCHEMA  Defines properties for @SettleTimeView class.

%   Author(s): John Glass
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:19:25 $

% Register class
superclass = findclass(findpackage('wrfc'), 'PointCharView');
c = schema.class(findpackage('resppack'), 'SettleTimeView', superclass);

% Public attributes
schema.prop(c, 'VLines', 'MATLAB array');    % Handles of vertical lines 
schema.prop(c, 'UpperHLines', 'MATLAB array');    % Handles of horizontal lines 
schema.prop(c, 'LowerHLines', 'MATLAB array');    % Handles of horizontal lines 
