function schema
%  SCHEMA  Defines properties for MPCController class

%  Author:   Larry Ricker
%  Revised:
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.8 $ $Date: 2004/04/10 23:35:51 $

% Find parent package
pkg = findpackage('mpcnodes');

% Find parent class
supclass = findclass(pkg, 'MPCnode');

% Register class (subclass) in package
c = schema.class(pkg, 'MPCController', supclass);
pkg.JavaPackage  =  'com.mathworks.toolbox.mpc';

% Properties
schema.prop(c,'ModelName','string');
schema.prop(c,'Model','MATLAB array');
schema.prop(c,'IOdata', 'MATLAB array');
schema.prop(c,'Ts','string');
schema.prop(c,'P','string');
schema.prop(c,'M','string');
schema.prop(c,'Blocking','int32');
schema.prop(c,'DefaultEstimator','int32');
schema.prop(c,'BlockMoves','string');
schema.prop(c,'BlockAllocation','string');
schema.prop(c,'CustomAllocation','string');
schema.prop(c,'EstimData','MATLAB array');
schema.prop(c,'Notes','string');
% The following gets set to true if the user modifies
% the tabular data in the MPCStructure node tables.  This
% signals MPCController to update the tables when they are
% displayed next, after which this parameter is reset to false.
schema.prop(c,'updateTables','int32');
% The following gets set to true if the user modifies
% the MPC design parameters once the tables have been
% initialized.  Gets reset to false when the new values
% are loaded into the MPC object.
schema.prop(c,'HasUpdated','int32');
schema.prop(c,'ExportNeeded','int32');
% The following stores the latest MPC object calculated for this
% node.  If the data change (causing the HasUpdated flag to be "true")
% we need to recalculate the object and re-store it before using it.
% The getController method performs these functions.
p = schema.prop(c,'MPCobject','MATLAB array');
p.AccessFlags.Serialize = 'off';  % Prevents saving large object.
schema.prop(c,'SofteningWindowLocation','java.awt.Point');
p = schema.prop(c, 'Label', 'string');  % Override definition in Explorer
p.setFunction = @LocalSetLabel;
p = schema.prop(c,'Frame', 'MATLAB array');
p.AccessFlags.Serialize = 'off';  

% --------------------------------------------------------------

function propval = LocalSetLabel(eventSrc, eventData)

% Only accept change in node label if it's unique and non-blank
MPCControllers = eventSrc.up;
if ~isempty(MPCControllers)
    Controllers = MPCControllers.getChildren;
    if ~isempty(Controllers.find('Label', eventData))
        propval = eventSrc.Label;
        Msg = sprintf('Name "%s" is already in use.  Reverting to "%s".', ...
            eventData, propval);
        uiwait(errordlg(Msg, 'MPC Error', 'modal'));
        return
    end
    % Reset currentController property
    MPCControllers.currentController = eventData;
end
if length(eventData) > 0
    propval = eventData;
else
    propval = eventSrc.Label;
end
