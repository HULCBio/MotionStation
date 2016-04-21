function p = genpath(d)
%GENPATH Generate recursive toolbox path.
%   P = GENPATH returns a new path string by adding
%   all the subdirectories of MATLABROOT/toolbox, including empty
%   subdirectories. 
%
%   P = GENPATH(D) returns a path string starting in D, plus, recursively, all
%   the subdirectories of D, including empty subdirectories.
%   
%   NOTE: GENPATH will not exactly recreate the original MATLAB path.
%
%   See also PATH, ADDPATH, RMPATH, SAVEPATH.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.13.4.3 $ $Date: 2004/03/17 20:05:14 $
%------------------------------------------------------------------------------

if nargin==0,
  p = genpath(fullfile(matlabroot,'toolbox'));
  if length(p) > 1, p(end) = []; end % Remove trailing pathsep
  return
end

% initialise variables
methodsep = '@';  % qualifier for overloaded method directories
p = '';           % path to be returned

% Generate path based on given root directory
files = dir(d);
if isempty(files)
  return
end

% Add d to the path even if it is empty.
p = [p d pathsep];

% set logical vector for subdirectory entries in d
isdir = logical(cat(1,files.isdir));
%
% Recursively descend through directories which are neither
% private nor "class" directories.
%
dirs = files(isdir); % select only directory entries from the current listing

for i=1:length(dirs)
   dirname = dirs(i).name;
   if    ~strcmp( dirname,'.')         & ...
         ~strcmp( dirname,'..')        & ...
         ~strncmp( dirname,methodsep,1)& ...
         ~strcmp( dirname,'private')
      p = [p genpath(fullfile(d,dirname))]; % recursive calling of this function.
   end
end

%------------------------------------------------------------------------------
