function schema
%SCHEMA  Defines properties for @NyquistPeakRespView class

%   Author(s): John Glass
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:19:12 $

% Register class
superclass = findclass(findpackage('wrfc'), 'PointCharView');
c = schema.class(findpackage('resppack'), 'NyquistPeakRespView', superclass);

% Public attributes
schema.prop(c, 'Lines', 'MATLAB array');     % Dashed lines from origin to peak