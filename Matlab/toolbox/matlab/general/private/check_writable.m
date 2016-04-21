% CHECK_WRITABLE. Check Destination for writable attribute
% [DestinationAttributes,DestinationReadOnly] = checkwritable(Source,Destination,mode)
% Input:
%        Source: string defining path to file object.
%        Destination: string defining path to file object.
%        mode: string vector defining copy mode. Optional. 
% Return:
%        TargetAttributes: struct array of file attributes in Destination
%        TargetReadOnly: logical array of file read-only attribute in
%                             Destination

%  Copyright 1984-2002 The MathWorks, Inc.
%  $Revision: 1.9.4.2 $ $Date: 2003/12/19 22:58:46 $
%-------------------------------------------------------------------------------
function [TargetAttributes,TargetReadOnly] = ...
            check_writable(Source,Destination,mode)
%-------------------------------------------------------------------------------

TargetAttributes = struct('Name',{}, ...
                          'archive',{},'system',{},'hidden',{},'directory',{}, ...
                          'UserRead',{},'UserWrite',{},'UserExecute',{}, ...
                          'GroupRead',{},'GroupWrite',{},'GroupExecute',{}, ...
                          'OtherRead',{},'OtherWrite',{},'OtherExecute',{});
TargetReadOnly = false;
Destination = strrep(Destination,'"','');
Source = strrep(Source,'"','');

if exist(Destination,'file')
   
   % Map Source onto Destination.
   if isdir(Source) && isdir(Destination)
      % Get source subtree listing
      SourceList = subtree(Source);
      % Trim source root from subtree listing.
      if ~isempty(SourceList)
         SourceList = regexprep(SourceList, ...
         [strrep(SourceList{1},'\','\\') '\' filesep],'',1);
      else
         SourceList = cellstr(Source);
      end
      % check file attribute of Destination
      [Success, TargetAttributes(1)] = fileattrib(Destination);
      for i = 2:length(SourceList)
          [d,file,ext] = fileparts(SourceList{i});
          fullpath = fullfile(Destination,d,[file,ext]);
          if ~isempty(file) && exist(fullpath,'file')
            [Success, TargetAttributes(i)] = fileattrib(fullpath);
          end
      end
   elseif ~isdir(Source) && isdir(Destination)
      % The destination is a directory, the source not.
      % Parse source into path and file.
      [d,file,ext] = fileparts(Source);
      % Get attributes of destination
      [Success, TargetAttributes(1)] = fileattrib(Destination);
      % If existing, get attributes of source file in destination.
      if ~isempty(file) && exist(fullfile(Destination,[file,ext]),'file')
         [Success, TargetAttributes(2)] = ...
         fileattrib(fullfile(Destination,[file,ext]));
      end
   else
      % Both source and destination are files.
      % Get attributes of destination file.
      [Success, TargetAttributes] = fileattrib(Destination);
   end
   % Collect the Target read-only attributes in a logical array.
   if ~isempty(TargetAttributes)
      TargetReadOnly = ~cat(1,TargetAttributes(:).UserWrite);
   end
   % Check whether user has specified overwrite of read-only contents in
   % destination. 
   if any(TargetReadOnly) & ~strcmp(mode,'writable')
      error('MATLAB:CHECKWRITABLE:WriteProtected',...
         '%s is read-only or contains read-only objects. Enforce writable',...
         Destination)
   end
end
%-------------------------------------------------------------------------------
return

%-------------------------------------------------------------------------------
function p = subtree(d)
%SUBTREE Generate recursive subtree directory list.
%   P = subtree returns a recursive directory list 
%   of the directory subtree below pwd (current directory).
%   P = subtree(D) returns a recursive directory list 
%   of the directory subtree below D.
%------------------------------------------------------------------------------

if nargin==0,
  p = subtree(pwd);
  return
end

% initialise variables
p = {};           % path to be returned

% Generate path based on given root directory
files = dir(d);
if isempty(files)
  return
end

% Add d to the path even if it contains no files but is not empty
% For example, toolbox\matlab contains only directories
% and is therefore added this directory to the path.
% On the other hand, a completely empty directory will not be added

% add directory item other than '.' or '..'
if length(files) > 2 || (length(files) == 1 && ~files.isdir)
   p = [cellstr(d)];
else
   return % on empty directory listing, return to previous level of recursion 
end

fs = filesep;

% Recursively descend down directory subtree 
for i=1:length(files)
    if ~files(i).isdir
        p = [p;cellstr([d fs files(i).name])];
    else
       DirEntry = files(i).name;
       if    ~strcmp( DirEntry,'.')         && ...
             ~strcmp( DirEntry,'..')        && ...
             ~isequal( regexp(DirEntry, 'cache-[0-9]+\.[0-9]+$'), 1)
          p = [p;subtree([d fs DirEntry])]; % recursive calling of this function.
       end
    end
end
%===============================================================================
