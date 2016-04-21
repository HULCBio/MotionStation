function record_start(hThis)
% Begin recording property changes

% Copyright 2002 The MathWorks, Inc.

taction = handle.transaction(hThis.Container);
schema.prop(taction,'CurrentTransaction','MATLAB array');

hThis.Transaction = taction;

target_props = hThis.TargetProperties;

% By default, record every property change
if strcmp(target_props,'-auto')
  
  % Turn on transaction recording
  taction.OperationStore = 'on';
  taction.InverseOperationStore = 'on';
  return;
end

% Limit recording to specified properties  
target = hThis.Target;
  
allProps = target.classhandle.properties;
propObj = [];

for n = 1:length(target_props)
  propObj = [propObj; find(allProps,'Name',target_props{n})];
end

% Set up the pre and post set listener to capture the transaction
plistener(1) = handle.listener(target, propObj, ...
    'PropertyPreSet', @locCaptureSetOp);
plistener(2) = handle.listener(target, propObj, ...
    'PropertyPostSet', @locStoreSetOp);

set(plistener,'CallbackTarget',taction);
set(hThis,'TransactionPropertyListeners',plistener);

% ---------------------------------------------------------------
function locCaptureSetOp(hT, hEvent)
% Capture the set operation through a transaction

t = handle.transaction(hEvent.AffectedObject);
hT.CurrentTransaction = t;
t.OperationStore = 'on';
t.InverseOperationStore = 'on';
t.Compression = 'on';

% ---------------------------------------------------------------
function locStoreSetOp(hT, hEvent)
% Commit the transaction that captured the set operation

ct = hT.CurrentTransaction;
hT.CurrentTransaction = ct.up;
ct.commit;
connect(ct, hT, 'up');

