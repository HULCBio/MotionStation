function [boardNum, boardIndex, success] = findBoardNum_TItarget(ccsbi, boardName)
%findBoardNum_TItarget     Compute board number corresponding to
%       indicated board name. 
% Using s.boardName, compute boardNum for constructors
% and boardIndex for ccsboardinfo-structure indexing.

% Copyright 2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/08 21:07:50 $

for i = 1:length(ccsbi),
    correct_board(i) = strcmp( ...
        mangleBoardProcName_TItarget(ccsbi(i).name), ...
        mangleBoardProcName_TItarget(boardName) );
end

success = any(correct_board);
if success,
    kvec = find(correct_board);
    boardIndex = kvec(1);
    boardNum = ccsbi(kvec(1)).number;
else
    boardIndex = -1;
    boardNum = -1;
end

% [EOF] findBoardNum_TItarget.m
