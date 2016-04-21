function add_engine_event_listener(model, eventType, listenerCallback)
%
%    'EnginePreCompStart'
%    'EnginePostCompStart'
%    'EnginePostLibraryLinkResolve'
%    'EnginePostModelRefUpdate'
%    'EnginePreParameterEval'
%    'EnginePostParamEval'
%    'EnginePostSizeProp'
%    'EnginePostSampleTimeProp'
%    'EnginePostTypeProp'
%    'EnginePostProp'
%    'EnginePostRateTransInsert'
%    'EnginePostBlock'
%    'EnginePostHiddenBufInsert'
%    'EnginePostCEDPropagation'
%    'EnginePostSortedList'
%    'EnginePostHiddenSubsysInsert'
%    'EnginePostCallGraph'
%    'EnginePostFullCanIO'
%    'EnginePostFullCanPrm'
%    'EnginePostCompChecksum'
%    'EnginePostCompReuseInfo'
%    'EnginePostCanIO'
%    'EnginePostCanPrm'
%    'EnginePostBufferAlloc'
%    'EnginePostDWorkAlloc'
%    'EngineCompFailed'
%    'EngineCompPassed'
%    'EnginePostRTWIndices'
%    'EnginePreRTWData'
%    'EnginePostRTWData'
%    'EnginePostRTWCompFileNames'
%    'EngineRTWGenFailed'
%    'EngineRTWGenPassed'
%

%   Copyright 1990-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $

%
% the requisite nargin checking...
%
if nargin ~= 3,
  error('Needs three input arguments.');
end

bdh = get_param(model, 'UDDObject');

if isempty(bdh)
  error('Can add listener only when block diagram is executing')
end

bdh = handle(bdh);

%
% 
%
p = findprop(bdh, 'Listener_Storage_');
if isempty(p)
  p = schema.prop(bdh, 'Listener_Storage_', 'handle vector');
  p.Visible = 'off';
end

%
% Make sure that the listener isn't allready attached
%
bdListeners = bdh.Listener_Storage_;
for i=1:length(bdListeners)
  if isequal(bdListeners(i).callback, listenerCallback)
    return;
  end
end

%
% Create a new listener and attach it to the block diagram
%
hl = handle.listener(bdh, eventType, listenerCallback);
hl = [bdh.Listener_Storage_; hl];
bdh.Listener_Storage_ = hl;
  
%% [EOF] add_engine_listener.m