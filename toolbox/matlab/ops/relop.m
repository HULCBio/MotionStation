%Relational operators.
% < > Relational operators.
%     The six relational operators are <, <=, >, >=, ==, and ~=.
%     A < B does element by element comparisons between A and B
%     and returns a matrix of the same size with elements set to logical
%     1 (TRUE) where the relation is true and elements set to logical 0
%     (FALSE) where it is not.  A and B must have the same dimensions
%     (or one can be a scalar).
%
% &   Element-wise Logical AND.
%     A & B is a matrix whose elements are logical 1 (TRUE) where both A 
%     and B have non-zero elements, and logical 0 (FALSE) where either has 
%     a zero element.  A and B must have the same dimensions (or one can 
%     be a scalar).
%
% &&  Short-Circuit Logical AND.
%     A && B is a scalar value that is the logical AND of scalar A and B.
%     This is a "short-circuit" operation in that MATLAB evaluates B only
%     if the result is not fully determined by A.  For example, if A equals
%     0, then the entire expression evaluates to logical 0 (FALSE), regard-
%     less of the value of B.  Under these circumstances, there is no need
%     to evaluate B because the result is already known.
%
% |   Element-wise Logical OR.
%     A | B is a matrix whose elements are logical 1 (TRUE) where either 
%     A or B has a non-zero element, and logical 0 (FALSE) where both have 
%     zero elements.  A and B must have the same dimensions (or one can 
%     be a scalar).
%
% ||  Short-Circuit Logical AND.
%     A || B is a scalar value that is the logical OR of scalar A and B.
%     This is a "short-circuit" operation in that MATLAB evaluates B only
%     if the result is not fully determined by A.  For example, if A equals
%     1, then the entire expression evaluates to logical 1 (TRUE), regard-
%     less of the value of B.  Under these circumstances, there is no need 
%     to evaluate B because the result is already known.
%
% ~   Logical complement (NOT).
%     ~A is a matrix whose elements are logical 1 (TRUE) where A has zero
%     elements, and logical 0 (FALSE) where A has non-zero elements.
%
% xor Exclusive OR.
%     xor(A,B) is logical 1 (TRUE) where either A or B, but not both, is 
%     non-zero.  See XOR.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 5.9.4.1 $  $Date: 2004/04/16 22:08:04 $
