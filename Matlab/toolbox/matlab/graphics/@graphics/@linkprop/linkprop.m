function [hThis] = linkprop(hlist,propnames)

% Copyright 2003 The MathWorks, Inc.

hThis = graphics.linkprop;
m(1) = handle.listener(hThis,findprop(hThis,'Enabled'),'PropertyPostSet',{@localSetEnabled,hThis});
set(hThis,'InternalListeners',m);
set(hThis,'UpdateFcn',@localUpdateListeners);

% Cast first input argument into handle array
hlist = handle(hlist);

% Cast second input argument into cell array
if isstr(propnames)
  propnames = {propnames};
end

if any(~ishandle(hlist)) || ~isvector(hlist)
  error('MATLAB:graphics:proplink', 'Invalid handle vector');
end

% Convert mx1 vector to 1xm vector for consistency
if size(hlist,1)>1
  hlist = hlist';
end

% Save state to object
set(hThis,'Targets',hlist);
set(hThis,'PropertyNames',propnames);

% Update listeners, call to pseudo-private method
feval(get(hThis,'UpdateFcn'),hThis); 

%-----------------------------------------------%
function localSetEnabled(obj,evd,hThis)

l = get(hThis,'Listeners');
newval = get(hThis,'Enabled');

set(l,'Enabled',newval);

if strcmp(newval,'on')
  % Call to pseudo-private method
  feval(get(hThis,'UpdateFcn'),hThis); 
end

%-----------------------------------------------%
function localUpdateListeners(hLink)

% dereference old listeners
set(hLink,'Listeners',[]);

% Get properties and handles 
propnames = get(hLink,'PropertyNames');
hlist = get(hLink,'Targets');
foundlistener = false;
count = 0;

% Cycle through list of objects
% Create listeners for each input object
for m = 1:length(hlist)
  if ishandle(hlist(m))
    
     % Listen to deletion
     hDeleteListener(m) = handle.listener(hlist(m), ...
                      'ObjectBeingDestroyed',...
                      {@localRemoveHandle,hlist(m),hLink});
     
     % Count the number of property objects
     count = 1;
     
     % Get list of property objects for listening
     foundprop = false;
     for n = 1:length(propnames)
        prop = findprop(hlist(m),propnames{n});
        if isempty(prop)
           warning('MATLAB:graphics:linkprop','Invalid property');
        else
           hProp(count) = prop;
           count = count + 1;
           foundprop = true;
        end
     end % for
     
     if foundprop
        % Create one handle listener per object
        hListener(m) = handle.listener(hlist(m),...
                                    hProp, ...
                                    'PropertyPostSet',...
                                    {@localUpdate,hLink,hlist});
        set(hListener(m),'Enabled',get(hLink,'Enabled'));
        foundlistener = true;    
     end

 end % if
end % for

% If we have delete listeners
if count > 0
   set(hLink,'TargetDeletionListeners',hDeleteListener);
end

% Bail out early if we have no listeners
if ~foundlistener, 
    return; 
end

set(hLink,'Listeners',hListener);

% Update all objects so they have the same properties 
% as the first object in the list. This is an arbitrary 
% convention documented in LINKPROP m-help

% Loop through properties
for n = 1:length(propnames)
   prop = propnames{n};

   % Get handles that have this property
   ind = find(isprop(hlist,prop));
   if length(ind) > 1
       
       % Set handles that have this property
       val = get(hlist(ind(1)),prop);
       set(hlist(ind),prop,val);
   end
   
end % for

%-----------------------------------------------------%
function localRemoveHandle(hProp,hEvent,hTarget,hLink)
removetarget(hLink,hTarget);

%-----------------------------------------------------%
function localUpdate(hProp,hEvent,hLink,hlist)

% Return early if invalid property object
if ~isa(hProp,'schema.prop')
  return;
end

% Return early if invalid handle
if ~all(ishandle(hlist))
  return;
end

propname = get(hProp,'Name');
propval = get(hEvent,'NewValue');

% Temporarily turn off listeners to avoid excessive 
% listener firing
hListeners = get(hLink,'Listeners');
set(hListeners,'Enabled','off');

% Update all linked objects that have this property
ind = find(isprop(hlist,propname)==true);
set(hlist(ind),propname,propval);

% Restore listeners
set(hListeners,'Enabled','on');





