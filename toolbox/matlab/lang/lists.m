%LISTS Comma separated lists.
%   Extracting multiple values from a cell array or structure results
%   in a list of values (as if separated by commas).  The comma-separated
%   lists are valid:
%      1) by themselves on the command line to display the values,
%            C{:} or S.name
%      2) within parentheses as part of a function call,
%            myfun(x,y,C{:}) or myfun(x,y,S.name)
%      3) within square brackets as part of a horizontal concatenation
%            [C{:}] or [S.name]
%      4) within square brackets as part of a function output list,
%            [C{:}] = myfun or [S.name] = myfun
%      5) within braces as part of a cell array construction.
%            {C{:}} or {S.name}
%
%   In all these uses, C{:} is the same as C{1},C{2},...,C{end} and
%   S.name is the same as S(1).name,S(2).name,...,S(end).name.  If
%   C or S is 1-by-1 then these expressions produce the familiar
%   single element extraction.  Any indexing expression that attempts
%   to extract more than one element produces a comma separated list.
%   Hence C{1:5} and S(2:3).name are also comma separated lists. 
%
%   Comma separated list are very useful when dealing with variable 
%   input or output argument lists or for converting the contents
%   of cell arrays and structures into matrices.
%
%   Examples
%      C = {1 2 3 4};
%      A = [C{:}];
%      B = cat(2,C{:});
%      [S(1:3).FIELD] = deal(5);
%
%   See also VARARGIN, VARARGOUT, DEAL, CELL2STRUCT, STRUCT2CELL, 
%            NUM2CELL, CAT, PAREN.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.11 $  $Date: 2002/04/15 04:15:40 $
