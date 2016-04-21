function [mpboards,mpprocs,brdnum] = checkForMultiProc(brdInfo)
% Checks for a multi-processor board.

% Copyright 2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/11/30 23:04:03 $

errid = ['MULTIPROCTUTORIAL:MultiprocBoardNotFound'];
if isempty(brdInfo)
    error(errid,'Multi-proccessor board not found');
end

mpboards = [];
mpprocs  = {};
lenBrd   = length(brdInfo);
for i=1:lenBrd,
    procnum = length(brdInfo(i).proc);
    % Determine if all processors are valid 
    procs = [];
    for j=1:procnum
        % Bypass devices (number='-') are not counted
        if ~isnumeric(brdInfo(i).proc(j).number)
            procnum = procnum-1;
        else
            procs(end+1) = brdInfo(i).proc(j).number;
        end
    end
    % If indeed multi-proc, store board number for next step
    if procnum>=2,
        brdnum = brdInfo(i).number;
        mpboards = [mpboards brdnum];
        mpprocs  = horzcat(mpprocs,{procs});
    end
end
if isempty(mpboards),
    error(errid,'Multi-proccessor board not found');
elseif length(mpboards)>1,
    disp('There are more than one multi-processor boards configured in the setup.');
    askBrdnum = 1;
    while askBrdnum,
        brdnum = input('Please enter the board number of the desired target: ');
        if ~isnumeric(brdnum) || isempty(brdnum) || ...
           ( isnumeric(brdnum) && length(brdnum)~=1 ), ...
            askBrdnum = 1;
        elseif isempty(find(brdnum==mpboards))
            disp(['Board ' num2str(brdnum) ' is not a multi-processor board.']);
            askBrdnum = 1;
        else
            askBrdnum = 0;
        end
    end
end