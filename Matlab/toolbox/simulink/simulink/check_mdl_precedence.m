function check_mdl_precedence(varargin)
%CHECK_MDL_PRECEDENCE Check MDL-files for logical precedence ambiguity.
%   Check all model files in the directories in the argument
%   list for logical expressions whose meaning will be
%   changed by the precedence of logical AND (&) being greater
%   than the precedence of logical OR (|).  All @class and
%   private directories contained by the argument list directories
%   will also be processed;  class and private directories need not
%   and should not be supplied as explicit arguments to this function.
%
%   If no argument list is specified, all files on
%   the MATLAB path and in the current working directory
%   will be checked, except those in toolboxes.
%
%   If the argument list is exactly '-toolboxes', all files on
%   the MATLAB path and in the current working directory
%   will be checked, including those in toolboxes.
%
%   See also checkSyntacticWarnings.

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.9.4.3 $ $Date: 2004/04/15 00:45:38 $

num_found = 0;
files = {};

for i=1:nargin,
  if ~ischar(varargin{i}),
    error('All arguments must be strings');
  end
end

% Gather up the list of directories and m-files
[w,wc,wp] = checkDirlist(varargin{:});

% Process files
[new_found, new_files] =  checkPrecedence(w);
num_found = num_found + new_found;
files = [files;new_files];

% Process methods
[new_found, new_files] =  checkPrecedence(wc);
num_found = num_found + new_found;
files = [files;new_files];

% Process private m-files and private methods
[new_found, new_files] =  checkPrecedence(wp);
num_found = num_found + new_found;
files = [files;new_files];

fprintf(1,'\n\nCompleted checking requested directories.\n');
fprintf(1,'%d model files detected with logical operator precedence ambiguity.\n',...
           num_found);
fprintf(1, 'Files found were:\n');

for i=1:size(files,2),
  disp(files{i});
end;

fprintf(1,'\n');

return;

%---------------------------------------------
function [wm,wcm,wpm] = checkDirlist(varargin)

if size(varargin,2) > 0 &&...
   (size(varargin,2) ~= 1 || 0 == strcmpi(varargin{1},'-toolboxes')),
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
    if (size(d,2) < tpl || 0 == strcmpi(tp, d(1:tpl))) ||...
       (size(varargin,2) == 1 && strcmpi(varargin{1},'-toolboxes')),
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

% Release information concerned only with mex, m,
% mat files, etc., and generate output values
if exist('w','var') == 0 || prod(size(w)) == 0,
  wm = [];
else
  [wm.path{1:size(w,1)}] = deal(w.path) ;
  [wm.mdl{1:size(w,1)}] = deal(w.mdl);
end

if exist('wc','var') == 0 || prod(size(wc)) == 0,
  wcm = [];
else
  [wcm.path{1:size(wc,1)}] = deal(wc.path);
  [wcm.mdl{1:size(wc,1)}] = deal(wc.mdl);
end

if exist('wp','var') == 0 || prod(size(wp)) == 0,
  wpm = [];
else
  [wpm.path{1:size(wp,1)}] = deal(wp.path);
  [wpm.mdl{1:size(wp,1)}] = deal(wp.mdl);
end

return;

%---------------------------------------------
function [num_found, files] = checkPrecedence(w)

num_found = 0;
files = {};

if isempty(w),
 return;
end

for i=1:size(w.path,2),
  pathname = char(w.path(i));
  fprintf(1, '\nChecking %s...', pathname);
  mlist = w.mdl(i);
  mlist = mlist{:};

  for j=1:size(mlist,1),
    if checkFilePrecedence(fullfile(char(w.path(i)),mlist{j})) ~= 0,
      num_found = num_found + 1;
      files(end+1) = {fullfile(char(w.path(i)),mlist{j})};
    end
  end
end

return;

%---------------------------------------------
function num_warn = checkFilePrecedence(file)

num_warn = 0;

fprintf(1,'\n   Checking model %s', file);
fid = fopen(file, 'r');
accum = '';
linenum = -1;

while 1
  line = fgetl(fid);
  linenum = linenum+1;
  if ~ischar(line),
    break;
  end;
  if isempty(line), 
    continue;
  end
  blk = find((line ~= ' '));  line = line(min(blk):max(blk));
  qt = findstr(line,'"');
  if ~isempty(qt) && max(qt) == size(line,2),
    line = line(min(qt)+1:end-1);
    if qt(1) == 1,
      accum = [accum line];
    else
      if ~isempty(accum)
        num_warn = num_warn + validate(accum, file, linenum);
      end;
      accum = line;
    end;
  else
      if ~isempty(accum)
        num_warn = num_warn + validate(accum, file, linenum);
      end;
      accum = '';
  end;
end;

if ~isempty(accum),
    num_warn = num_warn + validate(accum, file, linenum);
end;

fclose(fid);

return


function num_warn = validate(str, file, linenum)

num_warn = 0;

str = [ 'return; ' strrep(str, '\n', '') ];

evalmsg = evalc(str, '');

if (~isempty(findstr(evalmsg, 'logical expression(s) involving AND and OR')) || ...
    ~isempty(findstr(evalmsg, ['logical expression(s) involving OR and ' ...
                      'AND']))),
  msg = sprintf('In file %s at line %d', file, linenum);
  msg = [msg evalmsg];
  num_warn = num_warn+1;
  fprintf(1,'\n');
  warnState = warning('on');
  warning(msg);
  warning(warnState);
end;
