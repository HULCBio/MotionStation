function status = das_undo_gateway(varargin)

% Copyright 2004 The MathWorks, Inc.

  if (nargin < 1)
    status = logical(0);
    return;
  end
  
  
  cmd = varargin{1};
  switch(cmd)
   
   case 'can_undo'
    status = can_undo_l;
   case 'can_redo'
    status = can_redo_l;
   case 'register'
    user = varargin{2};
    status = register_l(user);
   case 'unregister'
    status = unregister_l;
   case 'undo'
    status = undo_l;
   case 'redo'
    status = redo_l;
   case 'clear'
    status = clear_l;
  end
  
  

function success = clear_l;
  mu = das_undo_stack ;
  mu.clear;
  success = logical(1);

function success = undo_l
  mu = das_undo_stack;
  mu.undo;
  success = logical(1);

function success = redo_l
  mu = das_undo_stack;
  mu.redo;
  success = logical(1);
  
function canUndo = can_undo_l
  mu = das_undo_stack;
  canUndo = mu.canUndo;
  
function canRedo = can_redo_l
  mu = das_undo_stack;
  canRedo = mu.canRedo;

function success = register_l(user)
  us = das_undo_stack;
  us.register(user);
  success = logical(1);

function success = unregister_l
  us = das_undo_stack;
  us.unregister;
  success = logical(1);
