function override(this,newproperties)

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/12/13 02:49:22 $

% User defined properties
fldnames = fieldnames(newproperties);
for i=1:length(fldnames)
  if isprop(this,fldnames{i})
    this.(fldnames{i}) = newproperties.(fldnames{i});
  else
    msg = sprintf('%s is not a property that can be set for a %s.', ...
          fldnames{i},getShapeType(class(this)));
    error('map:MapGraphics:badProperty','%s',msg);
  end
end


function type = getShapeType(classname)
s = regexp(classname,'\.');
f = regexp(classname,'Legend');
type = classname(s+1:f-1);
