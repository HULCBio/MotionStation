function pcode(varargin)
%PCODE  Create pre-parsed pseudo-code file (P-file).
%   PCODE FUN parses the M-file FUN.M into the pre-parsed pseudo-code file
%   (P-file) FUN.P and puts it into the current directory (private and
%   method directories will be created for private and object methods 
%   including UDD if the directories don't already exist). The original
%   M-file must exist and is searched for first on the MATLAB path.
%
%   PCODE FUN1 FUN2 ... creates P-files for the listed functions.
%
%   PCODE *.m creates P-files for all the M-files in the current
%   directory.
%
%   PCODE FILE.LST opens file FILE with extension LST (a list-file)
%   and reads each line as a valid file argument above. LST files
%   cannot be nested.
%   
%   PCODE ... -INPLACE  creates the P-files in the same directory
%   as the M-file.  An error occurs if the files can't be created.
%
%   PCODE DIR/*.m creates P-files for all the M-files in the directory DIR.
%
%   PCODE DIR is equivalent to PCODE DIR/*.m
%
%   File and directory paths can be relative. Paths that contain '..'
%   and '.' will not match on the MATLAB path but will work if they
%   exist.
%
%   Note: The P-code generated should not be affected by whether the
%         associated M-file is on the MATLAB path or not with one
%         exception. If the function sneaks in variables for example
%         by loading them from a MAT file then the generated P-code
%         can be sensitive to functions on the path other than methods,
%         for example from a private directory.
%
%   See also JAVA, PERL, MEX.
 
%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.30.4.1 $  $Date: 2004/03/17 20:05:28 $

inplace = 0;
flag = {};
for i=nargin:-1:1
  if ~isstr(varargin{i}) | ...
      size(varargin{i},1)~=1 | ndims(varargin{i})~=2
    error('Input arguments must be single strings.');
  end
  if strncmp(varargin{i},'-',1) % It's a flag
    if strcmp(varargin{i},'-inplace'),
      inplace = 1;
    else
      flag = [flag varargin(i)];
    end
    varargin(i) = []; % Remove flag from input list
  end
end

if length(flag)>1, error('Too many flags.'); end

for i=1:length(varargin),
  
  % Check for directory
  if isdir(varargin{i})
    dirname = varargin{i};
  else
    dirname = fileparts(varargin{i});
  end

  % Fix up directory only and * only cases by adding .m
  if strcmp(varargin{i},dirname), varargin{i} = fullfile(dirname,'*.m'); end
  if strcmp(varargin{i},'*'), varargin{i} = '*.m'; end

  % Wildcard (*) characters are not allowed in the directory
  % part of the path because dir() does not see them
  if any(varargin{i}=='*'),

    % Allow a directory part on the path
    files = dir(varargin{i});
    for j=1:length(files),
      if ~files(j).isdir

        % fullfile on the PC converts any / to \
        preparse(fullfile(dirname,files(j).name),inplace,flag);
      end
    end
  else
    file = varargin{i};

    % Be robust to / or \ on PC
    if ispc
      file = strrep(file,'/','\');
    end
    [fpath,fname,fext,fver] = fileparts(file);

    % Add .m if necessary
    if isempty(fext)
      file = [file '.m'];
    elseif strcmp(fext,'.p')
      file = fullfile(fpath,[fname '.m']);
    elseif strcmp(fext, '.lst')
      pcodelf(file,inplace,flag);
      continue
    end
    preparse(file,inplace,flag);
  end
end

%-------------------------------------------
function pcodelf(listfile,inplace,flag)
% Open and process list of files

% Read and split into lines
try
   lines = textread(listfile,'%s','delimiter', '\n','whitespace','');
catch
   warning('MATLAB:pcode:CannotOpenFile', ...
       'List File ''%s'' cannot be opened.',listfile)
   return
end

for i=1:length(lines)

  % Assume at most one token on the line
  file = strtok(lines{i});
  if isempty(file), continue, end

  % Check for directory
  if isdir(file)
    dirname = file;
  else
    dirname = fileparts(file);
  end

  % Fix up directory only and * only cases by adding .m
  if strcmp(file,dirname), file = fullfile(dirname,'*.m'); end
  if strcmp(file,'*'), file = '*.m'; end

  % Wildcard (*) characters are not allowed in the directory
  % part of the path because dir() does not see them
  if any(file=='*'),

    % Allow a directory part on the path
    files = dir(file);
    for j=1:length(files),
      if ~files(j).isdir

	% fullfile on the PC converts any / to \
        preparse(fullfile(dirname,files(j).name),inplace,flag);
      end
    end
  else
    % Be robust to / or \ on PC
    if ispc
      file = strrep(file,'/','\');
    end
    [fpath,fname,fext,fver] = fileparts(file);

    % Add .m if necessary
    if isempty(fext)
      file = [file '.m'];
    elseif strcmp(fext,'.p')
      file = fullfile(fpath,[fname '.m']);
    elseif strcmp(fext, '.lst')
      warning('MATLAB:pcode:NestedListUnsupported', ...
          'Nested list-file ''%s'' not allowed - skipped.',file)
      continue
    end
    preparse(file,inplace,flag);
  end
end

%-------------------------------------------
function preparse(file,inplace,flag)
%   Preparse file

% First try to find file on the MATLAB path
fn = which(file);

if isempty(fn),
  fid = fopen(file);
  if fid==-1,
     warning('MATLAB:pcode:FileNotFound','File ''%s'' not found.',file)
     return
  else
    fn = fopen(fid);
    fclose(fid);
  end

  % Convert to standard path
  fn = stdpath(fn);
end

% Make sure filename ends with .m or .lst
[dirname,fname,fext] = fileparts(fn);
if strcmp(lower(fext),'.m')
  if inplace,
    pfile(fn,[fn(1:end-2) '.p'],flag{:});
  else
    d = pwd;
    [dum,doops,dpriv] = basename(fullfile(pwd,'dummy.m'));
    [name,oops,priv] = basename(fn);
    if ~isempty(oops) & ~isequal(doops,oops)

      %handle up to two levels of @ directories
      if length(oops) > 1
        d = fullfile(d,oops{2},'');
        if ~exist(d,'dir')
          mkdir(oops{2})
          if ~exist(d,'dir')
            error(sprintf('Could not create %s directory.',d))
          end
        end
      end
      parent = d;
      d = fullfile(d,oops{1},'');
      if ~exist(d,'dir')
        mkdir(parent,oops{1})
        if ~exist(d,'dir')
          error(sprintf('Could not create %s directory.',d))
        end
      end
    end
    parent = d;
    if ~isempty(priv) & ~isequal(dpriv,priv)
      d = fullfile(d,priv,'');
      if ~exist(d,'dir')
        mkdir(parent,priv)
        if ~exist(d,'dir')
          error(sprintf('Could not create %s directory.',d))
        end
      end
    end
    
    pfile(fn,fullfile(d,[name(1:end-2) '.p']),flag{:});
  end
elseif strcmp(lower(fext),'.lst')
  pcodelf(fn,inplace,flag);
else
  warning('MATLAB:pcode:FileUnsupported', ...
      'Skipping ''%s'' since it isn''t an M-file or list-file.',file)
end

%-----------------------------
function [b,oops,priv] = basename(fn)
oops = '';
priv = '';
k = find(fn==filesep);
if isempty(k)
  b = fn;
else
  b = fn(k(end)+1:end);

  % Add leading separator to catch any leading directory
  fn = [filesep fn(1:k(end))];
  k = find(fn==filesep);
  
  % Look for private and class directories
  dirs = find((diff(k)-1)~=0);
  ix = length(dirs);
  if ix > 0
    dirname = fn(k(dirs(ix))+1:k(dirs(ix)+1)-1);
    if strcmp(dirname,'private')
      priv = 'private';
      ix = ix - 1;
    end
  end
  if ix > 0
    dirname = fn(k(dirs(ix))+1:k(dirs(ix)+1)-1);
    if strcmp(dirname(1:1),'@')
      oops{1} = dirname; % Class directory name
      ix = ix - 1; 
    end
  end
  % Handle one more level of @ directories for UDD
  if ix > 0
    dirname = fn(k(dirs(ix))+1:k(dirs(ix)+1)-1);
    if strcmp(dirname(1:1),'@')
      oops{2} = dirname; % Class directory name
    end
  end
end

%-----------------------------
function  fn = stdpath(file)
% Make into a standard path. Remove all .. or .
% File is guaranteed to exist.

[dirname,fname,fext,fver] = fileparts(file);
if isempty(dirname)
  fn = fullfile(pwd,file);
  return
end

% If relative path add on pwd to the front
if (ispc & length(dirname) == 1) | ...
   (ispc & length(dirname) > 1 & ...
   dirname(2:2) ~= ':' & dirname(1:2) ~= [filesep filesep]) | ...
   (isunix & dirname(1:1) ~= filesep)
  dirname = fullfile(pwd,dirname);
end

% Get the root (<letter>: or \\ on PC or / on UNIX)
if ispc
   root = dirname(1:2);
else
   root = dirname(1:1);
end

% At the root directory already
if strcmp(root,dirname)
  fn = fullfile(dirname,[fname fext]);
  return
end

% Peel off the root and add separators to front and back
if ispc 
   dirname2 = [filesep dirname(3:end) filesep];
else
   dirname2 = [filesep dirname(2:end) filesep];
end

k = find(dirname2==filesep);
ixdirs = find((diff(k)-1)~=0);
n = length(ixdirs);

% Run through all the directories handling '..' and '.'
dirs = cell(n,1);
ndirs = 0;
for i=1:n
  dir = dirname2(k(ixdirs(i))+1:k(ixdirs(i)+1)-1);
  if strcmp(dir,'.'), continue; end
  if strcmp(dir,'..')
    ndirs = ndirs - 1;
  else
    ndirs = ndirs + 1;
    dirs{ndirs} = dir;
  end
end
%
fn = fullfile(root,dirs{1:ndirs},[fname fext]);
