%   You can enter MATLAB commands using either a FUNCTION format or a
%   COMMAND format, as described below.
%
%
% FUNCTION FORMAT
%
%   A command in this format consists of the function name followed by 
%   one or more arguments separated by commas and enclosed in parentheses.
%
%      functionname(arg1, arg2, ..., argn)
%
%   You may assign the output of the function to one or more output values
%   separated by commas and enclosed in square brackets ([]).
%
%      [out1, out2, ..., outn] = functionname(arg1, arg2, ..., argn)
%
%   For example,
%
%      copyfile(srcfile, '..\mytests', 'writable')
%      [x1, x2, x3, x4] = deal(A{:})
%
%
%   Arguments are passed to the function by value.  See the examples below,
%   under ARGUMENT PASSING.
%
%
% COMMAND FORMAT
%
%   A command in this format consists of the function name followed by 
%   one or more arguments separated by spaces.
%
%      functionname arg1 arg2 ... argn
%
%   Unlike the function format, you may not assign the output of the function
%   to a variable.  Attempting to do so generates an error.
%
%   For example
%
%      save mydata.mat x y z
%      import java.awt.Button java.lang.String
%
%
%   Arguments are treated as string literals.  See the examples below,
%   under ARGUMENT PASSING.
%
%
% ARGUMENT PASSING
%
%   In the FUNCTION format, arguments are passed by value.
%   In the COMMAND format, arguments are treated as string literals.
%
%
%   In the following example, 
%
%      disp(A) - passes the value of variable A to the disp function
%      disp A  - passes the variable name, 'A'
%
%         A = pi;
%
%         disp(A)                    % Function format
%             3.1416
%
%         disp A                     % Command format
%             A
%
%
%   In the next example,
%
%      strcmp(str1, str2) - compares the strings 'one' and 'one'
%      strcmp str1 str2   - compares the strings 'str1' and 'str2'
%
%         str1 = 'one';    str2 = 'one';
%
%         strcmp(str1, str2)         % Function format
%         ans =
%              1        (equal)
%
%         strcmp str1 str2           % Command format
%         ans =
%              0        (unequal)
%
%
% PASSING STRINGS
%
%   When using the FUNCTION format to pass a string literal to a function,
%   you must enclose the string in single quotes, ('string').
%
%   For example, to create a new directory called MYAPPTESTS, use
%
%      mkdir('myapptests')
%
%   On the other hand, variables that contain strings do not need to be 
%   enclosed in quotes.
%
%      dirname = 'myapptests';
%      mkdir(dirname)
%
%   See also MLINT.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.4.4.1 $Date:
