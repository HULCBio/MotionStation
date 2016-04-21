function propVals = get_valid_property_values(obj, propName)

% Copyright 2003-2004 The MathWorks, Inc.

clsName = get(classhandle(obj), 'Name');

switch (clsName)
    case 'Data'
        propVals = data_values_l(obj, propName);
    case 'Event'
        propVals = event_values_l(obj, propName);
    otherwise
        propVals = default_values_l(obj, propName);      
end


function pv = data_values_l(obj, propName)
switch propName
  
 case 'Scope'

  isml = strcmp(obj.DataType, 'ml');
  % Local, Constant and Parameter don't depend on parentage
  pv = {'Local'};
  if (~isml)
    % "ml" type data cannot be Constant or Parameter
    pv = [pv; {'Constant'; 'Parameter'}];
  end
  
  parent = obj.up;
  
  % See if some additional scopes are valid
  if (isa(parent, 'Stateflow.Chart') | isa(parent, 'Stateflow.EMChart'))
    if (~isml)
      % "ml" type data cannot be chart IO
      pv = [pv; {'Input'; 'Output'}];
    end
  elseif(isa(parent, 'Stateflow.Function') | isa(parent, 'Stateflow.EMFunction') | isa(parent, 'Stateflow.TruthTable'))
    pv = [pv; {'Function input'; 'Function output'; 'Temporary'}];
  elseif(isa(parent, 'Simulink.BlockDiagram') | isa(parent, 'Stateflow.Machine'))
    pv = [pv; {'Imported'; 'Exported'}];
  end
  
 case 'Port'        
  scope = obj.scope;
  pv = {};
  if (isequal(scope, 'Input') | isequal(scope, 'Output'))
    others = find(obj.up, '-depth', 1, '-isa', 'Stateflow.Data', 'Scope', scope);
    for i=1:length(others)
      pv = [pv;{sf_scalar2str(i)}];
    end
  end
  
 case 'DataType'
  pv = {'double', 'single' ,'int32', 'int16', 'int8',... 
		    'uint32', 'uint16', 'uint8',...
		    'boolean', 'fixpt'};
  
  scope = obj.scope;
  if (strcmp(scope, 'Input') | strcmp(scope, 'Output') | strcmp(scope, 'Parameter'))
    pv = [{'inherited'}, pv];      
  elseif ~strcmp(scope, 'Constant')
    pv = [pv, {'ml'}];      
  end		    
  
 otherwise
  pv = default_values_l(obj, propName);
end



function pv = event_values_l(obj, propName)

parent = get(classhandle(obj.up), 'Name');
switch propName

    case 'Scope'
        pv = {'Local'};
        if (isequal(parent, 'Chart'))
            pv = [pv; {'Input'; 'Output'}];
        elseif(isequal(parent, 'BlockDiagram'))
            pv = [pv; {'Imported'; 'Exported'}];
        end
    
    case 'Trigger'
        scope = obj.Scope;
        if (isequal(scope, 'Output'))
            pv = {'Either'; 'Function call'};
        elseif (isequal(scope, 'Input'))
            pv = {'Either'; 'Rising'; ...
                'Falling'; 'Function call'};
        else
            pv = {};
        end
        
    case 'Port'        
        scope = obj.scope;
        pv = {};
        if (isequal(scope, 'Input'))
            others = find(obj.up, '-depth', 1, '-isa', 'Stateflow.Event', 'Scope', scope);
            for i=1:length(others)
                pv = [pv;{sf_scalar2str(i)}];
            end
        end
        if (isequal(scope, 'Output'))
            otherData = find(obj.up, '-depth', 1, '-isa', 'Stateflow.Data', 'Scope', scope);
            dl = length(otherData);
            others = find(obj.up, '-depth', 1, '-isa', 'Stateflow.Event', 'Scope', scope);
            for i=1:length(others)
                pv = [pv;{sf_scalar2str(dl+i)}];
            end
        end
          
            
    otherwise
        pv = default_values_l(obj, propName);
end


function pv = default_values_l(obj, propName)

try
    pv = set(obj, propName);
catch
    pv = {};
end

    

