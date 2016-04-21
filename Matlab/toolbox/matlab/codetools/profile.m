function s = profile(varargin)
%PROFILE Profile function execution time.
%   PROFILE ON starts the profiler and clears previously recorded
%   profile statistics.
%
%   PROFILE ON may be followed by the -HISTORY option.
%
%      -DETAIL LEVEL
%         This option specifies the set of functions for which
%         profiling statistics are gathered.  If LEVEL is 'mmex'
%         (the default), then information about M-functions,
%         M-subfunctions, and MEX-functions is recorded.  If
%         LEVEL is 'builtin', then in addition the profiler
%         records information about builtin functions such as
%         EIG.
%
%      -HISTORY
%         If this option is specified, MATLAB records the exact
%         sequence of function calls so that a function call
%         history report can be generated.  NOTE: MATLAB will
%         not record more than 10000 function entry and exit
%         events.  However, MATLAB will continue recording
%         other profiling statistics after this limit has been
%         reached.
%
%   PROFILE OFF stops the profiler.
%
%   PROFILE VIEWER stops the profiler and opens the graphical profile browser.
%   The output for PROFILE VIEWER is an HTML file in the Profiler window.
%   The file listing at the bottom of the function profile page shows four
%   columns to the left of each line of code.
%         Column 1 (red) is total time spent on the line in seconds.
%         Column 2 (blue) is number of calls to that line.
%         Column 3 is the line number
%
%   PROFILE RESUME restarts the profiler without clearing
%   previously recorded function statistics.
%
%   PROFILE CLEAR clears all recorded profile statistics.
%
%   S = PROFILE('STATUS') returns a structure containing
%   information about the current profiler state.  S contains
%   these fields:
%
%       ProfilerStatus   -- 'on' or 'off'
%       DetailLevel      -- 'mmex', or 'builtin'
%       HistoryTracking  -- 'on' or 'off'
%
%   STATS = PROFILE('INFO') suspends the profiler and returns
%   a structure containing the current profiler statistics.
%   STATS contains these fields:
%
%       FunctionTable    -- structure array containing stats
%                           about each called function
%       FunctionHistory  -- function call history table
%       ClockPrecision   -- precision of profiler time
%                           measurement
%       ClockSpeed       -- Estimated clock speed of the cpu (or 0)
%       Name             -- name of the profiler (i.e. MATLAB)
%
%   The FunctionTable array is the most important part of the STATS
%   structure. Its fields are:
%
%       FunctionName     -- function name, includes subfunction references
%       FileName         -- file name is a fully qualified path
%       Type             -- M-function, MEX-function
%       NumCalls         -- number of times this function was called
%       TotalTime        -- total time spent in this function
%       Children         -- FunctionTable indices to child functions
%       Parents          -- FunctionTable indices to parent functions
%       ExecutedLines    -- array detailing line-by-line details (see below)
%       IsRecursive      -- is this function recursive? boolean value
%
%   The ExecutedLines array has several columns. Column 1 is the line
%   number that executed. If a line was not executed, it does not appear in
%   this matrix. Column 2 is the number of times that line was executed,
%   and Column 3 is the total spent on that line. Note: The sum of Column 3 does
%   not necessarily add up to the function's TotalTime.
%
%   If you want to save the results of your profiler session to disk, use
%   the PROFSAVE command.
%
%   Examples:
%
%       profile on
%       plot(magic(35))
%       profile viewer
%       profsave(profile('info'),'profile_results')
%
%       profile on -history
%       plot(magic(4));
%       p = profile('info');
%       for n = 1:size(p.FunctionHistory,2)
%           if p.FunctionHistory(1,n)==0
%               str = 'entering function: ';
%           else
%               str = ' exiting function: ';
%           end
%           disp([str p.FunctionTable(p.FunctionHistory(2,n)).FunctionName]);
%       end
%
%   See also PROFSAVE, PROFVIEW.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.10 $  $Date: 2004/04/10 23:25:05 $

