%Parentheses, braces, and brackets.
%( )  Parentheses are used to indicate precedence in arithmetic
%     expressions and to enclose arguments of functions in the usual
%     way. They are used to enclose subscripts of vectors and matrices
%     in a manner somewhat more general than the usual way. If X and V
%     are vectors, then X(V) is [X(V(1)), X(V(2)), ..., X(V(N))]. The
%     components of V must be integers and are used as subscripts. An
%     error occurs if any such subscript is less than 1 or greater
%     than the dimension of X.
%  
%     Parenthesis can also enclose logical (or 0-1) subscripts.
%     If V is logical, the non-zero elements of V define a mask into the
%     array X.  Logical arrays are produced by the relational and logical
%     operators or by the LOGICAL command.  Parentheses are supported by all
%     the MATLAB data types including the traditional double precision
%     arrays as well as the structure, cell, and character arrays.
%  
%     Some examples:
%        X(3) is the third element of X.
%        X([1 2 3]) is the first three elements of X.
%        If X has N components, X(N:-1:1) reverses them.
%        X(X>0.5) returns those elements of X that are > 0.5.
%  
%     The same indirect subscripting is used in matrices and arrays.
%     If V has M components and W has N components, then A(V,W) is the
%     M-by-N matrix formed from the elements of A whose subscripts are
%     the elements of V and W. For example, A([1,5],:) = A([5,1],:)
%     interchanges rows 1 and 5 of A.
%  
%{ }  Braces are used to form cell arrays.  They are similar to
%     brackets [ ] except that nesting levels are preserved.
%     {magic(3) 6.9 'hello'} is a cell array with three elements.
%     {magic(3),6.9,'hello'} is the same thing.  
%     {'This' 'is' 'a';'two' 'row' 'cell'} is a 2-by-3 cell array.
%     The semicolon ends the first row. {1 {2 3} 4} is a 3 element
%     cell array where element 2 is itself a cell array.
%  
%     Braces are also used for content addressing of cell arrays.
%     They act similar to parentheses in this case except that the
%     contents of the cell are returned. 
%    
%     Some examples:
%        X{3} is the contents of the third element of X.
%        X{3}(4,5) is the (4,5) element of those contents.
%        X{[1 2 3])} is a comma-separated list of the first three
%        elements of X.  It is the same as X{1},X{2},X{3} and makes sense
%        inside [] ,{}, or in function input or output lists (see LISTS).
%  
%     You can repeat the content addressing for nested cells so
%     that X{1}{2} is the contents of the second element of the cell
%     inside the first cell of X.  This also works for nested
%     structures, as in X(2).field(3).name or combinations of cell arrays
%     and structures, as in  Z{2}.type(3).
%
%[ ]  Brackets are used in forming vectors and matrices.
%     [6.9 9.64 SQRT(-1)] is a vector with three elements
%     separated by blanks. [6.9, 9.64, sqrt(-1)] is the same
%     thing. [1+I 2-I 3] and [1 +I 2 -I 3] are not the same.
%     The first has three elements and the second has five.
%     [11 12 13; 21 22 23] is a 2-by-3 matrix. The semicolon
%     ends the first row.
%  
%     Vectors and matrices can be concatenated with [ ] brackets.
%     [A B; C] is allowed if the number of rows of A equals
%     the number of rows of B and the number of columns of A
%     plus the number of columns of B equals the number of
%     columns of C. This rule generalizes in a hopefully
%     obvious way to allow fairly complicated constructions.
%     N-D arrays within brackets are concatenated along the
%     first two dimensions. The remaining dimensions must match.
%
%     A = [] stores an empty matrix in A. See CLEAR to remove
%     variables from the current workspace.
%
%     For the use of [ and ] on the left of the = in multiple
%     assignment statements, see LU, EIG, SVD and so on.
%
%     See also LOGICAL, LISTS, PUNCT, CLEAR.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.14 $  $Date: 2002/04/15 04:09:16 $
