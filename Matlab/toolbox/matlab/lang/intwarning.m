function s = intwarning(arg)
%INTWARNING Controls the state of the 4 integer warnings.
%   The 4 integer warnings are:
%      MATLAB:intConvertNaN
%      MATLAB:intConvertNonIntVal
%      MATLAB:intConvertOverflow
%      MATLAB:intMathOverflow
%
%   INTWARNING('OFF') sets the 4 integer warnings to be off.
%
%   INTWARNING('ON') sets the 4 integer warnings to be on.
%
%   INTWARNING('QUERY') displays the states of the 4 integer warnings.
%
%   S = INTWARNING(ARG) returns a 4x1 struct array of the 4 integer warning
%   states before they are affected by ARG, if ARG is 'ON' or 'OFF'. If ARG
%   is 'QUERY', the states are not displayed, they are simply returned in S.
%
%   INTWARNING(S) sets the 4 integer warnings to the warning states in S.
%
%   Example:
%   intwarning('off') % this is the default state
%   intwarning('query') % display current states
%   s4 = intwarning('query') % capture current states
%   intwarning('on') % turn the 4 warnings on
%   intwarning('query') % display current states
%   intwarning(s4) % turn the 4 warnings back to their original state
%   intwarning('query') % display curent states
%
%   See also WARNING.

%   Copyright 2004 The MathWorks, Inc. 

if (nargout == 1)
    s(1,1) = warning('query','MATLAB:intConvertNaN');
    s(2,1) = warning('query','MATLAB:intConvertOverflow');
    s(3,1) = warning('query','MATLAB:intConvertNonIntVal');
    s(4,1) = warning('query','MATLAB:intMathOverflow');
end

if ischar(arg)
     switch lower(arg)
        case 'off'
            warning off MATLAB:intConvertNaN
            warning off MATLAB:intConvertNonIntVal
            warning off MATLAB:intConvertOverflow
            warning off MATLAB:intMathOverflow
        case 'on'
            warning on MATLAB:intConvertNaN
            warning on MATLAB:intConvertNonIntVal
            warning on MATLAB:intConvertOverflow
            warning on MATLAB:intMathOverflow
        case 'query'
            if (nargout == 0)
                warning('query','MATLAB:intConvertNaN');
                warning('query','MATLAB:intConvertNonIntVal');
                warning('query','MATLAB:intConvertOverflow');
                warning('query','MATLAB:intMathOverflow');
            end
        otherwise
            error('MATLAB:intwarning:badInputString',['Input string must be one of ''off'',''on'' or ''query''.'])
    end
elseif isstruct(arg)
    warning(arg)
else
    error('MATLAB:intwarning:badInput','Input must be a string or a struct.')
end

