function schema
%SCHEMA  Definition of @plot interface (part of @wrfc foundation package).

%  Author(s): P. Gahinet
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:27:27 $

% Find parent package
pkg = findpackage('wrfc');

% Register class 
c = schema.class(pkg, 'plot');

% Class attributes
schema.prop(c, 'AxesGrid',  'handle');         % Plot axes (@axesgrid)
schema.prop(c, 'BackgroundLines',  'MATLAB array');   % BackgroundLines lines
p = schema.prop(c, 'DataExceptionWarning', 'on/off'); % Enable/disables warning for data exceptions
p.FactoryValue = 'on';
schema.prop(c, 'Preferences', 'MATLAB array'); % Plot preferences (char + plot)
schema.prop(c, 'StyleManager', 'handle');      % Style manager 
schema.prop(c, 'Visible',    'on/off');        % Response plot visibility
schema.prop(c, 'Tag', 'string');               % Plot tag (identifier for FIND)
schema.prop(c, 'SaveData', 'MATLAB array');    % Presave data used during figure saves

% Private attributes
p(1) = schema.prop(c, 'Listeners', 'handle vector');
set(p, 'AccessFlags.PublicGet', 'off', 'AccessFlags.PublicSet', 'off');
