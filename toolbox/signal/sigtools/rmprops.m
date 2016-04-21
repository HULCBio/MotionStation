function rmprops(hParent, varargin)
%RMPROPS Remove dynamic props from an object
%   RMPROPS(H, PROPNAME1, PROPNAME2, etc) Remove the dynamic property
%   PROPNAME1, PROPNAME2, etc from the object H.
%
%   RMPROPS(H, HCHILD) Remove the dynamic properties that are defined by
%   the PROPSTOADD method.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/04/11 18:46:44 $

% Parse the inputs to get the properties to remove.
props = parseinputs(varargin{:});

if isempty(props), return; end

% Define the proplistener string.
spname = 'ChildPropListeners';

% Look for the property that stores the listeners.
pl = findprop(hParent, spname);
if isempty(pl), return; end

listen = get(hParent, spname);

% Loop over all the properties
for indx = 1:length(props)
    
    % Find the property to remove.
    p = findprop(hParent, props{indx});
    if ~isempty(listen)
        
        % Remove the property listener for this property from our list.
        listen = setdiff(listen, find(listen, 'SourceObject', p));
    end
    
    try
        % Remove the property.
        delete(p);
    catch
        % Property is static, just remove the listener.
    end
end

% Resave the property listeners.
set(hParent, spname, listen);

% -----------------------------------------------------------------------
function props = parseinputs(varargin)

% If the first input is an object, use its PROPSTOADD method to determine
% which properties should be removed.
if ishandle(varargin{1}),
    props = propstoadd(varargin{1});
else
    
    % If the first input is not an object assume they are strings.
    props = varargin;
    if length(props) == 1 && isempty(props{1}),
        props = {};
    end
end

% [EOF]
