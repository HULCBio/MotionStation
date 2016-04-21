%IF Conditionally execute statements.
%   The general form of the IF statement is
%
%      IF expression
%        statements
%      ELSEIF expression
%        statements
%      ELSE
%        statements
%      END
%
%   The statements are executed if the real part of the expression 
%   has all non-zero elements. The ELSE and ELSEIF parts are optional.
%   Zero or more ELSEIF parts can be used as well as nested IF's.
%   The expression is usually of the form expr rop expr where 
%   rop is ==, <, >, <=, >=, or ~=.
%
%   Example
%      if I == J
%        A(I,J) = 2;
%      elseif abs(I-J) == 1
%        A(I,J) = -1;
%      else
%        A(I,J) = 0;
%      end
%
%   See also RELOP, ELSE, ELSEIF, END, FOR, WHILE, SWITCH.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 5.9.4.1 $  $Date: 2004/04/16 22:07:11 $
%   Built-in function.
