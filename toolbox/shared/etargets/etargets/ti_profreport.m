function returnVal = ti_profreport(varargin)
%TI_PROFREPORT(ACTION, [...])   Generate html report containing
% information from the ccsdsp profile method and analysis of Simulink
% subsystems designated for profiling.  The user interface for this
% function is the CCSDSP PROFILE method.
%
% $Revision: 1.1.6.1 $ $Date: 2004/01/22 18:37:46 $
% Copyright 2001-2003 The MathWorks, Inc.

try

    returnVal = [];

    persistent S

    action = varargin{1};
    % All cases terminate in this switchyard except 'report'.
    if strcmp(action,'clear')
        S = [];
        saveProfileInfo(S);
        return
    elseif strcmp(action,'regSystemInfo')
        S.containsSimulinkSystems = true;
        systemInfo = varargin(2:end);
        S = regSysInfo_TItarget(S,systemInfo);
        saveProfileInfo(S);
        return
    elseif strcmp(action,'getStsObjectNames')
        if isempty(S),
            S = loadProfileInfo(S);
        end
        if ~isempty(S),
            S = parseSlInfo_TItarget(S);
            returnVal = S.stsObjNames;
            saveProfileInfo(S);
        else
            returnVal = {};
        end
        return
    elseif strcmp(action,'report')
        if length(varargin)~=2,
            error('Must specify CCS_Obj as second argument, and no further arguments')
        end
        cc = varargin{2};
        % Continue below
    else
        error('Invalid syntax');
    end

catch
    disp(['Error in ti_profreport.m:  ' lasterr])
    error(lasterr)
end

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Report generator

% Obtain profile data via CCS Link. If the loaded program is not a BIOS
% program, this statement will error out.
P = profile(cc,'raw');
profileTime = now;

if isempty(S) || ~isfield(S,'containsSimulinkSystems') || ...
        ~S.containsSimulinkSystems,
    S = loadProfileInfo(S);
    if isempty(S) || ~isfield(S,'containsSimulinkSystems'),
        S.containsSimulinkSystems = false;
    end
end

if ~S.containsSimulinkSystems,
    % Assume data is valid.
    S.validData = true;
end

% Analyze the contents of S and P; populate S with more info.
if S.containsSimulinkSystems,
    [S,P] = analyzeStats_TItarget(S,P);
end

% Invoke custom html report generator
fileName = generateHTML_TItarget(S,P,profileTime);

% Display in browser
web(fileName);

returnVal = fileName;


%----------------------------------------------------------------
function saveProfileInfo(S)

wd = pwd;
rtwDir = [gcs '_c6000_rtw'];
if isempty(findstr(pwd,rtwDir)),
    if exist(rtwDir)==7,
        cd(rtwDir);
    else
        return  % Can't do anything
    end
end
try
    save profileInfo S
end
cd(wd)

%----------------------------------------------------------------
function S = loadProfileInfo(S)
% Preserves existing S if not loaded

wd = pwd;
rtwDir = [gcs '_c6000_rtw'];
if isempty(findstr(pwd,rtwDir)),
    if exist(rtwDir)==7,
        cd(rtwDir);
    else
        return  % Can't do anything
    end
end
try
    load profileInfo
end
cd(wd)

% EOF  ti_profreport.m
