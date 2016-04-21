%SWITCH Switch among several cases based on expression.
%   The general form of the SWITCH statement is:
%
%       SWITCH switch_expr
%         CASE case_expr, 
%           statement, ..., statement
%         CASE {case_expr1, case_expr2, case_expr3,...}
%           statement, ..., statement
%        ...
%         OTHERWISE, 
%           statement, ..., statement
%       END
%
%   The statements following the first CASE where the switch_expr matches
%   the case_expr are executed.  When the case expression is a cell array
%   (as in the second case above), the case_expr matches if any of the
%   elements of the cell array match the switch expression.  If none of
%   the case expressions match the switch expression then the OTHERWISE
%   case is executed (if it exists).  Only one CASE is executed and
%   execution resumes with the statement after the END.
%
%   The switch_expr can be a scalar or a string.  A scalar switch_expr
%   matches a case_expr if switch_expr==case_expr.  A string
%   switch_expr matches a case_expr if strcmp(switch_expr,case_expr)
%   returns 1 (true).
%
%   Only the statements between the matching CASE and the next CASE,
%   OTHERWISE, or END are executed.  Unlike C, the SWITCH statement
%   does not fall through (so BREAKs are unnecessary).
%
%   Example:
%
%   To execute a certain block of code based on what the string, METHOD, 
%   is set to,
%
%       method = 'Bilinear';
%
%       switch lower(method)
%         case {'linear','bilinear'}
%           disp('Method is linear')
%         case 'cubic'
%           disp('Method is cubic')
%         case 'nearest'
%           disp('Method is nearest')
%         otherwise
%           disp('Unknown method.')
%       end
%
%       Method is linear
%
%   See also CASE, OTHERWISE, IF, WHILE, FOR, END.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.14.4.1 $  $Date: 2002/09/17 19:03:16 $
%   Built-in function.
