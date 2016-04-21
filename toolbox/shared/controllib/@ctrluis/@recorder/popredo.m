function T = popredo(r)
%POPREDO  Pops last transaction in Redo stack.

%   Author: P. Gahinet  
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:18:28 $

% Get last undone transaction
T = r.Redo(end);

% Remove it from Redo stack
r.Redo = r.Redo(1:end-1);

% Add it to Undo stack
r.Undo = [r.Undo ; T];
