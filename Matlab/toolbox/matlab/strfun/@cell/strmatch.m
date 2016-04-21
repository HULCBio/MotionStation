function out = strmatch(str,strs,flag)
%STRMATCH Cell array based string matching.
%   Implementation of STRMATCH for cell arrays of strings.  See
%   STRMATCH for more info.

%   Loren Dean 9/19/95
%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.15.4.1 $

error(nargchk(2,3,nargin));
if isempty(strs), out = []; return; end
if iscellstr(str), str = char(str); end
if iscellstr(strs), strs = char(strs); end

if ~ischar(str) || ~ischar(strs)
  error('Requires character array or cell array of strings as inputs.')
end
if (nargin==3) && ~ischar(flag)
  error('FLAG must be a string.');
end

if nargin==2,
  out = strmatch(str,strs);
else
  out = strmatch(str,strs,flag);
end

