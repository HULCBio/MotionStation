function schema
% Defines properties for @designconstr superclass.
%
%   Specifics about @designconstr subclasses:
%     * Changes in data properties have no immediate effect and  
%       require an explicit call to UPDATE to refresh the graphics

%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.16 $ $Date: 2002/04/10 05:12:10 $

pk = findpackage('plotconstr');

% Register class 
c = schema.class(pk,'designconstr');

% Constraint data
schema.prop(c, 'ButtonDownFcn', 'MATLAB callback');     % Button Down on marker/patch
schema.prop(c, 'EventManager','handle');        % Event coordinator (@eventmgr object)
schema.prop(c, 'Parent', 'handle');             % Parent axis (hg.axes object)
schema.prop(c, 'Selected', 'on/off');           % Selection flag 
schema.prop(c, 'TextEditor', 'handle');         % Constraint editor handle
schema.prop(c, 'Thickness', 'MATLAB array');    % Relative constraint thickness
schema.prop(c, 'Type', 'string');               % Bound type [upper|lower]
p = schema.prop(c, 'Zlevel', 'double');         % Z coordinate for layering (default=0)
p.FactoryValue = 0;

% Private properties 
schema.prop(c, 'Activated', 'bool');     % Needed to mitigate limitation of undo add
schema.prop(c, 'HG', 'MATLAB array');             % HG objects 
p = schema.prop(c, 'Listeners', 'handle vector'); % Listeners
schema.prop(c, 'AppData', 'MATLAB array');        % Storage area

% Events
% DataChanged: notifies environment that constraint data has changed 
%              (no listeners on individual data properties)
schema.event(c, 'DataChanged');
