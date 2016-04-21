function message = prepareOutputLocation(outputAbsoluteFilename)
%PREPAREOUTPUTLOCATION Verifies directory is writable and creates subdirectory.
%   PREPAREOUTPUTLOCATION(filename) checks that the directory exists, tries to
%   create the directory if it doesn't, and checks the file is writable.  It
%   returns a descriptive string if there's a problem or an empty string if
%   everything is OK.

% Matthew J. Simoneau, October 2003
% $Revision: 1.1.6.5 $  $Date: 2004/04/10 23:24:54 $
% Copyright 1984-2004 The MathWorks, Inc.

message = '';

% Make sure the output directory exists.  If not, try to make it.
outputDir = fileparts(outputAbsoluteFilename);
if isempty(dir(outputDir))
    try
        mkdir(outputDir)
    catch
        message = sprintf( ...
            'The output directory "%s" does not exist and can''t be created.', ...
            outputDir);
        return
    end
end

% Make sure the output location is writable.
if isempty(dir(outputAbsoluteFilename))
    % This file doesn't exist yet.  Can we write to this location?
    fid = fopen(outputAbsoluteFilename,'w');
    if (fid == -1)
        % No, we can't.
        message = sprintf( ...
            'The output directory "%s" is not writable.', ...
            outputDir);
    else
        % Yes, we can.
        fclose(fid);
        delete(outputAbsoluteFilename)
    end 
else
   % This file exists.  Delete it to make way.
    w = warning('off','MATLAB:DELETE:Permission');
    delete(outputAbsoluteFilename);
    warning(w);
    if ~isempty(dir(outputAbsoluteFilename))
       % Couldn't delete it.
       message = sprintf( ...
          'The output file "%s" already exists and is not writable.', ...
          outputAbsoluteFilename);
    end
end
