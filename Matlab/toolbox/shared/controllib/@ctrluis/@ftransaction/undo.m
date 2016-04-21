function undo(t)
% Undoes transaction.

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:18:13 $
feval(t.UndoFcn{:});