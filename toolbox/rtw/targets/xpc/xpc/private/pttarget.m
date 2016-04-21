function pttarget(ptfile)

% PTTARGET - xPC Target private function

% Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.6.4.2 $ $Date: 2004/04/08 21:04:36 $

ptfile = ptfile(4:end);

actdir = pwd;
cd('..');
pt = eval([ptfile,'pt;']);
cd(actdir);

k = length(pt);
names = cell(k, 2);
if ~isempty(pt)
  [names, map] = sortrows({pt(:).blockname; pt(:).paramname}');
  map = map - 1;
else
  map = [];
end

% generate xpctarget.pt file
fid = fopen('xpctarget.pt','w');
if fid == -1
  error('Error opening file xpctarget.pt');
end

fprintf(fid, 'const SortedBlockParameters sortedPT[] = {\n');
fprintf(fid, '   %5d,\n', map);

fprintf(fid, '      -1\n');
fprintf(fid, '};\n');

fclose(fid);
