function add_exec_event_listener(block, eventType, listenerCallback)
%ADD_EXEC_EVENT_LISTENER Adds execution event listener to block
%   ADD_EXEC_EVENT_LISTENER(block, eventType, listenerCallback) adds
%   an execution listener of type eventType to the specified
%   block. The callback that needs to run when the event fires is 
%   specified in listenerCallback.
%

%   Copyright 1990-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $

%
% the requisite nargin checking...
%
if nargin ~= 3,
  error('Needs three input arguments.');
end

rtih = get_param(block, 'RuntimeObject');

if isempty(rtih)
  error('Can add listener only when block diagram is executing')
end

rtih = handle(rtih);
hl   = handle.listener(rtih, eventType, listenerCallback);

p = findprop(rtih, 'Listener_Storage_');
if isempty(p)
  p = schema.prop(rtih, 'Listener_Storage_', 'handle vector');
  p.Visible = 'off';
end

hl = [rtih.Listener_Storage_; hl];

rtih.Listener_Storage_ = hl;
  
%% [EOF] add_execevent_listener.m