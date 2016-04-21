function schema
%SCHEMA  Defines properties for @FreqPeakGainView class

%   Author(s): John Glass
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:25:27 $

% Register class (subclass)
superclass = findclass(findpackage('wrfc'), 'PointCharView');
c = schema.class(findpackage('wavepack'), 'FreqPeakGainView', superclass);

% Public attributes
schema.prop(c, 'VLines', 'MATLAB array');    % Handles of vertical lines 
schema.prop(c, 'HLines', 'MATLAB array');    % Handles of horizontal lines 