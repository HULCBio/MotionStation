function r = subs(f,varargin)
%SUBS   Symbolic substitution.
%   SUBS(S) replaces all the variables in the symbolic expression S with
%   values obtained from the calling function, or the MATLAB workspace.
%   
%   SUBS(S,NEW) replaces the free symbolic variable in S with NEW.
%   SUBS(S,OLD,NEW) replaces OLD with NEW in the symbolic expression S.
%   OLD is a symbolic variable, a string representing a variable name, or
%   a string (quoted) expression. NEW is a symbolic or numeric variable
%   or expression.
%
%   If OLD and NEW are cell arrays of the same size, each element of OLD is
%   replaced by the corresponding element of NEW.  If S and OLD are scalars
%   and NEW is an array or cell array, the scalars are expanded to produce
%   an array result.  If NEW is a cell array of numeric matrices, the
%   substitutions are performed elementwise (i.e., subs(x*y,{x,y},{A,B})
%   returns A.*B when A and B are numeric).
%
%   If SUBS(S,OLD,NEW) does not change S, then SUBS(S,NEW,OLD) is tried.
%   This provides backwards compatibility with previous versions and 
%   eliminates the need to remember the order of the arguments.
%   SUBS(S,OLD,NEW,0) does not switch the arguments if S does not change.
%
%   Examples:
%     Single input:
%       Suppose a = 980 and C1 = 3 exist in the workspace.
%       The statement
%          y = dsolve('Dy = -a*y')
%       produces
%          y = exp(-a*t)*C1
%       Then the statement
%          subs(y)
%       produces
%          ans = 3*exp(-980*t)
%
%     Single Substitution:
%       subs(a+b,a,4) returns 4+b.
%
%     Multiple Substitutions:
%       subs(cos(a)+sin(b),{a,b},{sym('alpha'),2}) returns
%       cos(alpha)+sin(2)
%   
%     Scalar Expansion Case: 
%       subs(exp(a*t),'a',-magic(2)) returns
%
%       [   exp(-t), exp(-3*t)]
%       [ exp(-4*t), exp(-2*t)]
%
%     Multiple Scalar Expansion:
%       subs(x*y,{x,y},{[0 1;-1 0],[1 -1;-2 1]}) returns
%       [  0, -1]
%       [  2,  0]
%
%   See also SUBEXPR

%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.8 $  $Date: 2002/04/15 03:14:17 $

r = subs(sym(f),varargin{:});
