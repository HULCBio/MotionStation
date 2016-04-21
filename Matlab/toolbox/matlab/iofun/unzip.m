function unzip(zipFilename,outputDirectory)
%UNZIP Extract the contents of a zip file.
%   UNZIP(ZIPFILE) extracts the contents of a zip file into the current 
%   directory.
%
%   UNZIP(ZIPFILE,OUTPUTDIR) extracts the contents of a zip file into the 
%   directory OUTPUTDIR.
%
%   See also ZIP.

% Matthew J. Simoneau, 15-Nov-2001
% Copyright 1984-2004 The MathWorks, Inc.
% $Revision: 1.4.2.2 $ $Date: 2004/03/08 02:02:10 $

% This function requires Java.
if ~usejava('jvm')
   error('MATLAB:unzip:NoJvm','UNZIP requires Java.');
end

import java.io.*;
import java.util.zip.ZipFile;
import com.mathworks.mlwidgets.io.InterruptibleStreamCopier;

% Argument parsing.
error(nargchk(1,2,nargin));
if (nargin == 1)
    outputDirectory = pwd;
elseif ~exist(outputDirectory,'dir')
    error('Directory "%s" does not exist.',outputDirectory)
end
    
% Open the Zip file.
if ~exist(zipFilename,'file')
    error('File "%s" does not exist.',zipFilename);
end
try
    zipFile = ZipFile(zipFilename);
catch
    error('Error opening zip file "%s".',zipFilename);
end

% This InterruptibleStreamCopier is unsupported and may change without notice.
interruptibleStreamCopier = ...
    InterruptibleStreamCopier.getInterruptibleStreamCopier;

% Inflate all entries.
enumeration = zipFile.entries;
while enumeration.hasMoreElements
    zipEntry = enumeration.nextElement;
    % Open output stream.
    outputName = fullfile(outputDirectory,char(zipEntry.getName));
    file = java.io.File(outputName);
    if zipEntry.isDirectory
        file.mkdirs;
    else
        parent = File(file.getParent);
        parent.mkdirs;
        try
            fileOutputStream = java.io.FileOutputStream(file);
        catch
            error('Could not create "%s".',outputName);
        end
        % Extract entry to output stream.
        inputStream = zipFile.getInputStream(zipEntry);
        interruptibleStreamCopier.copyStream(inputStream,fileOutputStream);
        % Close streams.
        fileOutputStream.close;
        inputStream.close;
        % Set timestamp.
        lastModified = zipEntry.getTime;
        file.setLastModified(lastModified);
    end
end
% Close zip.
zipFile.close;
