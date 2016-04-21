function val = typecheck(arg,classname)
%TYPECHECK check if variable is of specified type
%   VAL = TYPECHECK(ARG,CLASSNAME) checks if ARG is an
%   object with classname CLASSNAME and returns true
%   if it is, and false if it is not.

% Copyright 2002 The MathWorks, Inc.

if (numel(arg) == 1) && ...
        ishandle(arg) && isa(handle(arg),classname)
    val = true;
else
    val = false;
end