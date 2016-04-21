function append(this,newproperties)

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/12/13 02:49:19 $

% User defined properties
fldnames = fieldnames(newproperties);
for i=1:length(fldnames)
  if isprop(this,fldnames{i})
    % Always replace the default with the new property's default, 
    % if there is one.
    if isAnyDefault(newproperties.(fldnames{i})) 
      legendDefault = strcmp('default',lower(this.(fldnames{i})(:,1)));
      ruleDefault = strcmp('default',lower(newproperties.(fldnames{i})(:,1))); 
      if any(ruleDefault)
        % Replace the default and cat the rest.
        this.(fldnames{i})(legendDefault,:) = newproperties.(fldnames{i})(ruleDefault,:); 
        newproperties.(fldnames{i})(ruleDefault,:) = [];
        this.(fldnames{i}) = cat(1,this.(fldnames{i}), ...          
                                 newproperties.(fldnames{i}));
      else
        this.(fldnames{i}) = cat(1,this.(fldnames{i}), ...
                                 newproperties.(fldnames{i}));
      end
    else
      this.(fldnames{i}) = cat(1,this.(fldnames{i}), ...
                               newproperties.(fldnames{i}));
    end
  else
    error('%s is not a property that can be set for a %s shape.', ...
          fldnames{i},getShapeType(class(this)));
  end
end

function b = isAnyDefault(rule)
% True if any of the rules for the property are a default rule.
b = false;
if  any(strcmp(lower({rule{:,1}}),'default')) &&...
      isempty(rule{strcmp(lower({rule{:,1}}),'default'),2})
  b = true;
end

function type = getShapeType(classname)
s = regexp(classname,'\.');
f = regexp(classname,'Legend');
type = classname(s+1:f-1);
