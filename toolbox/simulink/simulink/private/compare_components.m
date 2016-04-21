function diff = compare_components(componentA,componentB)
%
% Abstract
%   Given two configuration sets (or components) return the
% differences between them.
%
% Syntax
%
%   diff = compare_components(componentA, componentB)
%
% Inputs
%
%   componentA :  (Simulink.Configset)  
%                  
%   componentB :  (Simulink.Configset)     
%
% Output
%   diff       :  (struct) The elements of the structure are
%    
%     diff.Type       : The type of component that is being compared.
%
%     diff.Compatible : Whether the two components are compatible, that
%                       is they have the same number of fields and are
%                       of the same type.
%
%     diff.Differences: An array of structures of the form
%         Differences.Property : Name of the property
%         Differences.ValueA   : Value of the property for componentA
%         Differences.ValueB   : Value of the property for componentB
%
%     diff.Components : An array of structures of the same form as diff
%                       that give the differences for each subcomponent.
%
% Notes:
%   1.  Currently we use isequal to compare elements in the component,
%   we should probably do something more robust to detect differences.
%

% Copyright 2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $
  
  if nargin ~= 2
    error('There must be two arguments to this function.');
    diff = -1;
    return;
  end
 
  % Set up the difference structure.
  diff = struct('Type','','Compatible',true,'Differences','','Components','');
  diff.Differences = struct('Property',{},'ValueA',{},'ValueB',{});
  diff.Components = struct('Type','','Compatible',{},'Differences',{},'Components',{});
  
  % Check that the two components are of the same class and have
  % the same number of fields.
  if ~isequal(class(componentA), class(componentB))
    diff.Compatible = false;
    return;
  end

  diff.Type = class(componentA);
  afields = componentA.fields;
  bfields = componentB.fields;
  
  if (length(afields) ~= length(bfields))
    diff.Compatible =  false;
    return;
  end
  
  % Loop over all the fields in a component
  for i = 1:length(afields)
    if ~isequal(componentA.get(afields{i}), componentB.get(bfields{i}))
      compdiff.Property = afields{i};
      compdiff.ValueA = componentA.get(afields{i});
      compdiff.ValueB = componentB.get(afields{i});
      diff.Differences(end+1) = compdiff;
    end
  end
  
  % Currently, configuration sets should have the same number
  % of components.  For now return incompatible if they don't
  if (length(componentA.Components) ~= length(componentB.Components))
    diff.Compatible = false;
    return;
  else
    for i=1:length(componentA.Components)
      subDiff = compare_components(componentA.Components(i), componentB.Components(i));
      diff.Components(i) = subDiff;
    end
  end
  
%endfunction compare_components