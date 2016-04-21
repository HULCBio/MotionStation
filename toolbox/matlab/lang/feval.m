%FEVAL Execute the specified function.
%   FEVAL(F,x1,...,xn) evaluates the function specified by a function
%   handle or function name, F, at the given arguments, x1,...,xn.
%   For example, if F = @foo, FEVAL(F,9.64) is the same as foo(9.64).
%
%   If a function handle is bound to more than one built-in or 
%   M-file, (that is, it represents a set of overloaded functions), 
%   then the data type of the arguments x1 through xn, determines 
%   which function is executed.
%
%   FEVAL is usually used inside functions which take function
%   handles or function strings as arguments.  Examples include 
%   FZERO and EZPLOT.
%
%   [y1,..,yn] = FEVAL(F,x1,...,xn) returns multiple output arguments.
%
%   Within methods that overload built-in functions, use BUILTIN(F,...)
%   to execute the original built-in function.  Note that when using
%   BUILTIN, F must be a function name and not a function handle.
%
%   See also BUILTIN, EVAL.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 5.12.4.1 $  $Date: 2004/04/16 22:07:10 $
%   Built-in function.
