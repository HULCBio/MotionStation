function theus = das_undo_stack(varargin)

% Copyright 2004 The MathWorks, Inc.

  persistent us;
  
  if (isempty(us))
    us = DAStudio.UndoStack;
  end
  
  theus = us;
  
