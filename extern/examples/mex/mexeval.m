%MEXEVAL Execute string containing MATLAB expression.
%   MEXEVAL(s), where s is a string, causes MATLAB to execute
%   the string as an expression or statement.
%
%   MEXEVAL(s1,s2) provides the ability to catch errors.  It
%   execute string s1 and returns if the operation was 
%   successful.  If the operation generates an error,
%   string s2 is evaluated before returning.  Think of this
%   MEXEVAL('try','catch')
%
%   [X,Y,Z,...] = MEXEVAL(s) returns output arguments from the
%   expression in string s. [note: this is a bug!!]
%
%   The input strings to MEXEVAL are often created by
%   concatenating substrings and variables inside square
%   brackets.
%
%   See also MEXFEVAL.

%   MEX-File function.

% Copyright (c) 1984-98 by The MathWorks, Inc.
% All Rights Reserved.
% $Revision: 1.3 $

