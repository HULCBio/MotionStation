function Status = redo(h)
%REDO  Undoes transaction.

%   Author(s): P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:18:05 $

% Get last transaction
LastT = h.EventRecorder.popredo;

% Redo it (will perform required updating)
LastT.redo;

% Return status
Status = sprintf('Redoing %s.',LastT.Name);
h.newstatus(Status);
h.recordtxt('history',Status);

