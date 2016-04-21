function checkSyntacticWarnings(varargin)
%checkSyntacticWarnings Check M-files for syntactic warnings.
%   Check all M-files in the directories specified by the argument list for all
%   warnings which MATLAB generates when reading the M-file into memory. All
%   @class and private directories contained by the argument list directories
%   will also be processed; class and private directories need not and should
%   not be supplied as explicit arguments to this function.
%
%   If no argument list is specified, all files on the MATLAB path and in the
%   current working directory will be checked, except those in toolboxes.
%
%   If the argument list is exactly '-toolboxes', all files on the MATLAB path
%   and in the current working directory will be checked, including those in
%   toolboxes.
%
%   See also CHECK_MDL_PRECEDENCE, PRECEDENCE.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $ $Date: 2003/02/07 05:36:06 $

for i=1:nargin,
  if ~isstr(varargin{i}),
    error('All arguments must be strings');
  end
end

% Gather up the list of directories and m-files
[w,wc,wp] = checkDirlist(varargin{:});

% Process m-files on the path
checkPrecedence(w,1)

% Process methods
checkPrecedence(wc,0)

% Process private m-files and private methods
checkPrecedence(wp,0)

fprintf(1,'Completed checking requested directories.\n');

return;

%---------------------------------------------
function [wm,wcm,wpm] = checkDirlist(varargin)

if size(varargin,2) > 0 &...
   (size(varargin,2) ~= 1 | 0 == strcmpi(varargin{1},'-toolboxes')),
   % Use argument list supplied
  dlist = varargin;
else
  tp = [matlabroot filesep 'toolbox' filesep];
  tpl = size(tp,2);
  mp = matlabpath;
  kp = [0 find(mp==pathsep) length(mp)+1];
  dlist{1} = cd;
  for i=1:length(kp)-1,
    d = mp(kp(i)+1:kp(i+1)-1);
    if (size(d,2) < tpl | 0 == strcmpi(tp, d(1:tpl))) |...
       (size(varargin,2) == 1 & strcmpi(varargin{1},'-toolboxes')),
      % Use directory from path, unless toolbox when not wanted
      dlist{1+size(dlist,2)} = d;
    end
  end
end

% Get rid of leading and trailing cruft
for i=1:size(dlist,2),
  pathname = dlist{i};
  k = find(pathname ~= ' ');
  pathname = pathname(min(k):max(k)); 
  if (pathname(end) == filesep),
    pathname = pathname(1:end-1);
  end
  dlist{i} = pathname;
end

% Collect and normalize path directory contents
w=what(dlist{1});
for i=2:size(dlist,2),
  w = [w;what(dlist{i})];
end
[dum,keep] = unique(char({w.path}),'rows');
w = w(sort(keep));

% Add classes
for i=1:size(w,1),
  for j=1:size(w(i).classes,1),
    if exist('wc','var') == 0,
      wc = what(w(i).classes{j});
    else
      wc = [wc;what(w(i).classes{j})];
    end
  end
end

% Add private directories
for i=1:size(w,1),
  privpath = fullfile(w(i).path,'private','');
  if exist('wp','var') == 0,
    wp = what(fullfile(w(i).path,'private',''));
  else
    wp = [wp;what(fullfile(w(i).path,'private',''))];
  end
end

% Add private method directories
if exist('wc','var')
  for i=1:size(wc,1),
    if exist('wp','var') == 0,
      wp = what(fullfile(wc(i).path,'private',''));
    else
      wp = [wp;what(fullfile(wc(i).path,'private',''))];
    end
  end
end

% Release information concerned only with mex, models,
% mat files, etc., and generate output values
if exist('w','var') == 0 | prod(size(w)) == 0,
  wm = [];
else
  [wm.path{1:size(w,1)}] = deal(w.path);
  [wm.m{1:size(w,1)}] = deal(w.m);
end

if exist('wc','var') == 0 | prod(size(wc)) == 0,
  wcm = [];
else
  [wcm.path{1:size(wc,1)}] = deal(wc.path);
  [wcm.m{1:size(wc,1)}] = deal(wc.m);
end

if exist('wp','var') == 0 | prod(size(wp)) == 0,
  wpm = [];
else
  [wpm.path{1:size(wp,1)}] = deal(wp.path);
  [wpm.m{1:size(wp,1)}] = deal(wp.m);
end

return;

%---------------------------------------------
function checkPrecedence(w,ispath)

if isempty(w),
 return;
end

for i=1:size(w.path,2),
  pathname = char(w.path(i));
  fprintf(1, 'Checking %s...\n\n', pathname);
  mlist = w.m(i);
  mlist = mlist{:};
  
  if ispath == 0,
    pathname = fileparts(pathname);
    wasonpath = 1;
  else
    wasonpath = putOnPath(pathname);
  end

  for j=1:size(mlist,1),
    checkFilePrecedence(fullfile(char(w.path(i)),mlist{j}));
  end

  if wasonpath == 0,
    rmpath(pathname);
  end

  % Make sure not to accumulate thousands of loaded functions in memory...
  clear('functions');
end

return;

%---------------------------------------------
function wasonpath = putOnPath(pathname)

% Get rid of leading and trailing cruft
k = find(pathname ~= ' ');
pathname = pathname(min(k):max(k)); 
if (pathname(end) == filesep),
  pathname = pathname(1:end-1);
end
if isempty(findstr([pathsep pathname pathsep], [pathsep matlabpath pathsep])),
  wasonpath = 0;
  addpath(pathname, '-begin');
else
  wasonpath = 1;
end;

return;

%---------------------------------------------
function checkFilePrecedence(filename)

clear(filename);
tmpout = [tempname '.p'];

try
    % pfile is the most expensive, but it works for any loadable m-file
    output = evalc('pfile(filename,tmpout)');
    delete(tmpout);
    if (~isempty(output))
        disp(output); 
    end
catch
    disp(sprintf(['%s could not be loaded, and was not checked.\nThis' ...
                  ' file may contain syntax errors.\n'], filename)); 
end
