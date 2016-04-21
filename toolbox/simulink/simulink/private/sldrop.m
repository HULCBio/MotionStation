function output = sldrop(varargin)
% SLDROP -- handle drop event to a block diagram

% Copyright 2003 The MathWorks, Inc.
% $Revision: 1.1.6.6 $

% Input arguments
% 1 - Name of desired drop function
%     'canAcceptDrop'
%     'acceptDrop'
%     'canAcceptMouseDrop'
%     'getDropOperations'
%     'doDropOperation'
% 2 - Object receiving the drop (the model)
% 3 - List of objects being dragged
% 4 - Boolean to decide if we are allowed to take SF objects
% 5 - Optional argument depending on dropFunction
%     canAcceptMouseDrop - Mouse status structure
%     getDropOperations  - Mouse status structure
%     doDropOperation    - String describing operation
%

if (nargin > 3)
  dropFcn = varargin{1};
  model = varargin{2};
  dragVector = varargin{3};
  acceptSF = varargin{4};
  if (nargin > 4) 
    optionalArg = varargin{5};
  end

  if (isempty(dragVector))
    output = false;
    return;
  end


  [slVec, sfVec, other] = split_stateflow_simulink_and_other_l(dragVector);
    
  if (~isempty(other))
    output = false;
    switch (dropFcn)
     case {'canAcceptDrop',
	   'acceptDrop',
	   'canAcceptMouseDrop',
	   'doDropOperation'}
      % the above don't need to change from true
     case 'getDropOperations'
      output = [];
    end
    return;
  end
  output = true;

  if (~isempty(slVec)) 
    switch(dropFcn)
     case 'canAcceptDrop'
      output = can_accept_drop_l(model, slVec);
     case 'acceptDrop'
      output = accept_drop_l(model, slVec);
     case 'canAcceptMouseDrop'
      output = can_accept_mouse_drop_l(model, slVec, optionalArg);
     case 'doDropOperation'
      output = do_drop_operation_l(model, slVec, optionalArg);
     case 'getDropOperations'
      output = get_drop_operations_l(model, slVec, optionalArg);
    end
  end
  
  if (~isempty(sfVec))
    machine = find(model, '-isa', 'Stateflow.Machine');
    if (isempty(machine) | ~acceptSF)
      output = false;
    else
      switch(dropFcn)
       case 'canAcceptDrop'
	output = output & canAcceptDrop(machine, sfVec);
       case 'acceptDrop'
	output = output & acceptDrop(machine, sfVec);
       case 'canAcceptMouseDrop'
	try  
	  output = output & canAcceptMouseDrop(machine, sfVec, optionalArg);
	catch
	  output = output & canAcceptDrop(machine, sfVec);
	end
       case 'doDropOperation'
	try
	  output = output & doDropOperation(machine, sfVec, optionalArg);
	catch 
	  output = output & acceptDrop(machine, sfVec);
	end
	
       case 'getDropOperations'
	try
	  sfOutput = getDropOperations(machine, sfVec, optionalArg);
	  if (~isempty(slVec)) 
	    output = intersect(output, sfOutput);
	  else
	    output = sfOutput;
	  end
	catch 
	  if (canAcceptDrop(machine, sfVec))
	    if (~isempty(slVec)) 
	      output = intersect(output, {'Move'});
	    else
	      output = {'Move'};
	    end
	  end
	end
	
      end
    end
  end
  
else
  output = false
end




function [slVec, sfVec, otherVec] = split_stateflow_simulink_and_other_l(vec)
slVec = [];
sfVec = [];
otherVec = []; 

for i=1:length(vec)
  item = vec(i);
  pkgName = get(get(classhandle(item), 'Package'), 'Name');
  if (isequal(pkgName, 'Simulink'))
    slVec = [slVec item];
  elseif (isequal(pkgName, 'Stateflow'))
    sfVec = [sfVec item];
  else
    otherVec = [otherVec item];
  end
end



function canAccept = can_accept_drop_l(model, slVector)
canAccept = sl_is_movable_l(model, slVector);


function success = accept_drop_l(model, dragVector)
success = false;
if (can_accept_drop_l(model, dragVector))
  success = sl_copy_or_move_l(model, dragVector, true);
end



function canAccept = can_accept_mouse_drop_l(model, slVector, mouseState)
wantsToMove = true;
if (isfield(mouseState, 'Right'))
  if (mouseState.Right)
    wantsToMove = false;
  end
end

if (wantsToMove)
  canAccept = sl_is_movable_l(model, slVector);
else
  canAccept = sl_is_copyable_l(model, slVector);
end


function success = do_drop_operation_l(model, slVector, operation)
if (isequal(operation, 'Copy'))
  success = sl_copy_or_move_l(model, slVector, false);
else
  success = sl_copy_or_move_l(model, slVector, true);
end


function operations = get_drop_operations_l(model, slVector, mouseState)
operations = {};
if (isfield(mouseState, 'Right'))
  if (mouseState.Right)
    if (sl_is_copyable_l(model, slVector))
      operations = {'Copy'};
    end
  end  
end

if (sl_is_movable_l(model, slVector))
  operations = [operations; {'Move'}];
end





function success = sl_copy_or_move_l(model, vec, moveNotCopy)
success = true;
for i=1:length(vec)
  item = vec(i);
  copyItem = item.copy;
  try
    attachConfigSet(model, copyItem, true);
    if (moveNotCopy)
      csModel = item.up;
      csModel.detachConfigSet(item.Name);
    end    
  catch
    success = false;
    return;
  end
end


function movable = sl_is_movable_l(model, vec)
% Movable iff copyable, not default config set,
% AND not "moving" to same model
movable = false;
if (sl_is_copyable_l(model, vec))
  for (i=1:length(vec))
    item = vec(i);
    try
      currentModel = item.up;
      activeCS = currentModel.getActiveConfigSet;
      if (isequal(currentModel, model) | isequal(item, activeCS))
	return;
      end
    catch
      return;
    end
  end
  movable = true;
end

  


function copyable = sl_is_copyable_l(model, vec)

% Copyable iff all items are configsets and model is unlocked and not library
if (isequal(get(model, 'lock'), 'on')) || model.isLibrary
  copyable = false;
  return;
end

copyable = true;
for (i=1:length(vec))
  item = vec(i);
  if (~(isa(item, 'Simulink.ConfigSet')))
    copyable = false;
    return;
  end
end
