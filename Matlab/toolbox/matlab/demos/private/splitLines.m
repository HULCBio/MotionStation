function cells = splitLines(text);
% SPLITLINES Split into a cell array of strings at each newline character.

% Copyright 1984-2002 The MathWorks, Inc.
% $Revision: 1.1.6.1 $  $Date: 2002/11/04 10:43:17 $

newLine = char(10);
text = [newLine text newLine];
returns = find(text == newLine);
cells = {};
for i = 1:length(returns)-1
   cells{end+1} = text(returns(i)+1 : returns(i+1)-1);
end
