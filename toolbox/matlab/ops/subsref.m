%SUBSREF Subscripted reference.
%   A(I) is an array formed from the elements of A specifed by the
%   subscript vector I.  The resulting array is the same size as I except
%   for the special case where A and I are both vectors.  In this case,
%   A(I) has the same number of elements as I but has the orientation of A.
%
%   A(I,J) is an array formed from the elements of the rectangular
%   submatrix of A specified by the subscript vectors I and J.  The
%   resulting array has LENGTH(I) rows and LENGTH(J) columns.  A colon
%   used as a subscript, as in A(I,:), indicates the entire column (or
%   row).
%
%   For multi-dimensional arrays, A(I,J,K,...) is the subarray specified
%   by the subscripts.  The result is LENGTH(I)-by-LENGTH(J)-by-LENGTH(K)-...
%
%   A{I} when A is a cell array and I is a scalar is a copy of
%   the array in the specified cell of A.  If I has more than one
%   element, this expression is a comma separated list (see LISTS).
%   Multiple subscripts that specify a scalar element, as in A{3,4}, also
%   work.
%
%   A(I).field when A is a structure array and I is a scalar is a copy of
%   the array in the field with the name 'field'.  If I has more than one
%   element, this expression is a comma separated list.  If A is a 1-by-1
%   structure array, then the subscript can be dropped.  In this case,
%   A.field is the same as A(1).field.
%
%   B = SUBSREF(A,S) is called for the syntax A(I), A{I}, or A.I
%   when A is an object.  S is a structure array with the fields:
%       type -- string containing '()', '{}', or '.' specifying the
%               subscript type.
%       subs -- Cell array or string containing the actual subscripts.
%
%   For instance, the syntax A(1:2,:) invokes SUBSREF(A,S) where S is a
%   1-by-1 structure with S.type='()' and S.subs = {1:2,':'}. A colon
%   used as a subscript is passed as the string ':'.
%
%   Similarly, the syntax A{1:2} invokes SUBSREF(A,S) where S.type='{}'
%   and the syntax A.field invokes SUBSREF(A,S) where S.type='.' and
%   S.subs='field'.
%
%   These simple calls are combined in a straightforward way for
%   more complicated subscripting expressions.  In such cases
%   length(S) is the number of subscripting levels.  For instance, 
%   A(1,2).name(3:5) invokes SUBSREF(A,S) where S is 3-by-1 structure
%   array with the following values:
%       S(1).type='()'       S(2).type='.'        S(3).type='()'
%       S(1).subs={1,2}      S(2).subs='name'     S(3).subs={3:5}
%
%   See also SUBSASGN, SUBSTRUCT, PAREN, SUBSINDEX, LISTS.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.13 $  $Date: 2002/04/15 04:10:22 $
%   Built-in function.
