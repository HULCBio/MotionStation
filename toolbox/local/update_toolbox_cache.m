function update_toolbox_cache(varargin)
%UPDATE_TOOLBOX_CACHE Generate Cache of Path and Files on Path
%	UPDATE_TOOLBOX_CACHE saves a portion of the current
%       MATLAB path and the list of the contents of each directory,
%	as well as method and private directories contained by
%	the selected directories on the path.
%
%       The first argument is optional.  If present, it specifies whether
%       to cache everything under matlabroot ('-M'), or only the toolbox
%       directories ('-T').  If this argument is not provided, it defaults
%       to '-T'.
%
%       The remaining argument(s) are optional.  If present, they specify
%       one or more directories that should be excluded from the cache.
%       This list of excluded directories can be specified in two ways:
%
%       1. The list of excluded directories can be specified in a single
%          argument using a cell array of strings.  If a cell array if
%          strings is used to specify the excluded directories, it must
%          be the last argument.
%
%       2. The list of excluded directories can be specified using
%          multiple arguments, each of which must be a string.
%
%       The following examples are all equivalent:
%
%       x = {'dir1', 'dir2', 'dir3'};
%       update_toolbox_cache(x);
%       update_toolbox_cache dir1 dir2 dir3
%       update_toolbox_cache('-T', x);
%       update_toolbox_cache -T dir1 dir2 dir3
%
%       Each string in the list is interpreted as a partial path (that is,
%       as a suffix, not a prefix), and all directories that match the
%       partial path are excluded. For example, 'work' will exclude all
%       directories that end with a directory named "work".  'private'
%       will exclude all private directories.  [matlabroot DIRSEP 'work']
%       will exclude a directory named 'work' in the matlabroot directory,
%       but not other directories named 'work'.  '@char' will exclude all
%       directories that overload the character type;
%       'matlab/general/@char' will exclude only the character overload
%       directory in matlab/general.
%
%	The saved MAT file contains an array of structures CachedPath.
%
%	CachedPath.name contains the name of the directory, relative
%	to MATLABROOT.
%
%	CachedPath.contents is a character string containing all
%	names in the directory, each separated by 0 and the string 
%	terminated by 0 0.
%
%	CachedPath.isdir is a character flag vector with one
%	value per name, with 1 indicating that the name is a directory,
%	and 0 otherwise.

%   CGN
%   Copyright 1984-2001 The MathWorks, Inc.
%   $Revision: 1.5 $ $Date: 2002/02/05 14:08:05 $
%	

%
% Platform-specific preface.
%
cname = computer;
if strncmp(cname,'PC',2)
  DIRSEP = '\';
  TBX = [matlabroot DIRSEP 'toolbox' DIRSEP];
else
  DIRSEP = '/';
  TBX = [matlabroot DIRSEP 'toolbox' DIRSEP];
end
TBXSIZ = size(TBX,2);

%
% Validate and analyze the argument list.
%
if nargin == 0,
  args = {'-T'};
else
  args = varargin;
end;

if iscell(args{1}),
  rootopt = '-T';
else,
  rootopt = args{1};
end;

if ~ischar(rootopt) || ndims(rootopt) ~= 2 ||...
    size(rootopt, 1) ~= 1,
      error('Argument must be a string');
end;

if rootopt(1) ~= '-',
  rootopt = '-T';
else,
  if ~iscell(args{1}),
    args = {args{2:end}};
  end;
  if ndims(rootopt) ~= 2 || size(rootopt, 1) ~= 1 ||...
         size(rootopt, 2) ~= 2 ||...
         (rootopt(2) ~= 'M' && rootopt(2) ~= 'T'),
    error('Bad command option');
  end;
end; 

if rootopt(2) == 'M',
  PFX = [matlabroot DIRSEP];
  rootopt = 'M';
else,
  PFX = TBX;
  rootopt = 'T';
end;

PFXSIZ = size(PFX, 2);

if isempty(args),
  args = {};
