function schema
%  SCHEMA  Defines properties for @bodeview class

%  Author(s): Bora Eryilmaz
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:20:37 $

% Register class (subclass)
superclass = findclass(findpackage('wrfc'), 'view');
c = schema.class(findpackage('resppack'), 'bodeview', superclass);

% Class attributes
schema.prop(c, 'MagCurves', 'MATLAB array'); % Handles of HG lines for mag axes
schema.prop(c, 'MagNyquistLines', 'MATLAB array');    % Handles of Nyquist lines for mag axes
schema.prop(c, 'PhaseCurves', 'MATLAB array');        % Handles of HG lines for phase axes
schema.prop(c, 'PhaseNyquistLines', 'MATLAB array');  % Handles of Nyquist lines for phase axes
schema.prop(c, 'UnwrapPhase', 'on/off');              % Phase wrapping
