function recordoff(Constr,T)
%RECORDON  Starts recording Edit Constraint transaction.

%   Authors: P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.4 $ $Date: 2002/04/10 05:12:34 $

if ~isempty(Constr.HG) & ~isempty(T.Transaction.Operations)
    % Commit and stack transaction
    % RE: Only when something changed! (FocusLost listener triggers even w/o touching data)
    Constr.EventManager.record(T);
else
    delete(T);
end
