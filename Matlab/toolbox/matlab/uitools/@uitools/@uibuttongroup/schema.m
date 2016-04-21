function schema
% Schema for the uibuttongroup class. This is a subclass of the uipanel
% component. It defines two new properties in addition to the default
% uipanel properties
%
% SelectedObject - The currently selected object in the uibuttongroup.
% SelectionChangeFcn - Callback function invoked when the SelectedObject changes.
% SelectionChanged - Event fired when the SelectedObject changes.

% Copyright 2003-2004 The MathWorks, Inc.

% ToDo: 
%   1. Remove dependency on 'Callback' of the components.

%% Package and class info
pk = findpackage('uitools');
hg = findpackage('hg');

c = schema.class(pk,'uibuttongroup', hg.findclass('uipanel'));

p = schema.prop(c, 'SelectedObject', 'mxArray');
set(p, 'FactoryValue', [],'AccessFlags.Copy','off');
set(p, 'SetFunction', @SelObjSetFcn); % 'GetFunction', @SelObjGetFcn

p = schema.prop(c, 'SelectionChangeFcn', 'MATLAB callback');
set(p, 'FactoryValue', get(0,'DefaultUicontrolCallback'));

%% Event: SelectionChangeEvent.
e = schema.event(c, 'SelectionChanged');

%% Private(hidden) properties
% This is used to store all the listeners.
p = schema.prop(c, 'Listeners', 'MATLAB array');
set(p, 'AccessFlags.PublicGet','off','AccessFlags.PublicSet','off', ...
       'AccessFlags.PrivateGet','on','AccessFlags.PrivateSet','on',...
       'AccessFlags.Copy', 'off',...
       'AccessFlags.Serialize', 'off', 'Visible', 'off');
   
% This is used to save a ref to the previous SelectedObject, in case we 
% need to fire the callback (see childAddedCbk>manageButtons).
p = schema.prop(c, 'OldSelectedObject', 'handle');       
set(p, 'AccessFlags.PublicGet','on','AccessFlags.PublicSet','on', ...
       'AccessFlags.PrivateGet','on','AccessFlags.PrivateSet','on', ...
       'AccessFlags.Copy', 'off',...
       'FactoryValue', [], 'Visible', 'off');

% The following is a very sneaky way to attach a "static" class listener
% in m-udd. We attach a class instance created listener on a property
% of the class in the schema itself. This ensures three things:
% 1. There is only one such listener on the class (which is what we want).
% 2. The listener has the same life-cycle as the class.
% 3. This listener is fired even for the first instance that is created.
% If this sticks, we may need to formalize this for other hg m-udd objects.
schema.prop(p, 'ClassListener', 'handle');
%pk = findpackage('uitools');
%hclass = pk.findclass('uibuttongroup');
p.ClassListener = handle.listener(c, 'ClassInstanceCreated', @instanceCreated);

function instanceCreated(src, evt)
h = evt.Instance; 
% Add listeners to copy
addListeners(handle(h))


%% Set function for SelectedObject.   
function result = SelObjSetFcn(src, val)
manageSelection(src, val);
result = val;

% Doesn't change the output value.
% function result = SelObjGetFcn(src, val)
% result = double(val);

%% Selection state manager
function manageSelection(src, ctrl)

hgroup = src;
oldctrl = get(hgroup, 'SelectedObject');

% Prevent reentry into this code from valueChangedCbk(childAddedCbk.m)
setappdata(double(hgroup), 'inSelectedObjectSet', 1);
if (isempty(ctrl) | (ctrl ~= oldctrl))
    set(oldctrl, 'value', 0);
end
set(ctrl, 'Value', 1);
rmappdata(double(hgroup), 'inSelectedObjectSet');
