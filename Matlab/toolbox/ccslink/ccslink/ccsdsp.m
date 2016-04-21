function h = ccsdsp(varargin)
%CCSDSP - Base constructor for the 'Link to Code Composer Studio®'
%  Description of methods available for CCSDSP
%  ---------------------------------------------------------------------
%  ACTIVATE   Set the active project, text file or build configuration
%  ADD        Add source file to a project
%  ANIMATE    Initiate a target execution with breakpoint animation
%  ADDRESS    Search the target's symbol table for an address
%  BUILD      Compile/Link to build a program file
%  CCSDSP     Constructor which establishes the link to CCS
%  CD         Change or query working directory of Code Composer Studio
%  CLOSE      Close Code Composer Studio project or text file
%  CREATEOBJ  Create objects for manipulating target values
%  DELETE     Delete a debug point from DSP memory
%  DIR        List files in Code Composer Studio working directory
%  DISP       Display information about the CCSDSP object
%  GOTO       Execute the target to the entry of a function
%  HALT       Immediately terminate execution of the DSP processor
%  INFO       Produce a list of information about the target processor
%  INSERT     Insert a debug point into DSP memory
%  ISREADABLE Query if a block of DSP memory is available for reading
%  ISRUNNING  Query status of DSP execution
%  ISRTDXCAPABLE Query if DSP supports RTDX communications
%  ISVISIBLE  Query visibility of Code Composer Studio application
%  ISWRITABLE Query if a block of DSP memory is available for writing
%  LIST       Produce various lists of information from Code Composer
%  LOAD       Load a program file into the DSP processor
%  NEW        Create a default project, text file or build configuration
%  OPEN       Load a workspace, project or program file
%  PROFILE    Return measurements from any DSP/BIOS(tm) STS objects
%  READ       Return a block of data from the memory of the DSP
%  REGREAD    Return data stored in a DSP register
%  REGWRITE   Modify the contents of a DSP register
%  RELOAD     Reload most recently loaded program file
%  REMOVE     Remove a file from a project
%  RESET      Reset the target DSP
%  RESTART    Return PC to the beginning of a target program
%  RUN        Initiates execution of the DSP processor
%  SAVE       Save Code Composer Studio project or text file
%  SYMBOL     Return the target's entire symbol table
%  VISIBLE    Hide or reveal Code Composer Studio application window
%  WRITE      Place a block of MATLAB data into the memory of the DSP
%
%  For more information on a given method, use the following syntax:
%    help ccshelp/(method)
%
%  See also GET, SET, RTDX.

% Copyright 2000-2004 The MathWorks, Inc.
% $Revision: 1.15.4.4 $ $Date: 2004/04/08 20:47:22 $

try
    idxp = strmatch('procnum',{varargin{1:2:end}});
    idxb = strmatch('boardnum',{varargin{1:2:end}});
    args = varargin;
    
    if isempty(idxb) % default to first board
        boardnum = 0;
    else
        boardnum = varargin{idxb*2};   
        checkNumOfBoards(boardnum,varargin,idxb,idxp);
    end
    
    if isempty(idxp) % connect to all processors of the given board
        bds = ccsboardinfo;
        if isempty(bds)
            error(generateccsmsgid('CCSSetupIsEmpty'),...
                'Unable to attach to Code Composer Studio COM interface: No board configured in CCS Setup.');
        end
        procnum = findprocs(bds,boardnum); % indices of all procs in given board
        if isempty(procnum)
            error(generateccsmsgid('CannotCreateLink'),...
                'Unable to attach to Code Composer Studio COM interface: Invalid board selected.');
        end
        
        % Open CCS app, get api version abd attach to args
        [ccapp,apiver,args] = openCCApp(args);
        
        % Attach 'procnum'
        args(end+1) = {'procnum'};
        
        % Get 'procnum' indices based on ccsboardindo output
        idxp = strmatch('procnum',{args{1:2:end}});
    else
        % Open CCS app, get api version abd attach to args
        [ccapp,apiver,args] = openCCApp(args);
        
        % Get 'procnum' indices user input
        procnum = varargin{idxp*2};

        if isempty(procnum)
            procnum = 0; % default
        end
    end
    
    % Sort in ascending order, for display pusposes
    procnum = sort(procnum);
    
    % Create object for each processor
    
    for i=1:length(procnum)
        args{idxp*2} = procnum(i);
        h(i) = ccs.ccsdsp(args{:});
    end
catch
    rethrow(lasterror);
end

%-----------------------------------------
% returns indices of all procs to a given board
function procnum = findprocs(bds,boardnum)
procnum = [];
for k = 1:length(bds)
    if (bds(k).number == boardnum)
        stopndx = length(bds(k).proc);
        for m = 1:length(bds(k).proc)
            if (strcmpi(bds(k).proc(m).type,'BYPASS') && isequal(stopndx,length(bds(k).proc)))
                stopndx = m-1;
                m = length(bds(k).proc); %stop
            end
        end
        procnum = cat(1,bds(k).proc(1:stopndx).number);
        return;
    end
end

%--------------------------------------------------------------------------
% Open CCS application (thru MATLAB COM) and get API version
% Note:
% - keeping CCS app handle ensures faster CCSDSP constructor execution
% - must keep the ff lines here (after ccsboardinfo)
function [ccapp,apiver,args] = openCCApp(args)
[apiver,ccapp] = p_getApiVersion;
args = horzcat(args,{'apiversion',apiver});

%--------------------------------------------------------------------------
function checkNumOfBoards(boardnum,args,idxb,idxp)
% idxb*2,idxp*2 - location of boardnum/procnum value
if isempty(boardnum)
    errmsg = 'Property ''boardnum'' must be a scalar value.';
    error(generateccsmsgid('InvalidInput'),errmsg);
else
    if length(args{idxb*2})>1
        errmsg = 'Not supported: multiple board numbers specified';
        if isempty(idxp) % no procnum is supplied - may be supported in the future
            error(generateccsmsgid('InvalidInput'),errmsg);
        else % procnum is supplied
            if length(args{idxp*2})<=1, % procnum supplied is a single number - may be supported in the future
                error(generateccsmsgid('InvalidInput'),errmsg);
            else % procnum supplied is array of numbers - error
                error(generateccsmsgid('InvalidInput'),...
                    'Not supported: multiple board numbers and multiple processor numbers specified');
            end
        end
    end
end

% [EOF] ccsdsp.m
