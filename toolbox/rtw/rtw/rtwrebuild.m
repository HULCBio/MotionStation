function rtwrebuild(varargin) 
%RTWREBUILD  Calls the make command stored inside the information mat file to
%            rebuild the generated code as needed. Supports the following
%            usage:
% 1. rtwrebuild()
%    This usage requires user to CD into RTW build directory, i.e.,
%    ecdemo_ert_rtw. 
% 2. rtwrebuild(modelName)
%    This usage requires current directory to be one level above the model's
%    build directory, i.e. the Matlab pwd when RTW build was done.
% 3. rtwrebuild(path)
%    Same effect as option 1, except user can specify build directory.
% 
% rtwrebuild supports Model Reference. If the model contains submodels, before 
% rebuilding the top model, the submodels are built recursively.

%   Copyright 2003-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/04/15 00:24:59 $
savedpwd = pwd;
if nargin > 0
    if isdir(varargin{1})
        buildDir = varargin{1};
    else
        stfName = get_param(varargin{1},'RTWSystemTargetFile');
        buildDir = fullfile(savedpwd, [varargin{1} '_' strtok(stfName,'.') '_rtw']);
        if exist(buildDir) ~= 7
            error(['Couldn''t find build directory ' buildDir ' of model ' varargin{1}]);
        end
    end
    cd(buildDir);
else
    buildDir = savedpwd;
end

try
    if ~exist('rtw_proj.tmw') 
        error(['Build directory ' pwd ' is broken. Please try rebuild the model first.']);
    end
    rtwProjFile      = fullfile(pwd, 'rtw_proj.tmw');
    fid = fopen(rtwProjFile,'r');
    if fid == -1
        error(['Unable to open RTW project marker file: ',rtwProjFile]);
    end
    line1 = fgetl(fid);
    line2 = fgetl(fid);
    line2 = fgetl(fid); % rtwProjFileContents2 contains 2 lines
    line3 = fgetl(fid);
    fclose(fid);    
    if ischar(line3)
        rtwinfomatfile = deblank(strrep(line3,'The rtwinfomat located at: ',''));
    else
        error(['Incorrect RTW project marker file: ',rtwProjFile]);
    end
    if exist(rtwinfomatfile) ~= 2
        error(['Incorrect RTW project marker file: ',rtwProjFile]);
    end
    load(rtwinfomatfile);
    % recursive build submodels.
    subrebuildCommandPath = infoStruct.directlinkLibrariesFullPaths;
    for  idxrebuildCommandFile = 1:length(subrebuildCommandPath)
        cd(fullfile(infoStruct.relativePathToAnchor, fileparts(subrebuildCommandPath{idxrebuildCommandFile})));
        rtwrebuild;
        cd(buildDir);
    end
    % if submodel lib updated, we'll copy them to builddir.
    for idxLinkLibraries = 1:length(infoStruct.linkLibrariesFullPaths)
        srcLib = fullfile(infoStruct.relativePathToAnchor, infoStruct.linkLibrariesFullPaths{idxLinkLibraries});
        [srcLibpath, srcLibname, srcLibext] = fileparts(srcLib);
        dstLib = fullfile(buildDir, [srcLibname srcLibext]);
        if cmpTimeFlag(dstLib, srcLib) > 0  
            % 1 means dstLib earlier than srcLib, 2 means dstLib doesn't exist.
            rtw_copy_file(srcLib,buildDir);
        end
    end
    cd(buildDir);
    makeCmd = infoStruct.makeCmd;
    if isunix
        % on sol2/hp, make command is in the format of /ML/rtw/bin/sol2/make
        % -f model.mk, so we need do string replacement to make it
        % portable between different matlab root.
        makeCmd = strrep(makeCmd, '$(MATLAB_ROOT)', matlabroot);
        % support rebuild code generated on different MATLABROOT
        % installation.
        makeCmd = [makeCmd, ' MATLAB_ROOT=', matlabroot];
    end
    system(makeCmd);
    cd(savedpwd);
catch
    error(lasterr);
    cd(savedpwd);
end

