function schema
%  SCHEMA  Defines properties for MPCSim class

%  Author:  Larry Ricker
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.7 $ $Date: 2004/04/10 23:36:55 $

% Find parent package
pkg = findpackage('mpcnodes');

% Find parent classes
supclass = findclass(pkg, 'MPCnode');

% Register class (subclass) in package
c = schema.class(pkg, 'MPCSim', supclass);
pkg.JavaPackage  =  'com.mathworks.toolbox.mpc';

% Properties
% The following gets set to true if the user modifies
% the tabular data in the MPCStructure node tables.  This
% signals MPCController to update the tables when they are
% displayed next, after which this parameter is reset to false.
schema.prop(c,'updateTables','int32');
% The following gets set to true if the user modifies
% the scenario parameters once the tables have been
% initialized.  Gets reset to false when the scenario
% has been saved, so the setup can be reused.
schema.prop(c,'HasUpdated','int32');
schema.prop(c,'Scenario','MATLAB array');
schema.prop(c,'Results','MATLAB array');
schema.prop(c,'PlantName','string');
schema.prop(c,'ControllerName','string');
% This is saved here for convenience.  It comes from the
% controller object.  Function refreshTsLabel is responsible
% for keeping the value current.
schema.prop(c,'Ts','double');
schema.prop(c,'Tend','string');
schema.prop(c,'rLookAhead','int32');
schema.prop(c,'vLookAhead','int32');
schema.prop(c,'ClosedLoop','int32');
schema.prop(c,'ConstraintsEnforced','int32');
schema.prop(c,'Notes','string');
p = schema.prop(c, 'Label', 'string');  % Override definition in Explorer
p.setFunction = @LocalSetLabel;

% --------------------------------------------------------------

function propval = LocalSetLabel(eventSrc, eventData)

% Only accept change in node label if it's unique
MPCSims = eventSrc.up;
if ~isempty(MPCSims)
    Scenarios = MPCSims.getChildren;
    if ~isempty(Scenarios.find('Label', eventData))
        propval = eventSrc.Label;
        Msg = sprintf('Name "%s" is already in use.  Reverting to "%s".', ...
            eventData, propval);
        uiwait(errordlg(Msg, 'MPC Error', 'modal'));
        return
    end
    % The scenario will be renamed.  Set the current scenario property.
    MPCSims.currentScenario = eventData;
end
if length(eventData) > 0
    propval = eventData;
else
    propval = eventSrc.Label;
end
