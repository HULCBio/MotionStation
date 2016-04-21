function result = requestJavaAdapter(object)
%REQUESTJAVAADAPTER Support function for GUIDE

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.7 $
  
  len = length(object);
  if len == 1
    if ishandle(object) & ~isjava(object)
      result = java(handle(object));
    else
      error('''requestJavaAdapter'' argument must be a handle list.');
    end
  else
    if all(ishandle(object) & ~isjava(object))
      result = cell(len, 1);
      for i = 1:len
        result{i} = java(handle(object(i)));
      end
    else
      error('''requestJavaAdapter'' argument must be a handle list.');
    end
  end
