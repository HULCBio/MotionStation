function varargout = solve(varargin);
%SOLVE  Find the zeros of symbolic expressions.
%   SOLVE(expr1,expr2,...,exprN,var1,var2,...varN) or
%   SOLVE(expr1,expr2,...,exprN) finds zeros of symbolic expressions.
%
%   The exprs are symbolic expressions.  The vars are symbolic variables or
%   strings specifying the unknown variables.  SOLVE seeks zeros of the
%   expressions.  If not specified, the unknowns are determined by FINDSYM.
%   If no analytical zero is found and the number of expressions equals
%   the number of dependent variables, a numeric solution is attempted.
%
%   Three different types of output are possible.  For one expression and
%   one output, the resulting zero is returned, with multiple zeros in a
%   symbolic vector.  For several equations and an equal number of outputs,
%   the results are sorted in lexicographic order and assigned to the
%   outputs.  For several equations and a single output, a structure
%   containing the zeros is returned.
%
%   Examples:
%
%      Zeros of a polynomial:
%      solve(x^2-x-6)  returns
%        ans =
%        [ -2]
%        [  3]
%
%      Zeros of a system of expressions:
%        [X,Y] = solve(x+y-1, x-y-2)  returns
%        X = 3/2
%        Y = -1/2
%
%      A system with parameters:
%         S = solve(t*x+z*y-1, 2*t*x-3*z*y+2, t, z)   returns
%         S.t =
%            1/5/x
%         S.z =
%            4/5/y
%
%   See also SOLVE, DSOLVE.

%   Copyright 1993-2002 The MathWorks, Inc.
%   $Revision: 1.29 $  $Date: 2002/04/15 03:09:39 $

% Change all symbolic input to character strings.
for k = 1:nargin
    S{k} = char(varargin{k});
end

[varargout{1:max(1,nargout)}] = solve(S{:});
