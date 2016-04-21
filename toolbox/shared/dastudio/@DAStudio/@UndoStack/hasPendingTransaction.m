function hasTrans = hasPendingTransaction(h)

% Copyright 2004 The MathWorks, Inc.

  ct = h.CurrentTransactions;
  hasTrans = logical(0);
  for i=1:length(ct)
    t = ct(i);
    if (~h.isTransactionEmpty(t))
      hasTrans = logical(1);
      return;
    end
  end
  
    
  
	
