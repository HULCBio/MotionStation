function pushundo(r,T)
%PUSHUNDO  Pushes transaction onto Undo stack.

%   Author: P. Gahinet  
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:18:30 $

% Defaults 
% REVISIT: Add to sisoprefs
UndoStackDepth = 20;

% Clear Redo stack
if length(r.Redo)
    delete(r.Redo);
    r.Redo = [];
end
    
% Add transaction to bottom of Undo stack
UndoStack = [r.Undo;T];

% Truncate Undo stack
if length(UndoStack)>UndoStackDepth
    delete(UndoStack(1));
    UndoStack = UndoStack(2:end,:);
end

% Update property (triggers menu label update)
r.Undo = UndoStack;
