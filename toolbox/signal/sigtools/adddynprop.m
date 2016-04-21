function varargout = adddynprop(h, name, datatype, setfcn, getfcn)
%ADDDYNPROP   Add a dynamic property
%   ADDDYNPROP(H, NAME, TYPE)  Add the dynamic property with NAME and
%   datatype TYPE to the object H.
%
%   ADDDYNPROP(H, NAME, TYPE, SETFCN, GETFCN)  Add the dynamic property and
%   setup PostSet and PreGet listeners with the functions SETFCN and GETFCN.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/04/13 00:31:21 $

error(nargchk(3,5,nargin));

% Add the dynamic property.
hp = schema.prop(h, name, datatype);
set(hp, 'AccessFlags.Serialize', 'Off');

if nargin > 3

    % Define the storage property name
    spname = 'DynamicPropListeners';

    % Create and cache the listener to the set and get events.
    if ~isprop(h, spname)
        p = schema.prop(h, spname, 'handle.listener vector');
        set(p, 'Visible', 'Off', 'AccessFlags.Serialize', 'Off');
    end
    listen = get(h, spname);

    l = [];
    if ~isempty(setfcn),
        l = handle.listener(h, hp, 'PropertyPostSet', {@lclpostset_listener, setfcn});
        % Add a private property to store the real data.  g181336
        hpp = schema.prop(h, sprintf('geck%s', name), 'mxArray');
        set(hpp, 'Visible', 'Off', 'AccessFlags.Serialize', 'Off');
    end
    if nargin < 5, getfcn = []; end

    gl = handle.listener(h, hp, 'PropertyPreGet', {@lclpreget_listener, getfcn});
    if isempty(l),
        l = gl;
    else
        l = [l; gl];
    end

    set(l, 'CallbackTarget', h);
    if isempty(listen),
        listen = l;
    else
        listen = [listen; l];
    end
    set(h, spname, listen);
end

if nargout
    varargout = {hp};
end

% -------------------------------------------------------------------------
function lclpostset_listener(h, eventData, setfcn)

prop = get(eventData.Source, 'Name');

inputs = {h, get(eventData, 'NewValue')};
if iscell(setfcn),
    inputs = [inputs setfcn(2:end)];
    setfcn = setfcn{1};
end

% Call the set function.  it might modify the data.
out = feval(setfcn, inputs{:});

% Save the correct property value from the setfcn.  We don't need to
% disable the set function because we are already in the listener.

% We have to disable this.  If its left on, any other listeners will not
% fire.  emailed dave about this. g181336
% set(h, get(eventData.Source, 'Name'), out);

% Use the geck<Name> property because the <Name> property will cause
% problems.  We use the string 'geck' since it should be unique.  We have
% some code that has priv<Name> already in it.
set(h, sprintf('geck%s', prop), out);

% -------------------------------------------------------------------------
function lclpreget_listener(h, eventData, getfcn)

prop = get(eventData.Source, 'Name');

geckprop = sprintf('geck%s', prop);
if isprop(h, geckprop),
    val = get(h, geckprop);
else
    val = get(h, prop);
end

if ~isempty(getfcn)

    % Get the actually data from the GETFUNCTION
    inputs = {h, val};
    if iscell(getfcn),
        inputs = [inputs getfcn(2:end)];
        getfcn = getfcn{1};
    end
    val = feval(getfcn, inputs{:});
end

% Make sure that no listeners fire when we set the property with the data
% from the getfcn.
p = findprop(h, prop);
set(p, 'AccessFlags.Listener', 'Off');

if strcmpi(p.AccessFlags.PublicSet,'off'),
    p.AccessFlags.PublicSet = 'on';
    set(h, prop, val);
    p.AccessFlags.PublicSet = 'off';
else
    set(h, prop, val);
end

set(p, 'AccessFlags.Listener', 'On');

% [EOF]
