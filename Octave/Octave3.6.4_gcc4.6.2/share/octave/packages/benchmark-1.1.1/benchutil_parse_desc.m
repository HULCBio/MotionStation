% Copyright (C) 2008  Jaroslav Hajek <highegg@gmail.com>
% 
% This file is part of OctaveForge.
% 
% OctaveForge is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this software; see the file COPYING.  If not, see
% <http://www.gnu.org/licenses/>.
% 

% function [bench_desc, arg_desc, result_desc] = benchutil_parse_desc (mpath)
% parse the inline comment description from a benchmark
%

function [bench_desc, arg_desc, result_desc] = benchutil_parse_desc (mpath)
  fid = fopen (mpath, 'rt');
  
  line = ''; 
  iseof = feof (fid);
  while (~ (strncmp (line, '% description:', 14) || iseof))
    line = fgets (fid);
    iseof = feof (fid);
  end

  bench_desc = '';
  line = fgets (fid);
  iseof = feof (fid);
  while (~ (strncmp (line, '% arguments:', 12) || feof (fid)))
    %TODO fix
    bench_desc = [bench_desc, line(3:end)];
    line = fgets (fid);
    iseof = feof (fid);
  end

  line = fgetl (fid);
  iseof = feof (fid);
  while (~ (strncmp (line, '% results:', 10) || feof (fid)))
    i = strfind (line, ' = ');
    if (~ isempty (i))
      name = line (3:i(1)-1);
      arg_desc.(name) = line (i(1)+3:end);
    end
    line = fgetl (fid);
    iseof = feof (fid);
  end

  line = fgetl (fid);
  iseof = feof (fid);
  while (strncmp (line, '%', 1) && ~ feof (fid))
    i = strfind (line, ' = ');
    if (~ isempty (i))
      name = line (3:i(1)-1);
      result_desc.(name) = line (i(1)+3:end);
    end
    line = fgetl (fid);
    iseof = feof (fid);
  end

  fclose (fid);

