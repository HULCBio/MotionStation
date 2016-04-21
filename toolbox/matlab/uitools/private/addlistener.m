function hl=addlistener(hContainer, hSrc, eventName, response)
%  ADDLISTENER  Add a listener callback to one or more events.
%
%  ADDLISTENER(HContainer, HSrc, EventNames, Callback)
%  Adds a listener to each object in HContainer for events 
%  originating from each object in HSrc having one of the names listed
%  in EventNames.
%
%  If EventNames contains only property events (PreGet, PreSet, PostGet,
%  or PostSet), hSrc may contain a list of property handles or a list
%  of property names (string or cell array of strings).
%
%  ADDLISTENER always attaches the listener to each container object
%  so that the listener survives as long as the longest-lived 
%  container object.
%
%  ADDLISTENER(HSrc, EventNames, Callback)
%  Adds a listener to each object in HSrc for events originating from 
%  each object in HSrc having one of the names listed in EventNames.
%  

% Copyright 2003 The MathWorks, Inc.

% make sure we have handle objects
hContainer = handle(hContainer);

if (nargin == 3)
    response = eventName;
    eventName = hSrc;
    hSrc = hContainer;
elseif ischar(hSrc) && prod(size(hContainer)) == 1
    hSrc = hContainer.findprop(hSrc);
elseif iscell(hSrc) && prod(size(hContainer)) == 1
    for i = 1:length(hSrc)
	temp(i) = hContainer.findprop(hSrc{i});
    end
    hSrc = temp;
end

hl = handle.listener(hContainer, hSrc, eventName, response);
for i = 1:length(hContainer)
    hC = hContainer(i);
    p = findprop(hC, 'Listeners__');
    if (isempty(p))
	p = schema.prop(hC, 'Listeners__', 'handle vector');
	p.AccessFlags.Serialize = 'off';
    end
    hC.Listeners__ = [hC.Listeners__; hl];
end
