% removes opening and trailing blanks and null char.

% Author: P. Gahinet  1/94
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $

function s = dblnk(s)


if isempty(s), return; end

% remove null characters (null character ==> abs(s) == 0)
s(find(abs(s)==0)) = [];
if isempty(s), return; end

% remove trailing blanks
nbc = find(s~= ' ');
if isempty(nbc)
   s = '';
else
   s = s(min(nbc):max(nbc));
end
