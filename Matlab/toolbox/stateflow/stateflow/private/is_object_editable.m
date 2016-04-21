
% Copyright 2003-2004 The MathWorks, Inc.
  
function isEditable = is_object_editable(obj)

  % Model must not be locked
  model = obj.Machine.up;
  isEditable = ~isequal(model.Lock, 'on');

  % Machine must not be locked or iced
  isEditable = isEditable && ~obj.Machine.Locked && ~obj.Machine.Iced;
  
  % this object and every SF object above this object must also be unlocked/uniced
  while (isa(obj, 'Stateflow.Object') && isEditable)
    if (isa(obj, 'Stateflow.Chart') || ...
      isa(obj, 'Stateflow.EMChart'))
      % The current object might be locked or iced
      isEditable = isEditable && ~obj.Locked && ~obj.Iced;
    end
    obj = obj.up;
  end
  
