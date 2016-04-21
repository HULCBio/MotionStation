function s = getBoardInfo (h, boardName);

% $RCSfile: getBoardInfo.m,v $
% $Revision: 1.1.6.2 $ $Date: 2004/04/08 21:06:33 $
% Copyright 2003-2004 The MathWorks, Inc.

% Get ccs board info needed by all cases.
try
    s.ccsbi = ccsboardinfo;
    s.ccsInstalled = logical(1);
catch % CCS not installed
    msg = lasterr;
    if ~findstr(msg,'CCSDSP:The system cannot find the path specified') & ...
            ~findstr(msg,'CCSDSP:Class not registered')
        error(msg);  % Re-issue this unexpected error
    else
        s.ccsInstalled = logical(0);   % Handle this error below
    end
end

% Check for CCS installation and boards.  
% If either fails, we go to the bottom and export special-case values.
if s.ccsInstalled,
    s.nboards = length(s.ccsbi);
    if s.nboards>0,
        s.boardName = boardName;
        for i = 1:length(s.ccsbi),
            correct_board(i) = strcmp(s.ccsbi(i).name, s.boardName);
        end
        s.success = any(correct_board);
        if s.success,
            kvec = find(correct_board);
            s.boardIndex = kvec(1);
            s.boardNum = s.ccsbi(kvec(1)).number;
        end
    else  % No boards!
        s.boardList    = '[No_boards_detected]';  
        s.boardName    = '[No_boards_detected]'; 
        s.boardNum     = 0;
        s.boardIndex   = 1;
        s.success      = logical(0);
    end  
else  % CCS not found! 
    s.boardList    = '[Code_Composer_Studio_not_installed]';  
    s.boardName    = '[Code_Composer_Studio_not_installed]'; 
    s.boardNum     = 0;
    s.boardIndex   = 1;
    s.success      = logical(0);
end