function buildRTlibs_tic6000(varargin)
%buildRTlibs_tic6000   Pre-compile four RTW and DSP Blockset runtime libraries
%                      for TI C6000 chips with the specified endianness.  
%                      This file is executed in BaT, but can also be used manually.  
%
%  buildRTlibs_tic6000      builds all libs
%
%  buildRTlibs_tic6000(libName)   builds only the specified file identified
%                                 by filename.
%
%  buildRTlibs_tic6000(product,target,endianness)   builds subset of libs.
%     product:    'rtw' or 'dsp'
%     target:     'c6710', 'c6700', 'c6410'
%     endianness: 'big' or 'little'
%
%  Examples:
%     buildRTlibs_tic6000('dsp_rt_c6710.lib')        builds only one lib 
%     buildRTlibs_tic6000('dsp','c6710','little')    ditto
%     buildRTlibs_tic6000([],'c6700',[])             builds only c670x libs 
%     buildRTlibs_tic6000('dsp',[],'little')         builds only DSP Little Endian libs 
%
% This file must be on the MATLAB path so that it can be executed via the
% makefile.  Keep it at toolbox/rtw/targets/tic6000/tic6000, even though
% the libraries live in toolbox/rtw/targets/tic6000/tic6000/rtlib.  The
% destination directory is hard-coded into this m-file, so pwd is not
% important. 
%
% For more info, see /public/Tom_Hartley/runTimeLibraries/runTimeLibrarySpec.doc
%
% $Revision: 1.9.4.4 $  $Date: 2004/04/08 20:59:33 $
%   Copyright 2002-2004 The MathWorks, Inc.

% This entire function is wrapped in a try/catch to avoid an idle matlab
% that would be killed in BaT.  The catch clause calls myBatError().