else,
  if iscell(args{1}),
    if size(args,2) > 1,   
      error('Cell array form of exclude list must be the last argument');
    end;
    args = args{1};
    if ndims(args) ~= 2 || size(args, 1) ~= 1,
      error('A cell array exclude list argument must be 1-by-N');
    end;
  end;
end;

for i=1:size(args, 2),
  if ~ischar(args{i}) || ndims(args{i}) ~= 2 ||...
    size(args{i}, 1) ~= 1,
      error('Argument must be a string');
  end;
end;

excludelist = args;

%
% Check whether toolbox cache is writeable
%
tbxcname = [TBX 'local' DIRSEP 'toolbox_cache'];
tbxcnamefull = [tbxcname '.mat'];
tbxcache_exists = exist(tbxcnamefull);
tbxcfid = fopen(tbxcnamefull, 'wb');

if tbxcfid < 0,
  error(['Write access to ' TBX 'local is required']);
end;

fclose(tbxcfid);

%
% Cleanup any file that wsa created a a side-effect of probing the
% writeability of toolbox/local.
%
if tbxcache_exists <= 0,
  try
    delete(tbxcnamefull);
  catch
  end
end;

%
% Get path, path size.
% It's not necessary to do a REHASH TOOLBOX before doing this, because
% WHAT always goes out to the file system, even for toolboxes.
%
p = what(char(0));
ps = size(p,1);

%
% Count number of toolbox directories.
%
ntb = 1;
for i=1:ps
  if size(p(i).path, 2) >= PFXSIZ && strncmp(PFX, p(i).path, PFXSIZ) == 1 &&...
    NotOnExcludeList(p(i).path, excludelist, DIRSEP)
    ntb = ntb+1;
  end
end

%
% Preallocate path structure
%
% CachedPath(1).name is the internal timestamp for the cache and
% the absolute MATLAB path that was used to generate the cache.
%
% The first four characters of CachedPath(1).contents is a version
% string, to allow versioning of the header and structure format.
% Following that is the root option ('T' or 'M').
%
% CachedPath(1).isdir is directory separator used in the saved cache.
% Additional diagnostic options may follow the single separator character.
%
d = clock;  d = datestr(datenum(d(1),d(2),d(3),d(4),d(5),d(6)),0);
CachedPath(1).name = ['Path saved ' d ' ' matlabpath];
CachedPath(1).contents = ['*001 ' rootopt];
CachedPath(1).isdir = '/';
if ntb > 1
  CachedPath(ntb).name = '';
end

%
% Build each directory contents member of path structure.
%
ntb = 1;
for i=1:ps
  if size(p(i).path,2) >= PFXSIZ && strncmp(PFX, p(i).path, PFXSIZ) == 1 &&...
    NotOnExcludeList(p(i).path, excludelist, DIRSEP)
    % Normalize toolbox directory name.
    tn = p(i).path; tn = tn(PFXSIZ+1:end);
    if tn(end) == DIRSEP | tn(end) == ']'
	tn = tn(1:end-1);
    end
    if DIRSEP ~= '/'
	tn = strrep(tn, DIRSEP, '/');
    end
    % Get directory contents.
    d=dir(p(i).path);
    % Get number of names in directory. 
    k=size(d,1);
    % Build the contents string and the isDir bitmap.
    n = '';  nf = zeros(1,k);
    for j=1:k
      n = [n d(j).name 0];
      nf(j) = d(j).isdir;
    end;
    n = [n 0];
    % Full in path structure member for this dir.
    ntb = ntb+1;
    CachedPath(ntb).name = tn;
    CachedPath(ntb).contents = n;
    CachedPath(ntb).isdir = char(nf);
  end
end

%
% Save to MAT file
%
save(tbxcname, 'CachedPath');

function z = NotOnExcludeList(dirname, excludelist, DIRSEP)
z = 1;

if isempty(excludelist)
    return;
    end;

ds = size(dirname, 2);

for i=1:size(excludelist, 2)
    e = excludelist{i};
    es = size(e, 2);
    if ds > es && dirname(ds-es) == DIRSEP &&...
       strncmp(e, dirname(1+ds-es:end), es) == 1
      z = 0;
      return;
    end;
end;    


% End of update_toolbox_cache.m





