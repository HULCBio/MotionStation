function i = strmatch(str,strs,flag)
%STRMATCH Find possible matches for string.
%   I = STRMATCH(STR,STRS) looks through the rows of the character
%   array or cell array of strings STRS to find strings that begin
%   with string STR, returning the matching row indices.  STRMATCH is
%   fastest when STRS is a character array.
%
%   I = STRMATCH(STR,STRS,'exact') returns only the indices of the
%   strings in STRS matching STR exactly.
%
%   Examples
%     i = strmatch('max',strvcat('max','minimax','maximum'))
%   returns i = [1; 3] since rows 1 and 3 begin with 'max', and
%     i = strmatch('max',strvcat('max','minimax','maximum'),'exact')
%   returns i = 1, since only row 1 matches 'max' exactly.
%   
%   See also STRFIND, STRVCAT, STRCMP, STRNCMP, REGEXP.

%   Mark W. Reichelt, 8-29-94
%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.21.4.7 $  $Date: 2004/04/16 22:08:50 $

% The cell array implementation is in @cell/strmatch.m

[m,n] = size(strs);
len = numel(str);
if (nargin < 3)
    exactFlag = 0;
else
    exactFlag = 1;
end

% Special treatment for empty STR or STRS to avoid
% warnings and error below
if len==0
    str = reshape(str,1,len);
end 
if n==0
    strs = reshape(strs,max(m,1),n);
    [m,n] = size(strs);
end

if len > n
    i = [];
else
    if exactFlag && len < n % if 'exact' flag, pad str with blanks or nulls
        % Use nulls if anything in the last column is a null.
        null = char(0); 
        space = ' ';
        if ~isempty(strs) && any(strs(:,end)==null), 
            str = [str null(ones(1,n-len))];
        else
            str = [str space(ones(1,n-len))];
        end
        len = n;
    end

    mask = true(m,1); 
    % walk from end of strs array and search for row starting with str.
    for outer = 1:m
        for inner = 1:len
            if (strs(outer,inner) ~= str(inner))
                mask(outer) = false;
                break; % exit matching this row in strs with str.
            end   
        end
    end 
    i = find(mask);
end

