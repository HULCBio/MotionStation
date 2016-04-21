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

function benchutil_set_result (name)
  if (~ benchutil_verbose || evalin ('caller', 'nargout') > 0)
    evalin ('caller', sprintf ('results.%s = %s;', name, name));
  end
  if (benchutil_verbose)
    value_desc = evalin ('caller', sprintf ('result_desc.%s', name));
    value = evalin ('caller', name);
    fprintf (1, '%s: %g\n', value_desc, value);
    if (benchutil_is_octave)
      fflush (1);
    end
  end

