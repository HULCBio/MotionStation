function record_stop(hThis)
% Stop recording property changes

% Copyright 2002 The MathWorks, Inc.

hThis.TransactionPropertyListeners = [];
t = hThis.Transaction;
commit(t);

