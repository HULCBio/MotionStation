function openTransaction(h, name)

% Copyright 2004 The MathWorks, Inc.
  
  if (h.hasPendingTransaction)
    h.closeTransaction
  end

  get_transaction_l(h, 'Stateflow', name);
  get_transaction_l(h, 'Simulink', name);
  


function tr = get_transaction_l(h, dbname, name)
  try
    db = get(findpackage(dbname), 'DefaultDatabase');
    tr = handle.transaction(db);
    set(tr, 'OperationStore', 'on', 'InverseOperationStore', 'on');
    tr.Name = name;
    h.CurrentTransactions = [tr; h.CurrentTransactions];
  catch
    % ok to fail here if package is not loaded
    tr = [];
  end




  % Put this back when listener bug is fixed (G149260)
  % listener = handle.listener(t, 'ObjectChildAdded', 'disp(''called'')');
  % h.Listener = listener;