try  
    
    origPath = path;
    origPwd = pwd;
    rtlibDir = fullfile(matlabroot, ...
        'toolbox','rtw','targets','tic6000','tic6000','rtlib');
    cd(rtlibDir);
    
    % Create directory to hold project files and object files
    if ~dir_exists(pwd,'autobuild')
        disp(['### Creating ''autobuild'' directory in ' pwd]);
        dos('mkdir autobuild');
    end
    
    cd('autobuild');
    autobuildDir = pwd;
    
    % Store diary to this directory (optional, since makefile indicates MATLAB
    % log file for BaT anyways.  The diary would duplicate the BaT log.
    %diary(['MATLAB_log_' datestr(now,30) '.txt']);
    
    % Leave debug info for log.
    disp('###########################################################################')
    disp('######################  TI C6000 Run-time Library Builder #################')
    disp('###  This m-file will run in BaT and compile RTW and DSP Blockset run-time libraries')
    disp('###  for TI C6000 chips. Consult Tom Hartley with any complaints or suggestions.')
    disp(['### matlabroot: ' matlabroot]);
    disp(['### Target directory : ' rtlibDir]);
    
    % 8 total possible libraries listed with the following attributes:
    %          Name            Product   Target   Endianness
    libNamesAndAttributes = {...
            'rtw_rt_c6710.lib',  'rtw', 'c6710', 'little'; ...
            'rtw_rt_c6700.lib',  'rtw', 'c6700', 'little'; ...
            'rtw_rt_c6410.lib',  'rtw', 'c6410', 'little'; ...
            'rtw_rt_c6710e.lib', 'rtw', 'c6710', 'big'; ...
            'rtw_rt_c6700e.lib', 'rtw', 'c6700', 'big'; ...
            'rtw_rt_c6410e.lib', 'rtw', 'c6410', 'big'; ...
            'dsp_rt_c6710.lib',  'dsp', 'c6710', 'little'; ...
            'dsp_rt_c6700.lib',  'dsp', 'c6700', 'little'; ...
            'dsp_rt_c6410.lib',  'dsp', 'c6410', 'little'; ...
            'dsp_rt_c6710e.lib', 'dsp', 'c6710', 'big'; ...
            'dsp_rt_c6700e.lib', 'dsp', 'c6700', 'big'; ...
            'dsp_rt_c6410e.lib', 'dsp', 'c6410', 'big' };
    
    % Handle input arguments
    if isequal(nargin,0),
        libsToBuild = libNamesAndAttributes;
    elseif isequal(nargin,3)
        product = varargin{1};
        target = varargin{2};
        endian = varargin{3};
        libsToBuild = pickLibsToBuild(libNamesAndAttributes,product,target,endian);
    elseif isequal(nargin,1)
        libNameParam = varargin{1};
        found = find(strcmp(libNamesAndAttributes,libNameParam));  % index of match
        if isempty(found),
            myBatError('Unrecognized lib name parameter.')
        else
            libsToBuild = libNamesAndAttributes(found,:);
        end
    else
        myBatError('Must specify 0, 1, or 3 input arguments')
    end
    
    disp('### Requested libs to build:  ');
    disp('        File          product         target        endianness');
    disp(libsToBuild);
    
    % Get handle to CCS; assume board 0
    % In R12dsphw cluster, we use what's configured already.
    % Otherwise, we configure simulator now. 
    if strcmp(getenv('logname'),'batserve') & ~strcmpi(getenv('host'),'dsp00nt'),
        disp('### logname is ''batserve'' and host is not ''dsp00nt'';')
        disp('### therefore, we must reconfigure CCS setup for simulator...')
        configureSimulator;
    end  
    disp('### ccsboardinfo:')
    try
        ccsboardinfo
    catch
        myBatError(lasterr)
    end
    num = getBoardNum;
    disp(['### Instantiating handle to CCS for board ' num2str(num)]);
    ccsObj = ccsdsp('boardnum',num);
    
    disp('### Making CCS visible to aid in debuggin''');
    ccsObj.visible(1);
    
    % Loop through the cases and build
    for k = 1:size(libsToBuild,1),
        libNamek = libsToBuild{k,1};
        productk = libsToBuild{k,2};
        targetk  = libsToBuild{k,3};
        endiank  = libsToBuild{k,4};
        if strcmp(productk,'dsp'),  
            includePathk = fullfile(matlabroot,'toolbox','dspblks','include');
        else
            includePathk = fullfile(matlabroot,'rtw','c','libsrc');
        end
        % Create directory for each .lib file;  e.g., dir name 'rtw_rt_c6710' to hold 
        % project files for that .lib file.
        cd(autobuildDir);
        buildDirName = strrep(libNamek,'.lib','');
        if ~dir_exists(pwd,buildDirName)
            disp(['### Creating subdirectory ' buildDirName]);
            dos(['mkdir ' buildDirName]);
        end
        cd(buildDirName);
        ccsObj.cd(pwd);
        % Get build options
        buildOptions = createBuildOptionsStrings(...
            libNamek, includePathk, targetk, endiank);
        % Prepare project and build lib
        buildLib(libNamek,buildOptions,ccsObj);
        % Check build log for errors
        checkBuildLogForErrors(libNamek);
        cd(rtlibDir);
        verifyLibExists(libNamek);
    end
    
    % Clean up.
    ccsObj.visible(0);
    clear ccsObj;
    pause(3);
    cd(origPwd);
    path(origPath);
    disp('### buildRTlibs_tic6000.m  FINISHED; exiting')
    if strcmp(getenv('logname'),'batserve')
        disp('### Quitting MATLAB so that BaT may resume control.')
        % QUIT MATLAB!!!!!
        quit;
    end
    
catch
    
    myBatError(lasterr)
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%-------------------------------------------------------------------------------
function libsToBuild = pickLibsToBuild(libNamesAndAttributes,product,target,endian)
% For each of the libraries we know how to build, 
% determine if it was requested.
libsToBuild = {};
for k = 1:length(libNamesAndAttributes),
    productMatch = isempty(product) | isequal(product,libNamesAndAttributes{k,2});
    targetMatch  = isempty(target) | isequal(target,libNamesAndAttributes{k,3});
    endianMatch  = isempty(endian) | isequal(endian,libNamesAndAttributes{k,4});
    if productMatch & targetMatch & endianMatch,
        libsToBuild = cat(1, libsToBuild, {libNamesAndAttributes{k,:}});
    end
end

%-------------------------------------------------------------------------------
function buildLib(libName,buildOptions,ccsObj)

% name project file from the library name
projectName = fullfile(pwd,strrep(libName,'.lib','.pjt'));

% Create pjt file and add files to project.
createProject(libName, projectName, ccsObj);

% Set build options
disp(['### Setting build options for ' libName ':']);
buildOptions{:}
pause(2)
setLibBuildOptions(ccsObj,buildOptions);

% make sure DSP is halted
ccsObj.halt;

% build library
disp(['### Note: the following action may take up to 1 hour starting ' datestr(now) '.']);
disp(['### Initiating CCS build for run-time library:  ' libName]);
% compile and link the project file, timeout set to 1.2 hour = 4320 seconds
ccsObj.build(4320);
disp(['### Build ended ' datestr(now) ' (this means it either completed normally or was terminated) ']);
disp('### Saving and closing CCS project.');
ccsObj.save(projectName,'project');
ccsObj.close(projectName,'project');

%----------------------------------------------------------------------------
function sourceInfo=getLibSourceList(libName)
% Return list of source file names, source file paths, and include paths for
%    the run-time library to be built.
%
% syntax:
%    sourceInfo = getLibSourceList('RTWLIB')
%    sourceInfo = getLibSourceList('DSP_RT')
%
% output:
%    sourceInfo.includePath - cell array containing additional include
%                            directories. Those directories will be 
%                            expanded into include instructions of rtw 
%                            generated make files.
%     
%    sourceInfo.sourcePath - cell array containing additional source
%                            directories. Those directories will be
%                            expanded into rules of rtw generated make
%                            files.
%
%    sourceInfo.modules    - cell array containing list of source file
%                            names.

if ~isempty(strmatch('dsp_rt',libName)),
    % building dsp_rt*.lib
    rtDir = fullfile(matlabroot,'toolbox','rtw','dspblks','c');
    sourceInfo.includePath = fullfile(matlabroot,'toolbox','dspblks','include');
else % rtw_rt*.lib
    rtDir = fullfile(matlabroot,'rtw','c','libsrc');
    sourceInfo.includePath  = fullfile(matlabroot,'rtw','c','libsrc');
end

rtSubDirs = getfilesbytype(rtDir, 'd');

sourceInfo.sourcePath = {rtDir rtSubDirs{:}};
sourceInfo.modules  = strrep(getfilesbytype(rtDir, '*.c'),'.c','');


%----------------------------------------------------------------------------
function cellFiles = getfilesbytype(directory, pattern)
% Returns a cell array with filenames that matches the 'pattern' (eg. *.c)
% within the given 'directory' tree.
%
% Returns a cell array of directories if the 'pattern' equals 'd'.
%
cellFiles = {};
if pattern == 'd'
    bDir = 1;
    localPattern = '*';
else
    bDir = 0;
    localPattern = pattern;
end
currDir = pwd;

cd(directory);

if ~bDir
    files = dir(localPattern);
    for i=1:length(files)
        if ~(files(i).isdir)
            cellFiles{end+1} = files(i).name;
        end
    end
end

%%% recurse on directories
strDir = dir;
for i=1:length(strDir)
    if strDir(i).isdir & strDir(i).name(1) ~= '.'
        if bDir
            cellFiles{end+1} = fullfile(pwd, strDir(i).name);
        end
        tempCell = getfilesbytype(strDir(i).name, pattern);
        cellFiles = {cellFiles{:}, tempCell{:}};
    end
end

cd(currDir);

% ------------------------------------------------------
function  createProject(libName, projectName, ccsObj);

disp('### Getting source list')
sources=getLibSourceList(libName);

% Get full-path filenames via search algorithm
disp('### Getting full-path locations for all source files')
verifiedNames = {};
for i=1:length(sources.modules),
    if ~isempty(sources.modules{i}),
        for j=1:length(sources.sourcePath),
            % try next search path:
            trialName = [sources.sourcePath{j} '/' sources.modules{i} '.c'];
            if exist(trialName,'file'),
                % Found module name:
                verifiedNames{end+1} = trialName;
                break;
            end  % If we don't find it, it simply doesn't go in the library.
        end
    end
end

% Compare to cached list to see if any have since been removed - we can't
%  open the project if that happens, because CCS would issue a modal
%  dialog for the missing file. 
if exist('sourceNamesMatFile.mat')
    disp('### Comparing new source list to cached list to determine if we must start from scratch.')
    reconstructProjectFromScratch = false;  % default, unless any sources are obsolete
    fileVars = load('sourceNamesMatFile');
    previousNames = fileVars.verifiedNames;
    for k = 1:length(previousNames),
        
        % Search for previousNames{k} in verifiedNames{:}. 
        % Only take into account the name (not the path).
        [dummy1,oldName,dummy2,dummy3] = fileparts(previousNames{k});
        found = 0;
        for m = 1:length(verifiedNames)
            [dummy1,newName,dummy2,dummy3] = fileparts(verifiedNames{m});
            if strcmp(oldName,newName)
                found = 1;
                break
            end
        end 
        if found==0
            disp(['### This source file: ' previousNames{k} ...
                    '  was removed since the last CCS build. We must reconstruct ' ...
                    ' the project from scratch.']);
            reconstructProjectFromScratch = true;
            break
        end
        
    end 
else  % mat file does not exist 
    disp('### There is no cached file list, so we must build from scratch.')
    reconstructProjectFromScratch = true; 
end

disp('### Saving new list of names in mat file for next time...')
save sourceNamesMatFile verifiedNames;

% close previous library project
ccsObj.close('all','text');
ccsObj.save('all','project');
try
    % undocumented method:  Close project (any target)
    callSwitchyard(ccsObj.ccsversion,[45,ccsObj.boardnum,ccsObj.procnum,0,0], projectName)    
catch
    % projectName is not open in any board
end

% Create or Open the project file
if reconstructProjectFromScratch | ~exist(projectName,'file')
    disp('### Creating new project file')
    ccsObj.new(projectName,'projlib');
else
    disp('### Opening project file')
    try
        ccsObj.open(projectName,'Project',60);
    catch
        disp(lasterr)
        myBatError(msg);
    end
end

% add files to project and set build options
disp(['### Adding files to project for ' libName]);
for k = 1:length(verifiedNames),
    try  % if it's already in the project, we'll get an error.
        ccsObj.add(verifiedNames{k});
    end
end

% Remove SVD files that CCS has trouble compiling.
if ~isempty(strmatch('dsp_rt',libName)),
    removeSVD(ccsObj);
end

%-------------------------------------------------------------------------------
function setLibBuildOptions(ccsObj,build_options)
% get current build options
curOpts = ccsObj.getbuildopt;

% set build options for BIOS builder, compiler, and linker
for i=1:3;
    ccsObj.setbuildopt(curOpts(i).name, build_options{i});
end


%-------------------------------------------------------------------------------
function removeSVD(ccsObj)
% remove SVD sources because of compilation problems

ccsObj.remove('svd_d_rt.c');
ccsObj.remove('svd_z_rt.c');
ccsObj.remove('svd_c_rt.c');
ccsObj.remove('svd_r_rt.c');


%-------------------------------------------------------------------------------
function buildOptions = createBuildOptionsStrings(libName,libIncludePath,targetType,endianess)
% Set CCS build options

BIOSstr = '-v6x';

compilerStr = '-q -o2 ';
MLincludePaths = getIncludePaths;
compilerStr = [compilerStr MLincludePaths];
compilerStr = [compilerStr ' -i"' libIncludePath '"'];

if strcmp(endianess, 'big'),
    % set 'big endian'
    compilerStr = [compilerStr ' -me'];
end

% RTW defines
compilerStr = [compilerStr ' -d"MODEL=none" -d"RT" -d"NUMST=1" -d"TID01EQ=0" -d"NCSTATES=0" -d"MT=0"'];

objDir = fullfile(pwd,'obj');
compilerStr = [compilerStr ' -fr"' objDir '"'];

% processor-specific compiler switches
compilerStr = [compilerStr feval(['getCompilerSwitch_' targetType])];

% Write lib to the rtlib directory, two levels up
archiverStr = ['-r -o..\..\' libName];

buildOptions = {BIOSstr;compilerStr;archiverStr};


%-------------------------------------------------------------------------------
function str = getCompilerSwitch_c6710()

str = ' -ml3 -mv6710';

%-------------------------------------------------------------------------------
function str = getCompilerSwitch_c6700()

str = ' -ml3 -mv6700';

%-------------------------------------------------------------------------------
function str = getCompilerSwitch_c6410()

str = ' -ml3 -mv6410';


%-------------------------------------------------------------------------------
function includePaths = getIncludePaths()
% return include paths for targeting

mlroot = feval('matlabroot');
includePaths = ['-i"' mlroot '\simulink\include" '...
        '-i"' mlroot '\extern\include" '...
        '-i"' mlroot '\rtw\c\src" '...
        '-i"' mlroot '\rtw\c\libsrc" '...
        '-i"' mlroot '\toolbox\dspblks\include" '...
        '-i"' mlroot '\toolbox\rtw\targets\tic6000\tic6000\rtlib\include" '];

%-------------------------------------------------------------------------------
function num = getBoardNum;
% Get simulator board number.  If there is no simulator, simply use 
% board 0.

cb = ccsboardinfo;
num = 0;  % default
for k = 1:length(cb),
    if strcmp(cb(k).name,'C6xxx Simulator (Texas Instruments)'),
        num = cb(k).number;
        break;
    end
end
% xxx error out if not C6000

%-------------------------------------------------------------------------------
function checkBuildLogForErrors(libName)

logName = 'cc_build_Debug.log';
if ~exist(logName,'file')
    myBatError(['CCS build log file for "' libName '" does not exist!  Please investigate']);
end
fid = fopen('cc_build_Debug.log');
[logText,count] = fscanf(fid,'%c');
fclose(fid);

% 'Build Complete' must happen within 60 chars from end
found1 = findstr(logText,'Build Complete');
if isempty(found1) | ((found1-count)>60)
    myBatError(['CCS build log file for "' libName '" does not indicate' ...
            ' completed build.  Please investigate.']);
else
    disp(['### Verified that the CCS build log file indicates completed build.']);
end

% '0 Errors' must happen 19 chars after 'Build Complete'
found2 = findstr(logText,'0 Errors');
if isempty(found2) | ((found2-found1)~=19)
    myBatError(['CCS build log file for "' libName '" does not indicate' ...
            ' zero errors.  Please investigate.']);
else
    disp(['### Verified that the CCS build log file indicates zero errors.']);
end

%-------------------------------------------------------------------------------
function verifyLibExists(libName)

if ~exist(libName,'file')
    myBatError(['The file "' libName '" does not exist after its CCS build.  Please investigate!']);
else
    disp(['### Verified that the file "' libName '" exists after build.']);
end

%-------------------------------------------------------------------------------
function myBatError(msg)

% Make it look like a real error so BaT will detect it.  
% We can't actually issue an error,
% because we must exit cleanly so that matlab can then quit.
disp('### An error occurred during buildRTlibs_tic6000.  ')
disp('### Below, we display error text that looks like a')
disp('### real error for the benefit of BaT, and then we quit matlab.')
disp(['Error in ==> ' mfilename])
disp(msg)

% Make CCS invisible so it can terminate when handles disappear.
try
    cc = ccsdsp;
    cc.visible(0);
end

if strcmp(getenv('logname'),'batserve')
    disp('### An error ocurred: Quitting MATLAB so that BaT may resume control.')
    % QUIT MATLAB!!!!!
    quit; 
end

%-------------------------------------------------------------------------------
function result = dir_exists(parentName,dirName)
% exist(name,'dir') does this, but we uncovered some sort of bug 
% (geck 127818).
d = dir(parentName);
result = false;
for k = 1:length(d),
    if strcmp(d(k).name, dirName) & d(k).isdir,
        result = true;
        break
    end
end

% [EOF] buildRTlibs_tic6000.m
