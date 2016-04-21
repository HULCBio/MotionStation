function foundIndex = findBoardOrProc(struct1,name)
% Find board or processor with specified name.
% struct1 is either the ccsboardinfo structure (to find the board)
% or ccsbi(boardIndex).proc to find the processor.
% The caller should check for failure (output -1).

% Copyright 2003-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/08 20:44:39 $
foundIndex = -1;
for k = 1:length(struct1),
    if strcmp(struct1(k).name,name),
        foundIndex = k;
        break;
    end
end
