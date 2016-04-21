%RETURN Return to invoking function.
%   RETURN causes a return to the invoking function or to the keyboard.
%   It also terminates the KEYBOARD mode.
%
%   Normally functions return when the end of the function is reached.
%   A RETURN statement can be used to force an early return.
%
%   Example
%      function d = det(A)
%      if isempty(A)
%         d = 1;
%         return
%      else
%        ...
%      end
%
%   See also FUNCTION, KEYBOARD, BREAK, CONTINUE.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.10 $  $Date: 2002/04/15 04:14:52 $
%   Built-in function.
