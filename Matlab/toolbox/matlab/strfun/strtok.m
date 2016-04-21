function [token, remainder] = strtok(string, delimiters)
%STRTOK Find token in string.
%   STRTOK(S) returns the first token in the string S delimited by "white
%   space". Any leading white space characters are ignored. If S is a
%   cell array of strings then the output is a cell array of tokens.
%
%   STRTOK(S,D) returns the first token delimited by one of the characters
%   in D. Any leading delimiter characters are ignored.
%
%   [T,R] = STRTOK(...) also returns the remainder of the original string. 
%
%   If the token is not found in S then R is an empty string and T is the
%   same as S. 
% 
%   See also ISSPACE, STRREAD.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 5.14.4.4 $  $Date: 2004/04/10 23:33:01 $

if nargin<1 
   error('MATLAB:strtok:NrInputArguments','Not enough input arguments.');
end

token = ''; remainder = '';

len = length(string);
if len == 0
    return
end

if (nargin == 1)
    delimiters = [9:13 32]; % White space characters
end

i = 1;
while (any(string(i) == delimiters))
    i = i + 1;
    if (i > len), 
       return, 
    end
end

start = i;
while (~any(string(i) == delimiters))
    i = i + 1;
    if (i > len), 
       break, 
    end
end
finish = i - 1;

token = string(start:finish);

if (nargout == 2)
    remainder = string(finish + 1:length(string));
end
