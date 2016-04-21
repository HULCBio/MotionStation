function varargout = addprops(hParent, hChild, varargin)
%ADDPROPS Method to dynamically add properties to the parent object.
%   ADDPROPS(H, HC) Method to dynamically add properties from HC to H.  HC
%   is assumed to have the method PROPSTOADD, which should return a cell
%   array of strings.
%
%   ADDPROPS(H, HC, PROP1, PROP2, etc.) Adds PROP1, PROP2, etc. from HC to
%   H.  These should be specified with strings.
%
%   ADDPROPS(H, HC, '-not', PROP1, '-not', PROP2) Adds all properties
%   returned from HC's PROPSTOADD method except PROP1 and PROP2.
%
%   ADDPROPS(H, HC, {}) If an empty cell is passed as the third input, no
%   properties will be added to H.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2004/04/13 00:31:24 $

props = parseinputs(hChild, varargin{:});

% Define the storage property name
spname = 'ChildPropListeners';

if isempty(props),
    if nargout == 1, varargout = {[]}; end
    return;
end

if ~isprop(hParent, spname)
    p = schema.prop(hParent, spname, 'handle.listener vector');
    set(p, 'Visible', 'Off', 'AccessFlags.Serialize', 'Off');
end
listen = get(hParent, spname);

newp = {};
for indx = 1:length(props),
    
    hindxc = findprop(hChild, props{indx});
    
    if isprop(hParent, props{indx})
        hindx = findprop(hParent, props{indx});
    else
        % Create a property based on the parameter object.
        hindx = schema.prop(hParent, hindxc.name, hindxc.datatype);
        set(hindx, 'AccessFlags.Serialize', 'Off');
        set(hindx, 'AccessFlags.AbortSet', 'Off');
        
        newp{end+1} = hindx;
    end
    
    set(hParent, hindx.name, get(hChild, hindx.Name));
    
    % Child and parent must have the same PublicSet flag
    hindx.AccessFlags.PublicSet = hindxc.AccessFlags.PublicSet;
    
    % Add preget and postset listeners to link the parameter with the
    % property.
    lindx = [ ...
            handle.listener(hParent, hindx, 'PropertyPreGet', ...
            {@lclpreget_listener, hChild}); ...
            handle.listener(hParent, hindx, 'PropertyPostSet', ...
            {@lclpostset_listener, hChild}); ...
        ];
    if isempty(listen),
        listen = lindx;
    else
        listen = [listen; lindx];
    end
end
set(listen, 'CallbackTarget', hParent);
set(hParent, spname, listen);

if nargout, varargout = {[newp{:}]}; end

% -------------------------------------------------------------------------
function props = parseinputs(hChild, varargin)

% If we have an extra non '-not' input, it must be the properties to add.
if nargin < 2
    props = propstoadd(hChild);
else
    if strcmpi(varargin{1}, '-not')
        props = lclrmnotprops([propstoadd(hChild) varargin]);
    elseif isempty(varargin{1}),
        props = {};
    else
        if iscell(varargin{1}),
            props = varargin{1};
        else
            props = varargin;
        end
    end
end

% Make sure that there are no duplicate properties.
[props i] = unique(props);
[i newi]  = sort(i);
props = props(newi);

% -------------------------------------------------------------------------
function lclpreget_listener(hParent, eventData, hChild)

% When the user tries to get the property, get it from the child.  We do
% this in case the set operation caused an error or if the property was set
% using the child handle.
prop = get(eventData.Source, 'Name');

spname = 'ChildPropListeners';

% Disable the listener, we don't want to try to set the child on a get.
set(hParent.(spname), 'Enabled', 'Off');

% Turn PublicSet flag on temporarilly
pChild = findprop(hChild, prop);
oldflag = pChild.AccessFlags.PublicSet;
pParent = findprop(hParent, prop);
pParent.AccessFlags.PublicSet = 'on';

set(hParent, prop, get(hChild, prop));

% Restore PublicSet flag
pParent.AccessFlags.PublicSet = oldflag;

set(hParent.(spname), 'Enabled', 'On');

% -------------------------------------------------------------------------
function lclpostset_listener(hParent, eventData, hChild)

try
    % Turn PublicSet flag on temporarilly
    prop = get(eventData.Source, 'Name');
    pChild = findprop(hChild, prop);
    
    % When the user tries to set the property set it in the child object.
    set(hChild, get(eventData.Source, 'Name'), get(eventData, 'NewValue'));
    
catch
    
    % Rethrow the error in the catch to get rid of the stack.
    rethrow(lasterror);
end

% -------------------------------------------------------------------------
function props = lclrmnotprops(props)

% Eliminate all properties that are referenced to be a '-not'
indx = 1;
while indx < length(props)
    if strcmpi(props{indx}, '-not')
        idx = strcmpi(props{indx+1}, props);
        props([find(idx) indx]) = [];
        indx = indx - sum(idx) + 1;
    else
        indx = indx + 1;
    end
end

% [EOF]