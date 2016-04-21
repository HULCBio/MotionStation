function closeTransaction(h)

% Copyright 2004 The MathWorks, Inc.
  
  multiTrans = false;

  % Get the total number of transactions
  allTrans = h.CurrentTransactions;
  numTrans = 0;

  for i=length(allTrans):-1:1
      t = allTrans(i);
      if (~h.isTransactionEmpty(t))
         numTrans = numTrans+1;
      end
  end
  % If you have more than one Transaction make a 
  % transaction and make the others children of this 
  if (numTrans > 1)
    multiTrans = true;
    db = get(findpackage('DAStudio'), 'DefaultDatabase');
    tr = handle.transaction(db);
  end
  
  % go backwards so we don't have problems committing these in the wrong order
  for i= length(allTrans):-1:1
    t = allTrans(i);
    t.commit;
    % If you are in a multi-trans situation
    % add the children to the bigger transaction in DAStudio
    if (multiTrans == true)
        connect(t, tr, 'up');
    end
    
    % only add to the undo stack if something happened
    if (~h.isTransactionEmpty(t))
        % If you are in multi-Trans do not put the 
	 % children put just the parent in the undo stack
        if (multiTrans == false)
            h.UndoStack = [t; h.UndoStack];
        end
      h.RedoStack = [];
    end
  end
  % If you have a multi-Trans just put the bigger transaction in there 
  % We have already skipped adding the child transactions into our 
  % undo stack
  if (multiTrans == true)
    h.UndoStack = [tr; h.UndoStack];
    tr.commit;
  end
    
  h.CurrentTransactions = [];
