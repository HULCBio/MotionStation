function varargout = c6000tgtpref(varargin)
% c6000tgtpref   Called with no arguments, this function
%                opens the C6000 Target Preferences block library.
%
% The remaining calling syntaxes are for internal use:
%
% boardName = c6000tgtpref('getBoardName',sys)
% boardName = c6000tgtpref('getBoardName')
%     Gets the user-specified board name string.
%
% [b,p] = c6000tgtpref('getBoardProcNums',sys)
% [b,p] = c6000tgtpref('getBoardProcNums')
%     Gets the board and processor numbers (for ccsdsp constructor)
%     according to the user-specified choices, which are stored
%     in the block in name (string) form.
%
% c6000tgtpref('OpenFcn',gcb)
%     Called by the block when you double-click
%     on it.  Opens up the gui "boardprocsel.m" to provide the user
%     a choice of boards and processors.  Stores the info in the block.
%

% Copyright 2003 The MathWorks, Inc.
% $Revision: 1.1.6.2 $  $Date: 2004/04/08 21:00:13 $

if nargin==0,
    % Open the library
    c6000tgtpreflib
    return
end

action = varargin{1};

switch action

    case 'getBoardName',

        if nargin>1,
            sys = varargin{2};
        else
            sys = gcs;
        end
        blk = findTPBlock(sys);
        boardName = getBoardNameForThisTPBlock(blk);
        varargout{1} = boardName;

    case 'getBoardProcNums',

        if nargin>1,
            sys = varargin{2};
        else
            sys = gcs;
        end
        blk = findTPBlock(sys);
        [b,p] = getBoardProcNumsForThisTPBlock(blk);
        varargout{1} = b;
        varargout{2} = p;

    case 'OpenFcn',

        blk = varargin{2};
        [b, p] = boardprocsel;
        if isempty(b),
            % User clicked "X"... do nothing
            return
        end

        % Find corresponding board name and proc name
        % and store in the block
        c = ccsboardinfo;
        b_idx = -1;
        p_idx = -1;
        for k = 1:length(c),
            if c(k).number == b,
                b_idx = k;
                for m = 1:length(c(b_idx).proc),
                    if c(b_idx).proc(m).number == p,
                        p_idx = m;
                    end
                end
            end
        end
        % Failure is unexpected after boardprocsel, but just in case:
        if b_idx == -1,
            b_idx = 1;
        end
        if p_idx == -1,
            p_idx = 1;
        end

        ud.boardName = c(b_idx).name;
        ud.procName  = c(b_idx).proc(p_idx).name;
        set_param(blk,'UserData',ud);
        set_param(blk,'UserDataPersistent','on');
        set_param(blk,'Name',ud.boardName)

end  % switch

% ---------------------------------------------
function msg = emptyPrefMsg

msg = ['There is no board and processor specified '            ...
    'in the model; MATLAB Link for Code Composer Studio '      ...
    'will use the first available '                            ...
    'board and processor listed in CCS Setup.  Use the C6000 ' ...
    'Target Preferences block to specify a '                   ...
    'board and processor.'];

% ---------------------------------------------
function msg = searchFailureMsg

msg = ['Could not find the specified board or processor.  '    ...
    'MATLAB Link for Code Composer Studio '                    ...
    'will use the first available '                            ...
    'board and processor listed in CCS Setup.  Use the C6000 ' ...
    'Target Preferences block to specify the '                 ...
    'board and processor.'];

% ---------------------------------------------
function boardName = getBoardNameForThisTPBlock(blk);

ud = get_param(blk,'UserData');
if isempty(ud),
    c = ccsboardinfo;
    boardName = c(1).name;
    warning(emptyPrefMsg);
else
    boardName = ud.boardName;
end

% ---------------------------------------------
function [b,p] = getBoardProcNumsForThisTPBlock(blk)

if isempty(blk),
    b = 0;
    p = 0;
else
    ud = get_param(blk,'UserData');
    if isempty(ud),
        b = 0;
        p = 0;
        warning(emptyPrefMsg)
    else
        c = ccsboardinfo;
        b_idx = -1;
        p_idx = -1;
        for k = 1:length(c),
            if strcmpi( c(k).name, ud.boardName ),
                b_idx = k;
                for m = 1:length(c(b_idx).proc),
                    if strcmp( c(b_idx).proc(m).name, ud.procName ),
                        p_idx = m;
                    end
                end
            end
        end
        if b_idx == -1,
            b_idx = 1;
            warning(searchFailureMsg);
        end
        if p_idx == -1,
            % don't even warn; just pick #1.
            p_idx = 1;
        end
        b = c(b_idx).number;
        p = c(b_idx).proc(p_idx).number;
    end
end

% ---------------------------------------------
function blk = findTPBlock(sys)

blks = find_system(sys,'FollowLinks','off', ...
    'LookUnderMasks','off','MaskType', 'C6000 Target Preferences');
if isempty(blks),
    warning(emptyPrefMsg);
    blk = '';
else
    if length(blks)>1,
        error(['Only one C6000 Target Preferences block is ' ...
            'allowed in a model.'])
    end
    blk = blks{1};
end

% EOF
