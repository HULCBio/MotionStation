function [varargout] = logical(varargin)
%LOGICAL Convert numeric values to logical.
%   LOGICAL(X) converts the elements of the array X into logicals,
%   thus returning an array that can be used for logical indexing
%   or logical tests.  logicals can have the values 0 and 1 corresponding
%   to false and true, respectively.  Any non-zero real element of input
%   array X is converted to a logical 1 while zeros in X become logical 0.
%   Complex values and NaNs cannot be converted to logicals and will
%   result in a conversion error.  logical arrays can also be created
%   using the creation functions TRUE and FALSE.
%
%   Because logical arrays are returned by the logical operators (&,|,~)
%   and the relational operators (==,~=,<,<=,>=,>), as well as by
%   functions like ANY, ALL, ISNAN, ISINF, ISFINITE, ISEMPTY, ISEQUAL,
%   etc., it is unusual to need to invoke the LOGICAL function itself.
%
%   The term "logical indexing" refers to any indexing operation where
%   the index expression is a logical array, in which case the index is
%   treated as a mask that selects elements from the indexed array.  In
%   essence, it is a short-hand notation for A(FIND(B)) that enables us
%   to simply write A(B) when B is a logical array.  The result is the
%   elements of A at the indices where B is one.  It is often convenient
%   to derive the index expression from the indexed data itself.  For
%   example, the positive elements of a vector A can be obtained using
%   A(A>0).
%
%   Logicals can be combined with doubles in arithmetic operations and
%   will produce results that are of type double.  You can convert a
%   logical to any other numeric data type using the appropriate
%   conversion function.  For example, double(A) converts the logical
%   array A into a double array.
%
%   See also ISLOGICAL, FALSE, TRUE, RELOP, OPS.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/10 23:25:29 $
%   Built-in function.

if nargout == 0
  builtin('logical', varargin{:});
else
  [varargout{1:nargout}] = builtin('logical', varargin{:});
end
