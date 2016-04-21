function zip(zipFilename,files,rootDir)
%ZIP Compress files into a zip file.
%   ZIP(ZIPFILE,FILES) creates a zip file with the name ZIPFILE from the list
%   of files specified in FILES, a string or a cell array of strings.  Paths
%   specified in FILES must be either relative to the current directory or 
%   absolute.  Directories recursively include all of their content.
%
%   ZIP(ZIPFILE,FILES,ROOTDIR) allows the path for FILES to be specified
%   relative to ROOTDIR rather than the current directory.
% 
%   See also UNZIP.

% Matthew J. Simoneau, 15-Nov-2001
% Copyright 1984-2004 The MathWorks, Inc.
% $Revision: 1.4.2.2 $ $Date: 2004/03/26 13:26:39 $

% This function requires Java.
if ~usejava('jvm')
   error('MATLAB:zip:NoJvm','ZIP requires Java.');
end

import java.io.*;
import java.util.zip.*;
import com.mathworks.mlwidgets.io.InterruptibleStreamCopier;

% Parse arguments.
error(nargchk(2,3,nargin))
if (nargin < 3)
    rootDir = pwd;
end
if ischar(files)
    files = {files};
end

% If no extension is given for output, add ".zip".
[null,null,zipFilenameExt]=fileparts(zipFilename);
if isempty(zipFilenameExt)
    zipFilename = [zipFilename '.zip'];
end

% Create a structure of the inputs.
inputs = [];
for i = 1:length(files)
    filename = files{i};
    if isAbsolute(filename)
        [path,base,ext] = fileparts(filename);
        inputs(i).path = path;
        inputs(i).file = [base ext];
    else
        inputs(i).path = rootDir;        
        inputs(i).file = filename;
    end
end

% Build up list of entries.
entries = [];
while ~isempty(inputs)
    % Pop the next entry off the stack.
    path = inputs(1).path;
    file = inputs(1).file;
    inputs(1) = [];

    filePath = fullfile(path,file);
    if ~isempty(find(file == '*'))
        dirContents = dir(filePath);
        listing = {dirContents.name};
        listing = setdiff(listing,{'.','..'});
        % Push all matches onto the stack.
        for i = 1:length(listing)
            inputs(end+1).path = path;
            inputs(end).file = fullfile(fileparts(file),listing{i});
        end        
    elseif exist(filePath,'dir')
        dirContents = dir(filePath);
        listing = {dirContents.name};
        listing = setdiff(listing,{'.','..'});
        % Push directory contents onto the stack.
        for i = 1:length(listing)
            inputs(end+1).path = path;
            inputs(end).file = fullfile(file,listing{i});
        end
    elseif ~exist(filePath,'file')
        error('File "%s" does not exist.',filePath);
    else
        entries(end+1).file = filePath;
        if ispc
            file = strrep(file,'\','/');
        end
        entries(end).entry = file;
    end
end

% If there is nothing to do, error.  There is no such thing as an "empty zip".
if isempty(entries)
    error('Nothing to zip.')
end

% Check for duplicate entry names.
allNames = {entries.entry};
[uniqueNames,i] = unique(allNames);
if length(uniqueNames) < length(entries)
    firstDup = allNames{min(setdiff(1:length(entries),i))};
    error('Tried to add two files as "%s" in zip.',firstDup);
end

% Open output stream.
try
    fileOutputStream = FileOutputStream(zipFilename);
catch
    error('Could not open "%s" for writing.',zipFilename);
end
zipOutputStream = ZipOutputStream(fileOutputStream);

% This InterruptibleStreamCopier is unsupported and may change without notice.
interruptibleStreamCopier = ...
    InterruptibleStreamCopier.getInterruptibleStreamCopier;

% Add each entry to the zip.
for i = 1:length(entries)
    % Create the objects.
    file = File(entries(i).file);
    fileInputStream = FileInputStream(file);
    zipEntry = ZipEntry(entries(i).entry);
    % Set timestamp.
    lastModified = file.lastModified;
    zipEntry.setTime(lastModified);
    % Put the entry in the zip and copy in the file.
    zipOutputStream.putNextEntry(zipEntry);
    interruptibleStreamCopier.copyStream(fileInputStream,zipOutputStream);
    % Close everything up.
    fileInputStream.close;
    zipOutputStream.closeEntry;
end

%  Close streams.
zipOutputStream.close;
fileOutputStream.close;

%===============================================================================
function status = isAbsolute(file)
if ispc
    status = ~isempty(regexp(file,'^[a-zA-Z]*:\\')) || strncmp(file,'\\',2);
else
    status = strncmp(file,'/',1);
end
