%WHILE  Repeat statements an indefinite number of times.
%   The general form of a WHILE statement is:
% 
%      WHILE expression
%        statements
%      END
% 
%   The statements are executed while the real part of the expression
%   has all non-zero elements. The expression is usually the result of
%   expr rop expr where rop is ==, <, >, <=, >=, or ~=.
%
%   The BREAK statement can be used to terminate the loop prematurely.
%
%   For example (assuming A already defined):
% 
%           E = 0*A; F = E + eye(size(E)); N = 1;
%           while norm(E+F-E,1) > 0,
%              E = E + F;
%              F = A*F/N;
%              N = N + 1;
%           end
%
%   See also FOR, IF, SWITCH, BREAK, CONTINUE, END.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.10 $  $Date: 2002/04/15 04:14:55 $
%   Built-in function.
