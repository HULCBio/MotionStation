function retstat = reqmgrctl(command, subcommand, varargin)
%REQMGRCTL Requirements management work and context.
%  RETSTAT = REQMGRCTL(COMMAND, SUBCOMMAND) and
%  RETSTAT = REQMGRCTL(COMMAND, SUBCOMMAND, VARARGIN) allow 
%  iterative requirements management operations on a model.
%
%  Returns are all successful completions.  Errors are thrown.
%
%  REQMGRCTL is designed to be used in conjunction with REQMGR
%  and not by itself. See REQMGR.M for design and detailed
%  usage notes.
%
%  REQMGRCTL uses both the COMMAND and SUBCOMMAND to determine
%  how to proceed.
%
%  All persistent variables are capitalized and are prefixed
%  with "REQ."
%
%  See also REQMGR, DMISELECTBLOCKSTART_, DMISELECTBLOCK_, 
%     DMISELECTBLOCKEND_, INVOKE, ACTXSERVER, DELETE
%

%  Author(s): M. Greenstein, 07/17/98
%  Copyright 1998-2002 The MathWorks, Inc.
%  $Revision: 1.1.6.5 $   $Date: 2004/04/20 23:21:27 $

%  MATLAB ActiveX functions (ACTXSERVER, INVOKE, DELETE) are used
%  for communication with DOORS on Windows.  There is not any Unix
%  support yet. 

persistent REQBLOCKS REQMAX REQINDEX REQSYSHANDLE ...
    REQSYS REQSYSAPP REQCONNECTED REQINITIALIZED ...
REQNAME REQNAMEFULL REQFILETYPE REQTYPES REQLEVELS ...
REQBLOCKNAMES;

retstat = 0;
outstr = '';
command = lower(command);
subcommand = lower(subcommand);

switch command,
    %%%%%%%%%%%%%%%%%%%%%%%%%%
case 'init',
    % Set up specific requirements system to use.
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    REQSYSHANDLE = 0;
    REQCONNECTED = 0;
    REQINITIALIZED = 0;
    REQSYS = '';
    REQNAME = '';
    REQNAMEFULL = '';
    REQFILETYPE = 1; % default type {0 = model | 1 = file} 
    
    if (nargin > 1)
        switch subcommand,
        case 'doors',
            REQSYS = 'DOORS';
            REQSYSAPP = 'DOORS.Application';
        case 'word',
            REQSYS = 'WORD';
            REQSYSAPP = 'WORD.Application';
        case 'excel',
            REQSYS = 'EXCEL';
            REQSYSAPP = 'Excel.Application';
        case {'html','htm'}
            REQSYS = 'HTML';
            REQSYSAPP = '';
        otherwise,
            % Default to HTML.
            REQSYS = 'HTML';
            REQSYSAPP = '';
        end % switch subcommand,
    end % if (nargin >1)
    
    if (~strcmp(REQSYS, 'HTML') & isunix)
        errordlg([REQSYS ' is only supported on Windows.'], 'Error','Modal');  
    end
    REQINITIALIZED = 1;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%
