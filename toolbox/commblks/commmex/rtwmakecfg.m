function makeInfo=rtwmakecfg()
%RTWMAKECFG adds include and source directories to rtw make files.
%  makeInfo=RTWMAKECFG returns a structured array containing
%  following field:
%     makeInfo.includePath - cell array containing additional include
%                            directories. Those directories will be
%                            expanded into include instructions of rtw
%                            generated make files.
%
%     makeInfo.sourcePath  - cell array containing additional source
%                            directories. Those directories will be
%                            expanded into rules of rtw generated make
%                            files.

%       Copyright 1996-2004 The MathWorks, Inc.
%       $Revision: 1.7.4.8 $ $Date: 2004/04/12 23:03:10 $

disp('### Include Communications Blockset directories');

% MOD: Updated the include path to reflect the new folder structure.

 makeInfo.includePath = { ...
         fullfile(matlabroot,'toolbox','commblks','sim','include'), ...
         fullfile(matlabroot,'toolbox','commblks','sim','sfun','include'), ...
         fullfile(matlabroot,'toolbox','commblks','sim','src','handshake','include'), ...
         fullfile(matlabroot,'toolbox','commblks','sim','src','algorithm', 'include'), ...
         fullfile(matlabroot,'toolbox','comm','commshr','export','include'), ...
         fullfile(matlabroot,'toolbox','comm','commshr','src', 'include'), ...
         fullfile(matlabroot,'toolbox','dspblks','src','sim'), ...
         fullfile(matlabroot,'toolbox','dspblks','src','sim_common'), ...
         fullfile(matlabroot,'toolbox','dspblks','include') };

% makeInfo.includePath = { ...
%         fullfile(matlabroot,'toolbox','commblks','sim','export', 'include'), ...
%         fullfile(matlabroot,'toolbox','commblks','sim','sfun', 'include'), ...
%         fullfile(matlabroot,'toolbox','commblks','sim','src', 'include'), ...
%         fullfile(matlabroot,'toolbox','commblks','sim','src','legacy', 'include'), ...
%         fullfile(matlabroot,'toolbox','comm','commshr','export','include'), ...
%         fullfile(matlabroot,'toolbox','comm','commshr','src', 'include'), ...
%         fullfile(matlabroot,'toolbox','dspblks','src','sim'), ...
%         fullfile(matlabroot,'toolbox','dspblks','include') };

% For Linking in with DSP Run-time library 
rtDir = fullfile(matlabroot,'toolbox','rtw','dspblks','c'); 
 
% MOD: updated src path with src/handshake and src/algorithm.
% removed fullfile(matlabroot,'toolbox','commblks','sim', 'src', 'legacy') };
% FIX: Check if src/algorithm is needed.

if isequal(exist(rtDir), 7) % Check for folder's existence
    rtSubDirs = getfilesbytype(rtDir, 'd');
    makeInfo.sourcePath = { rtSubDirs{:}, ...
        fullfile(matlabroot,'toolbox','comm','commshr','src','legacy'),...
        fullfile(matlabroot,'toolbox','comm','commshr','src','algorithm'),...
        fullfile(matlabroot,'toolbox','commblks','commblksobsolete','v2p5','src'),...
        fullfile(matlabroot,'toolbox','commblks','sim', 'sfun'),...
        fullfile(matlabroot,'toolbox','commblks','sim', 'src', 'handshake'),...
        fullfile(matlabroot,'toolbox','commblks','sim', 'src', 'algorithm')};
else
    makeInfo.sourcePath = {...
        fullfile(matlabroot,'toolbox','comm','commshr','src','legacy'),...
        fullfile(matlabroot,'toolbox','comm','commshr','src','algorithm'),...
        fullfile(matlabroot,'toolbox','commblks','commblksobsolete','v2p5','src'),...
        fullfile(matlabroot,'toolbox','commblks','sim', 'sfun'),...
        fullfile(matlabroot,'toolbox','commblks','sim', 'src', 'handshake'),...
        fullfile(matlabroot,'toolbox','commblks','sim', 'src', 'algorithm')};
end

arch = lower(computer);
if ispc, arch = 'win32'; end

makeInfo.precompile = 1;
% xPC target on Windows uses static libraries, others use dsp_rt.dll,
% so when building for the xPC target or when precompiling static
% libraries,  use dsp_rt, otherwise use dsp_dyn_rt (import libraries
% for dsp_rt.dll).
if ispc,
    modelName = get_param(0, 'CurrentSystem');
    isxPCTarget = strcmp(get_param(modelName,'RTWSystemTargetFile'),...
                         'xpctarget.tlc');
    isPrecomp = strcmp(modelName, 'precomplib');
    if isPrecomp || isxPCTarget,
        makeInfo.library(1).Name = 'dsp_rt';
    else
        makeInfo.library(1).Name = 'dsp_dyn_rt';
    end
else
    makeInfo.library(1).Name     = 'dsp_rt';
end
makeInfo.library(1).Location = fullfile(matlabroot, 'toolbox','dspblks', 'lib', arch);

if isequal(exist(rtDir), 7) % Check for folder's existence
    makeInfo.library(1).Modules  = strrep(getfilesbytype(rtDir, '*.c'),'.c','');
else
    makeInfo.library(1).Modules = '';
end

% Function: getfilesbytype =====================================================
function cellFiles = getfilesbytype(directory, pattern)
% Abstract:
%      Returns a cell array with filenames that maches the 'pattern' (eg. *.c)
%      within the given 'directory' tree.
%      Returns a cell array of directories if the 'pattern' equals 'd'.

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

%% recurse on directories
strDir = dir;
for i=1:length(strDir)
    if strDir(i).isdir & strDir(i).name(1) ~= '.' & strDir(i).name(1) ~= 'CVS'
        if bDir
            cellFiles{end+1} = fullfile(pwd, strDir(i).name);
        end
        tempCell = getfilesbytype(strDir(i).name, pattern);
        cellFiles = {cellFiles{:}, tempCell{:}};
    end
end

cd(currDir);

% [EOF]
