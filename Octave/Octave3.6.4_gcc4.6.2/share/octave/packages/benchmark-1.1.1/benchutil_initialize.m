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

% function benchutil_initialize (mfname)
% initializes a benchmark. The argument passed must be the filename of the
% function.
%
function benchutil_initialize (mfname)
  [bench_desc, arg_desc, result_desc] = ...
    benchutil_parse_desc ([mfname, '.m']);
  assignin ('caller', 'result_desc', result_desc);
  if (benchutil_verbose)
    fprintf (1, 'Running benchmark: %s\n', mfname);
    fwrite (1, bench_desc);
    fprintf (1, '\n');
    argns = fieldnames (arg_desc);
    for argn = argns'
      argn = argn{1};
      argv = evalin ('caller', argn);
      fprintf (1, '%s (%s) = %g\n', arg_desc.(argn), argn, argv);
    end
    if (benchutil_is_octave)
      fflush (1);
    end
  end


  
