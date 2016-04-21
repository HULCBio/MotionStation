function h = getGraphicsProperties(this,feature)
%GETGRAPHICSPROPERTIES Returns a legend specific to a feature.
%
%   GETGRAPHICSPROPERTIES(FEATURE) returns a copy of this legend with property
%   values set to symbolize FEATURE.
%   

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/12/13 02:49:21 $

%   The "feature" is one feature of a layer. Features have "attributes" and
%   these attributes have specific values. The "spec" is this legend object. The
%   spec describes how to symbolize features in a layer. The graphics properties
%   of the feature can be made the same for all features of a layer (a
%   "Default"), or they can be dependent on the value of an attribute.

h = struct(this);

% specPropertyNames are HG properties.
specPropertyNames = fieldnames(h);

% For each HG property
for i=1:numel(specPropertyNames)
  match = false;
  specPropertyValue = this.(specPropertyNames{i});


  specAttributeNames = specPropertyValue(:,1)'; % The names of all the attributes
                                                % that the user wishes to use
                                                % to change the value of
                                                % specPropertyName.
  % Handle the default, if there is one.
  defaultIdx = strmatch('default',lower(specAttributeNames));
  if ~isempty(defaultIdx)
    if isempty(specPropertyValue{defaultIdx,2}) % {'Default,'',PropertyValue}
      h.(specPropertyNames{i}) = specPropertyValue{defaultIdx,3};
      specPropertyValue(defaultIdx,:) = []; 
      specAttributeNames = specPropertyValue(:,1)';
    end
  end % Finished handling the default.
  
  % For each attribute name in the spec
  for j=1:numel(specAttributeNames)
    % Get the value of the Attribute in the feature
    if isfield(feature.Attributes,specAttributeNames{j})
      featureAttributeValue = feature.Attributes.(specAttributeNames{j});
    else
      error('The features of this layer do not have a ''%s'' attribute.',...
            specAttributeNames{j});
    end
    specAttributeValue = specPropertyValue{j,2};
    specHGPropertyValue = specPropertyValue{j,3};
    % Compare the value of the attribute in the feature to the value of the
    % attribute in the spec.
    if length(specAttributeValue) == 2  &&... % specAttributeValue is a range.
          ~ischar(specAttributeValue) 
      if (specAttributeValue(1) <= featureAttributeValue) &&...
            (featureAttributeValue <= specAttributeValue(2)) % True if feature
                                                             % Attribute value
                                                             % is in the range.                
        if (size(specHGPropertyValue,2) == 2 &&... % Continuous symbolization
            ~ischar(specHGPropertyValue)) ||...    % The range won't be a character
              isColormap(specHGPropertyValue)
          
          if isColormap(specHGPropertyValue) % Colormap
            numColors = size(specHGPropertyValue,1);
            % featureAttributeValue will be in range already so INTERP1 will
            % never return NaN.
            p = interp1(specAttributeValue,[1 numColors],featureAttributeValue);	
            h.(specPropertyNames{i}) = specHGPropertyValue(round(p),:);
          else
            p = interp1(specAttributeValue,specHGPropertyValue,featureAttributeValue);
            h.(specPropertyNames{i}) = p;
          end
        else % Discrete symbolization
          h.(specPropertyNames{i}) = specHGPropertyValue;
        end
      end
    elseif isequal(featureAttributeValue,specAttributeValue) % Discrete and
                                                             % not a range.
      if isfield(h,specPropertyNames{i})
        h.(specPropertyNames{i}) = specHGPropertyValue;
      else
        error('Unable to set the ''%s'' property.',specPropertyNames{i})
      end
    end
  end
  % Removes the field associated with the property name from the structure.
  % This works as long as we are not setting any handle graphics property to
  % cell arrays.
  if iscell(h.(specPropertyNames{i}))
    h = rmfield(h,specPropertyNames{i});
  end
end

function b = isColormap(value)
% True if value is Mx3 and M > 1. This function treats a one color colormap as
% a single color and therefore returns false for one color colormaps.
b = isnumeric(value) && size(value,2) == 3 && size(value,1) > 1;
