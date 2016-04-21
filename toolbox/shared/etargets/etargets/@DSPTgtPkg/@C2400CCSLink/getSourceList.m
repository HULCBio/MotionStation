function sources = getSourceList (h, target_state, modelInfo, hLinkerOptions, modules)

% $RCSfile: getSourceList.m,v $
% $Revision: 1.1.6.2 $ $Date: 2004/04/08 21:05:54 $
% Copyright 2003-2004 The MathWorks, Inc.

sources = {};

if ( ~strcmp(hLinkerOptions.getLinkerCMDFile,'Custom_file'))
    linkerCommandFile = [modelInfo.name,'.cmd'];
    modules = [modules,' ',linkerCommandFile];
end

% create list of source files 
sourceFiles =  [h.getProjectFileList(modelInfo.name, modelInfo.buildOpts.sysTargetFile, 'source') modules];  

% Parse the source list and find full path names for each file
remainingSources = sourceFiles;
while ~isempty(remainingSources),
    % Get next source name
    [thisFile, remainingSources] = strtok(remainingSources);
    if ~isempty(thisFile),
        % Find full pathname of File
        fullPathName = {findFullPath(h, thisFile)};    
        % Add source to CCS project:
        sources = [sources; fullPathName];
    end
end

% add custom linker-command file
if ( strcmp(hLinkerOptions.getLinkerCMDFile,'Custom_file'))
    sources{length(sources)+1} = hLinkerOptions.getLinkerCMDFileName;
end


%-------------------------------------------------------------------------------
function fullSourceName = findFullPath(h, thisSource)
% returns the full name of a source file, including path.
searchPaths = h.getSearchPaths;
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

% [EOF] getSourceList.m
