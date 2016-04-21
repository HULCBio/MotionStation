function Status = undo(h)
%UNDO  Undoes transaction.

%   Author(s): P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:18:08 $

% RE: Coded for ransactions of class ctrluis/transaction 

% Get last transaction
LastT = h.EventRecorder.popundo;

% Undo it (will perform required updating)
LastT.undo;

% Update status and history
Status = sprintf('Undoing %s.',LastT.Name);
h.newstatus(Status);
h.recordtxt('history',Status);

