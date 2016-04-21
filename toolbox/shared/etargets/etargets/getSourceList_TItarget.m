function sources = getSourceList_TItarget (target_state, modelInfo, modules)

% $RCSfile: getSourceList_TItarget.m,v $
% $Revision: 1.1.6.1 $ $Date: 2004/01/22 18:37:32 $
% Copyright 2001-2003 The MathWorks, Inc.

sources = {};

useDSPBIOS = isUsingDSPBIOS_TItarget(modelInfo);

if (useDSPBIOS),    
    feval(['generate_CDB_TItarget'], target_state, modelInfo);
    % add DSP/BIOS configuration file and corresponding linker command file file
    cdbFile = [modelInfo.name,'.cdb'];
    modules = [modules ' ' cdbFile];
    linkerCommandFile = [modelInfo.name,'.cmd'];
    modules = [modules,' ',linkerCommandFile];         
else
    % add linker command file to modules list
    CMDfileOption = parseRTWBuildArgs_DSPtarget(modelInfo.buildArgs,'LINKER_CMD');
    if isUserDefined(CMDfileOption),
        linkerCommandFile = findCMDfile(modelInfo.buildArgs);
        sources = [sources; {linkerCommandFile}];
    else % use generated linker command file
        linkerCommandFile = [modelInfo.name,'.cmd'];
        modules = [modules,' ',linkerCommandFile];
    end
end

% create list of source files 
sourceFiles = getProjectFiles_TItarget(modelInfo.name,'source',useDSPBIOS);
sourceFiles = [sourceFiles modules];  

% Parse the source list and find full path names for each file
remainingSources = sourceFiles;
while ~isempty(remainingSources),
    % Get next source name
    [thisFile, remainingSources] = strtok(remainingSources);
    
    if ~isempty(thisFile),
        % Find full pathname of File
        fullPathName = {findFullPath(thisFile)};
        
        % Add source to CCS project:
        sources = [sources; fullPathName];
    end
end

% Add files (for certain block types) for which we shouldn't do the 
% normal full-path search, because we already know the exact
% location.

% Add HIL Block files
hilBlocks = find_system(modelInfo.name,'FollowLinks','on','LookUnderMasks','on',...
    'MaskType','Hardware-in-the-Loop Function Call');
for k = 1:length(hilBlocks),
    blk = hilBlocks{k};
    UDATA = get_param(blk,'UserData');
    for f = 1:length(UDATA.sourceFiles),
        thisFile = UDATA.sourceFiles{k};
        if exist(thisFile,'file')
            sources = [sources; {thisFile}];
        else
            error(['HIL Block error:  File ' thisFile ' does not exist.']);
        end
    end
end

% Add S-function Builder files
sfbBlocks = find_system(modelInfo.name,'FollowLinks','on','LookUnderMasks','on',...
    'MaskType','S-Function Builder');
for k = 1:length(sfbBlocks),
    blk = sfbBlocks{k};
    module1 = get_param(blk,'SFunctionModules');
    thisFile = strrep(module1,'_wrapper ','_wrapper.c');
    wd = pwd;
    cd('..'); % Go back to the directory where user started RTW build
    if exist(thisFile,'file')
        thisFile = which(thisFile);
        cd(wd);
        sources = [sources; {thisFile}];
    else
        cd(wd);
        error(['S-function Builder block file ' thisFile ' does not exist.']);
    end
end


%-------------------------------------------------------------------------------
function linkerCommandFile = findCMDfile(buildArgs)
% return full file path to user-defined linker command file

linkerCommandFile = parseRTWBuildArgs_DSPtarget(buildArgs,'USER_LINKER_CMD');
% look in specified full path
if isFullPath(linkerCommandFile),
    if ~exist(linkerCommandFile),
        error('Could not find user-defined linker command file in specified directory.');
    end
else 
    % check parent to working directory
    trialFullFile = fullfile(getParentDir, linkerCommandFile);
    if exist(trialFullFile),
        linkerCommandFile = trialFullFile;
    else
        % check MATLAB path
        linkerCommandFile = which(linkerCommandFile);
        if isempty(linkerCommandFile),
            error(sprintf(['Could not find user-defined linker command file in current\n'...
                    'working directory, or anywhere on the MATLAB path.']));
        end
    end
end

    
%-------------------------------------------------------------------------------
function bool = isUserDefined(linkerOption)

bool = strcmp(linkerOption, 'User_defined');


%-------------------------------------------------------------------------------
function bool = isFullPath(file)

[path,name,ext,ver] = fileparts(file);
bool = ~isempty(path);


%-------------------------------------------------------------------------------
function parentDir = getParentDir
% get full path to parent of current working directory

x= pwd;
y = findstr(pwd, filesep);
parentDir = x(1:y(length(y))-1);


%-------------------------------------------------------------------------------
function fullSourceName = findFullPath(thisSource)
% returns the full name of a source file, including path.

searchPaths = getSearchPaths_TItarget;

for i=1:length(searchPaths),
    trialName = fullfile(searchPaths{i}, thisSource);
    if exist(trialName,'file'),
		% found
        fullSourceName = trialName;
        return
    end
end

% Otherwise returns with empty string
fullSourceName = '';

% [EOF] getSourceList_TItarget.m
