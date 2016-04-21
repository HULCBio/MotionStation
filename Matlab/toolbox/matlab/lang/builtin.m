%BUILTIN  Execute built-in function from overloaded method.
%   BUILTIN is used in methods that overload built-in functions to execute
%   the original built-in function. If F is a string containing the name
%   of a built-in function then BUILTIN(F,x1,...,xn) evaluates that
%   function at the given arguments.
%
%   BUILTIN(...) is the same as FEVAL(...) except that it will call the
%   original built-in version of the function even if an overloaded one
%   exists (for this to work, you must never overload BUILTIN).
%
%   [y1,..,yn] = BUILTIN(F,x1,...,xn) returns multiple output arguments.
%
%   See also FEVAL.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9 $  $Date: 2002/04/15 04:16:04 $
%   Built-in function.