initialState = callstats('status');
callstats('stop');
enableAtEnd = strcmp(initialState, 'on');

[action, detailLevel, history, fname, msg] = ParseInputs(varargin{:});
if (~isempty(msg))
    error(msg);
end

switch action
    case 'on'
        callstats('stop');
        callstats('clear');
        callstats('level', detailLevel);
        callstats('history', history);
        notifyUI('start');
        callstats('start');

    case 'off'
        callstats('stop');
        enableAtEnd = 0;
        notifyUI('stop');

    case 'resume'
        notifyUI('start');
        callstats('resume');

    case 'clear'
        callstats('clear');
        notifyUI('clear');

    case 'report'
        profreport

    case 'viewer'
        if ~usejava('mwt')
            error('The profiler requires the Java VM');
        else
            callstats('stop');
            enableAtEnd = 0;

            stats = profile('info');
            if isempty(stats.FunctionTable)
                com.mathworks.mde.profiler.Profiler.invoke;
            else
                notifyUI('stop');
                profview(0,stats);
            end
        end

    case 'status'
        s.ProfilerStatus = initialState;
        switch callstats('level')
            case 1
                s.DetailLevel = 'mmex';

            case 2
                s.DetailLevel = 'builtin';
        end
        if (callstats('history'))
            s.HistoryTracking = 'on';
        else
            s.HistoryTracking = 'off';
        end

    case 'info'
        enableAtEnd = 0;
        [ft,fh,cp,name,cs] = callstats('stats');
        s.FunctionTable = ft;
        s.FunctionHistory = fh;
        s.ClockPrecision = cp;
        s.Name = name;
        s.ClockSpeed = cs;

    case 'none'
        % Nothing to do

    otherwise
        warning('MATLAB:profile:ObsoleteSyntax', ...
            'Unknown argument for PROFILE. See HELP PROFILE.');
end

if (enableAtEnd)
    callstats('resume');
end


%%%
%%% ParseInputs
%%%
function [action, level, history, fname, msg] = ParseInputs(varargin)
%PARSEINPUTS Parse user's input arguments.

% Defaults
action = 'none';
level = 1;
history = 0;
fname = '';
msg = '';

msg = nargchk(1,Inf,nargin);
if (~isempty(msg))
    return;
end

% Walk the input argument list
k = 1;
while (k <= nargin)
    arg = varargin{k};
    if (~ischar(arg) || isempty(arg))
        msg = 'Invalid input.';
        return;
    end

    if (arg(1) == '-')
        % It's an option
        options = {'detail', 'history'};
        idx = strmatch(lower(arg(2:end)), options);
        if (isempty(idx))
            msg = 'Unknown option.';
            return;
        end
        if (length(idx) > 1)
            msg = 'Ambiguous option.';
            return;
        end

        option = options{idx};
        switch option
            case 'detail'
                if (k == nargin)
                    msg = 'LEVEL must follow -DETAIL option';
                    return;
                end

                k = k + 1;
                levels = {'mmex', 'builtin'};
                level = strmatch(lower(varargin{k}), levels);
                if (isempty(level))
                    msg = 'Invalid LEVEL setting.';
                    return;
                elseif (length(level) > 1)
                    msg = 'Ambiguous LEVEL setting.';
                    return;
                end

            case 'history'
                history = 1;

            otherwise
                msg = 'Unknown option.';
                return;
        end

    else
        % It's an action
        action = varargin{k};

        if (strcmp(action, 'report'))
            if (k < nargin)
                fname = varargin{k+1};
                k = k + 1;
            else
                fname = tempname;
            end
        end
    end

    k = k + 1;
end


function notifyUI(action)

if usejava('mwt')
    import com.mathworks.mde.profiler.Profiler;
    switch action
        case 'start'
            Profiler.start;
        case 'stop'
            Profiler.stop;
        case 'clear'
            Profiler.clear;
    end
end
