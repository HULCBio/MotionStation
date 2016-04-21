function undo(t)
%UNDO  Undoes transaction.

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:18:37 $

% Undo transaction
t.Transaction.undo;

% Evaluate refresh function
for ct=1:length(t.RootObjects)
    try
        LocalRefresh(t.RootObjects(ct));
    end
end


%---------------------------------------------

function LocalRefresh(Root)
% REVISIT: this is a workaround 

switch Root.classhandle.package.Name
case 'sisodata'
    % Broadcast LoopDataChanged event (triggers global update)
    Root.dataevent('all');
case 'plotconstr'
    if ishandle(Root)
        update(Root);
    end
end
