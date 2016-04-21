function schema
%SCHEMA  Defines properties for @rlview class

%  Author(s): Bora Eryilmaz
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:23:07 $

% Register class
superclass = findclass(findpackage('wrfc'), 'view');
c = schema.class(findpackage('resppack'), 'rlview', superclass);

% Public properties
p = schema.prop(c, 'BranchColorList', 'MATLAB array');   % Branch coloring scheme
p.FactoryValue = cell(1,0);  % default = inherit from response style
schema.prop(c, 'Locus', 'handle vector');  % Handles of locus lines (vector)
schema.prop(c, 'SystemZero', 'handle');    % Handles of system zeros
schema.prop(c, 'SystemPole', 'handle');    % Handles of system poles
