function sourceInfo=getLibSourceList_DSPtarget(libName)
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

% $RCSfile: getLibSourceList_DSPtarget.m,v $
% $Revision: 1.1.6.2 $ $Date: 2004/04/08 21:08:00 $
% Copyright 2001-2003 The MathWorks, Inc.

if ~isempty(strmatch('dsp_rt',libName)),
    % building dsp_rt_c67xx.lib
    rtDir = fullfile(matlabroot,'toolbox','rtw','dspblks','c');
    sourceInfo.includePath = fullfile(matlabroot,'toolbox','dspblks','include');
else % rtw_c67xx.lib
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

%% recurse on directories
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

% [EOF] getLibSourceList_DSPtarget.m
