function schema
%SCHEMA  Defines properties for @sigmaview class.

%  Author(s): Kamesh Subbarao
%  Copyright 1986-2004 The MathWorks, Inc.

% Register class
superclass = findclass(findpackage('wrfc'), 'view');
c = schema.class(findpackage('resppack'), 'sigmaview', superclass);

% Class attributes
schema.prop(c, 'Curves', 'MATLAB array');        % Handles of sv curves
schema.prop(c, 'NyquistLines', 'MATLAB array');  % Handles of Nyquist lines
