function [varargout] = regexprep(varargin)
%REGEXPREP Replace string using regular expression.
%   S = REGEXPREP(STRING,EXPRESSION,REPLACE) replaces all occurrences of the
%   regular expression, EXPRESSION, in string, STRING, with the string, REPLACE.
%   The new string is returned.  If no matches are found REGEXPREP returns
%   STRING unchanged.
%
%   If STRING is a cell array of strings, REGEXPREP returns a cell array of
%   strings replacing each element of STRING individually.
%
%   If EXPRESSION is a cell array of strings, REGEXPREP replaces each element of
%   EXPRESSION sequentially.
%
%   If REPLACE is a cell array of strings, then EXPRESSION must be a cell array
%   of strings with the same number of elements.  REGEXPREP will replace each 
%   element of EXPRESSION sequentially with the corresponding element of 
%   REPLACE.
%
%   By default, REGEXPREP replaces all matches and is case sensitive.  Available
%   options are:
%
%           Option   Meaning
%   ---------------  --------------------------------
%     'ignorecase'   Ignore the case of characters when matching EXPRESSION to
%                       STRING.
%   'preservecase'   Ignore case when matching (as with 'ignorecase'), but
%                       override the case of REPLACE characters with the case of
%                       corresponding characters in STRING when replacing.
%           'once'   Replace only the first occurrence of EXPRESSION in STRING.
%               N    Replace only the Nth occurrence of EXPRESSION in STRING.
%
%   Example:
%      str = 'My flowers may bloom in May';
%      pat = 'm(\w*)y';
%      regexprep(str, pat, 'April')
%         returns 'My flowers April bloom in May'
%
%      regexprep(str, pat, 'April', 'ignorecase')
%         returns 'April flowers April bloom in April'
%
%      regexprep(str, pat, 'April', 'preservecase')
%         returns 'April flowers april bloom in April'
%
%   REGEXPREP can modify REPLACE using tokens from EXPRESSION.  The 
%   metacharacters for tokens are:
%
%    Metacharacter   Meaning
%   ---------------  --------------------------------
%              $N    Replace using the Nth token from EXPRESSION
%         $<name>    Replace using the named token 'name' from EXPRESSION
%              $0    Replace with the entire match
%
%   To escape a metacharacter in REGEXPREP, precede it with a '\'.
%
%   Example:
%      str = 'I walk up, they walked up, we are walking up, she walks.'
%      pat = 'walk(\w*) up'
%      regexprep(str, pat, 'ascend$1')
%         returns 'I ascend, they ascended, we are ascending, she walks.'
%
%   REGEXPREP supports international character sets.
%
%   See also REGEXP, REGEXPI, STRREP, STRCMP, STRNCMP, FINDSTR, STRMATCH.
%

%
%   E. Mehran Mestchian
%   J. Breslau
%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.7.4.3 $  $Date: 2004/04/10 23:32:46 $
%

if nargout == 0
  builtin('regexprep', varargin{:});
else
  [varargout{1:nargout}] = builtin('regexprep', varargin{:});
end
