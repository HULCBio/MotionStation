%ISGLOBAL True for global variables.
%   ISGLOBAL(A) is TRUE if A has been declared to be a global 
%   variable in the context from which ISGLOBAL is called,
%   and FALSE otherwise.
%
%   ISGLOBAL is obsolete and will be discontinued in a future
%   version of MATLAB.
%
%   ISGLOBAL is most commonly used in conjunction with
%   conditional global declaration.  An alternate approach
%   is to use a pair of variables, one local and one declared
%   global.
%
%   Instead of using:
%
%
%     if condition
%       global x
%     end
%
%     x = some_value
%
%     if isglobal(x)
%       do_something
%     end
%
%
%   You can use:
%
%
%     global gx
%     if condition
%       gx = some_value
%     else
%       x = some_value
%     end
%
%     if condition
%       do_something
%     end
%
%
%   If no other workaround is possible, "isglobal(variable)" may
%   be mimicked by using:
%
%     ~isempty(whos('global','variable'))
%
%
%   See also GLOBAL, CLEAR, WHO.

%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 5.10.4.1 $  $Date: 2003/08/05 19:23:00 $
%   Built-in function.
