function fullFileLocation = locateFileInPath(fileNames,possiblePaths,fileSeparator,fileQuotes)
% locateFileInPath attempts to locate each element of cell array fileNames
% in the paths specified in the cel array possiblePaths. Once it finds the
% file in a path, it adds path+filename to the returned cell array
% fullFileLocation. In the event no file exists in the specified paths,
% it returns a '' as the place holder for the corresponding element of the
% fileNames cell array. 
%
% NOTE:
%  1. The current folder is searched for implicitly by the search.
%  2. The file extension has to be specified. Otherwise, this function will
%     associate the name of a possible M-file/MEX file (if they exist on
%     MATLAB search path) without the .m or .mex* extensions. This will
%     cause a conflict with the build process.

% Copyright 2004 The MathWorks, Inc.

fullFileLocation = {};

if isempty(fileNames) || (~iscell(fileNames) && ~ischar(fileNames))
  return;
end

if nargin < 4
    fileQuotes = '';
end

numFiles = 0;
numPaths = 0;

if ischar(fileNames)
  numFiles = 1;
  fileNames = {fileNames};
else % should be cell array
  numFiles = length(fileNames);
end

[fullFileLocation{1:numFiles}] = deal(fileNames{1:numFiles});

if ischar(possiblePaths)
  numPaths = 1;
  possiblePaths = {possiblePaths};
elseif iscell(possiblePaths)
  numPaths = length(possiblePaths);
else
  return;
end

for fileNameIdx = 1:numFiles
  for pathIdx = 1:numPaths
    fullFileName = [possiblePaths{pathIdx} fileSeparator fileNames{fileNameIdx}];
    if (exist(fullFileName) >= 2)
      fullFileLocation{fileNameIdx} = [fileQuotes fullFileName fileQuotes];
      break;
    end
  end
end
