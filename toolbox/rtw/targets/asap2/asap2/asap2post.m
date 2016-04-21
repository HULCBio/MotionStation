function asap2post(ASAP2File, MAPFile)
% ASAP2POST Post-processing of ASAP2 file.
%
%   Operations performed:
%   - Replace MemoryAddress placeholders with addresses from appropriate MAP file
%
%   Syntax:
%   ASAP2POST(ASAP2File, MAPFile)
%
%   Inputs:
%   - ASAP2File: Name of ASAP2 file.
%   - MAPFile:   Name of corresponding MAP file.
%
%   MemoryAddress Placeholder Replacement:
%   --------------------------------------
%   - Calls PERL script to replace MemoryAddress placeholder in ASAP2 file with
%     actual memory address as specified in MAP file.
%   - The PERL script provided expects the following:
%     - MemoryAddress placeholder in ASAP2 file: @MemoryAddress@varName@
%     - MAP file format (space OR tab delimited):
%       ----------------------------------------
%       varName(column1)  MemoryAddress(column2)
%       ----------------------------------------
%       a                 0xFFF0
%       b                 0xFFF1
%       ...
%
%   MAP files vary from compiler to compiler. 
%   To use the provided PERL script with your compiler, either:
%   - Modify the existing PERL script to suite your MAP file format.
%   OR
%   - Reformat your MAP file to match the format described above.

%   Copyright 1994-2002 The MathWorks, Inc.
%   $Revision: 1.3 $

PerlFile  = 'asap2post.pl';

% Get directory in which ASAP2File exists
[ASAP2Dir, ASAP2FileName] = local_fileparts(ASAP2File);
  
% If MAPFile is not in ASAP2Dir, use full path for specifying MAPFileName
[MAPDir, MAPFileName] = local_fileparts(MAPFile);
if ~strcmp(ASAP2Dir, MAPDir)
  MAPFileName = fullfile(MAPDir, MAPFileName);
end

% Change to same directory as ASAP2 file
oldDir = cd;
cd(ASAP2Dir);

% Call PerlFile from operating system
result = callperl(PerlFile, ASAP2FileName, MAPFileName);

% Change back to previous directory
cd(oldDir);

% Display PerlFile output at command line
disp(result)

% ==============================================================================
% SUBFUNCTIONS
% ==============================================================================
function [directory, fileName] = local_fileparts(fileNameIn)
% LOCAL_FILEPARTS Creates file name from parts
% 
% This function assumes that fileNameIn is a valid file in MATLAB
% (ie. exist(fileNameIn) == 2)
%
% There are 6 options for what FileNameIn can contain:
% - 'FcnName'         on MATLAB path (or in current directory)
% - 'relPath\FcnName' on MATLAB path
% - 'absPath\FcnName' on MATLAB path
% - 'FileName.ext'    on MATLAB path
% - 'relPath\FileName.ext'
% - 'absolutePath\FileName.ext'

if exist(fileNameIn) == 2
  % Default covers: 
  % fileNameIn == 'absolutePath\FileName.ext'
  [directory, fileName, ext] = fileparts(fileNameIn);
  fileName = [fileName, ext];
  if isempty(directory) | isempty(ext)
    % fileNameIn == 'FcnName'      on MATLAB path (all 3 cases)
    % fileNameIn == 'FileName.ext' on MATLAB path
    [directory, fileName, ext] = fileparts(which(fileNameIn));
    fileName = [fileName, ext];
  elseif exist([cd, filesep, fileNameIn]);
    % fileNameIn == 'relPath\FileName.ext'
    directory = [cd, filesep, directory];
  end
else
  error(['Unable to find file: ', fileNameIn]);
end

% EOF (LOCAL_FILEPARTS)