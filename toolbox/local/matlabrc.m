%MATLABRC Master startup M-file.
%   MATLABRC is automatically executed by MATLAB during startup.
%   It establishes the MATLAB path, sets the default figure size,
%   and sets a few uicontrol defaults.
%
%   On multi-user or networked systems, the system manager can put
%   any messages, definitions, etc. that apply to all users here.
%
%   MATLABRC also invokes a STARTUP command if the file 'startup.m'
%   exists on the MATLAB path.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.154.4.17 $  $Date: 2004/05/10 21:41:38 $

% Try to catch a potential search path issue if PATHDEF.M throws an error
% or when USEJAVA.M is called. USEJAVA is not a builtin and only builtins
% are guaranteed to be available during initialization.
try
    % Set up path.
    % We check for a RESTOREDEFAULTPATH_EXECUTED variable to check whether
    % RESTOREDEFAULTPATH was run. If it was, we don't want to use PATHDEF,
    % since it may have been the culprit of the faulty path requiring us to
    % recover using RESTOREDEFAULTPATH.
    if exist('pathdef','file') && ~exist('RESTOREDEFAULTPATH_EXECUTED','var')
        oldPath = matlabpath;
        matlabpath(pathdef);
    end
    
    % Avoid running directly out of the bin\win32 directory as this is
    % not supported.
    if ispc,
        pathToBin = [matlabroot,filesep,'bin',filesep,'win32'];
        if isequal(pwd, pathToBin),
            cd (matlabroot);
        end;
    end;
    
    % Display helpful hints.
    % If the MATLAB Desktop is not running, then use the old message, since
    % the Help menu will be unavailable.
    cname = computer;

    if usejava('Desktop')
        fprintf('\n  To get started, select <a href="matlab: doc">MATLAB Help</a> or <a href="matlab: demo matlab">Demos</a> from the Help menu.\n\n')
    else
        disp(' ')
        disp('  To get started, type one of these: helpwin, helpdesk, or demo.')
        disp('  For product information, visit www.mathworks.com.')
        disp(' ')
    end
catch
    % When modifying this code, you can only use builtins
    warning('MATLAB:matlabrc:SuspectedPathProblem', ...
        ['MATLAB did not appear to successfully set the search path. To avoid this\n' ...
            'warning the next time you start MATLAB, use\n' ...
            'http://www.mathworks.com/access/helpdesk/help/techdoc/ref/pathdef.shtml\n' ...
            'to help troubleshoot the "pathdef.m" file. To recover for this session\n' ...
            'of MATLAB, type "restoredefaultpath;matlabrc".']);
    % The initial path was $MATLAB/toolbox/local, so ensure we still have it
    if strncmp(computer,'PC',2)
        osPathsep = ';';
    else
        osPathsep = ':';
    end
    matlabpath([oldPath osPathsep matlabpath])
    
    % Cache all functions that need to be used by RESTOREDEFAULTPATH
    temp=@unix; temp=@system; temp=@which; 
    temp=@regexprep; temp=@sprintf; temp=@clear;
end

% Disable support for SSE2 instructions for now.
feature allowsse2 off;

% Set default warning level to WARNING BACKTRACE.  See help warning.
warning backtrace

% The RecursionLimit forces MATLAB to throw an error when the specified
% function call depth is hit.  This protects you from blowing your stack
% frame (which can cause MATLAB and/or your computer to crash).  Set the
% value to inf if you don't want this protection.
if strncmp(cname,'GLNX',4)
    set(0,'RecursionLimit',100)
else
    set(0,'RecursionLimit',500)
end

% Initialize Handle Graphics.
hgrc

% If neither of the above lines are uncommented then guess
% which papertype and paperunits to use based on ISO 3166 country code.
if usejava('jvm') && ~exist('defaultpaper','var')
    if any(strncmpi(char(java.util.Locale.getDefault.getCountry), ...
            {'gb', 'uk', 'fr', 'de', 'es', 'ch', 'nl', 'it', 'ru',...
            'jp', 'kr', 'tw', 'cn', 'cz', 'sk', 'au', 'dk', 'fi',...
            'gr', 'hu', 'ie', 'il', 'in', 'no', 'pl', 'pt',...
            'ru', 'se', 'tr', 'za'},2))
        defaultpaper = 'A4';
        defaultunits = 'centimeters';
    end
end

% For the 'edit' command, to use an editor defined in the $EDITOR
% environment variable, the following line should be uncommented
% (UNIX only)

%system_dependent('builtinEditor','off')

if usejava('mwt')
    initprefs %% init java prefs system if java is present
    initdesktoputils  %% init desktop setup code if java is present
end

% Text-based preferences
NumericFormat = system_dependent('getpref','GeneralNumFormat');
if ~isempty(NumericFormat)
    eval(['format ' NumericFormat(2:end)]);
end
NumericDisplay = system_dependent('getpref','GeneralNumDisplay');
if ~isempty(NumericDisplay)
    format(NumericDisplay(2:end));
end
MaxTab = system_dependent('getpref','CommandWindowMaxCompletions');
if ~isempty(MaxTab) && MaxTab(1) == 'I'
    EnableTab = system_dependent('getpref','CommandWindowTabCompletion');
    TabSetting = strcmpi(EnableTab,'BTrue') * str2double(MaxTab(2:end));
    system_dependent('TabCompletion', TabSetting);
end
if (strcmp(system_dependent('getpref','GeneralEightyColumns'),'Btrue'))
    feature('EightyColumns',1);
end

% Recycling preference
if strcmp(system_dependent('getpref','GeneralDeleteFunctionRecycles'), ...
        'Btrue')
    recycle('on');
else
    recycle('off');
end

% Load any pre-computed FFTW wisdom information.
try
    s = load('mathworks_fftw.mat');
    fftw('wisdom', s.(computer).wisdom);
catch
end

% Clean up workspace.
clear

% Enable/Disable selected warnings by default
warning off MATLAB:nonScalarConditional
warning on  MATLAB:namelengthmaxExceeded
warning off MATLAB:max:mixedSingleDoubleInputs
warning off MATLAB:max:mixedIntegerScalarDoubleInputs
warning off MATLAB:min:mixedSingleDoubleInputs
warning off MATLAB:min:mixedIntegerScalarDoubleInputs
warning off MATLAB:mir_warning_unrecognized_pragma

% Integer conversion and math warnings
warning off MATLAB:intConvertNonIntVal
warning off MATLAB:intConvertNaN
warning off MATLAB:intConvertOverflow
warning off MATLAB:intMathOverflow

% Turn UsingLongNames warning to detect aliasing problems with legacy
% MATLAB code.  It will warn when any name longer than 31 characters
% is used.
%
warning off MATLAB:UsingLongNames

% Execute startup M-file, if it exists.
if (exist('startup','file') == 2) ||...
        (exist('startup','file') == 6)
    startup
end

% Defer echo until startup is complete
if strcmpi(system_dependent('getpref','GeneralEchoOn'),'BTrue')
    echo on
end
