function s = validateDSPBoard (h, modelInfo, boardName)

% $RCSfile: validateDSPBoard.m,v $
% $Revision: 1.1.6.2 $ $Date: 2004/04/08 21:06:40 $
% Copyright 2003-2004 The MathWorks, Inc.

% Note: procNum defaults to 0

s = h.getBoardInfo (boardName);

s.procNum = 0;

availableboards = '';
for i=1:length (s.ccsbi)
    if (i==1) delim =''; else, delim = ', '; end
    availableboards = [availableboards delim '''' s.ccsbi(i).name ''''];
end

if ~(s.ccsInstalled),
    msg='Code Composer Studio(tm) installation could not be found.';
elseif ~(s.success),   
    if (length (s.ccsbi)==0)
        s.errmsg = sprintf(['\n''Target Preference Block'' specifies that board labeled ''' boardName '''\n'...
                            'will be used to run generated code. However, no boards are found in your\n'...
                            'system. Run Code Composer Studio(tm) Setup and add a board with matching\n'...
                            'label to your system.']);
    else
        s.errmsg = sprintf(['\n''Target Preference Block'' specifies that board labeled ''' boardName '''\n'...
                            'will be used to run generated code. However, only the following boards exist\n'...
                            'in your system:\n'...
                            availableboards '\n'...
                            'Run Code Composer Studio(tm) Setup and make sure that a board with matching\n'...
                            'label has been configured for use in your system.']);       
    end
                
elseif s.procNum > (length(s.ccsbi(s.boardIndex).proc) - 1)
    s.errmsg = sprintf(['The desired processor does not exist on this\n' ...
                        'board, according to Code Composer Studio(tm) Setup.']);
else
    s.errmsg ='';
end

% [EOF] validateDSPBoard.m