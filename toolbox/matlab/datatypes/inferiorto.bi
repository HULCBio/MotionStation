function [varargout] = inferiorto(varargin)
%INFERIORTO Inferior class relationship.
%   INFERIORTO('CLASS1','CLASS2',...) invoked within a class
%   constructor method (say myclass.m) indicates that myclass's method
%   should not be invoked if a function is called with an object of class
%   myclass and one or more objects with class CLASS1, CLASS2, etc.
%
%   Suppose A is of class 'class_a', B is of class 'class_b' and C is of
%   class 'class_c'.  Also suppose class_c.m contains the statement:
%      INFERIORTO('CLASS_A')
%   then E = FUN(A,C) or E = FUN(C,A) will invoke CLASS_A/FUN.
%
%   If a function is called with two objects with an unspecified
%   relationship, then the two objects are considered to be of equal
%   precedence and the leftmost object's method will be called.  So
%   FUN(B,C) calls CLASS_B/FUN, while FUN(C,B) calls CLASS_C/FUN.
%
%   See also SUPERIORTO.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.9.4.2 $  $Date: 2004/04/10 23:25:20 $
%   Built-in function.

if nargout == 0
  builtin('inferiorto', varargin{:});
else
  [varargout{1:nargout}] = builtin('inferiorto', varargin{:});
end