case 'start',
    % Begin a transaction block.  Opens model, establishes
    % persistent data.
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    if (isempty(REQINITIALIZED) | (0 == REQINITIALIZED))
        retstat = -10;
        return;
    end
    
    % Is varargin{1} is a full filename?  Assume so if it
    % has a dot anywhere.  Use which to validate.  If not,
    % use which to expand.
    
    str = char(varargin{1});
    if (length(str))
        % There is a filename to work with.
        en = findstr(str, '.');
        if (~isempty(en))
            en = max(en) - 1;
            be = findstr(str, filesep);
            if (~isempty(be))
                be = max(be) + 1;
            else
                be = 1;
            end
            REQNAME = str(be:en);
			% dboissy says:
			% "which" doesn't work if not on path
            % REQNAMEFULL = which(str);
			REQNAMEFULL = str;
        else
            REQNAME = str;
			% dboissy says:
			% "which" doesn't work if not on path
            % REQNAMEFULL = which(REQNAME);
			REQNAMEFULL = str;
        end
    else
        % Use the current model.
        str = gcb;
        if (isempty(str))
            REQINITIALIZED = 0;
            error('There is no system currently opened.');
        end
        en = findstr(str, '/');
        if (~isempty(en))
            en = min(en) - 1;
        else
            en = length(str);
        end
        REQNAME = str(1:en);
		% dboissy says:
		% "which" doesn't work if not on path
        % REQNAMEFULL = which(REQNAME);
		REQNAMEFULL = str;
    end
    
    % Attempt to get the fully qualified path.
    if (~length(REQNAMEFULL))
        REQINITIALIZED = 0;
        error(['File' REQNAMEFULL ' not found.']);
    end
    
    
    switch subcommand,
    case 'send',
        % Can the file be written?
        testopenfid = fopen(REQNAMEFULL, 'r+');
        if (testopenfid == -1)
            REQINITIALIZED = 0;
            error(['File  "' REQNAMEFULL '" does not have write permission.'...
                    char(10) 'Synchronization process will not be done.']);         
        else
            fclose(testopenfid);
        end
    otherwise,
    end
    
    % Set the type of requirements file.
    if (findstr(REQNAMEFULL, '.mdl')), REQFILETYPE = 0; end
    
    % Open the model and make it current.  Open if not opened.
    if (~REQFILETYPE & ~IsModelOpenLocal(REQNAME))
        %%%%open_system(REQNAMEFULL);
        % Use evalc to trap potential Stateflow informational messages.
        evalc(['open_system(''' REQNAMEFULL ''')']);
    end
    
    if (~REQFILETYPE & -1 == gcbh)
        REQINITIALIZED = 0;
        error(['Model' REQNAMEFULL ' can''t be opened.']);
    end
    
    % server in this section.
    if (~strcmp(subcommand, 'display'))
        % Open connection only for 'Send' or 'Select'.
        if (~strcmp('HTML', REQSYS))
            % Do for ActiveX servers only.
            try,
                % Open connection to requirements system, if appropriate.
                REQSYSHANDLE = actxserver(REQSYSAPP);
            catch,
                REQINITIALIZED = 0;
                error([REQSYS ' requirements system not available (1).']);
            end
            REQCONNECTED = 1;
        end % if (~strcmp('HTML', REQSYS))
        
    end % if (~strcmp(subcommand, 'display'))
    
    % Operate on the subcommand once everything has been opened.
    switch subcommand,
    case 'send',
        if (~REQFILETYPE)            
            REQBLOCKS     = {REQNAME};
            REQBLOCKNAMES = {get_param(REQNAME, 'Name')};
            REQTYPES      = {'block_diagram'};
            REQLEVELS     = {'1'};
            
            % Add top level blocks.
            blks          = find_system(REQNAME, 'SearchDepth', 1, 'Parent', REQNAME);
            for (i = 1 : length(blks))
                blk       = blks{i};
                if (strcmp(get_param(blk, 'BlockType'), 'SubSystem'))
                    continue;
                else
                    REQBLOCKS = [REQBLOCKS ; {blk}];
                    REQBLOCKNAMES = [REQBLOCKNAMES ; {get_param(blk, 'Name')}];
                    REQTYPES  = [REQTYPES ; {get_param(blk, 'Type')}];
                    REQLEVELS = [REQLEVELS ; {'2'}];
                end
            end
                        
            % Add other subsystems
            subsystems    = find_system(REQNAME, 'LookUnderMasks', 'all', 'BlockType', 'SubSystem');
            for (i = 1 : length(subsystems))                
                subsystem = subsystems{i};
                maskType  = get_param(subsystem, 'MaskType');
                                                
                if (strcmpi(maskType, 'Stateflow'))
                    REQBLOCKS   = [REQBLOCKS ; {subsystem}];
                    REQTYPES    = [REQTYPES ; {'StateflowSubSystem'}];
                    REQBLOCKNAMES = [REQBLOCKNAMES ; {get_param(subsystem, 'Name')}];
                    REQLEVELS   = [REQLEVELS ; {GetLevelsLocal(subsystem)}];
                    
                    try
                        sfchart = rmchart(REQNAME, subsystem);
                        chartlevel = str2num(GetLevelsLocal(subsystem));
                    catch
                        % Can't do this without Stateflow.
                        if (REQCONNECTED)
                            delete(REQSYSHANDLE); % Close connection.
                        end
                        REQINITIALIZED = 0;
                        error(lasterr);
                    end
                    
                    [n, nn] = size(sfchart);
                    
                    % Add this entire chart to REQBLOCKS, REQTYPES, and REQLEVELS.
                    for j = 1:n
                        REQBLOCKS = [REQBLOCKS ; sfchart(j, 1)];                        
                        REQLEVELS = [REQLEVELS ; {num2str(chartlevel + str2num(sfchart{j, 2}))}];
                        REQTYPES  = [REQTYPES ; sfchart(j, 3)];
                        REQBLOCKNAMES = [REQBLOCKNAMES ; sfchart(j, 4)];
                    end
                else                    
                    REQBLOCKS   = [REQBLOCKS ; {subsystem}];
                    REQTYPES    = [REQTYPES ; {'SubSystem'}];
                    REQBLOCKNAMES = [REQBLOCKNAMES ; {get_param(subsystem, 'Name')}];
                    REQLEVELS   = [REQLEVELS ; {GetLevelsLocal(subsystem)}];
                    
                    blocks      = find_system(REQNAME, 'LookUnderMasks', 'all', 'Parent', subsystem);
                    for (i = 1 : length(blocks))
                        blk       = blocks{i};
                        if (strcmp(get_param(blk, 'BlockType'), 'SubSystem'))
                            continue;
                        else
                            REQBLOCKS = [REQBLOCKS ; {blk}];
                            REQBLOCKNAMES = [REQBLOCKNAMES ; {get_param(blk, 'Name')}];
                            REQTYPES  = [REQTYPES ; {get_param(blk, 'Type')}];
                            REQLEVELS = [REQLEVELS ; {GetLevelsLocal(blk)}];
                        end
                    end                        
                end
            end
            REQMAX        = length(REQBLOCKS);            
           
        else
            % File with one "logical" block.
            REQBLOCKS = {REQNAME};
            REQMAX = 1;
        end
        retstat = REQMAX;
        REQINDEX = 1;
        
        % Requirement System specifics
        switch REQSYS,
        case 'DOORS',
            outstr = ['dmiSendObjectStart_("' REQNAME '");'];
            
            % Make server call.
            try
                invoke(REQSYSHANDLE, 'runStr', outstr);
            catch
                if (REQCONNECTED)
                    delete(REQSYSHANDLE); % Close connection.
                end
                REQINITIALIZED = 0;
                error([REQSYS ' requirements system server not available (2).']);
            end
            
            % Handle result of successful server call.
            rstat = get(REQSYSHANDLE, 'Result');
            if (~isempty(rstat)),
                if (REQCONNECTED)
                    delete(REQSYSHANDLE); % Close connection.
                end
                REQINITIALIZED = 0;
                error(rstat);
            end
            
        otherwise,
            if (REQCONNECTED)
                delete(REQSYSHANDLE); % Close connection.
            end
            REQINITIALIZED = 0;
            error(['Unknown requirements system.']);
            
        end % switch REQSYS,
        
    case 'select',
        % Send only a particular selected item.
        % Get the currently selected block.
        
        % Requirement System specifics.
        switch REQSYS,
        case 'DOORS',
            outstr = ['dmiSelectObjectStart_("' REQNAME '");'];
            
            % Make server call.
            try
                invoke(REQSYSHANDLE, 'runStr', outstr);
            catch
                if (REQCONNECTED)
                    delete(REQSYSHANDLE); % Close connection.
                end
                REQINITIALIZED = 0;
                error([REQSYS ' requirements system server not available (3).']);
            end
            
            % Handle result of successful server call.
            rstat = get(REQSYSHANDLE, 'Result');
            if (~isempty(rstat)),
                if (REQCONNECTED)
                    delete(REQSYSHANDLE); % Close connection.
                end
                REQINITIALIZED = 0;
                error([rstat ' Try synchronizing from Requirements Management Interface.']);
            end
            
        case 'WORD',
            % Nothing required.
            
        case 'EXCEL',
            % Nothing required.
            
        case 'HTML', 
            % Nothing required.
            
        otherwise,
            if (REQCONNECTED)
                delete(REQSYSHANDLE); % Close connection.
            end
            REQINITIALIZED = 0;
            error(['Unknown requirements system.']);
            
        end % switch REQSYS,
        
    end % switch subcommand,
    
    %%%%%%%%%%%%%%%%%%%%%
case 'send',
    % Send information to the requirements system in the
    % expected format.
    %%%%%%%%%%%%%%%%%%%%%
    if (isempty(REQINITIALIZED) | (0 == REQINITIALIZED))
        retstat = -10; 
        return;
    end
    
    if (strcmp(subcommand, 'display'))
        % varargin{1} is the requirement unique identifier.
        % varargin{2} is the unique, fully-specified block name.
        % Block must have a RequirementInfo.
        id = varargin{1};
        
        if (~REQFILETYPE)
            % Highlight the block.  Don't worry whether or not it's linked (true),
            % for the moment.
            
            % First see if there are any requirements.
            cb = varargin{2};
            cb = strrep(cb, '``', char(10));
            
            % Get to the right subsystem or stateflow chart and highlight it.  Always try
            % Simulink first so as not to initialize Stateflow if not necessary.
            
            sid = 0;
            try
                s = get_param(cb, 'name');
            catch
                try
                    [cid, sid] = rmsfid(REQNAME, cb);
                catch
                    % Can't do this without Stateflow installed.
                    if (REQCONNECTED)
                        delete(REQSYSHANDLE); % Close connection.
                    end
                    REQINITIALIZED = 0;
                    error(lasterr);
                end
                if (sid == 0), sid = cid; end
            end
            
            if (sid)
                % Stateflow
                try
                    sf('Open', sid);
                    setfocus('Stateflow (chart)'); % Won't work correctly if more than 1 chart.
                catch
                    if (REQCONNECTED)
                        delete(REQSYSHANDLE); % Close connection.
                    end
                    REQINITIALIZED = 0;
                    error([cb ' is not in model ' REQNAME '.']);
                end
            else
                % Simulink
                try
                    s = get_param(cb, 'Parent');
                    % Close if not the top-level system.  Then re-open.
                    if (isempty(s)), s = cb; end
                    open_system(s, 'force');
                    
                    if (~isunix)
                        % Set the focus on the window containing the block name.  This is
                        % a serious Windows hack, but it works.
                        b = findstr(s, '/');
                        if (~isempty(b))
                            b = max(b) + 1;
                        else
                            b = 1;
                        end
                        s = s(b:end);
                        s = strrep(s, char(10), ' '); % Replace LFs with spaces.
                        setfocus(s); % Move to the foreground.  Seems to work when sub-system is closed.
                    end
                    
                    % Clear all existing selections.
                    s = find_system(REQNAME, 'LookUnderMasks', 'all', 'selected', 'on');
                    [ro, co] = size(s);
                    for i = 1:ro
                        set_param(s{i,1}, 'selected', 'off');
                    end
                    
                    % Select the requested item.
                    
                    try
                        set_param(cb, 'Selected', 'on');
                    catch
                    end
                    
                catch
                    if (REQCONNECTED)
                        delete(REQSYSHANDLE); % Close connection.
                    end
                    REQINITIALIZED = 0;
                    error([cb ' is not in model ' REQNAME '.']);
                end
            end % if (sid)
            
        else
            % Check to see if the file has been synchronized.
            % Open the file in the MATLAB editor.
            % Don't worry whether or not it's linked (true),
            % for the moment.
            
            % First see if there are any requirements.
            f = varargin{2}; % Contains file only, no path.  Use this instead of REQNAMEFULL.       
            
            % Does the file exist (on the user's path)?
            ff = which(f);
            if (isempty(ff))
                if (REQCONNECTED)
                    delete(REQSYSHANDLE); % Close connection.
                end
                REQINITIALIZED = 0;
                error(['File ' f ' not found.']);
            end
            
            % Now, finally, edit the file.
            edit(ff);
        end % if (~REQFILETYPE)
        
        return;
        
    elseif (strcmp(subcommand, 'select'))
        % This works for blocks and files.
        % varargin{1} is the unique id of the current block.
        % varargin{2} is the requirement unique identifier.
        id = varargin{1};
        bn = varargin{2};
        %if (~length(bn))
            %error('Missing blockname or filename argument.');
        %end
        reqs = ['"' id '"'];
        
    elseif (strcmp(subcommand, 'send'))
        if (~REQFILETYPE)
            % Initializations.
            slevels = 'null';
            blocktype = 'null';
            reqs = 'null';
            str = 'null';
            if (REQINDEX > REQMAX)
                retstat = 0;
                return;
            end
            retstat = REQINDEX;
            
            str = REQBLOCKS{REQINDEX};
            slevels = REQLEVELS{REQINDEX};
            blocktype = ['"' REQTYPES{REQINDEX} '"'];
            itemname = REQBLOCKNAMES{REQINDEX};
            
            % Are there requirements ids?
            reqstr = [];
            if (strcmp(REQTYPES{REQINDEX}, 'StateflowState')) % | strcmp(REQTYPES(REQINDEX), 'StateflowTransition'))
                noslashes = strrep(itemname, '//', '/');
                try
                    reqstr = reqsf('get', REQNAME, REQBLOCKS{REQINDEX}, noslashes);
                catch
                    % Can't do this without Stateflow.  This should have
                    % been flagged at "start" "send."  Catch here just in case.
                    if (REQCONNECTED)
                        delete(REQSYSHANDLE); % Close connection.
                    end
                    REQINITIALIZED = 0;
                    error(lasterr);
                end
            elseif (strcmp(REQTYPES{REQINDEX}, 'StateflowTransition')) 
                try
                    reqstr = reqsf('get', REQNAME, REQBLOCKS{REQINDEX}, itemname);
                catch
                    % Can't do this without Stateflow.  This should have
                    % been flagged at "start" "send."  Catch here just in case.
                    if (REQCONNECTED)
                        delete(REQSYSHANDLE); % Close connection.
                    end
                    REQINITIALIZED = 0;
                    error(lasterr);
                end
            else
                reqstr = get_param(str, 'RequirementInfo');                
            end
            if (~isempty(reqstr))
                % Initialize a temporary req to get the id.  (An empty
                % id should be ok.
                allreqs = reqinitstr(reqstr);
                r = reqget(allreqs, REQSYS, REQNAME);
                if (~isempty(r))
                    reqs = ['"' r{1,1} '"'];                                 
                end
            end
            
        else
            % Non-binary (M-file) file.
            slevels = '1';
            blocktype = '"File"';
            b = findstr(REQNAMEFULL, '.');
            b = max(b);
            str = [REQNAME REQNAMEFULL(b:end)]; % File name only , no path.
            itemname = str;
            reqs = 'null'; 
            retstat = 1;           
            
            % Get reqs, if there are any.
            reqstr = reqmf('get', REQNAMEFULL);
            if (~isempty(reqstr))
                allreqs = reqinitstr(reqstr);
                r = reqget(allreqs, REQSYS, REQNAME);
                if (~isempty(r)), reqs = ['"' r{1,1} '"']; end
            end
            
        end % if (~REQFILETYPE)
        
    end
    
    switch REQSYS,
        
    case 'EXCEL',
        workbooks = get(REQSYSHANDLE, 'workbooks'); % Get the document collection.
        try 
            invoke(workbooks, 'Open', bn);   % Open a file.
            set(REQSYSHANDLE, 'Visible', 2); % Make excel object visible.
            
            % Select the specified cell 
            try 
                % Get the current sheet. 
                workbook = get(workbooks, 'item', 1);
                sheets = get(workbook, 'sheets');
                sheet = get(sheets, 'item', 1);
                
                % Select the whole sheet.
                %IV20000 is assumed to be the last cell.
                range = get(sheet, 'range', 'A1:IV20000');
                % Invoke the search.
                if (~exist('id') | ~length(id))
                    range = get(sheet, 'range', 'A1');
                    invoke(range, 'select');
                else
                    r = invoke(range, 'find', id);
                    % Select the cell.
                    invoke(r, 'select');
                end
            catch 
            end
        catch
            if (REQCONNECTED)
                delete(REQSYSHANDLE); % Close connection.
            end
            REQINITIALIZED = 0;
            error(['Error occured while opening file. Excel returned the following error message:' ...
                    char(10) lasterr]);
        end
        return;
        
    case 'WORD',
        % Use document and section number.
        % Opens a document and makes it visible.
        worddocs = get(REQSYSHANDLE, 'Documents');
        try
			% dboissy says:
			% Open read-only to avoid problems
            %invoke(worddocs, 'Open', bn);
			worddocs.Open(bn, [], 1);
            set(REQSYSHANDLE, 'Visible', 2);
            
            % Select the specied item
            try 
                if (exist('id') & length(id))
                    % Navigate to a location in the document.
                    selection = get(REQSYSHANDLE, 'selection'); % Get the selection object.
                    find = get(selection, 'find');% Get the find object.
                    invoke(find, 'execute', id); % Find a string and select it.
                end
            catch 
            end
        catch
            if (REQCONNECTED)
                delete(REQSYSHANDLE); % Close connection.
            end
            REQINITIALIZED = 0;
            error(['Error occured while opening file. Word returned the following error message:' ...
                    char(10) lasterr]);
        end
                
        
        return;
        
    case 'HTML',
        % Use document and href location number.
        s = bn;
        if (exist('id') & length(id))
            s = [s '#' id]; % Append a "#" and the id (which is the href).
        end
        web(s);
        return;
        
    case 'DOORS', 
        % Determine which function name.
        sendfunc = '';
        switch subcommand,
        case 'send',
            % Format data for output.
            %%%%newstr = strrep(str, char(10), ' '); % Replace LFs with spaces.
            newstr = strrep(str, char(10), '``'); % Replace LFs.
            %%%newstr = str;

			% Escape quotes
			newstr   = strrep(newstr,   '"', '\"');
			itemname = strrep(itemname, '"', '\"');
			
			iname = ['"' itemname '"'];
            %%%%iname = strrep(iname, char(10), ' ');
            iname = strrep(iname, '//', '/');
			sendstr = [reqs ',"' newstr '",' blocktype ',' slevels ',' iname];
            sendfunc = 'dmiSendObject_';
            REQINDEX = REQINDEX + 1;
        case 'select',
            sendfunc = 'dmiSelectObject_';
            sendstr = reqs;
        otherwise,
            retstat = -1; % Unknown subcommand.
            return;
            
        end % switch subcommand,
        
        outstr = [sendfunc '(' sendstr ');'];
        % Make server call.
        try
            invoke(REQSYSHANDLE, 'runStr', outstr);
        catch
            if (REQCONNECTED)
                delete(REQSYSHANDLE); % Close connection.
            end
            REQINITIALIZED = 0;
            error([REQSYS ' requirements system server not available (4).']);
        end
        
        % Handle result of successful server call.
        rstat = get(REQSYSHANDLE, 'Result');
        if (strcmp(subcommand, 'select'))
            setfocus(['''' REQNAME ''''], 1);
            
		elseif (~isempty(rstat)) % This will only occur for subcommand 'send'.               
            if (strncmp(rstat, 'DMI Error', 9))
                % All errors here.
                if (REQCONNECTED)
                    delete(REQSYSHANDLE); % Close connection.
                end
                REQINITIALIZED = 0;
                error(rstat);
            else
                % Success.  Get the id from the requirements system and store it.
                s = get(REQSYSHANDLE, 'Result');
                if  (~REQFILETYPE)
                    % Get the requirements, if there are any.
                    try % First from Simulink.
                        reqstr = get_param(str, 'RequirementInfo');
                    catch
                        noslashes = strrep(itemname, '//', '/');               
                        try % Next from Stateflow.
                            reqstr = reqsf('get', REQNAME, str, noslashes);
                        catch % Should never get here.
                            if (REQCONNECTED)
                                delete(REQSYSHANDLE); % Close connection.
                            end
                            REQINITIALIZED = 0;
                            error(lasterr);
                        end
                    end
                    
                    % Make a req "object."
                    if (~isempty(reqstr))
                        r = reqinitstr(reqstr);
                    else
                        r = reqinit;
                    end
                    
                    % Add/update the req and write back to the model.
                    [t, s] = strtok(s, ',');      
                    s = strtok(s, ',');      
                    r = reqadd(r, REQSYS, REQNAME, t, s, 1);
                    if (strcmp(REQTYPES{REQINDEX - 1}, 'StateflowState'))
                        noslashes = strrep(itemname, '//', '/');
                        try
                            reqsf('set', REQNAME, str, noslashes, reqgetstr(r));
                        catch % Should never get here.
                            if (REQCONNECTED)
                                delete(REQSYSHANDLE); % Close connection.
                            end
                            REQINITIALIZED = 0;
                            error(lasterr);
                        end
                    elseif (strcmp(REQTYPES(REQINDEX - 1), 'StateflowTransition'))
                        try
                            reqsf('set', REQNAME, str, itemname, reqgetstr(r));
                        catch % Should never get here.
                            if (REQCONNECTED)
                                delete(REQSYSHANDLE); % Close connection.
                            end
                            REQINITIALIZED = 0;
                            error(lasterr);
                        end
                    else
                        set_param(str, 'RequirementInfo', reqgetstr(r));                        
                    end
                    
                else
                    % Get the M-file requirements, if there are any.
                    reqstr = reqmf('get', REQNAMEFULL);
                    if (~isempty(reqstr))
                        r = reqinitstr(reqstr);
                    else
                        r = reqinit;
                    end
                    
                    % Add/update the req and write back to the model.
                    [t, s] = strtok(s, ',');      
                    s = strtok(s, ',');      
                    r = reqadd(r, REQSYS, REQNAME, t, s);
                    try,
                        reqmf('set', REQNAMEFULL, reqgetstr(r));
                    catch
                        % Should never get here.
                        if (REQCONNECTED)
                            delete(REQSYSHANDLE); % Close connection.
                        end
                        REQINITIALIZED = 0;
                        error(lasterr);
                    end
                end
            end
        end
        
    otherwise,
        retstat = -1;
        
    end % switch REQSYS,
    
    %%%%%%%%%%%%%%%%%%%%%%%%
case 'end',
    % Finish the transaction block, close connections, and cleanup.
    %%%%%%%%%%%%%%%%%%%%%%%%
    
    if (isempty(REQINITIALIZED) | (0 == REQINITIALIZED))
        retstat = -10;
        return;
    end
    
	switch REQSYS,
	case 'DOORS'
		% dboissy says:
		% Why do we need to save the model?
		%
		%% Save the model and re-open for send only.
		%switch subcommand,
		%case 'send',
		%	if (~REQFILETYPE)
		%		try,
		%			close_system(REQNAME, 1); % Closes with save option
		%		catch
		%			if (REQCONNECTED)
		%				delete(REQSYSHANDLE); % Close connection.
		%			end
		%			REQINITIALIZED = 0;
		%			error('Error saving file.  Permission may be readonly.  Change and try again.');
		%		end
		%		if (~IsModelOpenLocal(REQNAME))
		%			open_system(REQNAMEFULL);
		%		end
		%		
		%		%else
		%		% M-file- no action required.  reqmf does this.
		%		
		%	end % if (~REQFILETYPE)
		%end % switch subcommand,

        endfunc = '';
        switch subcommand,
        case 'send',
            
            % Get and format the lastmodified date as "DD MMM YYYY HH:MM:SS".
            s = '';
            if (~REQFILETYPE) % model
                s = get_param(REQNAME, 'LastModifiedDate');
                s = [s(5:10) ' ' s(21:24) ' ' s(12:19)];
            else % file
                d = dir(REQNAMEFULL);
                if (~isempty(d))
                    s = d.date; 
                    s = strrep(s, '-', ' ');   
                end;
            end             
            endfunc = ['dmiSendObjectEnd_("' s '");'];
        case 'select',
            endfunc = 'dmiSelectObjectEnd_();';
        otherwise,
            retstat = -1; % Unknown subcommand.
            return;
        end % switch subcommand,
        
        % Make server call.
        try,
            invoke(REQSYSHANDLE, 'runStr', endfunc);
        catch
            if (REQCONNECTED)
                delete(REQSYSHANDLE); % Close connection.
            end
            REQINITIALIZED = 0;
            error([REQSYS ' requirements system server not available (5).']);
        end
        
        % Handle result of successful server call.
        rstat = get(REQSYSHANDLE, 'Result');
        if (~isempty(rstat)),
            if (REQCONNECTED)
                delete(REQSYSHANDLE); % Close connection.
            end
            REQINITIALIZED = 0;
            error(rstat);
        end
        
    otherwise,
        retstat = -1; % Unknown requirements system.
        
        % Do nothing with: case 'WORD',
        % Do nothing with: case 'EXCEL',
        
    end % switch REQSYS,
    
    if (REQCONNECTED)
        delete(REQSYSHANDLE); % Close connection.
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%
case 'getmodifieddate',
    % Get the last modified date from the model or file.
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    if (isempty(REQINITIALIZED) | (0 == REQINITIALIZED))
        retstat = -10; 
        return;
    end
    
    % Validate requirements system.
    if (~strcmp(REQSYS, 'DOORS'))
        if (REQCONNECTED)
            delete(REQSYSHANDLE); % Close connection.
        end
        REQINITIALIZED = 0;
        error('The run function is only supported with DOORS');
    end         
    
    fdate = '';
    if (~REQFILETYPE) % model
        try
            open_system(REQNAME);
            s = get_param(REQNAME, 'LastModifiedDate');
            fdate = [s(5:10) ' ' s(21:24) ' ' s(12:19)];
        catch
            if (REQCONNECTED)
                delete(REQSYSHANDLE); % Close connection.
            end
            REQINITIALIZED = 0;
            error(lasterr);
        end
    else % file
        d = dir(REQNAMEFULL);
        if (~isempty(d))
            fdate = d.date; 
            fdate = strrep(fdate, '-', ' ');
        else
            if (REQCONNECTED)
                delete(REQSYSHANDLE); % Close connection.
            end
            REQINITIALIZED = 0;
            error(lasterr);
        end
    end             
    
    % Make server call.
    try
        invoke(REQSYSHANDLE, 'runStr', ['dmiGetModifiedDate_("' REQNAME '");']);
    catch
        if (REQCONNECTED)
            delete(REQSYSHANDLE); % Close connection.
        end
        REQINITIALIZED = 0;
        error([REQSYS ' requirements system server not available (6).']);
    end
    
    % Handle result of server call.
    stat = get(REQSYSHANDLE, 'Result');    
    if (isempty(stat) | strncmp(stat, 'DMI Message', 9))
        retstat = 'true|Model or file is in sync with DOORS.';
	elseif (datenum(stat) == datenum(fdate))
 	    retstat = 'true|Model or file is in sync with DOORS.';
    else
        retstat = [ 'false|Model or file may not be in sync with DOORS!' char(10) ...
                '  MATLAB date is: ' fdate '.' char(10) '  DOORS date is: ' stat '.'];          
    end 
    
end % switch command,

% end function retstat = reqmgrctl(command, subcommand, varargin)


function r = IsModelOpenLocal(n)
%ISMODELOPENLOCAL gives model open status.
%   R = ISMODELOPENLOCAL(N) returns 1 if model N is open
%   and 0 if model N is not open.

a = find_system(0, 'blockdiagramtype', 'model');
b = get_param(a, 'name');
c = strcmp(n, b);
r = sum(c);

% end function r = IsModelOpenLocal(n)

function sl = GetLevelsLocal(str)
%GETLEVELSLOCAL returns number of levels (as a string) in a path.
%   SL = GETLEVELSLOCAL(STR) returns the number of levels
%   in string STR determined by the number of slashes.

if (iscell(str))
    sl = cell(length(str), 1);
    for (i = 1 : length(str))
        sl{i, 1} = GetLevelsLocal(str{i});
    end
else
    sl  = '0';
    str = strrep(str, '//', '\');
    sl  = length(findstr(str, '/'));
    if (~isempty(sl))
      sl  = num2str(sl + 1);
    end
end
%end function sl = GetLevelsLocal(str)

